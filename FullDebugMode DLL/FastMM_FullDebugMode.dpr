{

Fast Memory Manager: FullDebugMode Support DLL 1.62

Description:
 Support DLL for FastMM. With this DLL available, FastMM will report debug info
 (unit name, line numbers, etc.) for stack traces.

Usage:
 1) To compile you will need the JCL library (http://sourceforge.net/projects/jcl/)
 2) Place in the same location as the replacement borlndmm.dll or your
 application's executable module.

Change log:
 Version 1.00 (9 July 2005):
  - Initial release.
 Version 1.01 (13 July 2005):
  - Added the option to use madExcept instead of the JCL Debug library. (Thanks
    to Martin Aignesberger.)
 Version 1.02 (30 September 2005):
  - Changed options to display detail for addresses inside libraries as well.
 Version 1.03 (13 October 2005):
  - Added a raw stack trace procedure that implements raw stack traces.
 Version 1.10 (14 October 2005):
  - Improved the program logic behind the skipping of stack levels to cause
    less incorrect entries in raw stack traces. (Thanks to Craig Peterson.)
 Version 1.20 (17 October 2005):
  - Improved support for madExcept stack traces. (Thanks to Mathias Rauen.)
 Version 1.30 (26 October 2005):
  - Changed name to FastMM_FullDebugMode to reflect the fact that there is now
    a static dependency on this DLL for FullDebugMode. The static dependency
    solves a DLL unload order issue. (Thanks to Bart van der Werf.)
 Version 1.40 (31 October 2005):
  - Added support for EurekaLog. (Thanks to Fabio Dell'Aria.)
 Version 1.42 (23 June 2006):
  - Fixed a bug in the RawStackTraces code that may have caused an A/V in some
    rare circumstances. (Thanks to Primoz Gabrijelcic.)
 Version 1.44 (16 November 2006):
  - Changed the RawStackTraces code to prevent it from modifying the Windows
    "GetLastError" error code. (Thanks to Primoz Gabrijelcic.)
 Version 1.50 (14 August 2008):
  - Added support for Delphi 2009. (Thanks to Mark Edington.)
 Version 1.60 (5 May 2009):
  - Improved the code used to identify call instructions in the stack trace
    code. (Thanks to the JCL team.)
 Version 1.61 (5 September 2010):
  - Recompiled using the latest JCL in order to fix a possible crash on shutdown
    when the executable contains no debug information. (Thanks to Hanspeter
    Widmer.)
 Version 1.62 (19 July 2012):
  - Added a workaround for QC 107209 (Thanks to David Heffernan.)
  Version 1.63 (14 September 2013):
  - Added support for OSX (Thanks to Sebastian Zierer)

}

{$IFDEF MSWINDOWS}
{--------------------Start of options block-------------------------}

{Select the stack tracing library to use. The JCL, madExcept and EurekaLog are
 supported. Only one can be used at a time.}
{$define JCLDebug}
{.$define madExcept}
{.$define EurekaLog}

{--------------------End of options block-------------------------}
{$ENDIF}

// JCL_DEBUG_EXPERT_INSERTJDBG OFF
library FastMM_FullDebugMode;

uses
  {$ifdef JCLDebug}JCLDebug,{$endif}
  {$ifdef madExcept}madStackTrace,{$endif}
  {$ifdef EurekaLog}ExceptionLog,{$endif}
  SysUtils, {$IFDEF MACOS}Posix.Base, SBMapFiles {$ELSE} Windows {$ENDIF};

{$R *.res}

{$stackframes on}

{The name of the 64-bit DLL has a '64' at the end.}
{$if SizeOf(Pointer) = 8}
{$LIBSUFFIX '64'}
{$ifend}

{$if CompilerVersion < 20}
type
  PNativeUInt = ^Cardinal;
{$ifend}

{--------------------------Stack Tracing Subroutines--------------------------}

procedure GetStackRange(var AStackBaseAddress, ACurrentStackPointer: NativeUInt);
asm
  {$if SizeOf(Pointer) = 8}
  mov rax, gs:[abs 8]
  mov [rcx], rax
  mov [rdx], rbp
  {$else}
  mov ecx, fs:[4]
  mov [eax], ecx
  mov [edx], ebp
  {$ifend}
end;

{--------------------------Frame Based Stack Tracing--------------------------}

{$if SizeOf(Pointer) = 8}

