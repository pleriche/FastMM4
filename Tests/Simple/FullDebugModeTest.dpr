program FullDebugModeTest;
// FullDebugMode regression test for FastMM4-AVX.
//
// Covers the four FreePascal FullDebugMode defects behind issue #68, and is
// written so that it is also a general allocator test on Delphi:
//
//   1. A reused block reported as modified after being freed, GetMem then
//      returning nil (CheckFreeBlockUnmodified).
//   2. An access violation in the FullDebugMode counters, from a global
//      variable named inside an assembler block.
//   3. A reallocation that moves the block leaving the caller pointer
//      dangling (DebugReallocMem and its var parameter).
//   4. MemSize, FreememSize and AllocMem left nil in the memory manager
//      record, so growing a string called address zero.
//
// Compile with FreePascal:
//   fpc -B -Mdelphi -Twin64 -Px86_64 -dFullDebugMode -dNoMessageBoxes
//       FullDebugModeTest.dpr
//
// Compile with Delphi: open FullDebugModeTest.dproj. FullDebugMode and
// NoMessageBoxes are already set in the project defines.
//
// Windows needs FastMM_FullDebugMode.dll for 32 bit, or
// FastMM_FullDebugMode64.dll for 64 bit, beside the executable. Both are in
// "FullDebugMode DLL\Precompiled" in this repository.
//
// Modes, selected by the first command line argument:
//   (none)              the checks that must all pass, exit code 0
//   modify-after-free   writes into a freed block and expects the allocator
//                       to report it, exit code 0 when it does
//   corrupt-footer      overwrites the footer of a freed block and expects
//                       the allocator to report it, exit code 0 when it does
//
// The two named modes deliberately corrupt the heap, so each one runs on its
// own and the process stops as soon as the check is done. They also need the
// default LogErrorsToFile setting, since they look for the event log file.
//
// Note for Linux: FastMM4 undefines FullDebugMode for POSIX other than macOS,
// so on Linux this program still builds and runs but exercises the ordinary
// allocator. The FullDebugMode specific parts are compiled out to match.

{$IFNDEF UNIX}
{$APPTYPE CONSOLE}
{$ENDIF}

{Mirror the platform rule FastMM4 applies to FullDebugMode, so that the parts
 of this test that touch FullDebugMode only compile where the mode survives}
{$UNDEF FullDebugModeIsActive}
{$IFDEF FullDebugMode}
  {$IFDEF MSWINDOWS}
    {$DEFINE FullDebugModeIsActive}
  {$ENDIF}
  {$IFDEF MACOS}
    {$DEFINE FullDebugModeIsActive}
  {$ENDIF}
{$ENDIF}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  FastMM4 in '../../FastMM4.pas',
  FastMM4Messages in '../../FastMM4Messages.pas',
  SysUtils;

const
  TEST_PASSED = 0;
  TEST_FAILED = 1;

  {One size in each of the small, medium and large block ranges}
  CBlockSizes: array[0..9] of Integer =
    (1, 15, 64, 200, 1000, 5000, 30000, 100000, 300000, 1000000);

var
  GFailures: Integer = 0;

procedure Say(const AText: string);
begin
  WriteLn(AText);
  Flush(Output);
end;

procedure Check(ACondition: Boolean; const AWhat: string);
begin
  if ACondition then
    Say('  ok    ' + AWhat)
  else
  begin
    Say('  FAIL  ' + AWhat);
    Inc(GFailures);
  end;
end;

function EventLogFileName: string;
begin
  Result := ChangeFileExt(ParamStr(0), '') + '_MemoryManager_EventLog.txt';
end;

procedure DeleteEventLog;
begin
  if FileExists(EventLogFileName) then
    DeleteFile(EventLogFileName);
end;

{Allocate, fill, verify and free over every size class, several times over, so
 that blocks are reused. A reused block that is wrongly reported as modified
 after being freed shows up here as a nil result.}
procedure TestAllocateFillFree;
var
  LPointers: array[0..63] of Pointer;
  LRound, I, J, LSize: Integer;
  LOk: Boolean;
