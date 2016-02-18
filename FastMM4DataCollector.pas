unit FastMM4DataCollector;

{$I FastMM4Options.inc}

interface

type
  TStaticCollector = record
  strict private const
    CDefaultPromoteGen1_sec  = 1; // promote every second
    CDefaultPromoteGen1Count = 1; // promote allocations with Count > 1
    CGeneration1Size = 1024;
    CGeneration2Size = 256;
    CCollectedDataSize = CGeneration2Size;
    CMaxPointers = 11; // same as in FastMM4
  public type
    TPointers = record
      Pointers: array [1..CMaxPointers] of pointer;
      Count   : integer;
      class operator Equal(const a, b: TPointers): boolean;
    end;
    TDataInfo = record
      Data : TPointers;
      Count: integer;
    end;
    TCollectedData = array [1..CCollectedDataSize] of TDataInfo;
    TGenerationOverflowCount = record
      Generation1: integer;
      Generation2: integer;
    end;
  strict private type
    PDataInfo = ^TDataInfo;
    TGenerationPlaceholder = array [1..1] of TDataInfo;
    PGenerationPlaceholder = ^TGenerationPlaceholder;
    TGenerationInfo = record
      Data            : PGenerationPlaceholder;
      Size            : integer;
      Last            : integer;
      NextGeneration  : integer;
      PromoteEvery_sec: integer;
      PromoteCountOver: integer;
      OverflowCount   : integer;
      LastCheck_ms    : int64;
    end;
  var
    FGeneration1   : array [1..CGeneration1Size] of TDataInfo;
    FGeneration2   : array [1..CGeneration2Size] of TDataInfo;
    FGenerationInfo: array [0..2] of TGenerationInfo; //gen0 is used for merging
    FLocked        : boolean;
    FPadding       : array [1..3] of byte;
    function GetGen1_PromoteCountOver: integer;
    function GetGen1_PromoteEvery_sec: integer;
    function GetOverflowCount: TGenerationOverflowCount;
    procedure Lock;
    function Now_ms: int64; inline;
    procedure SetGen1_PromoteCountOver(const value: integer);
    procedure SetGen1_PromoteEvery_sec(const value: integer);
  private
    procedure AddToGeneration(generation: integer; const aData: TPointers;
      count: integer = 1);
    procedure CheckPromoteGeneration(generation: integer); inline;
    function FindInGeneration(generation: integer; const aData: TPointers): integer; inline;
    function FindInsertionPoint(generation, count: integer): integer; inline;
    procedure FlushAllGenerations;
    function InsertIntoGeneration(generation: integer; const dataInfo: TDataInfo): boolean;
    procedure PromoteGeneration(oldGen, newGen: integer);
    procedure ResortGeneration(generation, idxData: integer);
  public
    procedure Initialize;
    procedure Add(const pointers: pointer; count: integer);
    procedure GetData(var data: TCollectedData; var count: integer);
    procedure Merge(var mergedData: TCollectedData; var mergedCount: integer;
      const newData: TCollectedData; newCount: integer);
    property Gen1_PromoteCountOver: integer read GetGen1_PromoteCountOver
      write SetGen1_PromoteCountOver;
    property OverflowCount: TGenerationOverflowCount read GetOverflowCount;
    property Gen1_PromoteEvery_sec: integer read GetGen1_PromoteEvery_sec write
      SetGen1_PromoteEvery_sec;
  end;
  PStaticCollector = ^TStaticCollector;

implementation

uses
  Winapi.Windows; //used in Now_ms

{$RANGECHECKS OFF}

// Copied from FastMM4.pas
function LockCmpxchg(CompareVal, NewVal: Byte; AAddress: PByte): Byte;
asm
{$if SizeOf(Pointer) = 4}
  {On entry:
    al = CompareVal,
    dl = NewVal,
    ecx = AAddress}
  {$ifndef LINUX}
  lock cmpxchg [ecx], dl
  {$else}
  {Workaround for Kylix compiler bug}
  db $F0, $0F, $B0, $11
  {$endif}
{$else}
  {On entry:
    cl = CompareVal
    dl = NewVal
    r8 = AAddress}
  .noframe
  mov rax, rcx
  lock cmpxchg [r8], dl
{$ifend}
end;

{ TStaticCollector.TPointers }

class operator TStaticCollector.TPointers.Equal(const a, b: TPointers): boolean;
var
  i: integer;
