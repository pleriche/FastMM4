(*

Fast Memory Manager Usage Tracker 2.00

Description:

 - Shows FastMM4 allocation usage

 - Shows VM Memory in graphical map
    - Free
    - Commit
    - Reserved
    - EXE (Red)
    - DLLs (Blue)

 - VM Dump of the whole process
   (2GB standard, 3GB with the /3G switch set, and 4GB under WoW64)

 - General Information
    - System memory usage
    - Process memory usage
    - 5 Largest contiguous free VM memory spaces
    - FastMM4 summary information

Usage:
  - Add the FastMMUsageTracker unit
  - Add the ShowFastMMUsageTracker procedure to an event
  - FastMMUsageTracker form should not be autocreated

Notes:
  - Consider setting the base adress of your BPLs & DLLs or use Microsoft's
    ReBase.exe to set third party BPLs and DLLs. Libraries that do not have to
    be relocated can be shared across processes, thus conserving system
    resources.
  - The first of the "Largest contiguous free VM memory spaces" gives you an
    indication of the largest single memory block that can be allocated.

Change log:

  Version 2.00 (24 April 2008):
  - New usage tracker implemented by Hanspeter Widmer with many new features.
    (Thanks Hanspeter!);

*)

unit FastMMUsageTracker;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, Buttons, ComCtrls, Menus, FastMM4;

type
  TChunkStatusEx = (
    {Items that correspond to the same entry in TChunkStatus}
    csExUnallocated,
    csExAllocated,
    csExReserved,
    csExSysAllocated,
    csExSysReserved,
    {TChunkStatusEx additional detail}
    csExSysExe,
    csExSysDLL);

  TMemoryMapEx = array[0..65535] of TChunkStatusEx;

  TfFastMMUsageTracker = class(TForm)
    tTimer: TTimer;
    bClose: TBitBtn;
    bUpdate: TBitBtn;
    ChkAutoUpdate: TCheckBox;
    smVMDump: TPopupMenu;
    smMM4Allocation: TPopupMenu;
    smGeneralInformation: TPopupMenu;
    miVMDumpCopyAlltoClipboard: TMenuItem;
    miGeneralInformationCopyAlltoClipboard: TMenuItem;
    siMM4AllocationCopyAlltoClipboard: TMenuItem;
    pcUsageTracker: TPageControl;
    tsAllocation: TTabSheet;
    tsVMGraph: TTabSheet;
    tsVMDump: TTabSheet;
    tsGeneralInformation: TTabSheet;
    mVMStatistics: TMemo;
    sgVMDump: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    eAddress: TEdit;
    eState: TEdit;
    eDLLName: TEdit;
    ChkSmallGraph: TCheckBox;
    sgBlockStatistics: TStringGrid;
    dgMemoryMap: TDrawGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bCloseClick(Sender: TObject);
    procedure dgMemoryMapDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure dgMemoryMapSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure bUpdateClick(Sender: TObject);
    procedure ChkAutoUpdateClick(Sender: TObject);
    procedure ChkSmallGraphClick(Sender: TObject);
    procedure sgVMDumpMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgVMDumpMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgVMDumpDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure miVMDumpCopyAlltoClipboardClick(Sender: TObject);
    procedure miGeneralInformationCopyAlltoClipboardClick(Sender: TObject);
    procedure siMM4AllocationCopyAlltoClipboardClick(Sender: TObject);
  private
    {The current state}
    FMemoryManagerState: TMemoryManagerState;
    FMemoryMapEx: TMemoryMapEx;

    AddressSpacePageCount: Integer;

    OR_VMDumpDownCell: TGridCoord;

    procedure HeaderClicked(AGrid: TStringgrid; const ACell: TGridCoord);
    procedure SortGrid(grid: TStringgrid; PB_Nummeric: Boolean; byColumn: Integer; ascending: Boolean);

    procedure UpdateGraphMetrics;


  public
    {Refreshes the display}
    procedure RefreshSnapShot;
  end;

function ShowFastMMUsageTracker: TfFastMMUsageTracker;

implementation

uses
  Clipbrd, PsAPI;

{$R *.dfm}

const
  SystemBasicInformation = 0;
  SystemPerformanceInformation = 2;
  SystemTimeInformation = 3;


