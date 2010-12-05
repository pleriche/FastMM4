{

Fast Memory Manager: 选项配置文件

在这里为FastMM设置默认选项

FastMM 4.97

}

{
   Simplified Chinese translation by QianYuan Wang

   Contact me if you find any improper translation.
   如果翻译上有任何不恰当的地方请和我联系。

   E-Mail: wqyfavor@qq.com
}

{
 对各编译选项的翻译（不解释术语）
 
 Align16Bytes 					按16字节对齐
 UseCustomFixedSizeMoveRoutines 		使用固定尺寸内存移动函数
 UseCustomVariableSizeMoveRoutines 		使用可变尺寸内存移动函数
 AssumeMultiThreaded 				按多线程处理
 NeverSleepOnThreadContention 			线程冲突时不暂停进程
 InstallOnlyIfRunningInIDE 			仅在Delphi开发环境中加载内存管理器
 NeverUninstall 				不卸载FastMM
 UseRuntimePackages 				使用运行期包
 
 NoDebugInfo 					无调试信息
 NoMessageBoxes 				不显示信息
 UseOutputDebugString 				使用Windows API OutputDebugString
 ASMVersion 					汇编版本
 CheckHeapForCorruption 			检测堆错误
 DetectMMOperationsAfterUninstall 		检测在管理器卸载后对其的引用操作
 FullDebugMode 					全调试模式
   RawStackTraces 				彻底的栈追踪
   CatchUseOfFreedInterfaces 			捕捉对已销毁对象的引用
   LogErrorsToFile 				记录错误到文件
   LogMemoryLeakDetailToFile 			记录内存泄露细节到文件
   ClearLogFileOnStartup 			启动时清空日志文件
   LoadDebugDLLDynamically 			动态加载调试Dll
   AlwaysAllocateTopDown 			总从最顶端分配内存

 EnableMemoryLeakReporting 			允许内存泄露报告
   HideExpectedLeaksRegisteredByPointer 	隐藏由指针记录的可能的内存泄露
   RequireIDEPresenceForLeakReporting 		仅在IDE存在时进行泄露报告
   RequireDebuggerPresenceForLeakReporting 	仅在调试器存在时进行泄露报告
   RequireDebugInfoForLeakReporting 		泄露报告需要调试信息
   ManualLeakReportingControl 			手工控制泄露报告
   HideMemoryLeakHintMessage 			隐藏内存泄露提示信息

 EnableMMX 					允许使用MMX
   ForceMMX 					强制使用MMX

 ShareMM 					共享内存管理器
   ShareMMIfLibrary 				允许在Dll中共享内存管理器
 AttemptToUseSharedMM 				尝试共享内存管理器
 EnableBackwardCompatibleMMSharing 		允许向后兼容的内存管理器共享

 FullDebugModeInIDE 				在Delphi开发环境中进行全调试
}

{--------------------------- 综合选项 -----------------------------}

{开启此选项会将所有内存块按16字节对齐以便SSE指令可以安全使用。如果此选项关闭，一些
 最小的内存块会按8字节方式对齐，这将减少内存使用。不管是否开启此选项，中等和大的内
 存块都将按照16字节方式对齐。}
{.$define Align16Bytes}

{允许在增大小内存块时使用更快的定尺寸内存移动函数。因为这些函数被设计为移动固定尺寸
 内存，所以效率大幅高于Borland的RTL中的内存移动函数。这一选项可与FastMove库配合使用
 来达到更高的效率。}
{$define UseCustomFixedSizeMoveRoutines}

{开启此选项以使用优化的函数来移动任意大小的内存块。使用Fastcode的FastMove函数时禁用
 此选项。使用FastMove代码可以使整个程序都使用到更快的内存移动函数而不仅仅是内存管理
 器。因此建议将FastMM和FastMove代码相结合，并关闭此选项。}
{$define UseCustomVariableSizeMoveRoutines}

