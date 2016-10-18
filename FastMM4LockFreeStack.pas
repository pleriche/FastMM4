// Based on TOmniBaseBoundedStack class from the OmniThreadLibrary,
// originally written by GJ and Primoz Gabrijelcic.

unit FastMM4LockFreeStack;

interface

type
  PReferencedPtr = ^TReferencedPtr;
  TReferencedPtr = record
    PData    : pointer;
    Reference: NativeInt;
  end;

  PLinkedData = ^TLinkedData;
  TLinkedData = packed record
    Next: PLinkedData;
    Data: record end;           //user data, variable size
  end;

  TLFStack = record
  strict private
    FDataBuffer   : pointer;
    FElementSize  : integer;
    FNumElements  : integer;
    FPublicChainP : PReferencedPtr;
    FRecycleChainP: PReferencedPtr;
  class var
    class var obsIsInitialized: boolean;                //default is false
    class var obsTaskPopLoops : NativeInt;
    class var obsTaskPushLoops: NativeInt;
    class function  PopLink(var chain: TReferencedPtr): PLinkedData; static;
    class procedure PushLink(const link: PLinkedData; var chain: TReferencedPtr); static;
    procedure MeasureExecutionTimes;
  public
    procedure Empty;
    procedure Initialize(numElements, elementSize: integer);
    procedure Finalize;
    function  IsEmpty: boolean; inline;
    function  IsFull: boolean; inline;
    function  Pop(var value): boolean;
    function  Push(const value): boolean;
    property  ElementSize: integer read FElementSize;
    property  NumElements: integer read FNumElements;
  end;

implementation

uses
  Windows;

{$IF CompilerVersion < 23}
{$IFNDEF CPUX64}
type
  NativeInt = integer;
  NativeUInt = cardinal;
{$ENDIF}
{$IFEND}

var
  CASAlignment: integer; //required alignment for the CAS function - 8 or 16, depending on the platform

function RoundUpTo(value: pointer; granularity: integer): pointer;
begin
  Result := pointer((((NativeInt(value) - 1) div granularity) + 1) * granularity);
end;

function GetCPUTimeStamp: int64;
asm
  rdtsc
{$IFDEF CPUX64}
  shl   rdx, 32
  or    rax, rdx
{$ENDIF CPUX64}
end;

function GetThreadId: NativeInt;
//result := GetCurrentThreadId;
asm
{$IFNDEF CPUX64}
  mov   eax, fs:[$18]      //eax := thread information block
  mov   eax, [eax + $24]   //eax := thread id
{$ELSE CPUX64}
  mov   rax, gs:[abs $30]
  mov   eax, [rax + $48]
{$ENDIF CPUX64}
end;

function CAS(const oldValue, newValue: NativeInt; var destination): boolean; overload;
asm
{$IFDEF CPUX64}
  mov   rax, oldValue
{$ENDIF CPUX64}
  lock cmpxchg [destination], newValue
  setz  al
end;

function CAS(const oldValue, newValue: pointer; var destination): boolean; overload;
asm
{$IFDEF CPUX64}
  mov   rax, oldValue
{$ENDIF CPUX64}
  lock cmpxchg [destination], newValue
  setz  al
end;

function CAS(const oldData: pointer; oldReference: NativeInt; newData: pointer;
  newReference: NativeInt; var destination): boolean; overload;
asm
{$IFNDEF CPUX64}
  push  edi
  push  ebx
  mov   ebx, newData
  mov   ecx, newReference
  mov   edi, destination
  lock cmpxchg8b qword ptr [edi]
  pop   ebx
  pop   edi
{$ELSE CPUX64}
  .noframe
  push  rbx                     //rsp := rsp - 8 !
  mov   rax, oldData
  mov   rbx, newData
  mov   rcx, newReference
  mov   r8, [destination + 8]   //+8 with respect to .noframe
  lock cmpxchg16b [r8]
  pop   rbx
{$ENDIF CPUX64}
  setz  al
end;

{ TLFStack }