type
  {To get access to protected methods}
  TLocalStringGrid = class(TStringGrid);

  TMemoryStatusEx = packed record
    dwLength: DWORD;
    dwMemoryLoad: DWORD;
    ullTotalPhys: Int64;
    ullAvailPhys: Int64;
    ullTotalPageFile: Int64;
    ullAvailPageFile: Int64;
    ullTotalVirtual: Int64;
    ullAvailVirtual: Int64;
    ullAvailExtendedVirtual: Int64;
  end;
  PMemoryStatusEx = ^TMemoryStatusEx;
  LPMEMORYSTATUSEX = PMemoryStatusEx;

  TP_GlobalMemoryStatusEx = function(
    var PR_MemStatusEx: TMemoryStatusEx): LongBool; stdcall;

  TSystem_Basic_Information = packed record
    dwUnknown1: DWORD;
    uKeMaximumIncrement: ULONG;
    uPageSize: ULONG;
    uMmNumberOfPhysicalPages: ULONG;
    uMmLowestPhysicalPage: ULONG;
    uMmHighestPhysicalPage: ULONG;
    uAllocationGranularity: ULONG;
    pLowestUserAddress: Pointer;
    pMmHighestUserAddress: Pointer;
    uKeActiveProcessors: ULONG;
    bKeNumberProcessors: Byte;
    bUnknown2: Byte;
    wUnknown3: Word;
  end;

  TSystem_Performance_Information = packed record
    liIdleTime: LARGE_INTEGER;
    dwSpare: array[0..75] of DWORD;
  end;

  TSystem_Time_Information = packed record
    liKeBootTime: LARGE_INTEGER;
    liKeSystemTime: LARGE_INTEGER;
    liExpTimeZoneBias: LARGE_INTEGER;
    uCurrentTimeZoneId: ULONG;
    dwReserved: DWORD;
  end;

  TP_NtQuerySystemInformation = function(InfoClass: DWORD; Buffer: Pointer;
    BufSize: DWORD; ReturnSize: PCardinal): DWORD; stdcall;

var
  MP_GlobalMemoryStatusEx: TP_GlobalMemoryStatusEx = nil;
  MP_NtQuerySystemInformation: TP_NtQuerySystemInformation = nil;

//-----------------------------------------------------------------------------
// Various Global Procedures
//-----------------------------------------------------------------------------

function ShowFastMMUsageTracker: TfFastMMUsageTracker;
begin
  Application.CreateForm(TfFastMMUsageTracker, Result);
  if Assigned(Result) then
  begin
    Result.RefreshSnapShot;
    Result.Show;
  end;
end;

function CardinalToStringFormatted(const ACardinal: Cardinal): string;
begin
  Result := FormatFloat('#,##0', ACardinal);
end;

function Int64ToStringFormatted(const AInt64: Int64): string;
begin
  Result := FormatFloat('#,##0', AInt64);
end;

function CardinalToKStringFormatted(const ACardinal: Cardinal): string;
begin
  Result := FormatFloat('#,##0', ACardinal div 1024) + 'K';
end;

function Int64ToKStringFormatted(const AInt64: Int64): string;
begin
  Result := FormatFloat('#,##0', AInt64 div 1024) + 'K';
end;

procedure CopyGridContentsToClipBoard(AStringGrid: TStringGrid);
const
  TAB = Chr(VK_TAB);
  CRLF = #13#10;
var
  LI_r, LI_c: Integer;
  LS_S: string;
begin
  LS_S := '';
  for LI_r := 0 to AStringGrid.RowCount - 1 do
  begin
    for LI_c := 0 to AStringGrid.ColCount - 1 do
    begin
      LS_S := LS_S + AStringGrid.Cells[LI_c, LI_r];
      if LI_c < AStringGrid.ColCount - 1 then
        LS_S := LS_S + TAB;
    end;
    if LI_r < AStringGrid.RowCount - 1 then
      LS_S := LS_S + CRLF;
  end;
  ClipBoard.SetTextBuf(PChar(LS_S));
end;

//-----------------------------------------------------------------------------
// Form TfFastMMUsageTracker
//-----------------------------------------------------------------------------

procedure TfFastMMUsageTracker.FormCreate(Sender: TObject);
var
  LR_SystemInfo: TSystemInfo;
begin
  pcUsageTracker.ActivePage := tsAllocation;
  GetSystemInfo(LR_SystemInfo);
  {Get the number of address space pages}
  if (Cardinal(LR_SystemInfo.lpMaximumApplicationAddress) and $80000000) = 0 then
    AddressSpacePageCount := 32768
  else
    AddressSpacePageCount := 65536;
  {Update the graph metricx}
  UpdateGraphMetrics;
  {Set up the StringGrid columns}
  with sgBlockStatistics do
  begin
    Cells[0, 0] := 'Block Size';
    Cells[1, 0] := '# Live Pointers';
    Cells[2, 0] := 'Live Size';
    Cells[3, 0] := 'Used Space';
    Cells[4, 0] := 'Efficiency';
  end;
  with sgVMDump do
  begin
    Cells[0, 0] := 'VM Block';
    Cells[1, 0] := 'Size';
    Cells[2, 0] := 'Type';
    Cells[3, 0] := 'State';
    Cells[4, 0] := 'EXE/DLL';
  end;
end;