{开启此选项会使程序仅在Delphi IDE内运行时才加裁FastMM作为内存管理器。当你希望发布的
 Exe就是你调试的Exe，但只希望在开发主机上使用调试时请开启此选项。当开启后程序又并不
 在开发主机上运行，它会使用默认的Delphi内存管理器（在Delphi2006以后是不开启FullDebugMode
 的FastMM）}
{.$define InstallOnlyIfRunningInIDE}

{由于QC#14070（Delphi尝试在borlandmm.dll的关闭指令执行后释放内存），当使用了FastMM
 为核心的borlandmm.dll的替代品，FastMM不能被正常卸载。开启此选项会不卸载内存管理器
 而避开这个错误。}
{.$define NeverUninstall}

{如果在当前工程中使用了运行期的包，需要启动这个选项。会自动开启AssumeMultiThreaded。
 注意你必须确保在所有指针都释放后FastMM被卸载。如果不这么做会产生一个有很多A/V的巨
 大的内存泄露报告。（参考常见问题）你必须同时启动此选项和NeverUninstall选项。}
{.$define UseRuntimePackages}

{-----------------------Concurrency Management Options------------------------}

{开启后将默认程序是多线程的，但会导致单线程程序速度明显下降。在使用可能未正确设
 置IsMultiThread变量的多线程的第三方工具时请开启此选项。在单线程主程序和多线程Dll
 间共享内存管理器时也需开启。}
{.$define AssumeMultiThreaded}

{开启此选项将不会在线程冲突时让一个线程暂停，在活动进程与CPU核心数目比低（小于2）时
 将会提升速度。开启后，冲突时一个线程将会进入“等待”循环而不是交出时间片。}
{.$define NeverSleepOnThreadContention}

  {开启后，当线程冲突时会调用SwitchToThread而不是一直停留在“等待”循环中。这个选项需要
   配合NeverSleepOnThreadContention一起使用，并且必须在前者开启时才有效。当系统有多个
   CPU核心或线程有不同的优先级时，开启此选项可提高效率。SwitchToThread调用只在Windows2000
   及以后版本有效。}
  {.$define UseSwitchToThread}

{----------------------------- 调试选项 -------------------------------}

{开启此选项将不会为FastMM4.pas单元产生调试代码，也将同时阻止调试器进入FastMM4.pas单元}
{.$define NoDebugInfo}

{开启下面选项将不显示任何信息，在不可中止的服务器程序中比较有用}
{.$define NoMessageBoxes}

{如果要使用Windows API OutputDebugString过程来显示调试信息请开启下面选项}
{.$define UseOutputDebugString}

{开启此选项会使用汇编语言版本的FastMM，这比Pascal版本的要快。仅在调试时关闭此选项。
 开启CheckHeapForCorruption会自动关闭此设置}
{$define ASMVersion}

{FastMM总会捕捉到两次释放的同一内存区域的糟糕操作，它也可以检测堆的错误（通常是由
于程序越界读写内存）。这些检测很耗费时间，所以这个选项应仅当调试时使用。如果此选项
开启，ASMVersion会自动关闭}
{.$define CheckHeapForCorruption}

{开启此选项会检测在FastMM已卸载后对用户对FastMM的引用操作。开启后，当FastMM被卸载，
 将不会重新启动先前的内存管理器，而是假想存在一个内存管理器，并且一旦有内存操作便
 抛出错误。这会捕捉到当FastMM已被卸载而程序仍进行内存操作的错误。}
{$define DetectMMOperationsAfterUninstall}