function CaptureStackBackTrace(FramesToSkip, FramesToCapture: DWORD;
  BackTrace: Pointer; BackTraceHash: PDWORD): Word;
  external kernel32 name 'RtlCaptureStackBackTrace';

{We use the Windows API to do frame based stack tracing under 64-bit.}
procedure GetFrameBasedStackTrace(AReturnAddresses: PNativeUInt;
  AMaxDepth, ASkipFrames: Cardinal);
begin
  CaptureStackBackTrace(ASkipFrames, AMaxDepth, AReturnAddresses, nil);
end;

{$else}

{Dumps the call stack trace to the given address. Fills the list with the
 addresses where the called addresses can be found. This is the fast stack
 frame based tracing routine.}
procedure GetFrameBasedStackTrace(AReturnAddresses: PNativeUInt;
  AMaxDepth, ASkipFrames: Cardinal);
var
  LStackTop, LStackBottom, LCurrentFrame: NativeUInt;
begin
  {Get the call stack top and current bottom}
  GetStackRange(LStackTop, LStackBottom);
  Dec(LStackTop, SizeOf(Pointer) - 1);
  {Get the current frame start}
  LCurrentFrame := LStackBottom;
  {Fill the call stack}
  while (AMaxDepth > 0)
    and (LCurrentFrame >= LStackBottom)
    and (LCurrentFrame < LStackTop) do
  begin
    {Ignore the requested number of levels}
    if ASkipFrames = 0 then
    begin
      AReturnAddresses^ := PNativeUInt(LCurrentFrame + SizeOf(Pointer))^;
      Inc(AReturnAddresses);
      Dec(AMaxDepth);
    end
    else
      Dec(ASkipFrames);
    {Get the next frame}
    LCurrentFrame := PNativeUInt(LCurrentFrame)^;
  end;
  {Clear the remaining entries}
  while AMaxDepth > 0 do
  begin
    AReturnAddresses^ := 0;
    Inc(AReturnAddresses);
    Dec(AMaxDepth);
  end;
end;
{$ifend}

{-----------------------------Raw Stack Tracing-----------------------------}

const
  {Hexadecimal characters}
  HexTable: array[0..15] of AnsiChar = '0123456789ABCDEF';

type
  {The state of a memory page. Used by the raw stack tracing mechanism to
   determine whether an address is a valid call site or not.}
  TMemoryPageAccess = (mpaUnknown, mpaNotExecutable, mpaExecutable);

var
  {There are a total of 1M x 4K pages in the (low) 4GB address space}
  MemoryPageAccessMap: array[0..1024 * 1024 - 1] of TMemoryPageAccess;

{$IFDEF MSWINDOWS}
{Updates the memory page access map. Currently only supports the low 4GB of
 address space.}
procedure UpdateMemoryPageAccessMap(AAddress: NativeUInt);
var
  LMemInfo: TMemoryBasicInformation;
  LAccess: TMemoryPageAccess;
  LStartPage, LPageCount: NativeUInt;
begin
  {Query the page}
  if VirtualQuery(Pointer(AAddress), LMemInfo, SizeOf(LMemInfo)) <> 0 then
  begin
    {Get access type}
    if (LMemInfo.State = MEM_COMMIT)
      and (LMemInfo.Protect and (PAGE_EXECUTE_READ or PAGE_EXECUTE_READWRITE
        or PAGE_EXECUTE_WRITECOPY or PAGE_EXECUTE) <> 0)
      and (LMemInfo.Protect and PAGE_GUARD = 0) then
    begin
      LAccess := mpaExecutable
    end
    else
      LAccess := mpaNotExecutable;
    {Update the map}
    LStartPage := NativeUInt(LMemInfo.BaseAddress) div 4096;
    LPageCount := LMemInfo.RegionSize div 4096;
    if LStartPage < NativeUInt(Length(MemoryPageAccessMap)) then
    begin
      if (LStartPage + LPageCount) >= NativeUInt(Length(MemoryPageAccessMap)) then
        LPageCount := NativeUInt(Length(MemoryPageAccessMap)) - LStartPage;
      FillChar(MemoryPageAccessMap[LStartPage], LPageCount, Ord(LAccess));
    end;
  end
  else
  begin
    {Invalid address}
    MemoryPageAccessMap[AAddress div 4096] := mpaNotExecutable;
  end;
end;
{$ENDIF}