procedure TfFastMMUsageTracker.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfFastMMUsageTracker.SortGrid(grid: TStringgrid; PB_Nummeric: Boolean; byColumn: Integer; ascending: Boolean);

  function CompareNumeric(const S1, S2: string): Integer;
  var
    LVal1, LVal2: Integer;
  begin
    begin
      LVal1 := StrToInt(S1);
      LVal2 := StrToInt(S2);
      if LVal1 = LVal2 then
      begin
        Result := 0;
      end
      else
      begin
        if LVal1 > LVal2 then
          Result := 1
        else
          Result := -1;
      end;
    end;
  end;

  procedure ExchangeGridRows(i, j: Integer);
  var
    k: Integer;
  begin
    for k := 0 to Grid.ColCount - 1 do
      Grid.Cols[k].Exchange(i, j);
  end;

  procedure QuickSortNummeric(L, R: Integer);
  var
    I, J: Integer;
    P: string;
  begin
    repeat
      I := L;
      J := R;
      P := Grid.Cells[byColumn, (L + R) shr 1];
      repeat
        while CompareNumeric(Grid.Cells[byColumn, I], P) < 0 do
          Inc(I);
        while CompareNumeric(Grid.Cells[byColumn, J], P) > 0 do
          Dec(J);
        if I <= J then
        begin
          if I <> J then
            ExchangeGridRows(I, J);
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        QuickSortNummeric(L, J);
      L := I;
    until I >= R;
  end;

  procedure QuickSortString(L, R: Integer);
  var
    I, J: Integer;
    P: string;
  begin
    repeat
      I := L;
      J := R;
      P := Grid.Cells[byColumn, (L + R) shr 1];
      repeat
        while CompareText(Grid.Cells[byColumn, I], P) < 0 do
          Inc(I);
        while CompareText(Grid.Cells[byColumn, J], P) > 0 do
          Dec(J);
        if I <= J then
        begin
          if I <> J then
            ExchangeGridRows(I, J);
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        QuickSortString(L, J);
      L := I;
    until I >= R;
  end;

  procedure InvertGrid;
  var
    i, j: Integer;
  begin
    i := Grid.Fixedrows;
    j := Grid.Rowcount - 1;
    while i < j do
    begin
      ExchangeGridRows(I, J);
      Inc(i);
      Dec(j);
    end;
  end;

begin
  Screen.Cursor := crHourglass;
  Grid.Perform(WM_SETREDRAW, 0, 0);
  try
    if PB_Nummeric then
      QuickSortNummeric(Grid.FixedRows, Grid.Rowcount - 1)
    else
      QuickSortString(Grid.FixedRows, Grid.Rowcount - 1);
    if not Ascending then
      InvertGrid;
  finally
    Grid.Perform(WM_SETREDRAW, 1, 0);
    Grid.Refresh;
    Screen.Cursor := crDefault;
  end;
end;


procedure TfFastMMUsageTracker.HeaderClicked(AGrid: TStringgrid; const ACell: TGridCoord);
var
  i: Integer;
  LNumericSort: Boolean;
begin
  // The header cell stores a flag in the Objects property that signals the
  // current sort order of the grid column. A value of 0 shows no sort marker,
  // 1 means sorted ascending, -1 sorted descending
  // clear markers
  for i := AGrid.FixedCols to AGrid.ColCount - 1 do
  begin
    if Assigned(AGrid.Objects[i, 0]) and (i <> ACell.x) then
    begin
      AGrid.Objects[i, 0] := nil;
      TLocalStringGrid(AGrid).InvalidateCell(i, 0);
    end;
  end;
  // Sort grid on new column. If grid is currently sorted ascending on this
  // column we invert the sort direction, otherwise we sort it ascending.
  if ACell.X = 1 then
    LNumericSort := True
  else
    LNumericSort := False;
  if Integer(AGrid.Objects[ACell.x, ACell.y]) = 1 then
  begin
    SortGrid(AGrid, LNumericSort, ACell.x, False);
    AGrid.Objects[ACell.x, 0] := Pointer(-1);
  end
  else
  begin
    SortGrid(AGrid, LNumericSort, ACell.x, True);
    AGrid.Objects[ACell.x, 0] := Pointer(1);
  end;
  TLocalStringGrid(AGrid).InvalidateCell(ACell.x, ACell.y);
end;

procedure TfFastMMUsageTracker.UpdateGraphMetrics;
begin
  if ChkSmallGraph.Checked then
  begin
    dgMemoryMap.DefaultColWidth := 4;
    dgMemoryMap.ColCount := 128;
  end
  else
  begin
    dgMemoryMap.DefaultColWidth := 8;
    dgMemoryMap.ColCount := 64;
  end;
  dgMemoryMap.DefaultRowHeight := dgMemoryMap.DefaultColWidth;
  dgMemoryMap.RowCount := AddressSpacePageCount div dgMemoryMap.ColCount;
end;