{设置以下选项来对内存泄露进行广泛检测。所有内存块都会设置块首和跟踪器来校验堆的完
 整性。释放的内存块（指针）也会被清空以保证它们不会被再次使用。这一选项会大幅度降
 低内存操作速度，仅当调试一个会越界读写内存或重复使用已被释放的指针的程序时才使用。
 开启此选项会进而自动开启CheckHeapForCorruption并自动关闭ASMVersion。提示：当开启
 此选项时，程序需要使用FastMM_FullDebugMode.dll文件。如果此文件丢失，程序将无法启动。}
{.$define FullDebugMode}

  {开启此选项以进行彻底的栈追踪：检测所有栈条目以寻找合法的返回地址。注意这比使用
   主栈帧的方法要慢很多，但更彻底。仅当开启FullDebugMode时此选项有效。}
  {$define RawStackTraces}

  {开启此选项会检测程序中对已销毁对象的引用。注意这会使对已释放而又修改过（内容被
   覆盖）的内存块的检测无法进行（两者无法共存）。仅当开启FullDebugMode时此选项有效。}
  {.$define CatchUseOfFreedInterfaces}

  {开启此选项以记录所有的错误到一个与程序同目录的文本文件中。内存分配错误（当开启
   FullDebugMode）将会添加到这个日志里。如果FullDebugMode关闭，此选项无效}
  {$define LogErrorsToFile}

  {开启此选项将会记录所有泄露到一个与程序同目录的文本文件中。内存泄露报告（当开启
   FullDebugMode）将会添加到这个日志里。如果"LogErrorsToFile"和"FullDebugMode"未开
   启此选项无效。注意通常所有泄露都会被记录，甚至那些AddExpectedMemoryLeaks标识的
   可能的内存泄露。那些由指针引起的可能的泄露可能会由于开启HideExpectedLeaks-
   RegisteredByPointer而不显示。}
  {$define LogMemoryLeakDetailToFile}

  {程序启动时删除日志文件。当LogErrorsToFile不开启时无效}
  {.$define ClearLogFileOnStartup}

  {是否动态链接FASTMM_FullDebugMode.dll。如果找不到该Dll，栈追踪将无法进行。注意
   当共享内存管理器时由于Dll卸载顺序改变，可能会发生错误。}
  {.$define LoadDebugDLLDynamically}

    {.$define DoNotInstallIfDLLMissing}
    {开启此选项后，并且开启FullDebugMode和LoadDebugDLLDynamically时，如果
     FastMM_FullDebugMode.dll文件丢失，那么FastMM将不会加载。}

  {FastMM通常会使用最顶端的可用地址来分配大的内存块，而在最低端的可用地址上分配
   中、小内存块（这在一定程度上减少碎片）。开启此选项会使内存分配总优先使用最顶
   端的可用地址。如果过程使用了大于2GB的内存并且算法存在糟糕的指针分配 ，这个选
   项会帮助尽早发现错误}
  {$define AlwaysAllocateTopDown}

  {开启后将不会对内存转储进行日志记录，其它记录正常。}
  {.$define DisableLoggingOfMemoryDumps}

  {FullDebugMode模式下，当FreeMem调用失败时通常会返回一个“指针操作无效”的
   错误。如果此时另一个异常正在被处理（比如在“try..finally”中），那原先的异常就会丢失。
   开启此选项后，如果此时正有别的异常被处理，那么FastMM将忽略FreeMem中发生错误。}
  {$define SuppressFreeMemErrorsInsideException}

{--------------------------- 内存泄露报告 -----------------------------}