begin
  Say('allocate, fill and free over all size classes');
  LOk := True;
  for LRound := 1 to 8 do
  begin
    for I := 0 to High(LPointers) do
    begin
      LSize := CBlockSizes[I mod Length(CBlockSizes)] + LRound;
      GetMem(LPointers[I], LSize);
      if LPointers[I] = nil then
      begin
        LOk := False;
        Break;
      end;
      FillChar(LPointers[I]^, LSize, Byte(I));
    end;
    if not LOk then
      Break;
    for I := 0 to High(LPointers) do
    begin
      LSize := CBlockSizes[I mod Length(CBlockSizes)] + LRound;
      for J := 0 to LSize - 1 do
        if PByte(LPointers[I])[J] <> Byte(I) then
        begin
          LOk := False;
          Break;
        end;
    end;
    for I := 0 to High(LPointers) do
      FreeMem(LPointers[I]);
    if not LOk then
      Break;
  end;
  Check(LOk, '8 rounds of 64 blocks allocated, filled, verified and freed');
end;

{Grow a block far enough that it has to move, and check that the caller is left
 with the new block rather than the freed one}
procedure TestReallocateMoves;
var
  P: Pointer;
  I: Integer;
  LOk: Boolean;
begin
  Say('reallocation that moves the block');
  GetMem(P, 64);
  for I := 0 to 63 do
    PByte(P)[I] := Byte(I);
  ReallocMem(P, 400000);
  LOk := P <> nil;
  if LOk then
  begin
    for I := 0 to 63 do
      if PByte(P)[I] <> Byte(I) then
        LOk := False;
    {Writing over the whole new block would fault if the pointer were stale}
    FillChar(P^, 400000, $5A);
    FreeMem(P);
  end;
  Check(LOk, 'a moved block returns a usable pointer with the data preserved');
end;

{Grow and shrink within the space the block already has}
procedure TestReallocateInPlace;
var
  P, LFirst: Pointer;
  I, LStep: Integer;
  LOk, LStayed: Boolean;
begin
  Say('reallocation inside the existing block');
  GetMem(P, 100);
  for I := 0 to 99 do
    PByte(P)[I] := Byte(I);
  LFirst := P;
  LOk := True;
  LStayed := False;
  for LStep := 1 to 40 do
  begin
    ReallocMem(P, 100 + LStep * 8);
    if P = nil then
    begin
      LOk := False;
      Break;
    end;
    if P = LFirst then
      LStayed := True;
    for I := 0 to 99 do
      if PByte(P)[I] <> Byte(I) then
        LOk := False;
  end;
  if LOk then
  begin
    ReallocMem(P, 50);
    for I := 0 to 49 do
      if PByte(P)[I] <> Byte(I) then
        LOk := False;
    FreeMem(P);
  end;
  Check(LOk, '40 grows and a shrink keep the contents intact');
  Check(LStayed, 'at least one grow stayed in the same block');
end;

{Strings and dynamic arrays grow through the runtime rather than through
 GetMem, which is what reaches MemSize and the reallocation path}
procedure TestManagedTypes;
var
  S: AnsiString;
  A: array of Integer;
  I: Integer;
  LOk: Boolean;
begin
  Say('strings and dynamic arrays');
  S := '';
  for I := 1 to 1500 do
    S := S + 'abcdefghij';
  Check(Length(S) = 15000, 'an ansistring grown 1500 times has the right length');
  LOk := True;
  for I := 1 to Length(S) do
    {AnsiChar throughout: Chr returns the compiler's default character type,
     which is not AnsiChar on Delphi}
    if S[I] <> AnsiChar(Ord('a') + ((I - 1) mod 10)) then
      LOk := False;
  Check(LOk, 'the string contents are correct');
  SetLength(A, 0);
  for I := 1 to 3000 do
  begin
    SetLength(A, I);
    A[I - 1] := I;
  end;
  LOk := Length(A) = 3000;
  for I := 1 to 3000 do
    if A[I - 1] <> I then
      LOk := False;
  Check(LOk, 'a dynamic array grown 3000 times holds the right values');
  S := '';
  SetLength(A, 0);
end;

{$IFDEF FPC}
{The FreePascal memory manager record carries three entries that Delphi does
 not have. They were left nil under FullDebugMode, which killed the process the
 first time the runtime asked for the size of a block.}