procedure TfFastMMUsageTracker.RefreshSnapShot;
var
  LP_FreeVMList: TList;
  LU_MEM_FREE: DWord;
  LU_MEM_COMMIT: DWord;
  LU_MEM_RESERVE: DWord;
  LAllocatedSize, LTotalBlocks, LTotalAllocated, LTotalReserved: Cardinal;

  procedure UpdateVMGraph(var AMemoryMap: TMemoryMapEx);
  var
    LInd, LIndTop, I1: Integer;
    LChunkState: TChunkStatusEx;
    LMBI: TMemoryBasicInformation;
    LA_Char: array[0..MAX_PATH] of Char;
  begin
    LInd := 0;
    repeat
      {If the chunk is not allocated by this MM, what is its status?}
      if AMemoryMap[LInd] = csExSysAllocated then
      begin
        {Get all the reserved memory blocks and windows allocated memory blocks, etc.}
        VirtualQuery(Pointer(LInd * 65536), LMBI, SizeOf(LMBI));
        if LMBI.State = MEM_COMMIT then
        begin
          if (GetModuleFileName(DWord(LMBI.AllocationBase), LA_Char, MAX_PATH) <> 0) then
          begin
            if DWord(LMBI.AllocationBase) = SysInit.HInstance then
              LChunkState := csExSysExe
            else
              LChunkState := csExSysDLL;
          end
          else
          begin
            LChunkState := csExSysAllocated;
          end;
          if LMBI.RegionSize > 65536 then
          begin
            LIndTop := (Cardinal(LMBI.BaseAddress) + Cardinal(LMBI.RegionSize)) div 65536;
            // Fill up multiple tables
            for I1 := LInd to LIndTop do
              AMemoryMap[I1] := LChunkState;
            LInd := LIndTop;
          end
          else
          begin
            AMemoryMap[LInd] := LChunkState;
          end;
        end
      end;
      Inc(LInd);
    until LInd >= AddressSpacePageCount;
  end;

  procedure UpdateVMDump;
  var
    LP_Base: PByte;
    LR_Info: TMemoryBasicInformation;
    LU_rv: DWORD;
    LI_I: Integer;
    LA_Char: array[0..MAX_PATH] of Char;
  begin
    LP_Base := nil;
    LU_rv := VirtualQuery(LP_Base, LR_Info, sizeof(LR_Info));
    LI_I := 1;
    while LU_rv = sizeof(LR_Info) do
    begin
      with sgVMDump do
      begin
        Cells[0, LI_I] := IntToHex(Integer(LR_Info.BaseAddress), 8);
        Cells[1, LI_I] := IntToStr(LR_Info.RegionSize);
        Cells[3, LI_I] := IntToHex(Integer(LR_Info.Protect), 8);
        case LR_Info.State of

          MEM_Commit:
            begin
              LU_MEM_COMMIT := LU_MEM_COMMIT + LR_Info.RegionSize;
              if (GetModuleFileName(dword(LR_Info.AllocationBase), LA_Char, MAX_PATH) <> 0) then
              begin
                if DWord(LR_Info.AllocationBase) = SysInit.HInstance then
                  Cells[2, LI_I] := 'Exe'
                else
                  Cells[2, LI_I] := 'DLL';
                Cells[4, LI_I] := ExtractFileName(LA_Char);
              end
              else
              begin
                Cells[4, LI_I] := '';
                Cells[2, LI_I] := 'Commited';
              end;
            end;

          MEM_RESERVE:
            begin
              LU_MEM_RESERVE := LU_MEM_RESERVE + LR_Info.RegionSize;
              Cells[2, LI_I] := 'Reserved';
              Cells[4, LI_I] := '';
            end;

          MEM_FREE:
            begin
              LP_FreeVMList.Add(Pointer(LR_Info.RegionSize));
              LU_MEM_FREE := LU_MEM_FREE + Lr_Info.RegionSize;
              Cells[2, LI_I] := 'Free';
              Cells[4, LI_I] := '';
            end;
        end;

        Inc(LP_Base, LR_Info.RegionSize);
        LU_rv := VirtualQuery(LP_Base, LR_Info, sizeof(LR_Info));
        Inc(LI_I);
      end;
    end;

    sgVMDump.RowCount := LI_I;
  end;


  procedure UpdateFastMM4Data;
  var
    LInd: Integer;
    LU_StateLength: Cardinal;
  begin
    LU_StateLength := Length(FMemoryManagerState.SmallBlockTypeStates);
    {Set up the row count}
    sgBlockStatistics.RowCount := LU_StateLength + 4;
    sgBlockStatistics.Cells[0, LU_StateLength + 1] := 'Medium Blocks';
    sgBlockStatistics.Cells[0, LU_StateLength + 2] := 'Large Blocks';
    sgBlockStatistics.Cells[0, LU_StateLength + 3] := 'Overall';
    for LInd := 0 to High(FMemoryManagerState.SmallBlockTypeStates) do
    begin
      sgBlockStatistics.Cells[0, LInd + 1] :=
        IntToStr(FMemoryManagerState.SmallBlockTypeStates[LInd].InternalBlockSize)
        + '(' + IntToStr(FMemoryManagerState.SmallBlockTypeStates[LInd].UseableBlockSize) + ')';
    end;
    {Set the texts inside the results string grid}
    for LInd := 0 to High(FMemoryManagerState.SmallBlockTypeStates) do
    begin
      with FMemoryManagerState.SmallBlockTypeStates[LInd] do
      begin
        sgBlockStatistics.Cells[1, LInd + 1] := IntToStr(AllocatedBlockCount);
        Inc(LTotalBlocks, AllocatedBlockCount);
        LAllocatedSize := AllocatedBlockCount * UseableBlockSize;
        sgBlockStatistics.Cells[2, LInd + 1] := IntToStr(LAllocatedSize);
        Inc(LTotalAllocated, LAllocatedSize);
        sgBlockStatistics.Cells[3, LInd + 1] := IntToStr(ReservedAddressSpace);
        Inc(LTotalReserved, ReservedAddressSpace);
        if ReservedAddressSpace > 0 then
          sgBlockStatistics.Cells[4, LInd + 1] := FormatFloat('0.##%', LAllocatedSize / ReservedAddressSpace * 100)
        else
          sgBlockStatistics.Cells[4, LInd + 1] := 'N/A';
      end;
    end;
    {Medium blocks}
    LInd := length(FMemoryManagerState.SmallBlockTypeStates) + 1;
    sgBlockStatistics.Cells[1, LInd] := IntToStr(FMemoryManagerState.AllocatedMediumBlockCount);
    Inc(LTotalBlocks, FMemoryManagerState.AllocatedMediumBlockCount);
    sgBlockStatistics.Cells[2, LInd] := IntToStr(FMemoryManagerState.TotalAllocatedMediumBlockSize);
    Inc(LTotalAllocated, FMemoryManagerState.TotalAllocatedMediumBlockSize);
    sgBlockStatistics.Cells[3, LInd] := IntToStr(FMemoryManagerState.ReservedMediumBlockAddressSpace);
    Inc(LTotalReserved, FMemoryManagerState.ReservedMediumBlockAddressSpace);
    if FMemoryManagerState.ReservedMediumBlockAddressSpace > 0 then
      sgBlockStatistics.Cells[4, LInd] := FormatFloat('0.##%', FMemoryManagerState.TotalAllocatedMediumBlockSize / FMemoryManagerState.ReservedMediumBlockAddressSpace * 100)
    else
      sgBlockStatistics.Cells[4, LInd] := 'N/A';
    {Large blocks}
    LInd := length(FMemoryManagerState.SmallBlockTypeStates) + 2;
    sgBlockStatistics.Cells[1, LInd] := IntToStr(FMemoryManagerState.AllocatedLargeBlockCount);
    Inc(LTotalBlocks, FMemoryManagerState.AllocatedLargeBlockCount);
    sgBlockStatistics.Cells[2, LInd] := IntToStr(FMemoryManagerState.TotalAllocatedLargeBlockSize);
    Inc(LTotalAllocated, FMemoryManagerState.TotalAllocatedLargeBlockSize);
    sgBlockStatistics.Cells[3, LInd] := IntToStr(FMemoryManagerState.ReservedLargeBlockAddressSpace);
    Inc(LTotalReserved, FMemoryManagerState.ReservedLargeBlockAddressSpace);
    if FMemoryManagerState.ReservedLargeBlockAddressSpace > 0 then
      sgBlockStatistics.Cells[4, LInd] := FormatFloat('0.##%', FMemoryManagerState.TotalAllocatedLargeBlockSize / FMemoryManagerState.ReservedLargeBlockAddressSpace * 100)
    else
      sgBlockStatistics.Cells[4, LInd] := 'N/A';
    {Overall}
    LInd := length(FMemoryManagerState.SmallBlockTypeStates) + 3;
    sgBlockStatistics.Cells[1, LInd] := IntToStr(LTotalBlocks);
    sgBlockStatistics.Cells[2, LInd] := IntToStr(LTotalAllocated);
    sgBlockStatistics.Cells[3, LInd] := IntToStr(LTotalReserved);
    if LTotalReserved > 0 then
      sgBlockStatistics.Cells[4, LInd] := FormatFloat('0.##%', LTotalAllocated / LTotalReserved * 100)
    else
      sgBlockStatistics.Cells[4, LInd] := 'N/A';
  end;

  procedure UpdateStatisticsData;

    function LocSort(P1, P2: Pointer): Integer;
    begin
      if Cardinal(P1) = Cardinal(P2) then
        Result := 0
      else
      begin
        if Cardinal(P1) > Cardinal(P2) then
          Result := -1
        else
          Result := 1;
      end;
    end;

  const
    CI_MaxFreeBlocksList = 9;

  var
    LR_SystemInfo: TSystemInfo;
    LR_GlobalMemoryStatus: TMemoryStatus;
    LR_GlobalMemoryStatusEx: TMemoryStatusEx;
    LR_ProcessMemoryCounters: TProcessMemoryCounters;
    LR_SysBaseInfo: TSystem_Basic_Information;
    LU_MinQuota: Cardinal;
    LU_MaxQuota: Cardinal;
    LI_I: Integer;
    LI_Max: Integer;
  begin
    mVMStatistics.Lines.BeginUpdate;
    try
      mVMStatistics.Clear;

      LU_MinQuota := 0;
      LU_MaxQuota := 0;

      if Assigned(MP_GlobalMemoryStatusEx) then
      begin
        ZeroMemory(@LR_GlobalMemoryStatusEx, SizeOf(TMemoryStatusEx));
        LR_GlobalMemoryStatusEx.dwLength := SizeOf(TMemoryStatusEx);

        if not MP_GlobalMemoryStatusEx(LR_GlobalMemoryStatusEx) then
        begin
          mVMStatistics.Lines.Add('GlobalMemoryStatusEx err: ' + SysErrorMessage(GetLastError));
        end;
      end
      else
      begin
        LR_GlobalMemoryStatus.dwLength := SizeOf(TMemoryStatus);
        GlobalMemoryStatus(LR_GlobalMemoryStatus);
      end;

      LP_FreeVMList.Sort(@LocSort);

      GetProcessWorkingSetSize(GetCurrentProcess, LU_MinQuota, LU_MaxQuota);
      GetSystemInfo(LR_SystemInfo);

      with mVMStatistics.Lines do
      begin
        Add('System Info:');
        Add('------------');

        Add('Processor Count                   = ' + IntToStr(LR_SystemInfo.dwNumberOfProcessors));
        Add('Allocation Granularity            = ' + IntToStr(LR_SystemInfo.dwAllocationGranularity));

        if Assigned(MP_GlobalMemoryStatusEx) then
        begin
          with LR_GlobalMemoryStatusEx do
          begin
            Add('Available Physical Memory         = ' + Int64ToKStringFormatted(ullAvailPhys));
            Add('Total Physical Memory             = ' + Int64ToKStringFormatted(ullTotalPhys));
            Add('Available Virtual Memory          = ' + Int64ToKStringFormatted(ullAvailVirtual));
            Add('Total Virtual Memory              = ' + Int64ToKStringFormatted(ullTotalVirtual));
            Add('Total Virtual Extended Memory     = ' + Int64ToKStringFormatted(ullAvailExtendedVirtual));
          end;
        end

        else
        begin
          with LR_GlobalMemoryStatus do
          begin
            Add('Available Physical Memory         = ' + CardinalToKStringFormatted(dwAvailPhys));
            Add('Total Physical Memory             = ' + CardinalToKStringFormatted(dwTotalPhys));
            Add('Available Virtual Memory          = ' + CardinalToKStringFormatted(dwAvailVirtual));
            Add('Total Virtual Memory              = ' + CardinalToKStringFormatted(dwTotalVirtual));
          end;
        end;

        if Assigned(MP_NtQuerySystemInformation) then
        begin
          if MP_NtQuerySystemInformation(SystemBasicInformation, @LR_SysBaseInfo, SizeOf(LR_SysBaseInfo), nil) = 0 then
          begin
            with LR_SysBaseInfo do begin
              Add('Maximum Increment                 = ' + CardinalToKStringFormatted(uKeMaximumIncrement));
              Add('Page Size                         = ' + CardinalToKStringFormatted(uPageSize));
              Add('Number of Physical Pages          = ' + CardinalToKStringFormatted(uMmNumberOfPhysicalPages));
              Add('Lowest Physical Page              = ' + CardinalToStringFormatted(uMmLowestPhysicalPage));
              Add('Highest Physical Page             = ' + CardinalToKStringFormatted(uMmHighestPhysicalPage));
            end;
          end;
        end;

        // same as GetProcessMemoryInfo & NtQuerySystemInformation (SystemBasicInformation

        // The working set is the amount of memory physically mapped to the process context at a given
        // time. Memory in the paged pool is system memory that can be transferred to the paging file
        // on disk (paged) when it is not being used. Memory in the nonpaged pool is system memory
        // that cannot be paged to disk as long as the corresponding objects are allocated. The pagefile
        // usage represents how much memory is set aside for the process in the system paging file.
        // When memory usage is too high, the virtual memory manager pages selected memory to disk.
        // When a thread needs a page that is not in memory, the memory manager reloads it from the
        // paging file.


        if GetProcessMemoryInfo(GetCurrentProcess, @LR_ProcessMemoryCounters, SizeOf(LR_ProcessMemoryCounters)) then
        begin
          with LR_ProcessMemoryCounters do
          begin
            Add('Page Fault Count                  = ' + CardinalToKStringFormatted(PageFaultCount));
            Add('Peak Working Set Size             = ' + CardinalToKStringFormatted(PeakWorkingSetSize));
            Add('Working Set Size                  = ' + CardinalToKStringFormatted(WorkingSetSize));
            Add('Quota Peak Paged Pool Usage       = ' + CardinalToKStringFormatted(QuotaPeakPagedPoolUsage));
            Add('Quota Paged Pool Usage            = ' + CardinalToStringFormatted(QuotaPagedPoolUsage));
            Add('Quota Peak Non-Paged Pool Usage  = ' + CardinalToStringFormatted(QuotaPeakNonPagedPoolUsage));
            Add('Quota Non-Paged Pool Usage       = ' + CardinalToStringFormatted(QuotaNonPagedPoolUsage));
            Add('Pagefile Usage                    = ' + CardinalToKStringFormatted(PagefileUsage));
            Add('Peak Pagefile Usage               = ' + CardinalToKStringFormatted(PeakPagefileUsage));
          end;
        end;

        Add('');
        Add('Process Info: PID (' + IntToStr(GetCurrentProcessId) + ')');
        Add('------------------------');
        Add('Minimum Address                   = ' + CardinalToStringFormatted(Cardinal(LR_SystemInfo.lpMinimumApplicationAddress)));
        Add('Maximum VM Address                = ' + CardinalToKStringFormatted(Cardinal(LR_SystemInfo.lpMaximumApplicationAddress)));
        Add('Page Protection & Commit Size     = ' + IntToStr(LR_SystemInfo.dWPageSize));
        Add('');
        Add('Quota info:');
        Add('-----------');
        Add('Minimum Quota                     = ' + CardinalToStringFormatted(LU_MinQuota));
        Add('Maximum Quota                     = ' + CardinalToStringFormatted(LU_MaxQuota));
        Add('');
        Add('VM Info:');
        Add('--------');
        Add('Total Free                        = ' + CardinalToKStringFormatted(LU_MEM_FREE));
        Add('Total Reserve                     = ' + CardinalToKStringFormatted(LU_MEM_RESERVE));
        Add('Total Commit                      = ' + CardinalToKStringFormatted(LU_MEM_COMMIT));

        if LP_FreeVMList.Count > CI_MaxFreeBlocksList then
          LI_Max := CI_MaxFreeBlocksList - 1
        else
          LI_Max := LP_FreeVMList.Count - 1;

        for LI_I := 0 to LI_Max do
        begin
          Add('Largest Free Block ' + IntToStr(LI_I + 1) + '.             = ' + CardinalToKStringFormatted(Cardinal(LP_FreeVMList.List[LI_I])));
        end;

        Add('');
        Add('FastMM4 Info:');
        Add('-------------');
        Add('Total Blocks                      = ' + CardinalToStringFormatted(LTotalBlocks));
        Add('Total Allocated                   = ' + CardinalToStringFormatted(LTotalAllocated));
        Add('Total Reserved                    = ' + CardinalToStringFormatted(LTotalReserved));
      end;

    finally
      mVMStatistics.Lines.EndUpdate;
    end;
  end;

