{

Fast Memory Manager: Messages

French translation by Florent Ouchet.

}

unit FastMM4Messages;

interface

{$Include FastMM4Options.inc}

const
  {The name of the debug info support DLL}
  FullDebugModeLibraryName32Bit = 'FastMM_FullDebugMode.dll';
  FullDebugModeLibraryName64Bit = 'FastMM_FullDebugMode64.dll';
  {Event log strings}
  LogFileExtension = '_MemoryManager_Rapport.txt'#0;
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Class name messages}
  UnknownClassNameMsg = 'Inconnu';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'Contenu des 256 octets commençant à l''adresse ';
  {Block Error Messages}
  BlockScanLogHeader = 'Bloc alloué rapporté par LogAllocatedBlocksToFile. Sa taille est: ';
  ErrorMsgHeader = 'FastMM a détecté une erreur pendant un ';
  GetMemMsg = 'appel à GetMem';
  FreeMemMsg = 'appel à FreeMem';
  ReallocMemMsg = 'appel à ReallocMem';
  BlockCheckMsg = 'scan des blocs libres';
  OperationMsg = '. ';
  BlockHeaderCorruptedMsg = 'L''en-tête du bloc a été corrompue. ';
  BlockFooterCorruptedMsg = 'La fin du bloc a été corrompue. ';
  FreeModifiedErrorMsg = 'FastMM a détecté qu''un bloc a été modifié après avoir été libéré. ';
  FreeModifiedDetailMsg = #13#10#13#10'Modified byte offsets (and lengths): ';
  DoubleFreeErrorMsg = 'Tentative d''appeler free ou reallocate pour un bloc déjà libéré.';
  WrongMMFreeErrorMsg = 'An attempt has been made to free/reallocate a block that was allocated through a different FastMM instance. Check your memory manager sharing settings.';
  PreviousBlockSizeMsg = #13#10#13#10'La taille précédente du bloc était: ';
  CurrentBlockSizeMsg = #13#10#13#10'La taille du bloc est: ';
  PreviousObjectClassMsg = #13#10#13#10'Le bloc était précédemment utilisé pour un objet de la classe: ';
  CurrentObjectClassMsg = #13#10#13#10'Le bloc était actuellement utilisé pour un objet de la classe: ';
  PreviousAllocationGroupMsg = #13#10#13#10'Le groupe d''allocations était: ';
  PreviousAllocationNumberMsg = #13#10#13#10'Le nombre d''allocations était: ';
  CurrentAllocationGroupMsg = #13#10#13#10'Le groupe d''allocation est: ';
  CurrentAllocationNumberMsg = #13#10#13#10'Le nombre d''allocations est: ';
  BlockErrorMsgTitle = 'Erreur mémoire détectée';
  VirtualMethodErrorHeader = 'FastMM a détecté une tentative d''appel d''une méthode virtuelle d''un objet libéré. Une violation d''accès va maintenant être levée dans le but d''annuler l''opération courante.';
  InterfaceErrorHeader = 'FastMM a détecté une tentative d''utilisation d''une interface d''un objet libéré. Une violation d''accès va maintenant être levée dans le but d''annuler l''opération courante.';
  BlockHeaderCorruptedNoHistoryMsg = ' La corruption de l''entête du bloc ne permet pas l''obtention de l''historique.';
  FreedObjectClassMsg = #13#10#13#10'Classe de l''objet libéré: ';
  VirtualMethodName = #13#10#13#10'Méthode virtuelle: ';
  VirtualMethodOffset = 'Décalage +';
  VirtualMethodAddress = #13#10#13#10'Adresse de la méthode virtuelle: ';
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
  AlreadyInstalledMsg = 'FastMM4 est déjà installé.';
  AlreadyInstalledTitle = 'Déjà installé.';
  OtherMMInstalledMsg = 'FastMM4 ne peut pas être installé puisqu''un autre gestionnaire de mémoire s''est déjà installé.'#13#10
    + 'Pour utiliser FastMM4, FastMM4.pas doit être la toute première unité dans la section "uses" du fichier projet .dpr';
  OtherMMInstalledTitle = 'Impossible d''installer FastMM4 - un autre gestionnaire de mémoire est déjà installé';
  MemoryAllocatedMsg = 'FastMM4 ne peut pas être installé puisque des blocs de mémoire ont déjà été alloué par le gestionnaire de mémoire par défaut.'#13#10
    + 'FastMM4.pas DOIT être la première unité dans la section "uses" du fichier projet .dpr; dans le cas contraire, des blocs de mémoire '#1310
    + 'peuvent être alloués avant que FastMM4 ne prenne le contrôle, si vous utilisez un gestionnaire d''exception comme MadExcept '#1310
    + '(ou tout autre outil qui modifie l''ordre d''initialisation des unités). Veuillez modifier sur la page de configuration de cet outil'#1310
    + 'l''ordre d''initialisation des unités pour que FastMM4.pas soit initialisée avant tout autre unité';
  MemoryAllocatedTitle = 'Impossible d''installer FastMM4 - des blocs de mémoire ont déjà été alloués';
  {Leak checking messages}
  LeakLogHeader = 'Une fuite mémoire a été détectée. Sa taille est: ';
  LeakMessageHeader = 'Cette application a fuit de la mémoire. ';
  SmallLeakDetail = 'Les fuites de petits blocs sont'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluant toutes les fuites masquées)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'Les tailles des blocs moyens et grands sont'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluant toutes les fuites masquées)'
{$endif}
    + ': ';
  BytesMessage = ' octets: ';
  AnsiStringBlockMessage = 'AnsiString';
  UnicodeStringBlockMessage = 'UnicodeString';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Conseil: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Cette vérification des fuites mémoire n''est effectué que si Delphi est actuellement exécuté sur la même machine. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'Les détails des fuites de mémoire sont rapportés dans un fichier texte dans le même répertoire que l''application. '
    {$else}
    + 'Activez l''option "LogMemoryLeakDetailToFile" pour obtenir un fichier rapportant les détails des fuites de mémoire. '
    {$endif}
  {$else}
    + 'Pour obtenir un fichier rapport contenant les détails des fuites de mémoire, activez les options de compilation "FullDebugMode" et "LogMemoryLeakDetailToFile". '
  {$endif}
    + 'Pour désactiver cette vérification des fuites mémoires, désactivez l''option de compilation "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Fuite mémoire détectée';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM a été installé.';
  FastMMInstallSharedMsg = 'Partageant un exemplaire existant de FastMM.';
  FastMMUninstallMsg = 'FastMM a été désinstallé.';
  FastMMUninstallSharedMsg = 'Fin du partage avec un exemplaire existant de FastMM.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'Operation MM après la désinstallation.';
  InvalidGetMemMsg = 'FastMM a détecté un appel à GetMem après que FastMM ait été désinstallé.';
  InvalidFreeMemMsg = 'FastMM a détecté un appel à FreeMem après que FastMM ait été désinstallé.';
  InvalidReallocMemMsg = 'FastMM a détecté un appel à ReallocMem après que FastMM ait été désinstallé.';
  InvalidAllocMemMsg = 'FastMM a détecté un appel à AllocMem après que FastMM ait été désinstallé.';
{$endif}

implementation

end.

