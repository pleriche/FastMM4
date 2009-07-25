unit BorlndMM_;

interface

{--------------------Start of options block-------------------------}

{Set the following option to use the RTL MM instead of FastMM. Setting this
 option makes this replacement DLL almost identical to the default
 borlndmm.dll, unless the "FullDebugMode" option is also set.}
{.$define UseRTLMM}

{--------------------End of options block-------------------------}

{$Include FastMM4Options.inc}

{Cannot use the RTL MM with full debug mode}
{$ifdef FullDebugMode}
  {$undef UseRTLMM}
{$endif}

{$OBJEXPORTALL OFF}

function GetAllocMemCount: integer;
function GetAllocMemSize: integer;
procedure DumpBlocks;
function HeapRelease: Integer;
function HeapAddRef: Integer;
function SysReallocMem(P: Pointer; Size: Integer): Pointer;
function SysFreeMem(P: Pointer): Integer;
function SysGetMem(Size: Integer): Pointer;
{$ifdef BDS2006AndUp}
function SysAllocMem(Size: Cardinal): Pointer;
{$endif}

function ReallocMemory(P: Pointer; Size: Integer): Pointer; cdecl;
function FreeMemory(P: Pointer): Integer; cdecl;
function GetMemory(Size: Integer): Pointer; cdecl;

function GetHeapStatus: THeapStatus;
{$ifdef BDS2006AndUp}
function RegisterExpectedMemoryLeak(ALeakedPointer: Pointer): Boolean;
function UnregisterExpectedMemoryLeak(ALeakedPointer: Pointer): Boolean;
{$endif}

implementation

{$ifndef UseRTLMM}
uses
  FastMM4;
{$endif}

{$OPTIMIZATION ON}
{$STACKFRAMES OFF}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

{$ifdef NoDebugInfo}
  {$DEBUGINFO OFF}
{$endif}

//Export: GetAllocMemCount
//Symbol: @Borlndmm@GetAllocMemCount$qqrv
function GetAllocMemCount: integer;
begin
  {Return stats for the RTL MM only}
{$ifdef UseRTLMM}
  Result := System.AllocMemCount;
{$else}
  Result := 0;
{$endif}
end;

//Export: GetAllocMemSize
//Symbol: @Borlndmm@GetAllocMemSize$qqrv
function GetAllocMemSize: integer;
begin
  {Return stats for the RTL MM only}
{$ifdef UseRTLMM}
  Result := System.AllocMemSize;
{$else}
  Result := 0;
{$endif}
end;

//Export: DumpBlocks
//Symbol: @Borlndmm@DumpBlocks$qqrv
procedure DumpBlocks;
begin
  {Do nothing}
end;

//Export: @Borlndmm@HeapRelease$qqrv
//Symbol: @Borlndmm@HeapRelease$qqrv
function HeapRelease: Integer;
begin
  {Do nothing}
  Result := 2;
end;

//Export: @Borlndmm@HeapAddRef$qqrv
//Symbol: @Borlndmm@HeapAddRef$qqrv
function HeapAddRef: Integer;
begin
  {Do nothing}
  Result := 2;
end;

//Export: GetHeapStatus
//Symbol: @Borlndmm@GetHeapStatus$qqrv
function GetHeapStatus: THeapStatus;
begin
{$ifndef UseRTLMM}
  Result := FastGetHeapStatus;
{$else}
  Result := System.GetHeapStatus;
{$endif}
end;


//Export: ReallocMemory
//Symbol: @Borlndmm@ReallocMemory$qpvi
function ReallocMemory(P: Pointer; Size: Integer): Pointer; cdecl;
begin
  Result := System.ReallocMemory(P, Size);
end;

//Export: FreeMemory
//Symbol: @Borlndmm@FreeMemory$qpv
function FreeMemory(P: Pointer): Integer; cdecl;
begin
  Result := System.FreeMemory(P);
end;

