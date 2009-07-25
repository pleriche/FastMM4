{

Fast Memory Manager: Messages

Russian translation by Paul Ishenin.

2006-07-18
Some minor updates by Andrey V. Shtukaturov.

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
  UnknownClassNameMsg = 'Unknown';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'Текущий дамп памяти из 256 байт начиная с адреса ';
  {Block Error Messages}
  BlockScanLogHeader = 'Выделенный блок запротоколирован процедурой LogAllocatedBlocksToFile. Размер: ';
  ErrorMsgHeader = 'FastMM обнаружил ошибку во время ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = 'сканирования освобожденного блока';
  OperationMsg = ' операция. ';
  BlockHeaderCorruptedMsg = 'Заголовок блока поврежден. ';
  BlockFooterCorruptedMsg = 'Нижняя часть блока повреждена. ';
  FreeModifiedErrorMsg = 'FastMM обнаружил что блок был модифицирован после его освобождения. ';
  FreeModifiedDetailMsg = #13#10#13#10'Modified byte offsets (and lengths): ';
  DoubleFreeErrorMsg = 'Была предпринята попытка освободить/перевыделить не выделенный блок.';
  WrongMMFreeErrorMsg = 'An attempt has been made to free/reallocate a block that was allocated through a different FastMM instance. Check your memory manager sharing settings.';
  PreviousBlockSizeMsg = #13#10#13#10'Размер предыдущего блока был: ';
  CurrentBlockSizeMsg = #13#10#13#10'Размер блока: ';
  PreviousObjectClassMsg = #13#10#13#10'Блок был ранее использован для объекта класса: ';
  CurrentObjectClassMsg = #13#10#13#10'Блок в настоящее время используется для объекта класса: ';
  PreviousAllocationGroupMsg = #13#10#13#10'Выделенная группа была: ';
  PreviousAllocationNumberMsg = #13#10#13#10'Выделенный номер был: ';
  CurrentAllocationGroupMsg = #13#10#13#10'Выделенная группа стала: ';
  CurrentAllocationNumberMsg = #13#10#13#10'Выделенный номер стал: ';
  BlockErrorMsgTitle = 'Обнаружена ошибка памяти.';
  VirtualMethodErrorHeader = 'FastMM обнаружил попытку вызвать виртуальный метод освобожденного объекта. Сейчас будет вызвано нарушение доступа для прерывания текущей операции.';
  InterfaceErrorHeader = 'FastMM обнаружил попытку использовать интерфейс освобожденного объекта. Сейчас будет вызвано нарушение доступа для прерывания текущей операции.';
  BlockHeaderCorruptedNoHistoryMsg = ' К сожалению заголовок блока поврежден и история не доступна.';
  FreedObjectClassMsg = #13#10#13#10'Класс освобожденного объекта: ';
  VirtualMethodName = #13#10#13#10'Виртуальный метод: ';
  VirtualMethodOffset = 'Смещение +';
  VirtualMethodAddress = #13#10#13#10'Адрес виртуального метода: ';
  {Stack trace messages}
  CurrentThreadIDMsg = #13#10#13#10'The current thread ID is 0x';
  CurrentStackTraceMsg = ', and the stack trace (return addresses) leading to this error is:';
  ThreadIDPrevAllocMsg = #13#10#13#10'This block was previously allocated by thread 0x';
  ThreadIDAtAllocMsg = #13#10#13#10'This block was allocated by thread 0x';
  ThreadIDAtFreeMsg = #13#10#13#10'The block was previously freed by thread 0x';
  ThreadIDAtObjectAllocMsg = #13#10#13#10'The object was allocated by thread 0x';
  ThreadIDAtObjectFreeMsg = #13#10#13#10'The object was subsequently freed by thread 0x';
  StackTraceMsg = ', and the stack trace (return addresses) at the time was:';
  {Installation Messages}
  AlreadyInstalledMsg = 'FastMM4 уже установлен.';
  AlreadyInstalledTitle = 'Уже установлен.';
  OtherMMInstalledMsg = 'FastMM4 не может быть установлен при установленном другом менеджере памяти.'
    + #13#10'Если вы желаете использовать FastMM4, пожалуйста убедитесь что FastMM4.pas является самым первым модулем в'
    + #13#10'секции "uses" вашего ''s .dpr файла проекта.';
  OtherMMInstalledTitle = 'Невозможно установить FastMM4 - уже установлен другой менеджер памяти.';
  MemoryAllocatedMsg = 'FastMM4 невозможно установить когда память уже была '
    + 'выделена стандартным менеджером памяти.'#13#10'FastMM4.pas ДОЛЖЕН '
    + 'быть первым модулем в вашем файле .dpr файле проекта, иначе память может '
    + 'быть выделена'#13#10'через стандартный менеджер памяти перед тем как FastMM4 '
    + 'получит контроль. '#13#10#13#10'Если вы используете обработчик исключений '
    + 'типа MadExcept (или любой другой инструмент модифицирующий порядок инициализации '
    + 'модулей),'#13#10'то перейдите в страницу его конфигурации и убедитесь, что '
    + 'FastMM4.pas модуль инициализируется перед любым другим модулем.';
  MemoryAllocatedTitle = 'Не возможно установить FastMM4 - Память уже была выделена';
  {Leak checking messages}
  LeakLogHeader = 'Блок памяти был выделен и не освобожден. Размер: ';
  LeakMessageHeader = 'В этом приложении происходят утечки памяти. ';
  SmallLeakDetail = 'Утечки блоков маленького размера'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (исключая ожидаемые утечки зарегистрированные по указателю)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'Размеры утечек блоков среднего размера'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (исключая ожидаемые утечки зарегистрированные по указателю)'
{$endif}
    + ': ';
  BytesMessage = ' байт: ';
  AnsiStringBlockMessage = 'AnsiString';
  UnicodeStringBlockMessage = 'UnicodeString';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Note: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Эта проверка утечки памяти производится только в случае одновременной работы Delphi на том же компьютере. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'Детальная информация об утечках памяти журналируется в текстовый файл в том же каталоге, что и приложение. '
    {$else}
    + 'Включите "LogMemoryLeakDetailToFile" для получения журнала, содержащего детальную информацию об утечках памяти. '
    {$endif}
  {$else}
    + 'Для получения журнала, содержащего детальную информацию об утечках памяти, включите условия компиляции "FullDebugMode" и "LogMemoryLeakDetailToFile". '
  {$endif}
    + 'Для выключения этих проверок утечки памяти, уберите определение "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Обнаружена утечка памяти';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM has been installed.';
  FastMMInstallSharedMsg = 'Sharing an existing instance of FastMM.';
  FastMMUninstallMsg = 'FastMM has been uninstalled.';
  FastMMUninstallSharedMsg = 'Stopped sharing an existing instance of FastMM.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'MM Operation after uninstall.';
  InvalidGetMemMsg = 'FastMM has detected a GetMem call after FastMM was uninstalled.';
  InvalidFreeMemMsg = 'FastMM has detected a FreeMem call after FastMM was uninstalled.';
  InvalidReallocMemMsg = 'FastMM has detected a ReallocMem call after FastMM was uninstalled.';
  InvalidAllocMemMsg = 'FastMM has detected a ReallocMem call after FastMM was uninstalled.';
{$endif}

implementation

end.