{开启此选项以允许内存泄露报告，与下面两个选项组合使用。}
{$define EnableMemoryLeakReporting}

  {开启下面选项将不会显示和记录由指针类型导致的可能的内存泄露。由类（指针）引起
   的可能的内存泄露经常不明确，所以这些可能的泄露总是会记录到日志（在FullDebugMode
   与LogMemoryLeakDetailToFile开启时）并且当实际泄露比期待的多时一定会显示。}
  {$define HideExpectedLeaksRegisteredByPointer}

  {开启下面选项以实现仅在Delphi在主机上存在时才报告内存泄露。当"EnableMemoryLeakReporting"
   关闭时此选项无效。}
  {.$define RequireIDEPresenceForLeakReporting}

  {开启下面选项以实现仅在Delphi中调试程序时才报告内存泄露。当"EnableMemoryLeakReporting"
   关闭时此选项无效。此选项仅在调试EXE工程时有效，不支持Dll}
  {$define RequireDebuggerPresenceForLeakReporting}

  {开启下面选项以实现仅在被编译单元中存在调试指示符（$D）时才进行泄露检测。当
   "EnableMemoryLeakReporting"关闭时此选项无效。}
  {.$define RequireDebugInfoForLeakReporting}

  {开启此选项以手工控制内存泄露报告。当开启时，ReportMemoryLeaksOnShutdown（程序
   关闭时报告内存泄露，默认关闭）会改为选择是否生成报告。开启时，其它泄露检测选项
   也必须正确设置才能进行检测}
  {.$define ManualLeakReportingControl}

  {开启下面选项将不显示内存泄露信息下面的提示语}
  {.$define HideMemoryLeakHintMessage}

{-------------------------- 指令集设置 ----------------------------}

{开启下面选项以使用MMX指令集。关闭此选项会导致性能略微下降，但会与AMD K5、
 Pentium I等早期处理器保持兼容。目前MMX指令只在可变尺寸的内存移动中使用，所以如
 果UseCustomVariableSizeMoveRoutines关闭，此选项无效。}
{.$define EnableMMX}

  {开启下面选项以强制使用MMX指令集，而不管CPU是否支持。如果这一选项被关闭，
   将会首先检查CPU是否支持MMX指令。当EnabledMMX关闭时无效。}
  {$define ForceMMX}

{----------------------- 共享内存管理器设置 ------------------------}

{允许共同使用FastMM编译的主程序和Dll之间共享内存管理器。你可以向Dll中的函数传递
 动态数组和长字符串。需要编译Dll时开启AttemptToUseSharedMM才可以真正实现内存共享。
 注意如果主程序是单线程而Dll是多线程的，你必须在主程序里开启IsMultiThread,否则在
 线程冲突时程序会崩溃。注意静态链接的Dll会在主程序之前初始化，所以主程序实际会与
 Dll共享内存管理器。
}
{.$define ShareMM}

  {允许Dll之间（或静态链接Dll时与主程序之间）共享内存管理器,要求共同使用FastMM编译。
   在使用动态链接的Dll时需要注意，因为如果Dll被卸载而其它Dll仍在共享内存管理器，程
   序将会崩溃。这个选项只与Dll库相关而且需要ShareMM与AttemptToUseSharedMM开启。注意
   如果Dll是静态链接的，它们会在主程序之前初始化，实际是主程序与它们共享管理器。当
   ShareMM关闭时此选项无效} 
  {.$define ShareMMIfLibrary}

{开启下面选项，会尝试在主程序和与之共同编译的Dll（也开启此选项）之间共享内存管理
 器。当共享时，由使用共享者产生的泄露将不会自动清除。由于静态链接的Dll是在主程序
 之前初始化的，所以根据情况设置共享选项}
{.$define AttemptToUseSharedMM}

{开启下面编译选项以保证内存管理器的向后兼容性。对Delphi2006与Delphi2007与老版本
FastMM有效}
{$define EnableBackwardCompatibleMMSharing}

{-------------------------------- 组合设置 ------------------------------}

{开启此选项将激活FullDebugMode、InstallOnlyIfRunningInIDE、LoadDebugDLLDynamically。
 如果程序正在Delphi中进行调试运行，FastMM将会进行完全调试（开启FullDebugMode），否则
 将使用默认内存管理器（Delphi2006版本以后是未开启FullDebugMode的FastMM）。}
{.$define FullDebugModeInIDE}

{该选项搭配FullDebugMode、LoadDebugDLLDynamically和DoNotInstallIfDLLMissing一起
 使用。开启后如果有FastMM_FullDebugMode.dll文件并且开启了FullDebugMode那么将进入全
 调试模式。这样用于发布的exe和调试的exe可以是同一个文件，发布时只要去掉FastMM_FullDebugMode.dll
 文件就可以了。}
{.$define FullDebugModeWhenDLLAvailable}

