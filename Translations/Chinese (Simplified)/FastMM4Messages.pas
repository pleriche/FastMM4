{

Fast Memory Manager: Messages

Simplified Chinese translation by JiYuan Xie.

}

unit FastMM4Messages;

interface

{$Include FastMM4Options.inc}

const
  {The name of the debug info support DLL}
  FullDebugModeLibraryName = 'FastMM_FullDebugMode.dll';
  {Event log strings}
  LogFileExtension = '_MemoryManager_EventLog.txt'#0;
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Class name messages}
  UnknownClassNameMsg = '未知';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'由指针所指地址开始, 256 个字节的内存当前的内容 ';
  {Block Error Messages}
  BlockScanLogHeader = '被 LogAllocatedBlocksToFile 记录的已分配内存块. 大小是: ';
  ErrorMsgHeader = 'FastMM 已检测到一个错误, 当时正在进行 ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = '扫描自由内存块';
  OperationMsg = ' 操作. ';
  BlockHeaderCorruptedMsg = '内存块头部内容已被破坏. ';
  BlockFooterCorruptedMsg = '内存块尾部内容已被破坏. ';
  FreeModifiedErrorMsg = 'FastMM 检测到对已释放内存块内容的修改. ';
  FreeModifiedDetailMsg = #13#10#13#10'被修改字节的偏移地址(以及长度): ';
  DoubleFreeErrorMsg = '试图释放/重新分配一个尚未分配的内存块.';
  WrongMMFreeErrorMsg = 'An attempt has been made to free/reallocate a block that was allocated through a different FastMM instance. Check your memory manager sharing settings.';
  PreviousBlockSizeMsg = #13#10#13#10'上次使用时的内存块大小是: ';
  CurrentBlockSizeMsg = #13#10#13#10'内存块的大小是: ';
  PreviousObjectClassMsg = #13#10#13#10'该内存块上次被用于一个属于以下类的对象: ';
  CurrentObjectClassMsg = #13#10#13#10'该内存块当前被用于一个属于以下类的对象: ';
  PreviousAllocationGroupMsg = #13#10#13#10'分配组是: ';
  PreviousAllocationNumberMsg = #13#10#13#10'分配号码是: ';
  CurrentAllocationGroupMsg = #13#10#13#10'分配组是: ';
  CurrentAllocationNumberMsg = #13#10#13#10'分配号码是: ';
  BlockErrorMsgTitle = '检测到内存错误';
  VirtualMethodErrorHeader = 'FastMM 检测到对已释放对象的虚方法的调用. 一个访问冲突异常现在将被引发以中止当前的操作.';
  InterfaceErrorHeader = 'FastMM 检测到对已释放对象的接口的使用. 一个访问冲突异常现在将被引发以中止当前的操作.';
  BlockHeaderCorruptedNoHistoryMsg = ' 不幸地, 由于内存块头部的内容已被破坏, 无法得到该内存块的使用历史.';
  FreedObjectClassMsg = #13#10#13#10'被释放的对象所属的类: ';
  VirtualMethodName = #13#10#13#10'虚方法: ';
  VirtualMethodOffset = '偏移地址 +';
  VirtualMethodAddress = #13#10#13#10'虚方法的地址: ';
  {Stack trace messages}
  CurrentThreadIDMsg = #13#10#13#10'当前线程的 ID 是 0x';
  CurrentStackTraceMsg = ', 导致该错误的堆栈跟踪(返回地址): ';
  ThreadIDPrevAllocMsg = #13#10#13#10'该内存块上一次分配于线程 0x';
  ThreadIDAtAllocMsg = #13#10#13#10'该内存块分配于线程 0x';
  ThreadIDAtFreeMsg = #13#10#13#10'该内存块上一次释放于线程 0x';
  ThreadIDAtObjectAllocMsg = #13#10#13#10'该对象分配于线程 0x';
  ThreadIDAtObjectFreeMsg = #13#10#13#10'该对象随后释放于线程 0x';
  StackTraceMsg = ', 当时的堆栈跟踪(返回地址): ';
  {Installation Messages}
  AlreadyInstalledMsg = 'FastMM4 已经被安装';
  AlreadyInstalledTitle = '已经加载';
  OtherMMInstalledMsg = 'FastMM4 无法被安装, 因为其他第三方内存管理器已先自行安装.'
    + #13#10'如果你想使用 FastMM4, 请确认在你项目的 .dpr 文件的 "uses" 部分中, '
    + #13#10'FastMM4.pas 是第一个被使用的单元.';
  OtherMMInstalledTitle = '无法安装 FastMM4 - 其他内存管理器已先被安装';
  MemoryAllocatedMsg = 'FastMM4 无法安装, 因为此前已通过默认内存管理器分配了内存.'
    + #13#10'FastMM4.pas 必须是你项目的 .dpr 文件中第一个被使用的单元, 否则可能在'
    + #13#10'FastMM4 得到控制权之前, 应用程序已经通过默认内存管理器分配了内存.'
    + #13#10#13#10'如果你使用了异常捕捉工具, 象 MadExcept(或任何将修改单元初始化顺序的工具),'
    + #13#10'请到它的配置页面,确保 FastMM4.pas 单元在任何其他单元之前被初始化.';
  MemoryAllocatedTitle = '无法安装 FastMM4 - 之前已经分配了内存';
  {Leak checking messages}
  LeakLogHeader = '一个内存块已泄露. 大小是: ';
  LeakMessageHeader = '这个应用程序存在内存泄露. ';
  SmallLeakDetail = '小内存块的泄露有'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (不包括已按指针注册的预知泄露)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = '已泄露的中等及大内存块的大小是'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (不包括已按指针注册的预知泄露)'
{$endif}
    + ': ';
  BytesMessage = ' 字节: ';
  AnsiStringBlockMessage = 'AnsiString';
  UnicodeStringBlockMessage = 'UnicodeString';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'注意: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + '只有当 Delphi 同时运行在同一计算机上时才会进行内存泄露检查. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + '内存泄露的详细信息已经被记录到与本应用程序同一目录下的一个文本文件中. '
    {$else}
    + '请启用 "LogMemoryLeakDetailToFile" 条件编译开关以得到一个包含关于内存泄露的详细信息的日志文件. '
    {$endif}
  {$else}
    + '要得到一个包含关于内存泄露的详细信息的日志文件, 请启用 "FullDebugMode" 和 "LogMemoryLeakDetailToFile" 条件编译开关. '
  {$endif}
    + '要禁止内存泄露检查, 请关闭 "EnableMemoryLeakReporting" 条件编译开关.'#13#10
{$endif}
    + #0;
  LeakMessageTitle = '检测到内存泄露';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM 已被安装.';
  FastMMInstallSharedMsg = '正共用一个已存在的 FastMM 实例.';
  FastMMUninstallMsg = 'FastMM 已被卸载.';
  FastMMUninstallSharedMsg = '已停止共用一个已存在的 FastMM 实例.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = '卸载之后发生了 MM 操作.';
  InvalidGetMemMsg = 'FastMM 检测到在 FastMM 被卸载之后调用了 GetMem.';
  InvalidFreeMemMsg = 'FastMM 检测到在 FastMM 被卸载之后调用了 FreeMem.';
  InvalidReallocMemMsg = 'FastMM 检测到在 FastMM 被卸载之后调用了 ReallocMem.';
  InvalidAllocMemMsg = 'FastMM 检测到在 FastMM 被卸载之后调用了 AllocMem.';
{$endif}

implementation

end.

