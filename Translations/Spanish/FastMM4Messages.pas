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
  FullDebugModeLibraryName32Bit = 'FastMM_FullDebugMode.dll';
  FullDebugModeLibraryName64Bit = 'FastMM_FullDebugMode64.dll';
  {Event log strings}
  LogFileExtension = '_ManipuladorMemoria_Reporte.txt'#0;
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Class name messages}
  UnknownClassNameMsg = 'Desconocida';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'Vaciado de memoria actual de 256 bytes en la dirección ';
  {Block Error Messages}
  BlockScanLogHeader = 'El bloque reservado fue registrado por LogAllocatedBlocksToFile. El tamaño es: ';
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
  WrongMMFreeErrorMsg = 'Se realizó un intento de liberar/reasignar un bloque reservado a través de una instancia distinta de FastMM. Chequee las opciones de uso compartido de su manipulador de memoria.';
  PreviousBlockSizeMsg = #13#10#13#10'El tamaño anterior del bloque era: ';
  CurrentBlockSizeMsg = #13#10#13#10'El tamaño del bloque es: ';
  PreviousObjectClassMsg = #13#10#13#10'El bloque estuvo anteriormente reservado para un objeto de clase: ';
  CurrentObjectClassMsg = #13#10#13#10'El bloque está reservado para un objeto de clase: ';
  PreviousAllocationGroupMsg = #13#10#13#10'El grupo de la reservación fue: ';
  PreviousAllocationNumberMsg = #13#10#13#10'El número de la reservación fue: ';
  CurrentAllocationGroupMsg = #13#10#13#10'El grupo de la reservación es: ';
  CurrentAllocationNumberMsg = #13#10#13#10'El número de la reservación es: ';
  BlockErrorMsgTitle = 'Detectado error de memoria';
  VirtualMethodErrorHeader =
    'FastMM ha detectado un intento de ejecutar un método virtual de un objeto liberado. Una violación de acceso se generará ahora para abortar la operación.';
  InterfaceErrorHeader =
    'FastMM ha detectado un intento de utlización de una interfaz de un objeto liberado. Una violación de acceso se generará ahora para abortar la operación.';
  BlockHeaderCorruptedNoHistoryMsg =
    ' Desafortunadamente el encabezamiento de bloque ha sido corrompido, así que no hay historia disponible.';
  FreedObjectClassMsg = #13#10#13#10'Clase del objeto liberado: ';
  VirtualMethodName = #13#10#13#10'Método virtual: ';
  VirtualMethodOffset = 'Desplazamiento +';
  VirtualMethodAddress = #13#10#13#10'Dirección del método virtual: ';
  {Stack trace messages}
  CurrentThreadIDMsg = #13#10#13#10'El ID del hilo actual es 0x';
  CurrentStackTraceMsg = ', y el vaciado del stack (direcciones de retorno) que conduce a este error es:';
  ThreadIDPrevAllocMsg = #13#10#13#10'Este bloque fue previamente reservado por el hilo 0x';
  ThreadIDAtAllocMsg = #13#10#13#10'Este bloque fue reservado por el hilo 0x';
  ThreadIDAtFreeMsg = #13#10#13#10'Este bloque fue previamente liberado por el hilo 0x';
  ThreadIDAtObjectAllocMsg = #13#10#13#10'El objeto fue reservado por el hilo 0x';
  ThreadIDAtObjectFreeMsg = #13#10#13#10'El objeto fue posteriormente liberado por el hilo 0x';
  StackTraceMsg = ', y el vaciado del stack (direcciones de retorno) en ese momento es:';
  {Installation Messages}
  AlreadyInstalledMsg = 'FastMM4 ya ha sido instalado.';
  AlreadyInstalledTitle = 'Ya instalado.';
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
  LeakLogHeader = 'Ha habido una fuga de memoria. El tamaño del bloque es: ';
  LeakMessageHeader = 'Esta aplicación ha tenido fugas de memoria. ';
  SmallLeakDetail = 'Las fugas de memoria en los bloques pequeños son'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluyendo las fugas esperadas registradas por apuntador)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'Las fugas de memoria de bloques medianos y grandes son'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluyendo las fugas esperadas registrados por apuntador)'
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
    + 'Habilite "LogMemoryLeakDetailToFile" para obtener un *log* con los detalles de los escapes de memoria. '
    {$endif}
  {$else}
    + 'Para obtener un *log* con los detalles de los escapes de memoria, abilite las definiciones condicionales "FullDebugMode" y "LogMemoryLeakDetailToFile". '
  {$endif}
    + 'Para deshabilitar este chequeo de fugas de memoria, indefina "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Detectada fuga de memoria';
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