procedure TLFStack.Empty;
var
  linkedData: PLinkedData;
begin
  repeat
    linkedData := PopLink(FPublicChainP^);
    if not assigned(linkedData) then
      break; //repeat
    PushLink(linkedData, FRecycleChainP^);
  until false;
end;

procedure TLFStack.Finalize;
begin
  HeapFree(GetProcessHeap, 0, FDataBuffer);
end;

procedure TLFStack.Initialize(numElements, elementSize: integer);
var
  bufferElementSize : integer;
  currElement       : PLinkedData;
  dataBuffer        : pointer;
  iElement          : integer;
  nextElement       : PLinkedData;
  roundedElementSize: integer;
begin
  Assert(SizeOf(NativeInt) = SizeOf(pointer));
  Assert(numElements > 0);
  Assert(elementSize > 0);
  FNumElements := numElements;
  FElementSize := elementSize;
  //calculate element size, round up to next aligned value
  roundedElementSize := (elementSize + SizeOf(pointer) - 1) AND NOT (SizeOf(pointer) - 1);
  //calculate buffer element size, round up to next aligned value
  bufferElementSize := ((SizeOf(TLinkedData) + roundedElementSize) + SizeOf(pointer) - 1) AND NOT (SizeOf(pointer) - 1);
  //calculate DataBuffer
  FDataBuffer := HeapAlloc(GetProcessHeap, HEAP_GENERATE_EXCEPTIONS, bufferElementSize * numElements + 2 * SizeOf(TReferencedPtr) + CASAlignment);
  dataBuffer := RoundUpTo(FDataBuffer, CASAlignment);
  if NativeInt(dataBuffer) AND (SizeOf(pointer) - 1) <> 0 then
    // TODO 1 raise exception - how?
    Halt; //raise Exception.Create('TOmniBaseContainer: obcBuffer is not aligned');
  FPublicChainP := dataBuffer;
  inc(NativeInt(dataBuffer), SizeOf(TReferencedPtr));
  FRecycleChainP := dataBuffer;
  inc(NativeInt(dataBuffer), SizeOf(TReferencedPtr));
  //Format buffer to recycleChain, init obsRecycleChain and obsPublicChain.
  //At the beginning, all elements are linked into the recycle chain.
  FRecycleChainP^.PData := dataBuffer;
  currElement := FRecycleChainP^.PData;
  for iElement := 0 to FNumElements - 2 do begin
    nextElement := PLinkedData(NativeInt(currElement) + bufferElementSize);
    currElement.Next := nextElement;
    currElement := nextElement;
  end;
  currElement.Next := nil; // terminate the chain
  FPublicChainP^.PData := nil;
  MeasureExecutionTimes;
end;

function TLFStack.IsEmpty: boolean;
begin
  Result := not assigned(FPublicChainP^.PData);
end;

function TLFStack.IsFull: boolean;
begin
  Result := not assigned(FRecycleChainP^.PData);
end;

procedure TLFStack.MeasureExecutionTimes;
const
  NumOfSamples = 10;
var
  TimeTestField: array [0..1] of array [1..NumOfSamples] of int64;

  function GetMinAndClear(routine, count: cardinal): int64;
  var
    m: cardinal;
    n: integer;
    x: integer;
  begin
    Result := 0;
    for m := 1 to count do begin
      x:= 1;
      for n:= 2 to NumOfSamples do
        if TimeTestField[routine, n] < TimeTestField[routine, x] then
          x := n;
      Inc(Result, TimeTestField[routine, x]);
      TimeTestField[routine, x] := MaxLongInt;
    end;
  end;

var
  oldAffinity: NativeUInt;
  currElement: PLinkedData;
  n          : integer;

