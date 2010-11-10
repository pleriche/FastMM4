{

Fast Memory Manager: Replacement BorlndMM.DLL 1.05

Description:
 A replacement borlndmm.dll using FastMM instead of the RTL MM. This DLL may be
 used instead of the default DLL together with your own applications or the
 Delphi IDE, making the benefits of FastMM available to them.

Usage:
 1) Make sure the "NeverUninstall" conditional define is set in FastMM4.pas if
 you intend to use the DLL with the Delphi IDE, otherwise it must be off.
 2) Compile this DLL
 3) Ship it with your existing applications that currently uses the borlndmm.dll
 file that ships with Delphi for an improvement in speed.
 4) Copy it over the current borlndmm.dll in the Delphi \Bin\ directory (after
 renaming the old one) to speed up the IDE.*

Acknowledgements:
  - Arthur Hoornweg for notifying me of the image base being incorrect for
    borlndmm.dll.
  - Cord Schneider for notifying me of the compilation error under Delphi 5.

Change log:
 Version 1.00 (28 June 2005):
  - Initial release.
 Version 1.01 (30 June 2005):
  - Added an unofficial patch for QC#14007 that prevented a replacement
    borlndmm.dll from working together with Delphi 2005.
  - Added the "NeverUninstall" option in FastMM4.pas to circumvent QC#14070,
    which causes an A/V on shutdown of Delphi if FastMM uninstalls itself in the
    finalization code of FastMM4.pas.
  Version 1.02 (19 July 2005):
  - Set the imagebase to $00D20000 to avoid relocation on load (and thus allow
    sharing of the DLL between processes). (Thanks to Arthur Hoornweg.)
  Version 1.03 (10 November 2005):
  - Added exports for AllocMem and leak (un)registration
  Version 1.04 (22 December 2005):
  - Fixed the compilation error under Delphi 5. (Thanks to Cord Schneider.)
  Version 1.05 (23 February 2006):
  - Added some exports to allow access to the extended FullDebugMode
    functionality in FastMM.

*For this replacement borlndmm.dll to work together with Delphi 2005, you will
 need to apply the unofficial patch for QC#14007. To compile a replacement
 borlndmm.dll for use with the Delphi IDE the "NeverUninstall" option must be
 set (to circumvent QC#14070). For other uses the "NeverUninstall" option
 should be disabled. For a list of unofficial patches for Delphi 2005 (and
 where to get them), refer to the FastMM4_Readme.txt file.

}

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

{Set the correct image base}
{$IMAGEBASE $00D20000}

library BorlndMM;

{$ifndef UseRTLMM}
uses
  FastMM4 in 'FastMM4.pas',
  FastMM4Messages in 'FastMM4Messages.pas';

{$endif}

{$R *.RES}

function GetAllocMemCount: integer;
begin
  {Return stats for the RTL MM only}
{$ifdef UseRTLMM}
  Result := System.AllocMemCount;
{$else}
  Result := 0;
{$endif}
end;

function GetAllocMemSize: integer;
begin
  {Return stats for the RTL MM only}
{$ifdef UseRTLMM}
  Result := System.AllocMemSize;
{$else}
  Result := 0;
{$endif}
end;

procedure DumpBlocks;
begin
  {Do nothing}
end;

function HeapRelease: Integer;
begin
  {Do nothing}
  Result := 2;
end;

function HeapAddRef: Integer;
begin
  {Do nothing}
  Result := 2;
end;

function DummyRegisterAndUnregisterExpectedMemoryLeak(ALeakedPointer: Pointer): boolean;
begin
  Result := False;
end;

exports
  GetAllocMemSize name 'GetAllocMemSize',
  GetAllocMemCount name 'GetAllocMemCount',
{$ifndef UseRTLMM}
  FastGetHeapStatus name 'GetHeapStatus',
{$else}
  System.GetHeapStatus name 'GetHeapStatus',
{$endif}
  DumpBlocks name 'DumpBlocks',
  System.ReallocMemory name 'ReallocMemory',
  System.FreeMemory name 'FreeMemory',
  System.GetMemory name 'GetMemory',
{$ifndef UseRTLMM}
  {$ifndef FullDebugMode}
  FastReallocMem name '@Borlndmm@SysReallocMem$qqrpvi',
  FastFreeMem name '@Borlndmm@SysFreeMem$qqrpv',
  FastGetMem name '@Borlndmm@SysGetMem$qqri',
  FastAllocMem name '@Borlndmm@SysAllocMem$qqri',
  {$else}
  DebugReallocMem name '@Borlndmm@SysReallocMem$qqrpvi',
  DebugFreeMem name '@Borlndmm@SysFreeMem$qqrpv',
  DebugGetMem name '@Borlndmm@SysGetMem$qqri',
  DebugAllocMem name '@Borlndmm@SysAllocMem$qqri',
  {$endif}
  {$ifdef EnableMemoryLeakReporting}
  RegisterExpectedMemoryLeak(ALeakedPointer: Pointer) name '@Borlndmm@SysRegisterExpectedMemoryLeak$qqrpi',
  UnregisterExpectedMemoryLeak(ALeakedPointer: Pointer) name '@Borlndmm@SysUnregisterExpectedMemoryLeak$qqrpi',
  {$else}
  DummyRegisterAndUnregisterExpectedMemoryLeak name '@Borlndmm@SysRegisterExpectedMemoryLeak$qqrpi',
  DummyRegisterAndUnregisterExpectedMemoryLeak name '@Borlndmm@SysUnregisterExpectedMemoryLeak$qqrpi',
  {$endif}
{$else}
  System.SysReallocMem name '@Borlndmm@SysReallocMem$qqrpvi',
  System.SysFreeMem name '@Borlndmm@SysFreeMem$qqrpv',
  System.SysGetMem name '@Borlndmm@SysGetMem$qqri',
  {$ifdef VER180};
  System.SysAllocMem name '@Borlndmm@SysAllocMem$qqri',
  System.SysRegisterExpectedMemoryLeak name '@Borlndmm@SysRegisterExpectedMemoryLeak$qqrpi',
  System.SysUnregisterExpectedMemoryLeak name '@Borlndmm@SysUnregisterExpectedMemoryLeak$qqrpi',
  {$else}
  System.AllocMem name '@Borlndmm@SysAllocMem$qqri',
  DummyRegisterAndUnregisterExpectedMemoryLeak name '@Borlndmm@SysRegisterExpectedMemoryLeak$qqrpi',
  DummyRegisterAndUnregisterExpectedMemoryLeak name '@Borlndmm@SysUnregisterExpectedMemoryLeak$qqrpi',
  {$endif}
{$endif}
  {$ifdef FullDebugMode}
  SetMMLogFileName,
  GetCurrentAllocationGroup,
  PushAllocationGroup,
  PopAllocationGroup,
  LogAllocatedBlocksToFile,
  {$endif}
  HeapRelease name '@Borlndmm@HeapRelease$qqrv',
  HeapAddRef name '@Borlndmm@HeapAddRef$qqrv';

begin
  IsMultiThread := True;
end.