{Thread-safe version that avoids the global variable Default8087CW.}
procedure Set8087CW(ANewCW: Word);
var
  L8087CW: Word;
asm
  mov L8087CW, ANewCW
  fnclex
  fldcw L8087CW
end;

{$if CompilerVersion > 22}
{Thread-safe version that avoids the global variable DefaultMXCSR.}
procedure SetMXCSR(ANewMXCSR: Cardinal);
var
  LMXCSR: Cardinal;
asm
  {$if SizeOf(Pointer) <> 8}
  cmp System.TestSSE, 0
  je @exit
  {$ifend}
  {Remove the flag bits}
  and ANewMXCSR, $ffc0
  mov LMXCSR, ANewMXCSR
  ldmxcsr LMXCSR
@exit:
end;
{$ifend}

{$IFDEF MSWINDOWS}
{Returns true if the return address is a valid call site. This function is only
 safe to call while exceptions are being handled.}
function IsValidCallSite(AReturnAddress: NativeUInt): boolean;
var
  LCallAddress: NativeUInt;
  LCode8Back, LCode4Back, LTemp: Cardinal;
  LOld8087CW: Word;
{$if CompilerVersion > 22}
  LOldMXCSR: Cardinal;
{$ifend}
begin
  {We assume (for now) that all code will execute within the first 4GB of
   address space.}
  if (AReturnAddress > $ffff) and (AReturnAddress <= $ffffffff) then
  begin
    {The call address is up to 8 bytes before the return address}
    LCallAddress := AReturnAddress - 8;
    {Update the page map}
    if MemoryPageAccessMap[LCallAddress div 4096] = mpaUnknown then
      UpdateMemoryPageAccessMap(LCallAddress);
    {Check the page access}
    if (MemoryPageAccessMap[LCallAddress div 4096] = mpaExecutable)
      and (MemoryPageAccessMap[(LCallAddress + 8) div 4096] = mpaExecutable) then
    begin
      {Try to determine what kind of call it is (if any), more or less in order
       of frequency of occurrence. (Code below taken from the Jedi Code Library
       (jcl.sourceforge.net).)  We need to retrieve the current floating point
       control registers, since any external exception will reset it to the
       DLL defaults which may not otherwise correspond to the defaults of the
       main application (QC 107198).}
      LOld8087CW := Get8087CW;
{$if CompilerVersion > 22}
      LOldMXCSR := GetMXCSR;
{$ifend}
      try
        {5 bytes, CALL NEAR REL32}
        if PByteArray(LCallAddress)[3] = $E8 then
        begin
          Result := True;
          Exit;
        end;
        {Get the 4 bytes before the return address}
        LCode4Back := PCardinal(LCallAddress + 4)^;
        {2 byte call?}
        LTemp := LCode4Back and $F8FF0000;
        {2 bytes, CALL NEAR EAX}
        if LTemp = $D0FF0000 then
        begin
          Result := True;
          Exit;
        end;
        {2 bytes, CALL NEAR [EAX]}
        if LTemp = $10FF0000 then
        begin
          LTemp := LCode4Back - LTemp;
          if (LTemp <> $04000000) and (LTemp <> $05000000) then
          begin
            Result := True;
            Exit;
          end;
        end;
        {3 bytes, CALL NEAR [EAX+EAX*i]}
        if (LCode4Back and $00FFFF00) = $0014FF00 then
        begin
          Result := True;
          Exit;
        end;
        {3 bytes, CALL NEAR [EAX+$12]}
        if ((LCode4Back and $00F8FF00) = $0050FF00)
          and ((LCode4Back and $00070000) <> $00040000) then
        begin
          Result := True;
          Exit;
        end;
        {4 bytes, CALL NEAR [EAX+EAX+$12]}
        if Word(LCode4Back) = $54FF then
        begin
          Result := True;
          Exit;
        end;
        {6 bytes, CALL NEAR [$12345678]}
        LCode8Back := PCardinal(LCallAddress)^;
        if (LCode8Back and $FFFF0000) = $15FF0000 then
        begin
          Result := True;
          Exit;
        end;
        {6 bytes, CALL NEAR [EAX+$12345678]}
        if ((LCode8Back and $F8FF0000) = $90FF0000)
          and ((LCode8Back and $07000000) <> $04000000) then
        begin
          Result := True;
          Exit;
        end;
        {7 bytes, CALL NEAR [EAX+EAX+$1234567]}
        if (LCode8Back and $00FFFF00) = $0094FF00 then
        begin
          Result := True;
          Exit;
        end;
        {7 bytes, CALL FAR $1234:12345678}
        if (LCode8Back and $0000FF00) = $00009A00 then
        begin
          Result := True;
          Exit;
        end;
        {Not a valid call site}
        Result := False;
      except
        {The access has changed}
        UpdateMemoryPageAccessMap(LCallAddress);
        {The RTL sets the FPU control words to the default values if an
        external exception occurs.  Reset their values here to the values on
        entry to this call.}
        Set8087CW(LOld8087CW);
{$if CompilerVersion > 22}
        SetMXCSR(LOldMXCSR);
{$ifend}
        {Not executable}
        Result := False;
      end;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;
{$ENDIF}