//Export: GetMemory
//Symbol: @Borlndmm@GetMemory$qi
function GetMemory(Size: Integer): Pointer; cdecl;
begin
  Result := System.GetMemory(Size);
end;


//Export: @Borlndmm@SysReallocMem$qqrpvi
//Symbol: @Borlndmm@SysReallocMem$qqrpvi
function SysReallocMem(P: Pointer; Size: Integer): Pointer;
begin
{$ifndef UseRTLMM}
  {$ifndef FullDebugMode}
  Result := FastReallocMem(P, Size);
  {$else}
  Result := DebugReallocMem(P, Size);
  {$endif}
{$else}
  Result := System.SysReallocMem(P, Size);
{$endif}
end;

//Export: @Borlndmm@SysFreeMem$qqrpv
//Symbol: @Borlndmm@SysFreeMem$qqrpv
function SysFreeMem(P: Pointer): Integer;
begin
{$ifndef UseRTLMM}
  {$ifndef FullDebugMode}
  Result := FastFreeMem(P);
  {$else}
  Result := DebugFreeMem(P);
  {$endif}
{$else}
  Result := System.SysFreeMem(P);
{$endif}
end;

//Export: @Borlndmm@SysGetMem$qqri
//Symbol: @Borlndmm@SysGetMem$qqri
function SysGetMem(Size: Integer): Pointer;
begin
{$ifndef UseRTLMM}
  {$ifndef FullDebugMode}
  Result := FastGetMem(Size);
  {$else}
  Result := DebugGetMem(Size);
  {$endif}
{$else}
  Result := System.SysGetMem(Size);
{$endif}
end;

//Export: @Borlndmm@SysAllocMem$qqri
//Symbol: @Borlndmm@SysAllocMem$qqrui
function SysAllocMem(Size: Cardinal): Pointer;
begin
{$ifndef UseRTLMM}
  {$ifndef FullDebugMode}
  Result := FastAllocMem(Size);
  {$else}
  Result := DebugAllocMem(Size);
  {$endif}
{$else}
  //{$ifdef VER180}
  {$if RTLVersion >= 18}
  Result := System.SysAllocMem(Size);
  {$ifend}
  {$if RTLVersion < 18}
  Result := System.AllocMem(Size);
  {$ifend}
{$endif}
end;


//Export: @Borlndmm@SysUnregisterExpectedMemoryLeak$qqrpi
//Symbol: @Borlndmm@UnregisterExpectedMemoryLeak$qqrpv
function UnregisterExpectedMemoryLeak(ALeakedPointer: Pointer): Boolean;
begin
{$ifndef UseRTLMM}
  {$ifdef EnableMemoryLeakReporting}
  Result := UnregisterExpectedMemoryLeak(ALeakedPointer);
  {$else}
  Result := False;
  {$endif}
{$else}
  //{$ifdef VER180}
  {$if RTLVersion >= 18}
  Result := System.SysUnregisterExpectedMemoryLeak(ALeakedPointer);
  {$ifend}
  {$if RTLVersion < 18}
  Result := False;
  {$ifend}
{$endif} 
end;

//Export: @Borlndmm@SysRegisterExpectedMemoryLeak$qqrpi
//Symbol: @Borlndmm@RegisterExpectedMemoryLeak$qqrpv
function RegisterExpectedMemoryLeak(ALeakedPointer: Pointer): Boolean;
begin
{$ifndef UseRTLMM}
  {$ifdef EnableMemoryLeakReporting}
  Result := RegisterExpectedMemoryLeak(ALeakedPointer);
  {$else}
  Result := False;
  {$endif}
{$else}
  //{$ifdef VER180}
  {$if RTLVersion >= 18}
  Result := System.SysRegisterExpectedMemoryLeak(ALeakedPointer);
  {$ifend}
  {$if RTLVersion < 18}
  Result := False;
  {$ifend}
{$endif}
end;

initialization
  IsMultiThread := True;
finalization
end.
