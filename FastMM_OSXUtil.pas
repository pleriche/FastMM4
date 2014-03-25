unit FastMM_OSXUtil;

interface

type
  LPCSTR = PAnsiChar;
  LPSTR = PAnsiChar;
  DWORD = Cardinal;
  BOOL = Boolean;

  PSystemTime = ^TSystemTime;
  _SYSTEMTIME = record
    wYear: Word;
    wMonth: Word;
    wDayOfWeek: Word;
    wDay: Word;
    wHour: Word;
    wMinute: Word;
    wSecond: Word;
    wMilliseconds: Word;
  end;
  TSystemTime = _SYSTEMTIME;
  SYSTEMTIME = _SYSTEMTIME;
  SIZE_T = NativeUInt;
  PUINT_PTR = ^UIntPtr;

const
  PAGE_NOACCESS = 1;
  PAGE_READONLY = 2;
  PAGE_READWRITE = 4;
  PAGE_WRITECOPY = 8;
  PAGE_EXECUTE = $10;
  PAGE_EXECUTE_READ = $20;
  PAGE_EXECUTE_READWRITE = $40;
  PAGE_GUARD = $100;
  PAGE_NOCACHE = $200;
  MEM_COMMIT = $1000;
  MEM_RESERVE = $2000;
  MEM_DECOMMIT = $4000;
  MEM_RELEASE = $8000;
  MEM_FREE = $10000;
  MEM_PRIVATE = $20000;
  MEM_MAPPED = $40000;
  MEM_RESET = $80000;
  MEM_TOP_DOWN = $100000;

  EXCEPTION_ACCESS_VIOLATION         = DWORD($C0000005);


//function GetModuleHandleA(lpModuleName: LPCSTR): HMODULE; stdcall;
function GetEnvironmentVariableA(lpName: LPCSTR; lpBuffer: LPSTR; nSize: DWORD): DWORD; stdcall; overload;
function DeleteFileA(lpFileName: LPCSTR): BOOL; stdcall;
function VirtualAlloc(lpvAddress: Pointer; dwSize: SIZE_T; flAllocationType, flProtect: DWORD): Pointer; stdcall;
function VirtualFree(lpAddress: Pointer; dwSize, dwFreeType: Cardinal): LongBool; stdcall;

procedure RaiseException(dwExceptionCode, dwExceptionFlags, nNumberOfArguments: DWORD;
  lpArguments: PUINT_PTR); stdcall;

type
  PSecurityAttributes = ^TSecurityAttributes;
  _SECURITY_ATTRIBUTES = record
    nLength: DWORD;
    lpSecurityDescriptor: Pointer;
    bInheritHandle: BOOL;
  end;
  TSecurityAttributes = _SECURITY_ATTRIBUTES;
  SECURITY_ATTRIBUTES = _SECURITY_ATTRIBUTES;

const
  GENERIC_READ             = DWORD($80000000);
  GENERIC_WRITE            = $40000000;
  OPEN_ALWAYS = 4;
  FILE_ATTRIBUTE_NORMAL               = $00000080;
  FILE_BEGIN = 0;
  FILE_CURRENT = 1;
  FILE_END = 2;
  INVALID_SET_FILE_POINTER = DWORD(-1);

procedure GetLocalTime(var lpSystemTime: TSystemTime); stdcall;