{快速配置发布版本和调试版本}
{$ifdef Release}
  {发布版本请设置}
  {.$undef FullDebugMode}
  {.$undef CheckHeapForCorruption}
  {.$define ASMVersion}
  {.$undef EnableMemoryLeakReporting}
  {.$undef UseOutputDebugString}
{$else}
  {调试版本请设置}
  {.$define FullDebugMode}
  {.$define EnableMemoryLeakReporting}
  {.$define UseOutputDebugString}
{$endif}

{-------------------- borlndmm.dll 编译选项 ---------------------}
{如果正在重编译borlandmm.dll文件，请根据需要设置以下选项}

{当编译borlandmm.dll时请开启此选项}
{.$define borlndmmdll}

{如果dll被Delphi本身使用请开启此选项}
{.$define dllforide}

{编译调试dll文件时请开启此选项}
{.$define debugdll}

{以下内容请不要改动}
{$ifdef borlndmmdll}
  {$define AssumeMultiThreaded}
  {$undef HideExpectedLeaksRegisteredByPointer}
  {$undef RequireDebuggerPresenceForLeakReporting}
  {$undef RequireDebugInfoForLeakReporting}
  {$define DetectMMOperationsAfterUninstall}
  {$undef ManualLeakReportingControl}
  {$undef ShareMM}
  {$undef AttemptToUseSharedMM}
  {$ifdef dllforide}
    {$define NeverUninstall}
    {$define HideMemoryLeakHintMessage}
    {$undef RequireIDEPresenceForLeakReporting}
    {$ifndef debugdll}
      {$undef EnableMemoryLeakReporting}
    {$endif}
  {$else}
    {$define EnableMemoryLeakReporting}
    {$undef NeverUninstall}
    {$undef HideMemoryLeakHintMessage}
    {$define RequireIDEPresenceForLeakReporting}
  {$endif}
  {$ifdef debugdll}
    {$define FullDebugMode}
    {$define RawStackTraces}
    {$undef CatchUseOfFreedInterfaces}
    {$define LogErrorsToFile}
    {$define LogMemoryLeakDetailToFile}
    {$undef ClearLogFileOnStartup}
  {$else}
    {$undef FullDebugMode}
  {$endif}
{$endif}

{把BCB的相关设置都放在这里。在“Build with Dynamic RTL”选项开启的情况下，
CB2006/CB2007可以编译borlandmm.dll文件以追踪内存泄露。}
{------------------------------ 专为BCB设置 ----------------------------}

{要开启为BCB准备的补丁，你需要在"Project Options->Pascal/Delphi Compiler->Defines"
 中添加BCB的定义。（感谢JiYuan Xie实现这一部分）}

{$ifdef BCB}
  {$ifdef CheckHeapForCorruption}
    {$define PatchBCBTerminate}
  {$else}
    {$ifdef DetectMMOperationsAfterUninstall}
      {$define PatchBCBTerminate}
    {$else}
       {$ifdef EnableMemoryLeakReporting}
         {$define PatchBCBTerminate}
       {$endif}
    {$endif}
  {$endif}

  {$ifdef PatchBCBTerminate}
    {$define CheckCppObjectType}
    {$undef CheckCppObjectTypeEnabled}

    {$ifdef CheckCppObjectType}
      {$define CheckCppObjectTypeEnabled}
    {$endif}

    {如果"CheckHeapForCorruption"和"EnableMemoryLeakReporting"都未开启，请关闭
     "CheckCppObjectTypeEnabled"}
    {$ifdef CheckHeapForCorruption}
    {$else}
      {$ifdef EnableMemoryLeakReporting}
      {$else}
        {$undef CheckCppObjectTypeEnabled}
      {$endif}
    {$endif}
  {$endif}
{$endif}