{Dumps the call stack trace to the given address. Fills the list with the
 addresses where the called addresses can be found. This is the "raw" stack
 tracing routine.}

{$IFDEF MACOS}
function backtrace(result: PNativeUInt; size: Integer): Integer; cdecl; external libc name '_backtrace';
function _NSGetExecutablePath(buf: PAnsiChar; BufSize: PCardinal): Integer; cdecl; external libc name '__NSGetExecutablePath';
{$ENDIF}

procedure GetRawStackTrace(AReturnAddresses: PNativeUInt;
  AMaxDepth, ASkipFrames: Cardinal);
var
  LStackTop, LStackBottom, LCurrentFrame, LNextFrame, LReturnAddress,
    LStackAddress: NativeUInt;
  LLastOSError: Cardinal;

{$IFDEF MACOS}
  StackLog: PNativeUInt; //array[0..10] of Pointer;
  Cnt: Integer;
  I: Integer;
{$ENDIF}
begin
  {$IFDEF MACOS}
  {$POINTERMATH ON}
  Cnt := AMaxDepth + ASkipFrames;

  GetMem(StackLog, SizeOf(Pointer) * Cnt);
  try
    Cnt := backtrace(StackLog, Cnt);

    for I := ASkipFrames to Cnt - 1 do
    begin
//      writeln('Stack: ', inttohex(NativeUInt(stacklog[I]), 8));
      AReturnAddresses[I - ASkipFrames] := StackLog[I];
    end;

  finally
    FreeMem(StackLog);
  end;
  {$POINTERMATH OFF}
  {$ENDIF}
  {Are exceptions being handled? Can only do a raw stack trace if the possible
   access violations are going to be handled.}
{$IFDEF MSWINDOWS}
  if Assigned(ExceptObjProc) then
  begin
    {Save the last Windows error code}
    LLastOSError := GetLastError;
    {Get the call stack top and current bottom}
    GetStackRange(LStackTop, LStackBottom);
    Dec(LStackTop, SizeOf(Pointer) - 1);
    {Get the current frame start}
    LCurrentFrame := LStackBottom;
    {Fill the call stack}
    while (AMaxDepth > 0)
      and (LCurrentFrame < LStackTop) do
    begin
      {Get the next frame}
      LNextFrame := PNativeUInt(LCurrentFrame)^;
      {Is it a valid stack frame address?}
      if (LNextFrame < LStackTop)
        and (LNextFrame > LCurrentFrame) then
      begin
        {The pointer to the next stack frame appears valid: Get the return
         address of the current frame}
        LReturnAddress := PNativeUInt(LCurrentFrame + SizeOf(Pointer))^;
        {Does this appear to be a valid return address}
        if (LReturnAddress > $ffff) and (LReturnAddress <= $ffffffff) then
        begin
          {Is the map for this return address incorrect? It may be unknown or marked
           as non-executable because a library was previously not yet loaded, or
           perhaps this is not a valid stack frame.}
          if MemoryPageAccessMap[(LReturnAddress - 8) div 4096] <> mpaExecutable then
            UpdateMemoryPageAccessMap(LReturnAddress - 8);
          {Is this return address actually valid?}
          if IsValidCallSite(LReturnAddress) then
          begin
            {Ignore the requested number of levels}
            if ASkipFrames = 0 then
            begin
              AReturnAddresses^ := LReturnAddress;
              Inc(AReturnAddresses);
              Dec(AMaxDepth);
            end;
          end
          else
          begin
            {If the return address is invalid it implies this stack frame is
             invalid after all.}
            LNextFrame := LStackTop;
          end;
        end
        else
        begin
          {The return address is bad - this is not a valid stack frame}
          LNextFrame := LStackTop;
        end;
      end
      else
      begin
        {This is not a valid stack frame}
        LNextFrame := LStackTop;
      end;
      {Do not check intermediate entries if there are still frames to skip}
      if ASkipFrames <> 0 then
      begin
        Dec(ASkipFrames);
      end
      else
      begin
        {Check all stack entries up to the next stack frame}
        LStackAddress := LCurrentFrame + 2 * SizeOf(Pointer);
        while (AMaxDepth > 0)
          and (LStackAddress < LNextFrame) do
        begin
          {Get the return address}
          LReturnAddress := PNativeUInt(LStackAddress)^;
          {Is this a valid call site?}
          if IsValidCallSite(LReturnAddress) then
          begin
            AReturnAddresses^ := LReturnAddress;
            Inc(AReturnAddresses);
            Dec(AMaxDepth);
          end;
          {Check the next stack address}
          Inc(LStackAddress, SizeOf(Pointer));
        end;
      end;
      {Do the next stack frame}
      LCurrentFrame := LNextFrame;
    end;
    {Clear the remaining entries}
    while AMaxDepth > 0 do
    begin
      AReturnAddresses^ := 0;
      Inc(AReturnAddresses);
      Dec(AMaxDepth);
    end;
    {Restore the last Windows error code, since a VirtualQuery call may have
     modified it.}
    SetLastError(LLastOSError);
  end
  else
  begin
    {Exception handling is not available - do a frame based stack trace}
    GetFrameBasedStackTrace(AReturnAddresses, AMaxDepth, ASkipFrames);
  end;
  {$ENDIF}
