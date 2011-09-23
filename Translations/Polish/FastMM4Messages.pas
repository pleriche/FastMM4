{

Fast Memory Manager: Messages

Polish translation by Artur RedŸko (arturr@opegieka.pl).

}

unit FastMM4Messages;

interface

{$Include FastMM4Options.inc}

const
  {The name of the debug info support DLL}
  FullDebugModeLibraryName32Bit = 'FastMM_FullDebugMode.dll';
  FullDebugModeLibraryName64Bit = 'FastMM_FullDebugMode64.dll';
  {Event log strings}
  LogFileExtension = '_MemoryManager_raport.txt'#0;
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Class name messages}
  UnknownClassNameMsg = 'Nieznany';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'Aktualny zrzut pamiêci 256 bajtów zaczynaj¹cy siê od adresu ';
  {Block Error Messages}
  BlockScanLogHeader = 'Zaalokowany blok zapisany przez LogAllocatedBlocksToFile. Rozmiar : ';
  ErrorMsgHeader = 'FastMM wykry³ b³¹d podczas operacji ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = 'skanowania wolnego bloku';
  OperationMsg = '. ';
  BlockHeaderCorruptedMsg = 'Nag³ówek bloku jest uszkodzony. ';
  BlockFooterCorruptedMsg = 'Stopka bloku jest uszkodzona. ';
  FreeModifiedErrorMsg = 'FastMM wykry³ ¿e blok zosta³ zmodyfikowany po tym jak zosta³ zwolniony. ';
  FreeModifiedDetailMsg = #13#10#13#10'Modified byte offsets (and lengths): ';
  DoubleFreeErrorMsg = 'Wykryto próbê zwolnienia/realokacji niezaalokowanego bloku.';
  WrongMMFreeErrorMsg = 'An attempt has been made to free/reallocate a block that was allocated through a different FastMM instance. Check your memory manager sharing settings.';
  PreviousBlockSizeMsg = #13#10#13#10'Poprzedni rozmiar bloku by³: ';
  CurrentBlockSizeMsg = #13#10#13#10'Rozmiar bloku jest: ';
  PreviousObjectClassMsg = #13#10#13#10'Blok zosta³ poprzednio u¿yty w obiekcie klasy: ';
  CurrentObjectClassMsg = #13#10#13#10'Blok jest aktualnie u¿ywany w obiekcie klasy: ';
  PreviousAllocationGroupMsg = #13#10#13#10'By³a grupa alokacji : ';
  PreviousAllocationNumberMsg = #13#10#13#10'By³a iloœæ alokacji : ';
  CurrentAllocationGroupMsg = #13#10#13#10'Jest grupa alokacji : ';
  CurrentAllocationNumberMsg = #13#10#13#10'Jest iloœæ alokacji : ';
  BlockErrorMsgTitle = 'Wykryto b³¹d pamiêci';
  VirtualMethodErrorHeader = 'FastMM wykry³ próbê u¿ycia wirtualnej metody zwolnionego obiektu. Zostanie wygenerowany teraz wyj¹tek w celu przerwania aktualnej operacji.';
  InterfaceErrorHeader = 'FastMM wykry³ próbê u¿ycia interfejsu zwolnionego obiektu. Zostanie wygenerowany teraz wyj¹tek w celu przerwania aktualnej operacji.';
  BlockHeaderCorruptedNoHistoryMsg = ' Niestety nag³ówek bloku zosta³ uszkodzony wiêc historia nie jest dostêpna.';
  FreedObjectClassMsg = #13#10#13#10'Klasa zwolnionego obiektu: ';
  VirtualMethodName = #13#10#13#10'Metoda wirtualna: ';
  VirtualMethodOffset = 'przesuniêcie +';
  VirtualMethodAddress = #13#10#13#10'Adres metody wirtualnej: ';
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
  AlreadyInstalledMsg = 'FastMM4 jest ju¿ zainstalowany.';
  AlreadyInstalledTitle = 'Ju¿ zainstalowany.';
  OtherMMInstalledMsg = 'FastMM4 nie mo¿e byæ zainstalowany poniewa¿ inny mened¿er pamiêci '
    + 'zosta³ ju¿ zainstalowany.'#13#10'Jeœli chcesz u¿yæ FastMM4, '
    + 'zapewniaj¹c aby modu³ FastMM4.pas by³ zainicjowany jako pierwszy modu³ w twoim projekcie.';
  OtherMMInstalledTitle = 'Nie mo¿na zainstalowaæ FastMM4 - inny mened¿er pamiêci jest ju¿ zainstalowany';
  MemoryAllocatedMsg = 'FastMM4 nie mo¿e byæ zainstalowany poniewa¿ pamiêæ zosta³a '
    + 'juz zaalokowana przez domyœlny mened¿er pamiêci.'#13#10'FastMM4.pas MUSI '
    + 'byæ pierwszym modu³em w twoim projekcie, w przeciwnym wypadku pamiêæ mo¿e '
    + 'byæ zaalokowana'#13#10'przez domyœlny mened¿er pamiêci zanim FastMM4 '
    + 'przejmie kontrolê.'#13#10#13#10'Jeœli u¿ywasz aplikacji do przechwytywania wyj¹tków '
    + 'takich jak MadExcept,'#13#10'zmieñ jego konfiguracjê zapewniaj¹c aby modu³ '
    + 'FastMM4.pas by³ zainicjowany jako pierwszy modu³.';
  MemoryAllocatedTitle = 'Nie mo¿na zainstalowaæ FastMM4 - pamiêæ zosta³a ju¿ zaalokowana.'
    + 'FastMM4.pas jest inicjowany jako pierwszy modu³.';
  {Leak checking messages}
  LeakLogHeader = 'Wyciek³ blok pamiêci. Rozmiar wynosi: ';
  LeakMessageHeader = 'Aplikacja wykry³a wycieki pamiêci. ';
  SmallLeakDetail = 'Ma³e bloki wycieków s¹'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (wy³¹czaj¹c oczekiwane wycieki zarejestrowane przez wskaŸnik)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'Rozmiary œrednich i du¿ych wycieków wynosz¹'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (wy³¹czaj¹c oczekiwane wycieki zarejestrowane przez wskaŸnik)'
{$endif}
    + ': ';
  BytesMessage = ' bajtów: ';
  AnsiStringBlockMessage = 'AnsiString';
  UnicodeStringBlockMessage = 'UnicodeString';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Uwaga: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Sprawdzenie wycieków pamiêci wystêpuje tylko gdy Delphi jest uruchomione na tym samych komputerze. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'Szczegó³y wycieków s¹ rejestrowane w pliku tekstowym w tym samym katalogu co aplikacja. '
    {$else}
    + 'W³¹cz "LogMemoryLeakDetailToFile" aby uzyskaæ szczegó³owy plik z wyciekami pamiêci. '
    {$endif}
  {$else}
    + 'Aby uzyskaæ plik ze szczegó³ami wycieków pamiêci, w³¹cz definicje warunkowe "FullDebugMode" i "LogMemoryLeakDetailToFile". '
  {$endif}
    + 'Aby wy³¹czyæ raportowanie wycieków, wy³¹cz "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Wykryto wyciek pamiêci';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM zosta³ zainstalowany.';
  FastMMInstallSharedMsg = 'Rozpoczêcie wspó³dzielenia istniej¹cej instancji FastMM.';
  FastMMUninstallMsg = 'FastMM zosta³ odinstalowany.';
  FastMMUninstallSharedMsg = 'Zakoñczenie wspó³dzielenia istniej¹cej instancji FastMM.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'Operacja MM po deinstalacji.';
  InvalidGetMemMsg = 'FastMM wykry³ wywo³anie GetMem po tym jak FastMM zosta³ odinstalowany.';
  InvalidFreeMemMsg = 'FastMM wykry³ wywo³anie FreeMem po tym jak FastMM zosta³ odinstalowany.';
  InvalidReallocMemMsg = 'FastMM wykry³ wywo³anie ReallocMem po tym jak FastMM zosta³ odinstalowany.';
  InvalidAllocMemMsg = 'FastMM wykry³ wywo³anie AllocMem po tym jak FastMM zosta³ odinstalowany.';
{$endif}

implementation

end.