var
  Save_Cursor: TCursor;
begin
  if SizeOf(TMemoryMap) <> SizeOf(TMemoryMapEx) then
  begin
    Showmessage('Internal implementation error');
    Exit;
  end;

  LU_MEM_FREE := 0;
  LU_MEM_COMMIT := 0;
  LU_MEM_RESERVE := 0;

  LTotalBlocks := 0;
  LTotalAllocated := 0;
  LTotalReserved := 0;

  // Set hourglass cursor
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  LP_FreeVMList := TList.Create;
  try
    // retrieve FastMM4 info

    GetMemoryManagerState(FMemoryManagerState);
    GetMemoryMap(TMemoryMap(FMemoryMapEx));

    // Update FastMM4 Graph with EXE & DLL locations
    UpdateVMGraph(FMemoryMapEx);

    // VM dump
    UpdateVMDump;

    // FastMM4 data
    UpdateFastMM4Data;

    // General Information
    UpdateStatisticsData;

    // Screen updates
    dgMemoryMap.Invalidate;

  finally
    FreeAndNil(LP_FreeVMList);
    Screen.Cursor := Save_Cursor;
  end;
end;

procedure TfFastMMUsageTracker.tTimerTimer(Sender: TObject);
begin
  tTimer.Enabled := False;
  try
    RefreshSnapShot;
  finally
    tTimer.Enabled := True;
  end;
