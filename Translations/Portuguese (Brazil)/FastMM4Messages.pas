{

Fast Memory Manager: Messages

Portuguese (Brazil) translation by Johni Jeferson Capeletto (capeletto@gmail.com) - Love you Julia.

}

unit FastMM4Messages;

interface

{$Include FastMM4Options.inc}

const
  {The name of the debug info support DLL}
  FullDebugModeLibraryName32Bit = 'FastMM_FullDebugMode.dll';
  FullDebugModeLibraryName64Bit = 'FastMM_FullDebugMode64.dll';
  {Event log strings}
  LogFileExtension = '_MemoryManager_EventosLog.txt'#0;
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Class name messages}
  UnknownClassNameMsg = 'Desconhecida';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'Dump de memória atual de 256 bytes iniciando no endereço ';
  {Block Error Messages}
  BlockScanLogHeader = 'Bloco alocado logado por LogAllocatedBlocksToFile. O tamanho é: ';
  ErrorMsgHeader = 'FastMM detectou um erro durante ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = 'busca de bloco livre';
  OperationMsg = ' operação. ';
  BlockHeaderCorruptedMsg = 'O cabeçalho do bloco foi corrompido. ';
  BlockFooterCorruptedMsg = 'O rodapé do bloco foi corrompido. ';
  FreeModifiedErrorMsg = 'FastMM detectou que um bloco foi modificado após ter sido liberado. ';
  FreeModifiedDetailMsg = #13#10#13#10'Modified byte offsets (and lengths): ';
  DoubleFreeErrorMsg = 'Uma tentativa foi feita para liberar/realocar um bloco não alocado.';
  WrongMMFreeErrorMsg = 'An attempt has been made to free/reallocate a block that was allocated through a different FastMM instance. Check your memory manager sharing settings.';
  PreviousBlockSizeMsg = #13#10#13#10'O tamanho anterior do bloco era: ';
  CurrentBlockSizeMsg = #13#10#13#10'O tamanho do bloco é: ';
  PreviousObjectClassMsg = #13#10#13#10'O bloco foi usado anteriormente por um objeto da classe: ';
  CurrentObjectClassMsg = #13#10#13#10'O bloco está sendo usado por um objeto da classe: ';
  PreviousAllocationGroupMsg = #13#10#13#10'O grupo de alocação era: ';
  PreviousAllocationNumberMsg = #13#10#13#10'O número da alocação era: ';
  CurrentAllocationGroupMsg = #13#10#13#10'O grupo de alocação é: ';
  CurrentAllocationNumberMsg = #13#10#13#10'O número da alocação é: ';
  BlockErrorMsgTitle = 'Erro de memória detectado';
  VirtualMethodErrorHeader = 'FastMM detectou uma tentativa de chamada a um método virtual de um objeto liberado. Uma violação de acesso será disparada para abortar a operação corrente.';
  InterfaceErrorHeader = 'FastMM detectou uma tentativa de uso de uma interface de um objeto liberado. Uma violação de acesso será disparada para abortar a operação corrente.';
  BlockHeaderCorruptedNoHistoryMsg = ' Infelizmente o cabeçalho do bloco foi corrompido e a história não está disponível.';
  FreedObjectClassMsg = #13#10#13#10'Classe do objeto liberado: ';
  VirtualMethodName = #13#10#13#10'Método virtual: ';
  VirtualMethodOffset = 'Offset +';
  VirtualMethodAddress = #13#10#13#10'Endereço do método virtual: ';
  {Stack trace messages}
  CurrentThreadIDMsg = #13#10#13#10'O ID da thread atual é 0x';
  CurrentStackTraceMsg = ', e a análise da pilha interna (endereços de retorno) que levaram a este erro é:';
  ThreadIDPrevAllocMsg = #13#10#13#10'Este bloco foi criado anteriormente pela thread 0x';
  ThreadIDAtAllocMsg = #13#10#13#10'Este bloco foi alocado pela thread 0x';
  ThreadIDAtFreeMsg = #13#10#13#10'Este bloco foi liberado anteriormente pela thread 0x';
  ThreadIDAtObjectAllocMsg = #13#10#13#10'O objeto foi alocado pela thread 0x';
  ThreadIDAtObjectFreeMsg = #13#10#13#10'O objeto foi liberado posteriormente pela thread 0x';
  StackTraceMsg = ', e a análise da pilha interna (endereços de retorno) no momento era:';
  {Installation Messages}
  AlreadyInstalledMsg = 'FastMM4 já foi instalado.';
  AlreadyInstalledTitle = 'Já foi instalado.';
  OtherMMInstalledMsg = 'FastMM4 não pode ser instalado já que outro gerenciador externo '
    + 'de memória já foi instalado.'#13#10'Se você quer usar o FastMM4, '
    + 'tenha certeza que a unit FastMM4.pas seja a primeira na seção "uses"'
    + #13#10'do arquivo .dpr do seu projeto.';
  OtherMMInstalledTitle = 'Impossível instalar FastMM4 - Outro gerenciador de memória já está instalado';
  MemoryAllocatedMsg = 'O FastMM4 não pode ser instalado já que a memória já foi '
    + 'alocada através do gerenciador de memória padrão.'#13#10'FastMM4.pas DEVE '
    + 'ser a primeira unit no arquivo .dpr do seu projeto, caso contrário a memória pode '
    + 'ser alocada'#13#10'através do gerenciador de memória padrão antes que o FastMM '
    + 'ganhe o controle. '#13#10#13#10'Se você estiver usando um interceptador de exceções '
    + 'como MadExcept (ou qualquer outra ferramenta que modifica a ordem de inicialização da '
    + 'unit),'#13#10'vá para sua página de configuração e tenha certeza que a unit '
    + 'FastMM4.pas seja inicializada antes de qualquer outra unit.';
  MemoryAllocatedTitle = 'Impossível instalar FastMM4 - A memória já foi alocada';
  {Leak checking messages}
  LeakLogHeader = 'Um bloco de memória vazou. O tamanho é: ';
  LeakMessageHeader = 'Essa aplicação teve vazamentos de memória. ';
  SmallLeakDetail = 'Os vazamentos dos blocos pequenos são'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluindo os vazamentos esperados registrados por ponteiro)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'O tamanho dos vazamentos dos blocos médios e grandes são'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (excluindo os vazamentos esperados registrados por ponteiro)'
{$endif}
    + ': ';
  BytesMessage = ' bytes: ';
  AnsiStringBlockMessage = 'AnsiString';
  UnicodeStringBlockMessage = 'UnicodeString';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Nota: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Essa checagem de vazamento de memória somente é feita se o Delphi está rodando atualmente no mesmo computador. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'O detalhe do vazamento de memória está logado em um arquivo texto na mesma pasta que essa aplicação. '
    {$else}
    + 'Habilite o DEFINE "LogMemoryLeakDetailToFile" para obter um arquivo de log contendo detalhes dos vazamentos de memória. '
    {$endif}
  {$else}
    + 'Para obter um arquivo de log contendo detalhes dos vazamentos de memória, habilite os DEFINES "FullDebugMode" e "LogMemoryLeakDetailToFile". '
  {$endif}
    + 'Para desabilitar essa checagem de vazamento de memória, desabilite o DEFINE "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Vazamento de memória detectado';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM foi instalado.';
  FastMMInstallSharedMsg = 'Compartilhando uma instancia existente do FastMM.';
  FastMMUninstallMsg = 'FastMM foi desinstalado.';
  FastMMUninstallSharedMsg = 'Parando de compartilhar uma instancia existente do FastMM.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'Operação no Gerenciador de Memória após desinstalação.';
  InvalidGetMemMsg = 'FastMM detectou uma chamada GetMem depois que o FastMM foi desinstalado.';
  InvalidFreeMemMsg = 'FastMM detectou uma chamada FreeMem depois que o FastMM foi desinstalado.';
  InvalidReallocMemMsg = 'FastMM detectou uma chamada ReallocMem depois que o FastMM foi desinstalado.';
  InvalidAllocMemMsg = 'FastMM detectou uma chamada ReallocMem depois que o FastMM foi desinstalado.';
{$endif}

implementation

end.