function CreateFileA(lpFileName: LPCSTR; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; stdcall;

function SetFilePointer(hFile: THandle; lDistanceToMove: Longint;
  lpDistanceToMoveHigh: PLongInt; dwMoveMethod: DWORD): DWORD; stdcall;

function CloseHandle(hObject: THandle): BOOL; stdcall;

implementation

uses
  Posix.Stdlib, Posix.Unistd, Posix.SysMman, Posix.Fcntl, Posix.SysStat, Posix.SysTime, Posix.Time, Posix.Errno, Posix.Signal;

function CreateFileA(lpFileName: LPCSTR; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; stdcall;
var
  Flags: Integer;
  FileAccessRights: Integer;
begin
//           O_RDONLY        open for reading only
//           O_WRONLY        open for writing only
//           O_RDWR          open for reading and writing
//           O_NONBLOCK      do not block on open or for data to become available
//           O_APPEND        append on each write
//           O_CREAT         create file if it does not exist
//           O_TRUNC         truncate size to 0
//           O_EXCL          error if O_CREAT and the file exists
//           O_SHLOCK        atomically obtain a shared lock
//           O_EXLOCK        atomically obtain an exclusive lock
//           O_NOFOLLOW      do not follow symlinks
//           O_SYMLINK       allow open of symlinks
//           O_EVTONLY       descriptor requested for event notifications only
//          O_CLOEXEC       mark as close-on-exec

  Flags := 0;
  FileAccessRights := S_IRUSR or S_IWUSR or S_IRGRP or S_IWGRP or S_IROTH or S_IWOTH;

  case dwDesiredAccess and (GENERIC_READ or GENERIC_WRITE) of //= (GENERIC_READ or GENERIC_WRITE) then
    GENERIC_READ or GENERIC_WRITE: Flags := Flags or O_RDWR;
    GENERIC_READ: Flags := Flags or O_RDONLY;
    GENERIC_WRITE: Flags := Flags or O_WRONLY;
    else
      Exit(THandle(-1));
  end;

  case dwCreationDisposition of
//    CREATE_NEW:
//    CREATE_ALWAYS:
//    OPEN_EXISTING:
    OPEN_ALWAYS: Flags := Flags or O_CREAT;
//    TRUNCATE_EXISTING:
  end;

  Result := THandle(__open(lpFileName, Flags, FileAccessRights));

  // ShareMode

//    smode := Mode and $F0 shr 4;
//    if ShareMode[smode] <> 0 then
//    begin
//      LockVar.l_whence := SEEK_SET;
//      LockVar.l_start := 0;
//      LockVar.l_len := 0;
//      LockVar.l_type := ShareMode[smode];
//      Tvar :=  fcntl(FileHandle, F_SETLK, LockVar);
//      Code := errno;
//      if (Tvar = -1) and (Code <> EINVAL) and (Code <> ENOTSUP) then
//       EINVAL/ENOTSUP - file doesn't support locking
//      begin
//        __close(FileHandle);
//        Exit;
//      end;
end;

type
  _LARGE_INTEGER = record
    case Integer of
    0: (
      LowPart: DWORD;
      HighPart: Longint);
    1: (
      QuadPart: Int64);
  end;


function SetFilePointer(hFile: THandle; lDistanceToMove: Longint;
  lpDistanceToMoveHigh: PLongInt; dwMoveMethod: DWORD): DWORD; stdcall;
var
  dist: _LARGE_INTEGER;
begin
  dist.LowPart := lDistanceToMove;
  if Assigned(lpDistanceToMoveHigh) then
    dist.HighPart := lpDistanceToMoveHigh^
  else
    dist.HighPart := 0;

  dist.QuadPart := lseek(hFile, dist.QuadPart, dwMoveMethod); // dwMoveMethod = same as in windows
  if dist.QuadPart = -1 then
    Result := DWORD(-1)
  else
  begin
    Result := dist.LowPart;
    if Assigned(lpDistanceToMoveHigh) then
      lpDistanceToMoveHigh^ := dist.HighPart;
  end;
end;

procedure GetLocalTime(var lpSystemTime: TSystemTime); stdcall;
var
  T: time_t;
  TV: timeval;
  UT: tm;
begin
  gettimeofday(TV, nil);
  T := TV.tv_sec;
  localtime_r(T, UT);

  lpSystemTime.wYear := UT.tm_year;
  lpSystemTime.wMonth := UT.tm_mon;
  lpSystemTime.wDayOfWeek := UT.tm_wday;
  lpSystemTime.wDay := UT.tm_mday;
  lpSystemTime.wHour := UT.tm_hour;
  lpSystemTime.wMinute := UT.tm_min;
  lpSystemTime.wSecond := UT.tm_sec;
  lpSystemTime.wMilliseconds := 0;
end;

function CloseHandle(hObject: THandle): BOOL; stdcall;
begin
  Result := __close(hObject) = 0;
end;

function StrLen(const Str: PAnsiChar): Cardinal;
begin
  Result := Length(Str);
end;

function StrLCopy(Dest: PAnsiChar; const Source: PAnsiChar; MaxLen: Cardinal): PAnsiChar;
var
  Len: Cardinal;
begin
  Result := Dest;
  Len := StrLen(Source);
  if Len > MaxLen then
    Len := MaxLen;
  Move(Source^, Dest^, Len * SizeOf(AnsiChar));
  Dest[Len] := #0;
end;

function StrPLCopy(Dest: PAnsiChar; const Source: AnsiString; MaxLen: Cardinal): PAnsiChar;
begin
  Result := StrLCopy(Dest, PAnsiChar(Source), MaxLen);
end;

function GetModuleHandle(lpModuleName: PWideChar): HMODULE;
begin
  Result := 0;
  if lpModuleName = 'kernel32' then
    Result := 1;
end;

function GetModuleHandleA(lpModuleName: LPCSTR): HMODULE; stdcall;
begin
  Result := GetModuleHandle(PChar(string(lpModuleName)));
end;

function GetEnvironmentVariableA(lpName: LPCSTR; lpBuffer: LPSTR; nSize: DWORD): DWORD; stdcall; overload;
var
  Len: Integer;
  Env: string;
begin
  env := string(getenv(lpName));

  Len := Length(env);
  Result := Len;
  if nSize < Result then
    Result := nSize;

  StrPLCopy(lpBuffer, env, Result);
  if Len > nSize then
    SetLastError(122) //ERROR_INSUFFICIENT_BUFFER)
  else
    SetLastError(0);
end;

function DeleteFileA(lpFileName: LPCSTR): BOOL; stdcall;
begin
  Result := unlink(lpFileName) <> -1;
end;

//    ReservedBlock := VirtualAlloc(Pointer(DebugReservedAddress), 65536, MEM_RESERVE, PAGE_NOACCESS);


function VirtualAlloc(lpvAddress: Pointer; dwSize: SIZE_T; flAllocationType, flProtect: DWORD): Pointer; stdcall;
var
  PageSize: LongInt;
  AllocSize: LongInt;
  Protect: Integer;
begin
  if lpvAddress <> nil then
  begin
    if flAllocationType <> MEM_RESERVE then
      Exit(0);

    if flProtect <> PAGE_NOACCESS then
      Exit(0);

    PageSize := sysconf(_SC_PAGESIZE);
    AllocSize := dwSize - (dwSize mod PageSize) + PageSize;

    Result := mmap(lpvAddress, AllocSize, PROT_NONE, MAP_PRIVATE or MAP_ANON, -1, 0);
    Exit;
  end;

  Result := malloc(dwSize);
  FillChar(Result^, dwSize, 0);
  //Result := valloc(dwSize);



//  FreeItem.Addr := mmap(nil, PageSize, PROT_WRITE or PROT_EXEC,
//                        MAP_PRIVATE or MAP_ANON, -1, 0);
end;

function VirtualFree(lpAddress: Pointer; dwSize, dwFreeType: Cardinal): LongBool; stdcall;
begin
  Result := True;
  if dwFreetype = MEM_RELEASE then
  begin
    if lpAddress = Pointer($80800000) then
      munmap(lpAddress, dwSize)
    else
      free(lpAddress);
  end;
end;

procedure RaiseException(dwExceptionCode, dwExceptionFlags, nNumberOfArguments: DWORD;
  lpArguments: PUINT_PTR); stdcall;
begin
  WriteLN('ACCESS VIOLATION (set breakpoint in FastMM_OSXUtil: RaiseException for easier debugging)');
  kill(getppid, SIGSEGV);
  asm int 3; end;
end;


end.
