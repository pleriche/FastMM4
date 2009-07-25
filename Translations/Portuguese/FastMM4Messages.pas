{

Fast Memory Manager: Messages

Portuguese translation by Carlos Mação (Carlos.Macao@gmail.com).

}

unit FastMM4Messages;

interface

{$Include FastMM4Options.inc}

const
  {The name of the debug info support DLL}
  FullDebugModeLibraryName = 'FastMM_FullDebugMode.dll';
  {Event log strings}
  LogFileExtension = '_MemoryManager_EventosLog.txt'#0;
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Class name messages}
  UnknownClassNameMsg = 'Desconhecida';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'O Dump de memória actual de 256 bytes tem inicio no endereço ';
  {Block Error Messages}
  BlockScanLogHeader = 'Bloco atribuído registado por LogAllocatedBlocksToFile. O Tamanho é: ';
  ErrorMsgHeader = 'FastMM detectou um erro durante ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = 'procura de bloco livre';
  OperationMsg = ' operação. ';
  BlockHeaderCorruptedMsg = 'O cabeçalho do bloco foi corrompido. ';
  BlockFooterCorruptedMsg = 'O rodapé do bloco foi corrompido. ';
  FreeModifiedErrorMsg = 'FastMM detectou que um bloco de memória foi modificado após ter sido libertado. ';
  FreeModifiedDetailMsg = #13#10#13#10'Modified byte offsets (and lengths): ';
  DoubleFreeErrorMsg = 'Foi feita uma tentativa para libertar/atribuir um bloco não atribuido.';
  WrongMMFreeErrorMsg = 'An attempt has been made to free/reallocate a block that was allocated through a different FastMM instance. Check your memory manager sharing settings.';
  PreviousBlockSizeMsg = #13#10#13#10'O tamanho anterior do bloco era: ';
  CurrentBlockSizeMsg = #13#10#13#10'O tamanho do bloco é: ';
  PreviousObjectClassMsg = #13#10#13#10'O bloco foi usado anteriormente por um objecto da classe: ';
  CurrentObjectClassMsg = #13#10#13#10'O bloco está sendo usado por um objecto da classe: ';
  PreviousAllocationGroupMsg = #13#10#13#10'O grupo de atribuição era: ';
  PreviousAllocationNumberMsg = #13#10#13#10'O número de atribuição era: ';
  CurrentAllocationGroupMsg = #13#10#13#10'O grupo de atribuição é: ';
  CurrentAllocationNumberMsg = #13#10#13#10'O número de atribuição era: ';
  BlockErrorMsgTitle = 'Erro de memória detectado';
  VirtualMethodErrorHeader = 'FastMM detectou uma tentativa de chamada a um método virtual de um objecto libertado. Uma violação de acesso será iniciada para abortar a operação corrente.';
  InterfaceErrorHeader = 'FastMM detectou uma tentativa de uso de uma interface de um objecto libertado. Uma violação de acesso será iniciada para abortar a operação corrente.';
  BlockHeaderCorruptedNoHistoryMsg = ' Infelizmente o cabeçalho do bloco foi corrompido e o histórico não está disponível.';
  FreedObjectClassMsg = #13#10#13#10'Classe do objecto libertado: ';
  VirtualMethodName = #13#10#13#10'Método virtual: ';
  VirtualMethodOffset = 'Deslocamento +';
  VirtualMethodAddress = #13#10#13#10'Endereço do método virtual: ';
  {Stack trace messages}
  CurrentThreadIDMsg = #13#10#13#10'O ID da thread actual é 0x';
  CurrentStackTraceMsg = ', e a análise da pilha interna (endereços de retorno) que conduziram a este erro é:';
  ThreadIDPrevAllocMsg = #13#10#13#10'Este bloco foi préviamente criado pela thread 0x';
  ThreadIDAtAllocMsg = #13#10#13#10'Este bloco foi criado pela thread 0x';
  ThreadIDAtFreeMsg = #13#10#13#10'Este bloco foi préviamente libertado pela thread 0x';
  ThreadIDAtObjectAllocMsg = #13#10#13#10'O objecto foi criado pela thread 0x';
  ThreadIDAtObjectFreeMsg = #13#10#13#10'O objecto foi posteriormente libertado pela thread 0x';
  StackTraceMsg = ', e a análise da pilha interna (endereços de retorno) nesse momento era:';
  {Installation Messages}
  AlreadyInstalledMsg = 'FastMM4 já se encontra instalado.';
  AlreadyInstalledTitle = 'Já se encontra instalado.';
  OtherMMInstalledMsg = 'FastMM4 não pôde ser instalado já que outro gestor '
    + 'de memória externo já foi instalado.'#13#10'Se você quer usar o FastMM4, '
    + 'garanta que a unit FastMM4.pas é a primeira na secção "uses"'
    + #13#10'do ficheiro .dpr do seu projecto.';
  OtherMMInstalledTitle = 'Impossível instalar FastMM4 - Outro gestor de memória já se encontra instalado';
  MemoryAllocatedMsg = 'O FastMM4 não pode ser instalado já que a memória já foi '
    + 'atribuida através do gestor de memória padrão.'#13#10'FastMM4.pas DEVE '
    + 'ser a primeira unit no arquivo .dpr do seu projecto, caso contrário a memória pode '
    + 'ser atribuida'#13#10'através do gestor de memória padrão antes que o FastMM '
    + 'obtenha o controle. '#13#10#13#10'Se você estiver usando um interceptador de excepções '
    + 'como MadExcept (ou qualquer outra ferramenta que modifica a ordem de inicialização da '
    + 'unit),'#13#10'vá para sua página de configuração e assegure-se que a unit '
    + 'FastMM4.pas ''é inicializada antes de qualquer outra unit.';
  MemoryAllocatedTitle = 'Impossível instalar FastMM4 - A memória já foi atribuida';
  {Leak checking messages}
  LeakLogHeader = 'Um bloco de memória não foi libertado. O tamanho é: ';
  LeakMessageHeader = 'Esta aplicação teve fugas de memória. ';
  SmallLeakDetail = 'As fugas dos blocos pequenos são'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluindo as fugas esperadas, registadas por ponteiro)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'O tamanho das fugas dos blocos médios e grandes é'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluindo as fugas esperadas registadas por ponteiro)'
{$endif}
    + ': ';
  BytesMessage = ' bytes: ';
  AnsiStringBlockMessage = 'AnsiString';
  UnicodeStringBlockMessage = 'UnicodeString';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Nota: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Os testes de fugas de memória só serão efectuados se o Delphi estiver activo no mesmo computador. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'O detalhe da fuga de memória foi registado num ficheiro de texto na mesma pasta desta aplicação. '
    {$else}
    + 'Active o DEFINE "LogMemoryLeakDetailToFile" para obter um ficheiro de registos contendo detalhes das fugas de memória. '
    {$endif}
  {$else}
    + 'Para obter um ficheiro de registo contendo detalhes das fugas de memória, active os DEFINES "FullDebugMode" e "LogMemoryLeakDetailToFile". '
  {$endif}
    + 'Para activar a detecção de fugas de memória, active o DEFINE "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Fuga de memória detectada';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM foi instalado.';
  FastMMInstallSharedMsg = 'Partilhando uma instância já existente do FastMM.';
  FastMMUninstallMsg = 'FastMM foi removido.';
  FastMMUninstallSharedMsg = 'Parando a partilha duma instância existente do FastMM.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'Operação com o gestor de Memória após a sua remoção.';
  InvalidGetMemMsg = 'FastMM detectou uma chamada a GetMem após a remoção do FastMM.';
  InvalidFreeMemMsg = 'FastMM detectou uma chamada a FreeMem após a remoção do FastMM.';
  InvalidReallocMemMsg = 'FastMM detectou uma chamada a ReallocMem após a remoção do FastMM.';
  InvalidAllocMemMsg = 'FastMM detectou uma chamada a ReallocMem após a remoção do FastMM.';
{$endif}

implementation

end.