end;

{-----------------------------Stack Trace Logging----------------------------}

{Gets the textual representation of the stack trace into ABuffer and returns
 a pointer to the position just after the last character.}
{$ifdef JCLDebug}
{Converts an unsigned integer to a hexadecimal string at the buffer location,
 returning the new buffer position.}
function NativeUIntToHexBuf(ANum: NativeUInt; APBuffer: PAnsiChar): PAnsiChar;
const
  MaxDigits = 16;
var
  LDigitBuffer: array[0..MaxDigits - 1] of AnsiChar;
  LCount: Cardinal;
  LDigit: NativeUInt;
begin
  {Generate the digits in the local buffer}
  LCount := 0;
  repeat
    LDigit := ANum;
    ANum := ANum div 16;
    LDigit := LDigit - ANum * 16;
    Inc(LCount);
    LDigitBuffer[MaxDigits - LCount] := HexTable[LDigit];
  until ANum = 0;
  {Copy the digits to the output buffer and advance it}
  System.Move(LDigitBuffer[MaxDigits - LCount], APBuffer^, LCount);
  Result := APBuffer + LCount;
end;

{Subroutine used by LogStackTrace}
procedure AppendInfoToString(var AString: string; const AInfo: string);
begin
  if AInfo <> '' then
    AString := Format('%s[%s]', [AString, AInfo]);
end;

function LogStackTrace(AReturnAddresses: PNativeUInt; AMaxDepth: Cardinal;
  ABuffer: PAnsiChar): PAnsiChar;
var
  LInd: Cardinal;
  LAddress: NativeUInt;
  LNumChars: Integer;
  LInfo: TJCLLocationInfo;
  LTempStr: string;
begin
  Result := ABuffer;
  for LInd := 0 to AMaxDepth - 1 do
  begin
    LAddress := AReturnAddresses^;
    if LAddress = 0 then
      Exit;
    Result^ := #13;
    Inc(Result);
    Result^ := #10;
    Inc(Result);
    Result := NativeUIntToHexBuf(LAddress, Result);
    {Get location info for the caller (at least one byte before the return
     address).}
    GetLocationInfo(Pointer(Cardinal(LAddress) - 1), LInfo);
    {Build the result string}
    LTempStr := ' ';
    AppendInfoToString(LTempStr, LInfo.SourceName);
    AppendInfoToString(LTempStr, LInfo.UnitName);
    AppendInfoToString(LTempStr, LInfo.ProcedureName);
    if LInfo.LineNumber <> 0 then
      AppendInfoToString(LTempStr, IntToStr(LInfo.LineNumber));
    {Return the result}
    if Length(LTempStr) < 256 then
      LNumChars := Length(LTempStr)
    else
      LNumChars := 255;
    StrLCopy(Result, PAnsiChar(AnsiString(LTempStr)), LNumChars);
    Inc(Result, LNumChars);
    {Next address}
    Inc(AReturnAddresses);
  end;
