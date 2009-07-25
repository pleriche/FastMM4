{

Fast Memory Manager: Messages

Spanish translation by JRG (TheDelphiGuy@gmail.com).

Change Log:
  15 Feb 2006: Updated by Marcelo Montenegro.

}

unit FastMM4Messages;

interface

{$Include FastMM4Options.inc}

const
  {The name of the debug info support DLL}
  FullDebugModeLibraryName = 'FastMM_FullDebugMode.dll';
  {Event log strings}
  LogFileExtension = '_ManipuladorMemoria_Reporte.txt'#0;
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Class name messages}
  UnknownClassNameMsg = 'Desconocida';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'Vaciado de memoria actual de 256 bytes en la dirección ';
  {Block Error Messages}
  BlockScanLogHeader = 'Allocated block logged by LogAllocatedBlocksToFile. The size is: ';
  ErrorMsgHeader = 'FastMM ha detectado un error durante una operación ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = 'de búsqueda de bloque libre';
  OperationMsg = '. ';
  BlockHeaderCorruptedMsg = 'El encabezamiento de bloque ha sido corrompido. ';
  BlockFooterCorruptedMsg = 'La terminación de bloque ha sido corrompida. ';
  FreeModifiedErrorMsg = 'FastMM detectó que un bloque ha sido modificado luego de liberarse. ';
  FreeModifiedDetailMsg = #13#10#13#10'Modified byte offsets (and lengths): ';
  DoubleFreeErrorMsg = 'Se realizó un intento de liberar/reasignar un bloque no reservado.';
  WrongMMFreeErrorMsg = 'An attempt has been made to free/reallocate a block that was allocated through a different FastMM instance. Check your memory manager sharing settings.';
  PreviousBlockSizeMsg = #13#10#13#10'El tamaño anterior del bloque era: ';
  CurrentBlockSizeMsg = #13#10#13#10'El tamaño del bloque es: ';
  PreviousObjectClassMsg = #13#10#13#10'El bloque estuvo anteriormente reservado para un objeto de clase: ';
  CurrentObjectClassMsg = #13#10#13#10'El bloque está reservado para un objeto de clase: ';
  PreviousAllocationGroupMsg = #13#10#13#10'The allocation group was: ';
  PreviousAllocationNumberMsg = #13#10#13#10'The allocation number was: ';
  CurrentAllocationGroupMsg = #13#10#13#10'The allocation group is: ';
  CurrentAllocationNumberMsg = #13#10#13#10'The allocation number is: ';
  BlockErrorMsgTitle = 'Detectado Error de Memoria';
  VirtualMethodErrorHeader =
    'FastMM ha detectado un intento de ejecutar un método virtual de un objeto liberado. Una violación de acceso se generará ahora para abortar la operación.';
  InterfaceErrorHeader =
    'FastMM ha detectado un intento de utlización de una interfaz de un objeto liberado. Una violación de acceso se generará ahora para abortar la operación.';
  BlockHeaderCorruptedNoHistoryMsg =
    ' Desafortunadamente el encabezamiento de bloque ha sido corrompido así que no hay historia disponible.';
  FreedObjectClassMsg = #13#10#13#10'Clase del objeto liberado: ';
  VirtualMethodName = #13#10#13#10'Método virtual: ';
  VirtualMethodOffset = 'Desplazamiento +';
  VirtualMethodAddress = #13#10#13#10'Dirección del método virtual: ';
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
  AlreadyInstalledMsg = 'FastMM4 ya ha sido instalado.';
  AlreadyInstalledTitle = 'Ya Instalado.';
  OtherMMInstalledMsg =
    'FastMM4 no puede instalarse ya que otro manipulador de memoria alternativo se ha instalado anteriormente.'#13#10 +
    'Si desea utilizar FastMM4, por favor asegúrese de que FastMM4.pas es la primera unit en la sección "uses"'#13#10 +
    'del .DPR de su proyecto.';
  OtherMMInstalledTitle = 'FastMM4 no se puede instalar - Otro manipulador de memoria instalado';
  MemoryAllocatedMsg =
    'FastMM4 no puede instalarse ya que se ha reservado memoria mediante el manipulador de memoria estándar.'#13#10 +
    'FastMM4.pas TIENE que ser la primera unit en el fichero .DPR de su proyecto, de otra manera podría reservarse memoria'#13#10 +
    'mediante el manipulador de memoria estándar antes de que FastMM4 pueda ganar el control. '#13#10#13#10 +
    'Si está utilizando un interceptor de excepciones como MadExcept (o cualquier otra herramienta que modifique el orden de inicialización de las units),'#13#10 + //Fixed by MFM
    'vaya a su página de configuración y asegúrese de que FastMM4.pas es inicializada antes que cualquier otra unit.';
  MemoryAllocatedTitle = 'FastMM4 no se puede instalar - Ya se ha reservado memoria';
  {Leak checking messages}
  LeakLogHeader = 'Un bloque de memoria ha escapado. El tamaño es: ';
  LeakMessageHeader = 'Esta aplicación ha tenido escapes de memoria. ';
  SmallLeakDetail = 'Los escapes de bloques pequeños son'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluyendo los escapes esperados registrados por apuntador)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'Los escapes de bloques medianos y grandes son'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluyendo los escapes esperados registrados por apuntador)'
{$endif}
    + ': ';
  BytesMessage = ' bytes: ';
  AnsiStringBlockMessage = 'AnsiString';
  UnicodeStringBlockMessage = 'UnicodeString';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Nota: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Este chequeo de escape de memoria sólo se realiza si Delphi está ejecutándose en el mismo ordenador. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'Los detalles del escape de memoria se salvan a un fichero texto en la misma carpeta donde reside esta aplicación. '
    {$else}
    + 'Abilite "LogMemoryLeakDetailToFile" para obtener un *log* con los detalles de los escapes de memoria. '
    {$endif}
  {$else}
    + 'Para obtener un *log* con los detalles de los escapes de memoria, abilite las definiciones condicionales "FullDebugMode" y "LogMemoryLeakDetailToFile". '
  {$endif}
    + 'Para desabilitar este chequeo de escapes de memoria, indefina "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Detectado Escape de Memoria';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM ha sido instalado.';
  FastMMInstallSharedMsg = 'Compartiendo una instancia existente de FastMM.';
  FastMMUninstallMsg = 'FastMM ha sido desinstalado.';
  FastMMUninstallSharedMsg = 'Cesando de compartir una instancia existente de FastMM.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'Operación en el MM luego de desinstalarlo.';
  InvalidGetMemMsg = 'FastMM ha detectado una llamada a GetMem luego de desinstalar FastMM.';
  InvalidFreeMemMsg = 'FastMM ha detectado una llamada a FreeMem luego de desinstalar FastMM.';
  InvalidReallocMemMsg = 'FastMM ha detectado una llamada a ReallocMem luego de desinstalar FastMM.';
  InvalidAllocMemMsg = 'FastMM ha detectado una llamada a ReallocMem luego de desinstalar FastMM.';
{$endif}

implementation

end.

