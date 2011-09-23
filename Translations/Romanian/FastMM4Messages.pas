{

Fast Memory Manager: Messages

Romanian translation by Ionut Muntean

}

unit FastMM4Messages;

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
  UnknownClassNameMsg = 'Necunoscut';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'Dump curent 256 bytes incepand cu adresa pointerului: ';
  {Block Error Messages}
  BlockScanLogHeader = 'Bloc memorie alocat de LogAllocatedBlocksToFile. Dimensiunea este de: ';
  ErrorMsgHeader = 'FastMM a detectat o eroare in ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = 'scanarea blocurilor libere';
  OperationMsg = ' operatie. ';
  BlockHeaderCorruptedMsg = 'Inceputul (header) de bloc este corupt. ';
  BlockFooterCorruptedMsg = 'Sfarsitul (footer) de bloc este corupt. ';
  FreeModifiedErrorMsg = 'FastMM a detectat ca un bloc a fost modificat dupa eliberare. ';
  FreeModifiedDetailMsg = #13#10#13#10'Modified byte offsets (and lengths): ';
  DoubleFreeErrorMsg = 'A fost detectata o incercare de eliberare/realocare a unui bloc nealocat.';
  WrongMMFreeErrorMsg = 'An attempt has been made to free/reallocate a block that was allocated through a different FastMM instance. Check your memory manager sharing settings.';
  PreviousBlockSizeMsg = #13#10#13#10'Dimensiunea precedenta a blocului a fost de: ';
  CurrentBlockSizeMsg = #13#10#13#10'Dimensiunea blocului este de: ';
  PreviousObjectClassMsg = #13#10#13#10'Blocul de memorie a fost folosit inainte pentru un obiect de clasa: ';
  CurrentObjectClassMsg = #13#10#13#10'Blocul de memorie este folosit pentru un obiect de clasa: ';
  PreviousAllocationGroupMsg = #13#10#13#10'Grupul de alocare a fost: ';
  PreviousAllocationNumberMsg = #13#10#13#10': Numarul de alocare a fost';
  CurrentAllocationGroupMsg = #13#10#13#10'Grupul de alocare este: ';
  CurrentAllocationNumberMsg = #13#10#13#10'Numarul de alocare este: ';
  BlockErrorMsgTitle = 'A fost detectata o eroare de memorie';
  VirtualMethodErrorHeader = 'FastMM a detectat o incercare de apel a unei proceduri virtuale dupa ce obiectul a fost eliberat. O exceptie de tip "Access violation" va fi alocata pentru a stopa operatia curenta.';
  InterfaceErrorHeader = 'FastMM a detectat o incercare de utilizare a unei interfete a unui obiect deja eliberat. O exceptie de tip "Access violation" va fi alocata pentru a stopa operatia curenta.';
  BlockHeaderCorruptedNoHistoryMsg = ' Din pacate, inceputul (headerul) de bloc este atat de corupt incat nici un istoric pentru acesta nu poate fi stabilit.';
  FreedObjectClassMsg = #13#10#13#10'Clasa obiectului eliberat: ';
  VirtualMethodName = #13#10#13#10'Metoda virtuala: ';
  VirtualMethodOffset = 'Offset +';
  VirtualMethodAddress = #13#10#13#10'Adresa metoda virtuala: ';
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
  AlreadyInstalledMsg = 'FastMM4 este deja instalat.';
  AlreadyInstalledTitle = 'Deja instalat.';
  OtherMMInstalledMsg = 'FastMM4 nu poate fi instalat din cauza unui alt Memory Manager '
    + 'care este deja instalat in contextul curent.'#13#10'Daca doriti utilizarea FastMM4, '
    + 'asigurati-va ca FastMM4.pas este primul unit inclus in clauza "uses"'
    + 'din fisierul .dpr a proiectului Dvs..';
  OtherMMInstalledTitle = 'Nu pot instala FastMM4 - Un alt Memory Manager este deja instalat.';


//******************************************************************************************************


  MemoryAllocatedMsg =
      'FastMM4 nu poate fi instalat din cauza faptului ca memorie a fost deja alocata print MM implicit.'
    + #13#10'FastMM4.pas TREBUIE sa fie primul unit in fisierul .dpr al proiectului Dvs.'
    + #13#10#13#10'Daca utilizati un program de control al exceptiilor, cum ar fi '
    + 'MadExcept (ori orice alt instrument care modifica ordinea initializarii uniturilor'
    + 'FastMM4.pas ny other unit.';

    
//******************************************************************************************************


  MemoryAllocatedTitle = 'Nu pot instala FastMM4 - memorie deja alocata prin alte cai.';
  {Leak checking messages}
  LeakLogHeader = 'A aparut o pierdere de memorie alocata. Adresa este: ';
  LeakMessageHeader = 'Aceasta aplicatie pierde memorie. ';
  SmallLeakDetail = 'Pierderile de memorie in blocurile mici sunt:';
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluzand pierderile normale inregistrate de pointeri)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'Dimensiunile blocurilor medii si mari sunt'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluzand pierderile normale inregistrate de pointeri)'
{$endif}
    + ': ';
  BytesMessage = ' bytes: ';
  AnsiStringBlockMessage = 'AnsiString';
  UnicodeStringBlockMessage = 'UnicodeString';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Nota: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Testele de pierdere de memorie alocata sunt facute numai daca Delphi ruleaza pe acelasi computer.'
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'Detaliile sunt inregistrate intr-un fisier text in acelasi director cu aplicatia.'
    {$else}
    + 'Utilizati optiunea "LogMemoryLeakDetailsToFile" pentru a obtine inregistrarile despre pierderile de memorie alocata.'
    {$endif}
  {$else}
    + 'Pentru a obtine inregistrarile continand detalii despre pierderile de memorie, utilizati definirile conditionale "FullDebugMode" si "LogMemoryLeakDetailToFile"';
  {$endif}
    + 'Pentru a dezactiva testele de meorie, nu folositi definitia conditionala "LogMemoryLeakDetailToFile"';
{$endif}
    + #0;
  LeakMessageTitle = 'Pierderi de memorie alocata';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM a fost instalat.';
  FastMMInstallSharedMsg = 'Start al impartirii accesului la o instanta a FastMM.';
  FastMMUninstallMsg = 'FastMM a fost dezinstalat.';
  FastMMUninstallSharedMsg = 'Stop al impartirii accesului la o instanta a FastMM.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'Operatie Memory manager DUPA dezinstalater.';
  InvalidGetMemMsg = 'FastMM a detectat un apel GetMem dupa ce FastMM a fost dezinstalat.';
  InvalidFreeMemMsg = 'FastMM a detectat un apel FreeMem dupa ce FastMM a fost dezinstalat.';
  InvalidReallocMemMsg = 'FastMM a detectat un apel ReAllocMem dupa ce FastMM a fost dezinstalat.';
  InvalidAllocMemMsg = 'FastMM a detectat un apel GetMem dupa ce AllocMem a fost dezinstalat.';
{$endif}

implementation

end.

