{

Fast Memory Manager: Messages

Czech translation by Rene Mihula.

Modifications:
25.04.2005  rm       Added resource strings for FastMM v4.64 compilability
01.03.2007  rm       Corrections of keying mistakes
17.03.2007  rm       Update to version FastMM v4.90
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
  UnknownClassNameMsg = 'Neznámá tøída';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'Vıpis prvních 256 bytù pamìti, které zaèínají na adrese ';
  {Block Error Messages}
  BlockScanLogHeader = 'Alokované bloky byly zalogovány pomocí LogAllocatedBlocksToFile. Velikost je: ';
  ErrorMsgHeader = 'FastMM detekoval chyby bìhem operace ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = 'hledání prázdnıch blokù';
  OperationMsg = ' . ';
  BlockHeaderCorruptedMsg = 'Hlavièka bloku byla poškozena. ';
  BlockFooterCorruptedMsg = 'Patièka bloku byla poškozena. ';
  FreeModifiedErrorMsg = 'FastMM detekoval modifikaci bloku po jeho uvolnìní. ';
  FreeModifiedDetailMsg = #13#10#13#10'Modified byte offsets (and lengths): ';
  DoubleFreeErrorMsg = 'Probìhl pokus o uvolnìní / realokaci ji uvolnìného bloku.';
  WrongMMFreeErrorMsg = 'An attempt has been made to free/reallocate a block that was allocated through a different FastMM instance. Check your memory manager sharing settings.';
  PreviousBlockSizeMsg = #13#10#13#10'Pøedchozí velikost bloku: ';
  CurrentBlockSizeMsg = #13#10#13#10'Velikost bloku: ';
  PreviousObjectClassMsg = #13#10#13#10'Blok byl ji vyuit pro objekt typu: ';
  CurrentObjectClassMsg = #13#10#13#10'Blok je aktuálnì vyuíván pro objekt typu: ';
  PreviousAllocationGroupMsg = #13#10#13#10'Alokaèní skupina byla: '; //
  PreviousAllocationNumberMsg = #13#10#13#10'Alokaèní èíslo bylo: ';
  CurrentAllocationGroupMsg = #13#10#13#10'Alokaèní skupina je: ';
  CurrentAllocationNumberMsg = #13#10#13#10'Alokaèní èíslo je: ';
  BlockErrorMsgTitle = 'Detekována chyba práce s pamìtí';
  VirtualMethodErrorHeader = 'FastMM detekoval pokus o volání virtuální metody ji uvolnìného objektu. Pro ukonèení této operace bude nyní vyhozena vyjímka (access violation).';
  InterfaceErrorHeader = 'FastMM detekoval pokus o pøístup k interface ji uvolnìného objektu. Pro ukonèení této operace bude nyní vyhozena vyjímka (access violation).';
  BlockHeaderCorruptedNoHistoryMsg = ' Historie je nedostupná z dùvodu poškození hlavièky bloku.';
  FreedObjectClassMsg = #13#10#13#10'Typ uvolòovaného objektu: ';
  VirtualMethodName = #13#10#13#10'Název virtuální metody: ';
  VirtualMethodOffset = 'Offset +';
  VirtualMethodAddress = #13#10#13#10'Adresa virtuální metody: ';
  {Stack trace messages}
  CurrentThreadIDMsg = #13#10#13#10'ID aktivního vlákna (thread ID) je 0x';
  CurrentStackTraceMsg = ' a stav na zásobníku volání (návratové adresy) je následující:';
  ThreadIDPrevAllocMsg = #13#10#13#10'Tento blok byl ji jednou alokován vláknem 0x';
  ThreadIDAtAllocMsg = #13#10#13#10'Tento blok byl alokován vláknem 0x';
  ThreadIDAtFreeMsg = #13#10#13#10'Blok ji byl jednou uvolnìn vláknem 0x';
  ThreadIDAtObjectAllocMsg = #13#10#13#10'Objekt byl alokován vláknem 0x';
  ThreadIDAtObjectFreeMsg = #13#10#13#10'Objekt byl opakovanì uvolnìn vláknem 0x';
  StackTraceMsg = ' v okamiku, kdy zásobník volání obsahoval tyto návratové adresy:';
  {Installation Messages}
  AlreadyInstalledMsg = 'FastMM4 ji byl nainstalován.';
  AlreadyInstalledTitle = 'Nainstalováno.';
  OtherMMInstalledMsg = 'FastMM4 nemohl bıt nainstalován, protoe jinı memory '
    + 'manager (MM tøetí strany) ji byl nainstalován.'#13#10'Pro pouití FastMM4 '
    + 'zkontrolujte, zda je unita FastMM4.pas první unitou v sekci "uses" tohoto '
    + 'projektu (.dpr soubor).';
  OtherMMInstalledTitle = 'Nelze nainstalovat FastMM4 - Jinı memory manager je ji nainstalován';
  MemoryAllocatedMsg = 'FastMM4 nemohl bıt nainstalován, protoe jinı memory '
    + 'manager (standardní MM) ji byl nainstalován.'#13#10'Pro pouití FastMM4 '
    + 'zkontrolujte, zda je unita FastMM4.pas první unitou v sekci "uses" tohoto '
    + 'projektu (.dpr soubor).'#13#10#13#10
    + 'Pokud pouíváte nìjakı exception trapper (napø. MadExcept) nebo libovolnı '
    + 'jinı nástroj, kterı modifikuje poøadí sekcí initialization, nakonfigurujte '
    + 'jej tak, aby unita FastMM4.pas byla inicializována pøed všemi ostatními unitami.';
  MemoryAllocatedTitle = 'Nelze nainstalovat FastMM4 - Pamì ji byla alokována';
  {Leak checking messages}
  LeakLogHeader = 'Blok pamìti zùstal neuvolnìn. Velikost(i): ';
  LeakMessageHeader = 'Aplikace neuvolnila pouívanou pamì. ';
  SmallLeakDetail = 'Bloky malé velikosti'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (vyjma chyb registrovanıch pomocí ukazatelù)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'Bloky støední a velké velikosti'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (vyjma chyb registrovanıch pomocí ukazatelù)'
{$endif}
    + ': ';
  BytesMessage = ' bytù: ';
  AnsiStringBlockMessage = 'AnsiString';
  UnicodeStringBlockMessage = 'UnicodeString';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Poznámka: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Kontrola neuvolnìné pamìti je provádìna pouze pokud je prostøedí Delphi aktivní na tomté systému. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'Detailní informace o neuvolnìné pamìti jsou zapsány do textového souboru v adresáøi aplikace. '
    {$else}
    + 'Povolením direktivy "LogMemoryLeakDetailToFile" lze do souboru logu zapsat detailní informace o neuvolnìné pamìti. '
    {$endif}
  {$else}
    + 'Pro získání logu s detailními informacemi o neuvolnìné pamìti je potøeba povolit direktivy "FullDebugMode" a "LogMemoryLeakDetailToFile". '
  {$endif}
    + 'Vypnutím direktivy "EnableMemoryLeakReporting" lze deaktivovat tuto kontrolu neuvolnìné pamìti.'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Byla detekována neuvolnìná pamì (Memory Leak)';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM byl nataen.';
  FastMMInstallSharedMsg = 'Sdílení existující instance FastMM.';
  FastMMUninstallMsg = 'FastMM byl odinstalován.';
  FastMMUninstallSharedMsg = 'Zastaveno sdílení existující instance FastMM.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'Detekce MM volání po odinstalování FastMM.';
  InvalidGetMemMsg = 'FastMM detekoval volání GetMem, které probìhlo po odinstalaci FastMM.';
  InvalidFreeMemMsg = 'FastMM detekoval volání FreeMem, které probìhlo po odinstalaci FastMM.';
  InvalidReallocMemMsg = 'FastMM detekoval volání ReallocMem, které probìhlo po odinstalaci FastMM.';
  InvalidAllocMemMsg = 'FastMM detekoval volání ReallocMem, které probìhlo po odinstalaci FastMM.';
{$endif}

implementation

end.

