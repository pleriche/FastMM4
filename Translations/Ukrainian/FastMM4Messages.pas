{

Fast Memory Manager: Messages

2006-07-18
Ukrainian translation by Andrey V. Shtukaturov.

}

unit FastMM4MessagesUKR;

interface

{$Include FastMM4Options.inc}

const
  {The name of the debug info support DLL}
  FullDebugModeLibraryName32Bit = 'FastMM_FullDebugMode.dll';
  FullDebugModeLibraryName64Bit = 'FastMM_FullDebugMode64.dll';
  {Event log strings}
  LogFileExtension = '_MemoryManager_EventLog.txt'#0;
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Class name messages}
  UnknownClassNameMsg = 'Unknown';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'Поточний дамп пам’’яті з 256 байт починаючи з адреси ';
  {Block Error Messages}
  BlockScanLogHeader = ' Виділений блок запротокольовано процедурою LogAllocatedBlocksToFile. Розмір: ';
  ErrorMsgHeader = 'FastMM виявив помилку під час ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = 'сканування звільненого блоку ';
  OperationMsg = ' операція. ';
  BlockHeaderCorruptedMsg = ' Заголовок блоку ушкоджений. ';
  BlockFooterCorruptedMsg = ' Нижня частина блоку ушкоджена. ';
  FreeModifiedErrorMsg = 'FastMM виявив що блок було модифіковано після його звільнення. ';
  FreeModifiedDetailMsg = #13#10#13#10'Modified byte offsets (and lengths): ';
  DoubleFreeErrorMsg = ' Була спроба звільнити/перевиділити не виділений блок.';
  WrongMMFreeErrorMsg = 'An attempt has been made to free/reallocate a block that was allocated through a different FastMM instance. Check your memory manager sharing settings.';
  PreviousBlockSizeMsg = #13#10#13#10'Розмір попереднього блоку був: ';
  CurrentBlockSizeMsg = #13#10#13#10'Розмір блоку: ';
  PreviousObjectClassMsg = #13#10#13#10'Блок був раніше використаний для об’’єкта класу: ';
  CurrentObjectClassMsg = #13#10#13#10'Блок на даний момент використовується для об’’єкта класу: ';
  PreviousAllocationGroupMsg = #13#10#13#10'Виділена група була: ';
  PreviousAllocationNumberMsg = #13#10#13#10'Виділений номер був: ';
  CurrentAllocationGroupMsg = #13#10#13#10'Виділена група стала: ';
  CurrentAllocationNumberMsg = #13#10#13#10'Виділений номер став: ';
  BlockErrorMsgTitle = 'Виявлено помилку пам’’яті.';
  VirtualMethodErrorHeader = 'FastMM виявив спробу викликати віртуальний метод звільненого об’’єкту. Зараз буде викликане порушення доступу для переривання поточної операції.';
  InterfaceErrorHeader = 'FastMM виявив спробу використати інтерфейс звільненого об’’єкту. Зараз буде викликане порушення доступу для переривання поточної операції.';
  BlockHeaderCorruptedNoHistoryMsg = ' На жаль заголовок блоку ушкоджений і історія недоступна.';
  FreedObjectClassMsg = #13#10#13#10'Клас звільненого об’’єкту: ';
  VirtualMethodName = #13#10#13#10'Віртуальний метод: ';
  VirtualMethodOffset = 'Зсув +';
  VirtualMethodAddress = #13#10#13#10'Адреса віртуального методу: ';
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
  AlreadyInstalledMsg = 'FastMM4 вже встановлено.';
  AlreadyInstalledTitle = 'Вже встановлено.';
  OtherMMInstalledMsg = 'FastMM4 не може бути встановлено якщо вже встановлено інший менеджер пам’’яті.'
    + #13#10'Якщо ви бажаєте використовувати FastMM4, будь-ласка переконайтесь що FastMM4.pas є самим першим модулем в'
    + #13#10'секції "uses" вашого .dpr файлу проекту.';
  OtherMMInstalledTitle = 'Неможливо встановити FastMM4 - вже встановлено інший менеджер пам’’яті.';
  MemoryAllocatedMsg = 'FastMM4 неможливо встановити коли пам’’ять вже була '
    + 'виділена стандартним менеджером пам’’яти.'#13#10'FastMM4.pas ПОВИНЕН '
    + 'бути першим модулем у вашому файлі .dpr файлі проекту, інакше пам’’ять може '
    + 'бути виділена'#13#10'через стандартний менеджер пам’’яті перед тим як FastMM4 '
    + 'отримає контроль. '#13#10#13#10'Якщо ви використовуєте обробник особливих ситуацій, '
    + 'наприклад MadExcept (або будь-який інший інструмент що модифікує порядок ініціалізації '
    + 'модулей),'#13#10'тоді перейдіть на сторінку його конфігурації та переконайтеся, що '
    + 'FastMM4.pas модуль ініціалізується перед будь-яким іншим модулем.';
  MemoryAllocatedTitle = 'Неможливо встановити FastMM4 - Пам’’ять вже була виділена';
  {Leak checking messages}
  LeakLogHeader = 'Блок пам’’яті був виділений та не звільнений. Розмір: ';
  LeakMessageHeader = 'В цьому додатку відбуваються втрати пам’’яті.';
  SmallLeakDetail = 'Втрати блоків пам''яті маленького розміру'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (за винятком очікуваних втрат пам''яті зареєстрованих по вказівнику)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'Розміри втрат блоків пам''яті середнього розміру'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (за винятком очікуваних втрат пам''яті зареєстрованих по вказівнику)'
{$endif}
    + ': ';
  BytesMessage = ' байт: ';
  AnsiStringBlockMessage = 'AnsiString';
  UnicodeStringBlockMessage = 'UnicodeString';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Note: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Ця перевірка втрати пам’’яті виконується лише у випадку одночасної роботи Delphi на тому ж комп’’ютері. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'Детальна інформація про втрату и пам’’яті журналюється у текстовий файл в тому ж каталозі, що й додаток. '
    {$else}
    + 'Включіть "LogMemoryLeakDetailToFile" для того щоб отримати журнал, що містить детальну інформацію про втрату пам’’яті. '
    {$endif}
  {$else}
    + 'Для того щоб отримати журнал, що містить детальну інформацію про втрату пам’’яті, включіть умови компіляції "FullDebugMode" та "LogMemoryLeakDetailToFile". '
  {$endif}
    + 'Для того щоб виключити ці перевірки втрат пам’’яті, необхідно видалити визначення "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Виявлено втрату пам’’яті';
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