procedure TestFreePascalManagerEntries;
var
  P: Pointer;
  I: Integer;
  LZeroed: Boolean;
begin
  Say('the FreePascal memory manager entries');
  P := AllocMem(256);
  Check(P <> nil, 'AllocMem returns a block');
  if P = nil then
    Exit;
  LZeroed := True;
  for I := 0 to 255 do
    if PByte(P)[I] <> 0 then
      LZeroed := False;
  Check(LZeroed, 'AllocMem zeroes the block');
  Check(MemSize(P) >= 256, 'MemSize reports at least the requested size');
  FreeMem(P, 256);
  Say('  ok    FreeMem with an explicit size returned');
end;
{$ENDIF}

{$IFDEF FullDebugModeIsActive}
{Repeat the allocation checks with the whole pool scanned before every
 operation, which is the most thorough setting FullDebugMode has}
procedure TestWithPoolScan;
begin
  Say('the same allocations with the memory pool scanned before every operation');
  FullDebugModeScanMemoryPoolBeforeEveryOperation := True;
  try
    TestReallocateInPlace;
  finally
    FullDebugModeScanMemoryPoolBeforeEveryOperation := False;
  end;
end;

{Write into a block after freeing it and confirm that the allocator notices
 when the block is handed out again}
function RunModifyAfterFreeCheck: Integer;
var
  P, Q: Pointer;
begin
  Say('modify after free detection');
  DeleteEventLog;
  GetMem(P, 128);
  FreeMem(P);
  PNativeUInt(P)^ := NativeUInt($DEADBEEF);
  PByte(P)[64] := $AA;
  GetMem(Q, 128);
  if Q <> nil then
    FreeMem(Q);
  if FileExists(EventLogFileName) then
  begin
    Say('  ok    the change was reported');
    Result := TEST_PASSED;
  end
  else
  begin
    Say('  FAIL  the change was not reported');
    Result := TEST_FAILED;
  end;
end;

{Overwrite the footer of a freed block and confirm that the allocator notices}
function RunCorruptFooterCheck: Integer;
const
  CSize = 128;
var
  P, Q: Pointer;
begin
  Say('corrupted footer detection');
  DeleteEventLog;
  GetMem(P, CSize);
  FreeMem(P);
  {The footer sits immediately after the user area of the block}
  PNativeUInt(PByte(P) + CSize)^ := NativeUInt($0BADF00D);
  GetMem(Q, CSize);
  if Q <> nil then
    FreeMem(Q);
  if FileExists(EventLogFileName) then
  begin
    Say('  ok    the damaged footer was reported');
    Result := TEST_PASSED;
  end
  else
  begin
    Say('  FAIL  the damaged footer was not reported');
    Result := TEST_FAILED;
  end;
end;
{$ENDIF}

var
  LMode: string;
begin
{$IFDEF FullDebugModeIsActive}
  Say('FullDebugMode is active');
{$ELSE}
  Say('FullDebugMode is not active in this build, the general checks still run');
{$ENDIF}

  LMode := '';
  if ParamCount > 0 then
    LMode := LowerCase(ParamStr(1));

  if LMode <> '' then
  begin
{$IFDEF FullDebugModeIsActive}
    if LMode = 'modify-after-free' then
      Halt(RunModifyAfterFreeCheck);
    if LMode = 'corrupt-footer' then
      Halt(RunCorruptFooterCheck);
    Say('unknown mode: ' + LMode);
    Halt(TEST_FAILED);
{$ELSE}
    Say('this mode needs FullDebugMode, skipping');
    Halt(TEST_PASSED);
{$ENDIF}
  end;

  TestAllocateFillFree;
  TestReallocateMoves;
  TestReallocateInPlace;
  TestManagedTypes;
{$IFDEF FPC}
  TestFreePascalManagerEntries;
{$ENDIF}
{$IFDEF FullDebugModeIsActive}
  TestWithPoolScan;
{$ENDIF}

  if GFailures = 0 then
  begin
    Say('all checks passed');
    Halt(TEST_PASSED);
  end
  else
  begin
    Say('failures: ' + IntToStr(GFailures));
    Halt(TEST_FAILED);
  end;
end.