end;
{$endif}

{$ifdef madExcept}
function LogStackTrace(AReturnAddresses: PNativeUInt;
  AMaxDepth: Cardinal; ABuffer: PAnsiChar): PAnsiChar;
begin
  {Needs madExcept 2.7i or madExcept 3.0a or a newer build}
  Result := madStackTrace.FastMM_LogStackTrace(
    AReturnAddresses,
    AMaxDepth,
    ABuffer,
    {madExcept stack trace fine tuning}
    false, //hide items which have no line number information?
    true,  //show relative address offset to procedure entrypoint?
    true,  //show relative line number offset to procedure entry point?
    false  //skip special noise reduction processing?
    );
end;
{$endif}

{$ifdef EurekaLog}
function LogStackTrace(AReturnAddresses: PNativeUInt; AMaxDepth: Cardinal;
  ABuffer: PAnsiChar): PAnsiChar;
begin
  {Needs EurekaLog 5.0.5 or a newer build}
  Result := ExceptionLog.FastMM_LogStackTrace(
    AReturnAddresses, AMaxDepth, ABuffer,
    {EurekaLog stack trace fine tuning}
    False, // Show the DLLs functions call.  <--|
           //                                   |-- See the note below!
    False, // Show the BPLs functions call.  <--|
    True  // Show relative line no. offset to procedure start point.
    );
// NOTE:
// -----
// With these values set both to "False", EurekaLog try to returns the best
// call-stack available.
//
// To do this EurekaLog execute the following points:
// --------------------------------------------------
// 1)...try to fill all call-stack items using only debug data with line no.
// 2)...if remains some empty call-stack items from the previous process (1),
//      EurekaLog try to fill these with the BPLs functions calls;
// 3)...if remains some empty call-stack items from the previous process (2),
//      EurekaLog try to fill these with the DLLs functions calls;
end;
{$endif}

{$IFDEF MACOS}

{Appends the source text to the destination and returns the new destination
 position}
function AppendStringToBuffer(const ASource, ADestination: PAnsiChar; ACount: Cardinal): PAnsiChar;
begin
  System.Move(ASource^, ADestination^, ACount);
  Result := Pointer(PByte(ADestination) + ACount);
end;

var
  MapFile: TSBMapFile;

function LogStackTrace(AReturnAddresses: PNativeUInt;
  AMaxDepth: Cardinal; ABuffer: PAnsiChar): PAnsiChar;
var
  s1: AnsiString;
  I: Integer;
  FileName: array[0..255] of AnsiChar;
  Len: Cardinal;
begin
  {$POINTERMATH ON}
//  writelN('LogStackTrace');
//  for I := 0 to AMaxDepth - 1 do
//    Writeln(IntToHex(AReturnAddresses[I], 8));

//  s1 := IntToHex(Integer(AReturnAddresses[0]), 8);
//  result := ABuffer;
//  Move(pointer(s1)^, result^, Length(s1));
//  inc(result, Length(s1));

  if MapFile = nil then
  begin
    MapFile := TSBMapFile.Create;
    Len := Length(FileName);
    _NSGetExecutablePath(@FileName[0], @Len);
    if FileExists(ChangeFileExt(FileName, '.map')) then
      MapFile.LoadFromFile(ChangeFileExt(FileName, '.map'));
  end;

  Result := ABuffer;

  s1 := #13#10;
  Result := AppendStringToBuffer(PAnsiChar(s1), Result, Length(s1));

  for I := 0 to AMaxDepth - 1 do
  begin
    s1 := IntToHex(AReturnAddresses[I], 8);
    s1 := s1 + ' ' + MapFile.GetFunctionName(AReturnAddresses[I]) + #13#10;
    Result := AppendStringToBuffer(PAnsiChar(s1), Result, Length(s1));
  end;

  {$POINTERMATH OFF}
end;
{$ENDIF}

{-----------------------------Exported Functions----------------------------}

exports
  GetFrameBasedStackTrace,
  GetRawStackTrace,
  LogStackTrace;

begin
{$ifdef JCLDebug}
  JclStackTrackingOptions := JclStackTrackingOptions + [stAllModules];
{$endif}
end.