end;

procedure TfFastMMUsageTracker.bCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfFastMMUsageTracker.dgMemoryMapDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  LChunkIndex: integer;
  LChunkColour: TColor;
begin
  {Get the chunk index}
  LChunkIndex := ARow * dgMemoryMap.ColCount + ACol;

  {Get the correct colour}
  case FMemoryMapEx[LChunkIndex] of

    csExAllocated:
      begin
        LChunkColour := $9090FF;
      end;

    csExReserved:
      begin
        LChunkColour := $90F090;
      end;

    csExSysAllocated:
      begin
        LChunkColour := $707070;
      end;

    csExSysExe:
      begin
        LChunkColour := clRed;
      end;

    csExSysDLL:
      begin
        LChunkColour := clBlue;
      end;

    csExSysReserved:
      begin
        LChunkColour := $C0C0C0;
      end

  else
    begin
      {ExUnallocated}
      LChunkColour := $FFFFFF;
    end;
  end;

  {Draw the chunk background}
  dgMemoryMap.Canvas.Brush.Color := LChunkColour;

  if State = [] then
    dgMemoryMap.Canvas.FillRect(Rect)
  else
    dgMemoryMap.Canvas.Rectangle(Rect);
end;

procedure TfFastMMUsageTracker.dgMemoryMapSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  LChunkIndex: Cardinal;
  LMBI: TMemoryBasicInformation;
  LA_Char: array[0..MAX_PATH] of char;