begin
  Result := a.Count = b.Count;
  if Result then
    for i := 1 to a.Count do
      if a.Pointers[i] <> b.Pointers[i] then
        Exit(false);
end;

{ TStaticCollector }

procedure TStaticCollector.Add(const pointers: pointer; count: integer);
var
  ptrData: TPointers;
begin
  Lock;
  ptrData.Count := CMaxPointers;
  if count < CMaxPointers then
    ptrData.Count := count;
  Move(pointers^, ptrData.Pointers[1], ptrData.Count * SizeOf(pointer));
  AddToGeneration(1, ptrData);
  FLocked := false;
end;

procedure TStaticCollector.AddToGeneration(generation: integer; const aData: TPointers;
  count: integer = 1);
var
  dataInfo: TDataInfo;
  idxData : integer;
begin
  CheckPromoteGeneration(generation);

  with FGenerationInfo[generation] do begin
    idxData := FindInGeneration(generation, aData);
    if idxData >= 1 then begin
      Data^[idxData].Count := Data^[idxData].Count + count;
      ResortGeneration(generation, idxData);
    end
    else begin
      dataInfo.Data := aData;
      dataInfo.Count := count;
      InsertIntoGeneration(generation, dataInfo);
    end;
  end;
end; { TStaticCollector.AddToGeneration }

procedure TStaticCollector.CheckPromoteGeneration(generation: integer);
begin
  with FGenerationInfo[generation] do begin
    if NextGeneration > 0 then begin
      if LastCheck_ms = 0 then
        LastCheck_ms := Now_ms
      else if ((Now_ms - LastCheck_ms) div 1000) >= PromoteEvery_sec then begin
        PromoteGeneration(generation, NextGeneration);
        LastCheck_ms := Now_ms;
      end;
    end;
  end;
end;

function TStaticCollector.FindInGeneration(generation: integer; const aData: TPointers):
  integer;
begin
  with FGenerationInfo[generation] do begin
    for Result := 1 to Last do
      if Data^[Result].Data = aData then
        Exit;
  end;
  Result := 0;
end;

function TStaticCollector.FindInsertionPoint(generation, count: integer): integer;
var
  insert: integer;
begin
  with FGenerationInfo[generation] do begin
    for insert := Last downto 1 do begin
      if Data^[insert].Count > count then
        Exit(insert+1);
    end;
    Result := 1;
  end;
end;

procedure TStaticCollector.FlushAllGenerations;
var
  generation: integer;
  nextGen   : integer;
begin
  generation := 1;
  while generation <> 0 do begin
    nextGen := FGenerationInfo[generation].NextGeneration;
    if nextGen > 0 then
      PromoteGeneration(generation, nextGen);
    generation := nextGen;
  end;
end;

procedure TStaticCollector.GetData(var data: TCollectedData; var count: integer);
begin
  Lock;
  FlushAllGenerations;
  Assert(Length(data) = Length(FGeneration2));
  count := FGenerationInfo[2].Last;
  Move(FGeneration2[1], data[1], count * SizeOf(data[1]));
  FLocked := false;
end;

function TStaticCollector.GetGen1_PromoteCountOver: integer;
begin
  Result := FGenerationInfo[1].PromoteCountOver;
end;

function TStaticCollector.GetGen1_PromoteEvery_sec: integer;
begin
  Result := FGenerationInfo[1].PromoteEvery_sec;
end;

function TStaticCollector.GetOverflowCount: TGenerationOverflowCount;
begin
  Result.Generation1 := FGenerationInfo[1].OverflowCount;
  Result.Generation2 := FGenerationInfo[2].OverflowCount;
end;

procedure TStaticCollector.Initialize;
begin
  Assert(SizeOf(TStaticCollector) mod SizeOf(pointer) = 0);
  with FGenerationInfo[1] do begin
    Data := @FGeneration1;
    Size := CGeneration1Size;
    Last := 0;
    NextGeneration := 2;
    PromoteEvery_sec := CDefaultPromoteGen1_sec;
    PromoteCountOver := CDefaultPromoteGen1Count;
    LastCheck_ms := 0;
  end;
  with FGenerationInfo[2] do begin
    Data := @FGeneration2;
    Size := CGeneration2Size;
    NextGeneration := 0;
  end;
end;

function TStaticCollector.InsertIntoGeneration(generation: integer; const dataInfo:
  TDataInfo): boolean;