begin
  if not obsIsInitialized then begin
    oldAffinity := SetThreadAffinityMask(GetCurrentThread, 1);
    try
      //Calculate  TaskPopDelay and TaskPushDelay counter values depend on CPU speed!!!}
      obsTaskPopLoops := 1;
      obsTaskPushLoops := 1;
      for n := 1 to NumOfSamples do begin
        SwitchToThread;
        //Measure RemoveLink rutine delay
        TimeTestField[0, n] := GetCPUTimeStamp;
        currElement := PopLink(FRecycleChainP^);
        TimeTestField[0, n] := GetCPUTimeStamp - TimeTestField[0, n];
        //Measure InsertLink rutine delay
        TimeTestField[1, n] := GetCPUTimeStamp;
        PushLink(currElement, FRecycleChainP^);
        TimeTestField[1, n] := GetCPUTimeStamp - TimeTestField[1, n];
      end;
      //Calculate first 4 minimum average for RemoveLink rutine
      obsTaskPopLoops := GetMinAndClear(0, 4) div 4;
      //Calculate first 4 minimum average for InsertLink rutine
      obsTaskPushLoops := GetMinAndClear(1, 4) div 4;

      //This gives better performance (determined experimentally)
      obsTaskPopLoops := obsTaskPopLoops * 2;
      obsTaskPushLoops := obsTaskPushLoops * 2;

      obsIsInitialized := true;
    finally SetThreadAffinityMask(GetCurrentThread, oldAffinity); end;
  end;
end;

function TLFStack.Pop(var value): boolean;
var
  linkedData: PLinkedData;
begin
  linkedData := PopLink(FPublicChainP^);
  Result := assigned(linkedData);
  if not Result then
    Exit;
  Move(linkedData.Data, value, ElementSize);
  PushLink(linkedData, FRecycleChainP^);
end;

class function TLFStack.PopLink(var chain: TReferencedPtr): PLinkedData;
//nil << Link.Next << Link.Next << ... << Link.Next
//                                            ^------ < chainHead
var
  AtStartReference: NativeInt;
  CurrentReference: NativeInt;
  TaskCounter     : NativeInt;
  ThreadReference : NativeInt;
label
  TryAgain;
begin
  ThreadReference := GetThreadId + 1;                           //Reference.bit0 := 1
  with chain do begin
TryAgain:
    TaskCounter := obsTaskPopLoops;
    AtStartReference := Reference OR 1;                         //Reference.bit0 := 1
    repeat
      CurrentReference := Reference;
      Dec(TaskCounter);
    until (TaskCounter = 0) or (CurrentReference AND 1 = 0);
    if (CurrentReference AND 1 <> 0) and (AtStartReference <> CurrentReference) or
       not CAS(CurrentReference, ThreadReference, Reference)
    then
      goto TryAgain;
    //Reference is set...
    Result := PData;
    //Empty test
    if result = nil then
      CAS(ThreadReference, 0, Reference)         //Clear Reference if task own reference
    else if not CAS(Result, ThreadReference, Result.Next, 0, chain) then
      goto TryAgain;
  end; //with chain
end;

function TLFStack.Push(const value): boolean;
var
  linkedData: PLinkedData;
begin
  linkedData := PopLink(FRecycleChainP^);
  Result := assigned(linkedData);
  if not Result then
    Exit;
  Move(value, linkedData.Data, ElementSize);
  PushLink(linkedData, FPublicChainP^);
end;

class procedure TLFStack.PushLink(const link: PLinkedData; var chain: TReferencedPtr);
var
  PMemData   : pointer;
  TaskCounter: NativeInt;
begin
  with chain do begin
    for TaskCounter := 0 to obsTaskPushLoops do
      if (Reference AND 1 = 0) then
        break;
    repeat
      PMemData := PData;
      link.Next := PMemData;
    until CAS(PMemData, link, PData);
  end;
end;

procedure InitializeTimingInfo;
var
  stack: TLFStack;
begin
  stack.Initialize(10, 4); // enough for initialization
  stack.Finalize;
end;

initialization
  {$IFDEF CPUX64}
  CASAlignment := 16;
  {$ELSE}
  CASAlignment := 8;
  {$ENDIF CPUX64}
  InitializeTimingInfo;
end.