begin
  eDLLName.Text := '';
  LChunkIndex := ARow * dgMemoryMap.ColCount + ACol;
  eAddress.Text := Format('$%0.8x', [LChunkIndex shl 16]);

  case FMemoryMapEx[LChunkIndex] of

    csExAllocated:
      begin
        eState.Text := 'FastMM Allocated';
      end;

    csExReserved:
      begin
        eState.Text := 'FastMM Reserved';
      end;

    csExSysAllocated:
      begin
        eState.Text := 'System Allocated';
      end;

    csExSysExe:
      begin
        eState.Text := 'System Exe';
        VirtualQuery(Pointer(LChunkIndex shl 16), LMBI, SizeOf(LMBI));
        if (GetModuleFileName(dword(LMBI.AllocationBase), LA_Char, MAX_PATH) <> 0) then
        begin
          eDLLName.Text := LA_Char;
        end;
      end;

    csExSysDLL:
      begin
        eState.Text := 'System/User DLL';
        VirtualQuery(Pointer(LChunkIndex shl 16), LMBI, SizeOf(LMBI));
        if (GetModuleFileName(dword(LMBI.AllocationBase), LA_Char, MAX_PATH) <> 0) then
        begin
          eDLLName.Text := LA_Char;
        end;
      end;

    csExSysReserved:
      begin
        eState.Text := 'System Reserved';
      end

  else
    begin
      {ExUnallocated}
      eState.Text := 'Free';
    end;
  end;