var
  idx: integer;
begin
  // We already know that this element does not exist in the generation.

  Result := true;
  with FGenerationInfo[generation] do begin
    idx := FindInsertionPoint(generation, dataInfo.Count);
    if idx > Last then begin
      if Last = Size then begin
        Inc(OverflowCount);
        Result := false;
      end
      else begin
        Inc(Last);
        Data^[Last] := dataInfo;
      end;
    end
    else begin
      if Last < Size then begin
        Move(Data^[idx], Data^[idx+1], (Last-idx+1) * SizeOf(Data^[idx]));
        Inc(Last);
      end
      else begin
        if Last > idx then
          Move(Data^[idx], Data^[idx+1], (Last-idx) * SizeOf(Data^[idx]));
        Inc(OverflowCount);
      end;
      Data^[idx] := dataInfo;
    end;
  end;
end;

procedure TStaticCollector.Lock;
begin
{$ifndef AssumeMultiThreaded}
  if IsMultiThread then
{$endif}
  begin
    while LockCmpxchg(0, 1, @FLocked) <> 0 do
    begin
{$ifdef NeverSleepOnThreadContention}
  {$ifdef UseSwitchToThread}
      SwitchToThread;
  {$endif}
{$else}
      Sleep(0);
      if LockCmpxchg(0, 1, @FLocked) = 0 then
        Break;
      Sleep(1);
{$endif}
    end;
  end;
end;

procedure TStaticCollector.Merge(var mergedData: TCollectedData;
  var mergedCount: integer; const newData: TCollectedData; newCount: integer);
var
  iNew: integer;
begin
  // Merges two sorted arrays.

  FGenerationInfo[0].Data := @mergedData;
  FGenerationInfo[0].Last := mergedCount;
  FGenerationInfo[0].Size := CCollectedDataSize;
  FGenerationInfo[0].NextGeneration := 0;

  for iNew := 1 to newCount do
    AddToGeneration(0, newData[iNew].Data, newData[iNew].Count);

  mergedCount := FGenerationInfo[0].Last;
end;

function TStaticCollector.Now_ms: int64;
var
  st: TSystemTime;
begin
  // We cannot use SysUtils as that gets memory allocator called before FastMM is initialized.
  GetSystemTime(st);
  SystemTimeToFileTime(st, TFileTime(Result));
  Result := Result div 10000;
end;

procedure TStaticCollector.PromoteGeneration(oldGen, newGen: integer);
var
  canInsert : boolean;
  idxNew    : integer;
  idxOld    : integer;
  newGenData: PGenerationPlaceholder;
  pOldData  : PDataInfo;
begin
  canInsert := true;
  newGenData := FGenerationInfo[newGen].Data;
  with FGenerationInfo[oldGen] do begin
    for idxOld := 1 to Last do begin
      pOldData := @Data^[idxOld];
      if pOldData^.Count <= PromoteCountOver then
        break; //for idxOld
      idxNew := FindInGeneration(newGen, pOldData^.Data);
      if idxNew > 0 then begin
        newGenData^[idxNew].Count := newGenData^[idxNew].Count + pOldData^.Count;
        ResortGeneration(newGen, idxNew);
      end
      else if canInsert then
        canInsert := InsertIntoGeneration(newGen, pOldData^)
      else with FGenerationInfo[newGen] do
        Inc(OverflowCount);
    end; //for idxOld
    Last := 0;
  end;
end;

procedure TStaticCollector.ResortGeneration(generation, idxData: integer);
var
  dataInfo: TDataInfo;
  idx     : integer;
begin
  // Data^[idxData].Count was just updated, resort the generation.
  with FGenerationInfo[generation] do begin
    idx := FindInsertionPoint(generation, Data^[idxData].Count);
    if idx < idxData then begin
      dataInfo := Data^[idxData];
      Move(Data^[idx], Data^[idx+1], (idxData-idx) * SizeOf(Data^[idx]));
      Data^[idx] := dataInfo;
    end;
  end;
end;

procedure TStaticCollector.SetGen1_PromoteCountOver(const value: integer);
begin
  FGenerationInfo[1].PromoteCountOver := value;
end;

procedure TStaticCollector.SetGen1_PromoteEvery_sec(const value: integer);
begin
  FGenerationInfo[1].PromoteEvery_sec := value;
end;

end.
