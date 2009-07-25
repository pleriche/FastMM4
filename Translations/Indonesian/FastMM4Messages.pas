{

Fast Memory Manager: Messages

Indonesian translation by Zaenal Mutaqin.

}

unit FastMM4Messages;

interface

{$Include FastMM4Options.inc}

const
  {The name of the debug info support DLL}
  FullDebugModeLibraryName = 'FastMM_FullDebugMode.dll';
  {Event log strings}
  LogFileExtension = '_Laporan_ManajerMemori.txt'#0;
  CRLF = #13#10;
  EventSeparator = '--------------------------------';
  {Class name messages}
  UnknownClassNameMsg = 'Tidak dikenal';
  {Memory dump message}
  MemoryDumpMsg = #13#10#13#10'Dump memori saat ini dari 256 byte dimulai pada alamat pointer ';
  {Block Error Messages}
  BlockScanLogHeader = 'Allocated block logged by LogAllocatedBlocksToFile. The size is: ';
  ErrorMsgHeader = 'FastMM mendeteksi terjadi kesalahan sewaktu ';
  GetMemMsg = 'GetMem';
  FreeMemMsg = 'FreeMem';
  ReallocMemMsg = 'ReallocMem';
  BlockCheckMsg = 'membebaskan pemantauan blok';
  OperationMsg = ' operasi. ';
  BlockHeaderCorruptedMsg = 'Kepala blok sudah terkorupsi. ';
  BlockFooterCorruptedMsg = 'Kaki blok sudah terkorupsi. ';
  FreeModifiedErrorMsg = 'FastMM mendeteksi bahwa blok sudah diubah setelah dibebaskan. ';
  FreeModifiedDetailMsg = #13#10#13#10'Modified byte offsets (and lengths): ';
  DoubleFreeErrorMsg = 'Percobaan dilakukan untuk membebaskan/realokasi blok yang tidak dialokasikan';
  WrongMMFreeErrorMsg = 'An attempt has been made to free/reallocate a block that was allocated through a different FastMM instance. Check your memory manager sharing settings.';
  PreviousBlockSizeMsg = #13#10#13#10'Besar blok sebelumnya adalah: ';
  CurrentBlockSizeMsg = #13#10#13#10'Besar blok adalah: ';
  PreviousObjectClassMsg = #13#10#13#10'Blok yang sebelumnya digunakan untuk obyek dari kelas: ';
  CurrentObjectClassMsg = #13#10#13#10'Blok yang digunakan saat ini untuk obyek dari kelas: ';
  PreviousAllocationGroupMsg = #13#10#13#10'The allocation group was: ';
  PreviousAllocationNumberMsg = #13#10#13#10'The allocation number was: ';
  CurrentAllocationGroupMsg = #13#10#13#10'The allocation group is: ';
  CurrentAllocationNumberMsg = #13#10#13#10'The allocation number is: ';
  BlockErrorMsgTitle = 'Kesalahan Memori Terdeteksi';
  VirtualMethodErrorHeader = 'FastMM mendeteksi percobaan pemanggilan metode virtual pada obyek yang dibebaskan. Pelanggaran akses akan ditampilkan sekarang untuk membatalkan operasi saat ini.';
  InterfaceErrorHeader = 'FastMM mendeteksi percobaan penggunaan antar muka dari obyek yang sudah dibebaskan. Pelanggaran akses akan ditampilkan sekarang untuk membatalkan operasi saat ini.';
  BlockHeaderCorruptedNoHistoryMsg = ' Kebetulan kepala blok sudah terkorupsi oleh karenanya tidak ada histori yang tersedia.';
  FreedObjectClassMsg = #13#10#13#10'Kelas obyek yang dibebaskan: ';
  VirtualMethodName = #13#10#13#10'Metode virtual: ';
  VirtualMethodOffset = 'Ofset +';
  VirtualMethodAddress = #13#10#13#10'Alamat metode virtual: ';
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
  AlreadyInstalledMsg = 'FastMM4 sudah diinstalasi.';
  AlreadyInstalledTitle = 'Sudah terinstalasi.';
  OtherMMInstalledMsg = 'FastMM4 tidak bisa diinstalasi karena manajer memori pihak ketiga '
    + 'sudah menginstalasi dirinya sendiri.'#13#10'Jika anda ingin menggunakan FastMM4, '
    + 'pastikan bahwa FastMM4.pas adalah untit paling pertama dalam seksi "uses"'
    + #13#10'dari file proyek .dpr anda.';
  OtherMMInstalledTitle = 'Tidak bisa menginstalasi FastMM4 - Manajer memori lain sudah diinstalasi';
  MemoryAllocatedMsg = 'FastMM4 tidak bisa menginstalasi karena memori sudah '
    + 'dialokasikan melalui manajer memori default.'#13#10'FastMM4.pas HARUS '
    + 'unit pertama dalam file proyek .dpr anda, sebaliknya memori bisa '
    + 'dialokasikan '#13#10'melalui manajer memori default sebelum FastMM4 '
    + 'mendapatkan kontrolnya. '#13#10#13#10'Jika anda menggunakan penjebak kekecualian  '
    + 'seperti MadExcept (atau piranti lain yang mengubah urutan inisialiasai unit, '
    + #13#10'lihat ke dalam halaman konfigurasinya dan pastikan bahwa '
    + 'unit FastMM4.pas diinisialisasi sebelum unit lainnya.';
  MemoryAllocatedTitle = 'Tidak bisa menginstalasi FastMM4 - Memori sudah dialokasikan';
  {Leak checking messages}
  LeakLogHeader = 'Blok memori sudah bocor. Besarnya adalah: ';
  LeakMessageHeader = 'Aplikasi ini mempunyai kebocoran memori. ';
  SmallLeakDetail = 'Blok kecil kebocoran adalah'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (tidak termasuk kebocoran yang didaftarkan oleh pointer)'
{$endif}
    + ':'#13#10;
  LargeLeakDetail = 'Besar dari kebocoran blok medium dan besar adalah'
{$ifdef HideExpectedLeaksRegisteredByPointer}
    + ' (tidak termasuk kebocoran yang terdaftar oleh pointer)'
{$endif}
    + ': ';
  BytesMessage = ' byte: ';
  AnsiStringBlockMessage = 'AnsiString';
  UnicodeStringBlockMessage = 'UnicodeString';
  LeakMessageFooter = #13#10
{$ifndef HideMemoryLeakHintMessage}
    + #13#10'Catatan: '
  {$ifdef RequireIDEPresenceForLeakReporting}
    + 'Kebocoran memori ini hanya ditampilkan jika Delphi saat ini berjalan pada komputer yang sama. '
  {$endif}
  {$ifdef FullDebugMode}
    {$ifdef LogMemoryLeakDetailToFile}
    + 'Perincian kebocoran memori dicatat ke file teks dalam folder yang sama dengan aplikasi ini. '
    {$else}
    + 'Hidupkan "LogMemoryLeakDetailToFile" untuk mendapatkan file log yang berisi perincian kebocoran memori. '
    {$endif}
  {$else}
    + 'Untuk mendapatkan file log yang berisi perincian kebocoran memori, hidupkan definisi kondisional "FullDebugMode" dan "LogMemoryLeakDetailToFile". '
  {$endif}
    + 'Untuk mematikan pemeriksaan kebocoran, jangan definisikan "EnableMemoryLeakReporting".'#13#10
{$endif}
    + #0;
  LeakMessageTitle = 'Kebocoran Memori Terdeteksi';
{$ifdef UseOutputDebugString}
  FastMMInstallMsg = 'FastMM sudah diinstalasi.';
  FastMMInstallSharedMsg = 'Membagi instan FastMM yang sudah ada.';
  FastMMUninstallMsg = 'FastMM sudah di deinstalasi.';
  FastMMUninstallSharedMsg = 'Pembagian instan FastMM yang ada dihentikan.';
{$endif}
{$ifdef DetectMMOperationsAfterUninstall}
  InvalidOperationTitle = 'Operasi MM setelah deinstalasi.';
  InvalidGetMemMsg = 'FastMM mendeteksi pemanggilan GetMem setelah FastMM di deinstalasi.';
  InvalidFreeMemMsg = 'FastMM mendeteksi pemanggilan FreeMem setelah FastMM di deinstalasi.';
  InvalidReallocMemMsg = 'FastMM mendeteksi pemanggilan ReallocMem setelah FastMM di deinstalasi.';
  InvalidAllocMemMsg = 'FastMM mendeteksi pemanggilan ReallocMem setelah FastMM di deinstalasi.';
{$endif}

implementation

end.