end;

procedure TfFastMMUsageTracker.bUpdateClick(Sender: TObject);
begin
  RefreshSnapShot;
end;

procedure TfFastMMUsageTracker.ChkAutoUpdateClick(Sender: TObject);
begin
  tTimer.Enabled := ChkAutoUpdate.Checked;
end;

procedure TfFastMMUsageTracker.ChkSmallGraphClick(Sender: TObject);
begin
  UpdateGraphMetrics;
  dgMemoryMap.Invalidate;
  dgMemoryMap.SetFocus;
end;

procedure TfFastMMUsageTracker.sgVMDumpMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (Shift = [ssLeft]) then
  begin
    (Sender as TStringgrid).MouseToCell(X, Y, OR_VMDumpDownCell.X, OR_VMDumpDownCell.Y);
  end
  else
  begin
    OR_VMDumpDownCell.X := 0;
    OR_VMDumpDownCell.Y := 0;
  end;
end;

procedure TfFastMMUsageTracker.sgVMDumpMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TGridCoord;
  LGrid: TStringgrid;
begin
  LGrid := Sender as TStringGrid;
  if (Button = mbLeft) and (Shift = []) then
  begin
    LGrid.MouseToCell(X, Y, p.X, p.Y);
    if CompareMem(@p, @OR_VMDumpDownCell, sizeof(p))
      and (p.Y < LGrid.FixedRows)
      and (p.X >= LGrid.FixedCols) then
    begin
      HeaderClicked(LGrid, p);
    end;
  end;
  OR_VMDumpDownCell.X := 0;
  OR_VMDumpDownCell.Y := 0;
end;

procedure TfFastMMUsageTracker.sgVMDumpDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  LGrid: TStringgrid;
  LMarker: Char;
begin
  LGrid := Sender as TStringgrid;
  // paint the sort marker on header columns
  if (ACol >= LGrid.FixedCols) and (aRow = 0) then
  begin
    if Assigned(LGrid.Objects[aCol, aRow]) then
    begin
      if Integer(LGrid.Objects[aCol, aRow]) > 0 then
        LMarker := 't' // up wedge in Marlett font
      else
        LMarker := 'u'; // down wedge in Marlett font
      with LGrid.canvas do
      begin
        font.Name := 'Marlett';
        font.Charset := SYMBOL_CHARSET;
        font.Size := 12;
        textout(Rect.Right - TextWidth(LMarker), Rect.Top, LMarker);
        font := LGrid.font;
      end;
    end;
  end;
end;

procedure TfFastMMUsageTracker.siMM4AllocationCopyAlltoClipboardClick(Sender: TObject);
begin
  CopyGridContentsToClipBoard(sgBlockStatistics);
end;

procedure TfFastMMUsageTracker.miVMDumpCopyAlltoClipboardClick(Sender: TObject);
begin
  CopyGridContentsToClipBoard(sgVMDump);
end;

procedure TfFastMMUsageTracker.miGeneralInformationCopyAlltoClipboardClick(Sender: TObject);
begin
  with mVMStatistics do
  begin
    Lines.BeginUpdate;
    try
      SelectAll;
      CopyToClipboard;
      SelStart := 0;
    finally
      Lines.EndUpdate;
    end;
  end;
end;

procedure ModuleInit;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    MP_GlobalMemoryStatusEx := TP_GlobalMemoryStatusEx(
      GetProcAddress(GetModuleHandle(kernel32), 'GlobalMemoryStatusEx'));
    MP_NtQuerySystemInformation := TP_NtQuerySystemInformation(
      GetProcAddress(GetModuleHandle('ntdll.dll'), 'NtQuerySystemInformation'));
  end;
end;

initialization
  ModuleInit;

end.
