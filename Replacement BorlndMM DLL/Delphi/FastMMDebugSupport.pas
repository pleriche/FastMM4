{

Fast Memory Manager: FullDebugMode Borlndmm.dll support unit

If you use the replacement Borlndmm.dll compiled in FullDebugMode, and you need
 access to some of the extended functionality that is not imported by
 sharemem.pas, then you may use this unit to get access to it. Please note that
 you will still need to add sharemem.pas as the first unit in the "uses"
 section of the .dpr, and the FastMM_FullDebugMode.dll must be available on the
 path. Also, the borlndmm.dll that you will be using *must* be compiled using
 FullDebugMode.}

unit FastMMDebugSupport;

interface

{Specify the full path and name for the filename to be used for logging memory
 errors, etc. If ALogFileName is nil or points to an empty string it will
 revert to the default log file name.}
procedure SetMMLogFileName(ALogFileName: PAnsiChar = nil);
{Returns the current "allocation group". Whenever a GetMem request is serviced
 in FullDebugMode, the current "allocation group" is stored in the block header.
 This may help with debugging. Note that if a block is subsequently reallocated
 that it keeps its original "allocation group" and "allocation number" (all
 allocations are also numbered sequentially).}
function GetCurrentAllocationGroup: Cardinal;
{Allocation groups work in a stack like fashion. Group numbers are pushed onto
 and popped off the stack. Note that the stack size is limited, so every push
 should have a matching pop.}
procedure PushAllocationGroup(ANewCurrentAllocationGroup: Cardinal);
procedure PopAllocationGroup;
{Logs detail about currently allocated memory blocks for the specified range of
 allocation groups. if ALastAllocationGroupToLog is less than
 AFirstAllocationGroupToLog or it is zero, then all allocation groups are
 logged. This routine also checks the memory pool for consistency at the same
 time.}
procedure LogAllocatedBlocksToFile(AFirstAllocationGroupToLog, ALastAllocationGroupToLog: Cardinal);

implementation

const
  borlndmm = 'borlndmm.dll';

procedure SetMMLogFileName; external borlndmm;
function GetCurrentAllocationGroup; external borlndmm;
procedure PushAllocationGroup; external borlndmm;
procedure PopAllocationGroup; external borlndmm;
procedure LogAllocatedBlocksToFile; external borlndmm;

end.
