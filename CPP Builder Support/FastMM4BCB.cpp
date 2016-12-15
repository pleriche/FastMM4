/*

Fast Memory Manager: BCB support 2.04

Description:
 FastMM support unit for C++ Builder. Loads FastMM4 on startup of the Borland 
 C++ Builder application or DLL.

Usage:
 1) Copy FastMM4BCB.cpp, FastMM4.pas, FastMM4Message.pas, FastMM4Options.inc,
    and FastMM_FullDebugMode.lib to your source folder.
 2) Copy FastMM_FullDebugMode.dll to your application's .exe directory (if you
    intend to use FullDebugMode).
 3) To your project, add FastMM4Messages.pas first, then FastMM4.pas, then
    FastMM4BCB.cpp. On compiling the .pas files, .hpp files are created and
    imported by the subsequent files.
 4) Add USEOBJ("FastMM4BCB.cpp") to your project file, BEFORE any other
    USEFORM directives.
 5) Under the Project -> Options -> Linker menu uncheck "Use Dynamic RTL"
    (sorry, won't work with the RTL DLL).
 FastMM will now install itself on startup and replace the RTL memory manager.

Acknowledgements:
 - Jarek Karciarz, Vladimir Ulchenko (Vavan) and Bob Gonder for their help in
   implementing the initial BCB support.
 - JiYuan Xie for doing an entire rewrite of this unit to allow leak reporting,
   etc. under BCB.
 - Remy Lebeau for some bugfixes.
 - James Nachbar and Albert Wiersch for improved usage instructions and
   bugfixes.

Change log:
 Version 1.00 (15 June 2005):
  - Initial release. Due to limitations of BCB it cannot be uninstalled (thus
    no leak checking and not useable in DLLs unless the DLL always shares the
    main application's MM). Thanks to Jarek Karciarz, Vladimir Ulchenko and Bob
    Gonder for their help.
 Version 1.01 (6 August 2005):
  - Fixed a regression bug (Thanks to Omar Zelaya).
 Version 2.00 (22 April 2008):
  - Rewritten by JiYuan Xie to implement leak reporting, etc. (Thank you!)
 Version 2.01 (9 December 2008):
  - Fixed a compiler error when 'STRICT' is defined
 Version 2.02 (24 January 2009):
  - JiYuan Xie fixed the BCB compatibility. (Thanks!)
 Version 2.03 (03 March 2009):
  - Changes for BCB2009 in "TCHAR = wchar_t" mode
 Version 2.04 (10 January 2010):
  - Fixed a compilation error in BCB6 (Thanks to Remy Lebeau)

*/

//#ifndef _NO_VCL

#pragma option push
#pragma option -k- -d -vi- -O2 -b- -3 -a8 -pc -RT- -x -xd -r -AT -vG- -vG0- -vG1- -vG2- -vG3- -vGc- -vGt- -vGd-

#pragma hdrstop
#include "FastMM4Messages.hpp"
#include "FastMM4.hpp"

//BCB6 support
#include <tchar.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef PatchBCBTerminate

#ifdef FullDebugMode
#ifndef LoadDebugDLLDynamically

#pragma link "FastMM_FullDebugMode.lib"

#if defined(RawStackTraces)
__declspec(dllimport) void __fastcall GetRawStackTrace(unsigned * AReturnAddresses,
  unsigned AMaxDepth, unsigned ASkipFrames);
#else
__declspec(dllimport) void __fastcall GetFrameBasedStackTrace(unsigned * AReturnAddresses,
  unsigned AMaxDepth, unsigned ASkipFrames);
#endif
__declspec(dllimport) void __fastcall LogStackTrace(unsigned * AReturnAddresses,
  unsigned AMaxDepth, char *ABuffer);
  
#endif
#endif

#pragma pack(push,1)
typedef struct {
  unsigned char JmpInst; //E9
  int Offset;
} TRelativeJmp32, * PRelativeJmp32;

typedef struct {
  unsigned short JmpInst; //FF 25
  void * * DestPtr;
} TIndirectJmp32, * PIndirectJmp32;
#pragma pack(pop)

//Return true if write OK
bool __fastcall WriteMem(void * Location, void * Data, unsigned int DataSize)
{
  unsigned long OldProtect;
  
  if (VirtualProtect(Location, DataSize, PAGE_EXECUTE_READWRITE, &OldProtect))
  {
    memmove(Location, Data, DataSize);

    FlushInstructionCache(GetCurrentProcess(), Location, sizeof(DataSize));
    VirtualProtect(Location, DataSize, OldProtect, &OldProtect);

    return true;
  }
  else {
    return false;
  }
}

#define RelativeJmp32Inst  (0xE9)

//Return true if patch OK
bool __fastcall PatchProc(void * OldProc, void * NewProc, TRelativeJmp32 * Backup)
{
  if (OldProc && NewProc)
  {
    TRelativeJmp32 JmpData;

    JmpData.JmpInst = RelativeJmp32Inst;
    JmpData.Offset = (int)NewProc - ((int)OldProc + sizeof(JmpData));

    if (Backup)
    {
      *Backup = *((PRelativeJmp32)OldProc);
    }

    return WriteMem(OldProc, &JmpData, sizeof(JmpData));
  }
  else {
    return false;
  }
};

//Return true if unpatch OK
bool __fastcall UnPatchProc(void * OldProc, void * NewProc, TRelativeJmp32 * Backup)
{
  if (OldProc && NewProc && Backup)
  {
    int Offset = (int)NewProc - ((int)OldProc + sizeof(TRelativeJmp32));
    if ((((PRelativeJmp32)OldProc)->JmpInst == RelativeJmp32Inst)
      && (((PRelativeJmp32)OldProc)->Offset == Offset))
    {
      return WriteMem(OldProc, &Backup, sizeof(*Backup));
    }
  }

  return false;
};

typedef void * (__fastcall * GetMemFunc)(int Size);
typedef int (__fastcall * FreeMemFunc)(void * P);
typedef void * (__fastcall * ReallocMemFunc)(void * P, int Size);
#if __BORLANDC__ >= 0x582
//>= BDS2006 ?
typedef void * (__fastcall * AllocMemFunc)(unsigned Size);
#endif

#ifndef _RTLDLL //Not using Dynamic RTL
extern void _terminate(int code);
#endif

#ifndef FullDebugMode
  #define InternalGetMem FastGetMem
  #define InternalFreeMem FastFreeMem
  #define InternalReallocMem FastReallocMem

  #if __BORLANDC__ >= 0x582
  //>= BDS2006 ?
    #define InternalAllocMem FastAllocMem
  #endif
#else
  #define InternalGetMem DebugGetMem
  #define InternalFreeMem DebugFreeMem
  #define InternalReallocMem DebugReallocMem

  #if __BORLANDC__ >= 0x582
  //>= BDS2006 ?
    #define InternalAllocMem DebugAllocMem
  #endif
#endif //FullDebugMode


#ifdef CheckCppObjectTypeEnabled
void __fastcall FinalizeModuleCodeDataRanges(void);
#endif
void __fastcall FinalizeHeapRedirectorStoreList(void);
extern bool IsBorlandMMDLL;
#if defined(__DLL__) && defined(FullDebugMode) && defined(LoadDebugDLLDynamically)
void __fastcall CallOldFullDebugModeDllEntry(void);
#endif

void * StockGetMemPtr = NULL;


void New_terminate(int code)
{
  //FasttMM4.pas need export a "FinalizeMemoryManager" routine which contain
  //codes of original "finalization" section
  FinalizeMemoryManager();

  #ifdef CheckCppObjectTypeEnabled
  GetCppVirtObjSizeByTypeIdPtrFunc = NULL;
  GetCppVirtObjTypeIdPtrFunc = NULL;
  GetCppVirtObjTypeNameFunc = NULL;
  GetCppVirtObjTypeNameByTypeIdPtrFunc = NULL;
  GetCppVirtObjTypeNameByVTablePtrFunc = NULL;

  FinalizeModuleCodeDataRanges();
  #endif

  #ifdef DetectMMOperationsAfterUninstall
    //Do nothing
  #endif

  if (IsBorlandMMDLL)
  {
    FinalizeHeapRedirectorStoreList();
  }

  #if defined(__DLL__) && defined(FullDebugMode) && defined(LoadDebugDLLDynamically)
  CallOldFullDebugModeDllEntry();
  #endif
  
  ExitProcess(code);              
}

void * PatchLocation = NULL;

#if defined(__DLL__) && defined(FullDebugMode) && defined(LoadDebugDLLDynamically)

#pragma pack(push,1)

typedef struct {
  unsigned char PushEbp; //0x55
  unsigned short MovEbpEsp; //0x8B 0xEC
  unsigned char SubEsp[3]; //0x83 0xC4 0xC4
} DelphiDllEntryInsts, *DelphiDllEntryInstsPtr;

typedef struct {
  DelphiDllEntryInsts OldInsts;
  TRelativeJmp32 JmpToRemainInsts;
} FullDebugModeDllEntryThunk; 

#pragma pack(pop)

FullDebugModeDllEntryThunk OldFullDebugModeDllEntryThunk;
bool ExecuteOldFullDebugModeDllEntry = false;
bool FullDebugModeDllEntryHooked = false;

bool __fastcall PrepareFullDebugModeDllEntryThunk(FullDebugModeDllEntryThunk *Thunk,
  void *OldEntry)
{
  DelphiDllEntryInstsPtr OldInstsPtr = (DelphiDllEntryInstsPtr)OldEntry;
  if ((OldInstsPtr->PushEbp == 0x55)
    && (OldInstsPtr->MovEbpEsp == 0xEC8B)
    && (OldInstsPtr->SubEsp[0] == 0x83)
    && (OldInstsPtr->SubEsp[1] == 0xC4))
  {
    unsigned long OldProtect;

    if (VirtualProtect((void *)Thunk, sizeof(*Thunk), PAGE_EXECUTE_READWRITE, &OldProtect))
    {
      Thunk->OldInsts = *OldInstsPtr;
      //jump to (OldEntry + sizeof(*OldInstsPtr)) from Thunk->JmpToRemainInsts
      Thunk->JmpToRemainInsts.JmpInst = RelativeJmp32Inst;
      Thunk->JmpToRemainInsts.Offset = ((int)OldInstsPtr + sizeof(*OldInstsPtr))
        - ((int)&Thunk->JmpToRemainInsts + sizeof(Thunk->JmpToRemainInsts));

      return true;
    }
  }
  return false;
}

#if defined(PURE_CPLUSPLUS) //__BORLANDC__ < 0x0560

typedef BOOL WINAPI (*DllEntryFunc)(
    HINSTANCE hinstDLL,
    DWORD fdwReason,
    LPVOID lpvReserved);

BOOL WINAPI NewFullDebugModeDllEntry(
  HINSTANCE hinstDLL,
  DWORD fdwReason,
  LPVOID lpvReserved)
{
  //[ESP +  4] hinstDLL
  //[ESP +  8] fdwReason
  //[ESP + 12] lpvReserved

  if (fdwReason != DLL_PROCESS_DETACH)
  {
    DllEntryFunc OldDllEntry = (DllEntryFunc)(&OldFullDebugModeDllEntryThunk);
    return (*OldDllEntry)(hinstDLL, fdwReason, lpvReserved);
  }
  else
  {
    if (ExecuteOldFullDebugModeDllEntry)
    {
      ExecuteOldFullDebugModeDllEntry = 0;

      DllEntryFunc OldDllEntry = (DllEntryFunc)(&OldFullDebugModeDllEntryThunk);
      return (*OldDllEntry)(hinstDLL, fdwReason, lpvReserved);
    }
    else
    {
      return true;
    }
  }
}

#else

//#pragma warn -8002 //"W8002: Restarting compile using assembly"
#pragma option -w-asc

//#pragma warn -8070 //"W8070 Function should return a value"
#pragma option -w-rvl //the same as above

__declspec(naked) BOOL WINAPI NewFullDebugModeDllEntry(
  HINSTANCE hinstDLL,
  DWORD fdwReason,
  LPVOID lpvReserved)
{
  //[ESP +  4] hinstDLL
  //[ESP +  8] fdwReason
  //[ESP + 12] lpvReserved

/*
  if (fdwReason != DLL_PROCESS_DETACH)
  {
    DllEntryFunc OldDllEntry = (DllEntryFunc)(&OldFullDebugModeDllEntryThunk);
    return (*OldDllEntry)(hinstDLL, fdwReason, lpvReserved);
  }
  else
  {
    if (ExecuteOldFullDebugModeDllEntry)
    {
      ExecuteOldFullDebugModeDllEntry = 0;

      DllEntryFunc OldDllEntry = (DllEntryFunc)(&OldFullDebugModeDllEntryThunk);
      return (*OldDllEntry)(hinstDLL, fdwReason, lpvReserved);
    }
    else
    {
      return true;
    }
  }
*/
  asm
  {
    mov   eax, [esp + 8]  //fdwReason
    test  eax, eax        //is DLL_PROCESS_DETACH ?
    jz   ProcessDetech
  #if __BORLANDC__ < 0x0560
    lea  eax, OldFullDebugModeDllEntryThunk  //not DLL_PROCESS_DETACH, call original entry
    jmp  eax
  #else
    jmp   OldFullDebugModeDllEntryThunk  //not DLL_PROCESS_DETACH, call original entry
  #endif

  ProcessDetech:
    movzx eax, ExecuteOldFullDebugModeDllEntry
    test  eax, eax
    jz    Exit    //do nothing if ExecuteOldFullDebugModeDllEntry flag not set
    xor   eax, eax
    mov   ExecuteOldFullDebugModeDllEntry, al //reset ExecuteOldDebugModeDllEntry flag

  #if __BORLANDC__ < 0x0560
    lea  eax, OldFullDebugModeDllEntryThunk
    jmp  eax
  #else
    jmp   OldFullDebugModeDllEntryThunk
  #endif
  Exit:
    setz al
    ret
  }
}
#endif

void * __fastcall GetModuleEntryPoint(HMODULE AModule)
{
  if (AModule)
  {
    PIMAGE_NT_HEADERS ntheader = (PIMAGE_NT_HEADERS)((unsigned)AModule
      + ((PIMAGE_DOS_HEADER)AModule)->e_lfanew);

    return (void *)(ntheader->OptionalHeader.AddressOfEntryPoint
      + (unsigned)AModule);
  }
  else
  {
    return NULL;
  }
}

bool __fastcall TryHookFullDebugModeDllEntry(void)
{
  HMODULE AModule = GetModuleHandle(FullDebugModeLibraryName);
  if (AModule)
  {
    void *Entry = GetModuleEntryPoint(AModule);
    if (Entry)
    {
      if (PrepareFullDebugModeDllEntryThunk(&OldFullDebugModeDllEntryThunk, Entry))
      {
        FullDebugModeDllEntryHooked = PatchProc(Entry, &NewFullDebugModeDllEntry, NULL);
        return FullDebugModeDllEntryHooked;
      }
    }
  }

  return false;
}

void __fastcall CallOldFullDebugModeDllEntry(void)
{
  if (FullDebugModeDllEntryHooked)
  {
    HMODULE AModule = GetModuleHandle(FullDebugModeLibraryName);
    if (AModule)
    {
      ExecuteOldFullDebugModeDllEntry = 1;

      NewFullDebugModeDllEntry((HINSTANCE)AModule, DLL_PROCESS_DETACH, NULL);
    }
  }
}
#endif

#define DVCLALResName _TEXT("DVCLAL")

#define _terminateExport "_terminate"

//Return true if patched OK
bool __fastcall Patch_terminate(void)
{
  if (!PatchLocation)
  {
    #ifndef _RTLDLL //Not uses Dynamic RTL
    PatchLocation = &_terminate;
    #else
    //Get module handle of RTL dll
    PIndirectJmp32 P = (PIndirectJmp32)&exit; 
    if ((!IsBadReadPtr(P, sizeof(TIndirectJmp32))) && (P->JmpInst == 0x25FF)
      && (P->DestPtr) && (!IsBadReadPtr(P->DestPtr, sizeof(void *))))
    {
      PatchLocation = *(P->DestPtr);
    }
    else {
      PatchLocation = P;
    }

    PatchLocation = (void *)System::FindHInstance(PatchLocation);
    if (PatchLocation)
    {
      //Get real patch location
      PatchLocation = GetProcAddress((HMODULE)PatchLocation, _terminateExport);
      if (!PatchLocation)
      {
        return false;
      }
    }
    else {
      return false;
    }
    #endif //_RTLDLL

    if ((((PRelativeJmp32)PatchLocation)->JmpInst == RelativeJmp32Inst)
      || (!PatchProc(PatchLocation, &New_terminate, NULL)))
    {
      PatchLocation = NULL;
      return false;
    }
    else {
      return true;
    }
  }
  else {
    return true;
  }
}

extern  int __CPPdebugHook;

bool IsMMInstalled = false;
bool IsInDLL = false;
bool IsBorlandMMDLL = false;
bool terminatePatched = false;

#define CPPdebugHookExport  "___CPPdebugHook"


//#ifndef _RTLDLL

#if (__BORLANDC__ < 0x0560) || (__BORLANDC__ > 0x0711)
#if defined(PURE_CPLUSPLUS) || defined(__clang__)

void * _RTLENTRY Cpp_malloc_Stub(size_t size)
{
  if (size)
    return InternalGetMem(size);
  else
    return NULL;
}

void _RTLENTRY Cpp_free_Stub(void *block)
{
  if (block)
    InternalFreeMem(block);
}

void * _RTLENTRY Cpp_realloc_Stub(void *block, size_t size)
{
  if (!block)
  {
    if (size)
      return InternalGetMem(size);
    else
      return NULL;
  }
  else {
    if (!size)
    {
      InternalFreeMem(block);
      return NULL;
    }
    else
      return InternalReallocMem(block, size);
  }
}

void _RTLENTRY Cpp_terminate_Stub(void)
{
}

#else

GetMemFunc GetMemPtr;
FreeMemFunc FreeMemPtr;
ReallocMemFunc ReallocMemPtr;

//#pragma warn -8002 //"W8002: Restarting compile using assembly"
#pragma option -w-asc

//#pragma warn -8070 //"W8070 Function should return a value"
#pragma option -w-rvl //the same as above

__declspec(naked) void * _RTLENTRY Cpp_malloc_Stub(size_t size)
{
  asm
  {
    mov  eax, [esp + 4] //size
    test eax, eax
    jz   malloc_Exit
  //#if __BORLANDC__ >= 0x564
  //  jmp  GetMemPtr
  //  nop
  //#else
    call GetMemPtr
    ret
  //#endif
    nop
  malloc_Exit:
    ret
  }
}

__declspec(naked) void _RTLENTRY Cpp_free_Stub(void *block)
{
  asm
  {
    mov  eax, [esp + 4] //block
    test eax, eax
    jz   free_Exit
  //#if __BORLANDC__ >= 0x564
  //  jmp  FreeMemPtr
  //  nop
  //#else
    call FreeMemPtr
    ret
  //#endif
    nop
  free_Exit:
    ret
  }
}

__declspec(naked) void * _RTLENTRY Cpp_realloc_Stub(void *block, size_t size)
{
  asm
  {
    mov  eax, [esp + 4] //block
    test eax, eax
    jnz  realloc_Realloc
  realloc_Alloc:
    mov  eax, [esp + 8] //size
    test eax, eax
    jz   realloc_Exit2 //realloc_Exit1
  //#if __BORLANDC__ >= 0x564
  //  jmp  GetMemPtr
  //  nop
  //#else
    call GetMemPtr
    ret
  //#endif
    nop
  ////realloc_Exit1:
  //  //ret
  realloc_Realloc:
    mov  edx, [esp + 8] //size
    test edx, edx
    jnz  realloc_DoRealloc
    call FreeMemPtr
  realloc_ReturnNULL:
    xor  eax, eax
  realloc_Exit2:
    ret
    nop
    nop
    nop
  realloc_DoRealloc:
  //#if __BORLANDC__ >= 0x564
  //  jmp  ReallocMemPtr
  //  //ret
  //#else
    call ReallocMemPtr
    ret
  //#endif
  }
}

__declspec(naked) void _RTLENTRY Cpp_terminate_Stub(void)
{
  //Do nothing
  asm ret;
}
#endif

#else
//#pragma warn -8070 //"W8070 Function should return a value"
#pragma option -w-rvl //the same as above
__declspec(naked) void * _RTLENTRY Cpp_malloc_Stub(size_t size)
{
  //if (size)
    //return InternalGetMem(size);
  //else
    //return NULL;
  asm
  {
    mov  eax, [esp + 4] //size
    test eax, eax
    jz   malloc_Exit
  #if __BORLANDC__ >= 0x564
    jmp  InternalGetMem
    nop
  #else
    call InternalGetMem
    ret
  #endif
    nop
    nop
  malloc_Exit:
    ret
  }
}

__declspec(naked) void _RTLENTRY Cpp_free_Stub(void *block)
{
  //if (block)
    //InternalFreeMem(block);
  asm
  {
    mov  eax, [esp + 4] //block
    test eax, eax
    jz   free_Exit
  #if __BORLANDC__ >= 0x564
    jmp  InternalFreeMem
    nop
  #else
    call InternalFreeMem
    ret
  #endif
    nop
    nop
  free_Exit:
    ret
  }
}

__declspec(naked) void * _RTLENTRY Cpp_realloc_Stub(void *block, size_t size)
{
  /*
  if (!block)
  {
    if (size)
      return InternalGetMem(size);
    else
      return NULL;
  }
  else {
    if (!size)
    {
      InternalFreeMem(block); 
      return NULL;
    }
    else
      return InternalReallocMem(block, size);
  }
  */
  asm
  {
    mov  eax, [esp + 4] //block
    test eax, eax
    jnz  realloc_Realloc
  realloc_Alloc:
    mov  eax, [esp + 8] //size
    test eax, eax
    jz   realloc_Exit2 //realloc_Exit1
  #if __BORLANDC__ >= 0x564
    jmp  InternalGetMem
    nop
  #else
    call InternalGetMem
    ret
  #endif
    nop
    nop
  //realloc_Exit1:
    //ret
  realloc_Realloc:
    mov  edx, [esp + 8] //size
    test edx, edx
    jnz  realloc_DoRealloc
    call InternalFreeMem
  realloc_ReturnNULL:
    xor  eax, eax
  realloc_Exit2:
    ret
  realloc_DoRealloc:
  #if __BORLANDC__ >= 0x564
    jmp  InternalReallocMem
    //ret
  #else
    call InternalReallocMem
    ret
  #endif
  }
}

__declspec(naked) void _RTLENTRY Cpp_terminate_Stub(void)
{
  //Do nothing
  asm ret;
}
#endif

#ifdef DetectMMOperationsAfterUninstall

GetMemFunc InvalidGetMemPtr;
FreeMemFunc InvalidFreeMemPtr;
ReallocMemFunc InvalidReallocMemPtr;

#if defined(PURE_CPLUSPLUS) //__BORLANDC__ < 0x0560

void * _RTLENTRY Cpp_Invalid_malloc_Stub(size_t size)
{
  if (size)
    return (*InvalidGetMemPtr)(size);
  else
    return NULL;
}

void _RTLENTRY Cpp_Invalid_free_Stub(void *block)
{
  if (block)
    (*InvalidFreeMemPtr)(block);
}

void * _RTLENTRY Cpp_Invalid_realloc_Stub(void *block, size_t size)
{
  if (!block)
  {
    if (size)
      return (*InvalidGetMemPtr)(size);
    else
      return NULL;
  }
  else {
    if (!size)
    {
      (*InvalidFreeMemPtr)(block);
      return NULL;
    }
    else
      return (*InvalidReallocMemPtr)(block, size);
  }
}

#else

//#pragma warn -8002 //"W8002: Restarting compile using assembly"
#pragma option -w-asc

//#pragma warn -8070 //"W8070 Function should return a value"
#pragma option -w-rvl //the same as above

__declspec(naked) void * _RTLENTRY Cpp_Invalid_malloc_Stub(size_t size)
{
  asm
  {
    mov  eax, [esp + 4] //size
    test eax, eax
    jz   Invalid_malloc_Exit
  #if __BORLANDC__ >= 0x564
    jmp  InvalidGetMemPtr
    nop
  #else
    call InvalidGetMemPtr
    ret
  #endif
    nop
  Invalid_malloc_Exit:
    ret
  }
}

__declspec(naked) void _RTLENTRY Cpp_Invalid_free_Stub(void *block)
{
  asm
  {
    mov  eax, [esp + 4] //block
    test eax, eax
    jz   Invalid_free_Exit
  #if __BORLANDC__ >= 0x564
    jmp  InvalidFreeMemPtr
    nop
  #else
    call InvalidFreeMemPtr
    ret
  #endif
    nop
  Invalid_free_Exit:
    ret
  }
}

__declspec(naked) void * _RTLENTRY Cpp_Invalid_realloc_Stub(void *block, size_t size)
{
  asm
  {
    mov  eax, [esp + 4] //block
    test eax, eax
    jnz  Invalid_realloc_Realloc
  Invalid_realloc_Alloc:
    mov  eax, [esp + 8] //size
    test eax, eax
    jz   Invalid_realloc_Exit2 //Invalid_realloc_Exit1
  #if __BORLANDC__ >= 0x564
    jmp  InvalidGetMemPtr
    nop
  #else
    call InvalidGetMemPtr
    ret
  #endif
    nop
  //Invalid_realloc_Exit1:
    //ret
  Invalid_realloc_Realloc:
    mov  edx, [esp + 8] //size
    test edx, edx
    jnz  Invalid_realloc_DoRealloc
    call InvalidFreeMemPtr
  Invalid_realloc_ReturnNULL:
    xor  eax, eax
  Invalid_realloc_Exit2:
    ret
    nop
    nop
    nop
  Invalid_realloc_DoRealloc:
  #if __BORLANDC__ >= 0x564
    jmp  InvalidReallocMemPtr
    //ret
  #else
    call InvalidReallocMemPtr
    ret
  #endif
  }
}
#endif

#endif //DetectMMOperationsAfterUninstall

#pragma option push -b -a8

typedef void   (_RTLENTRY *HeapRedirect_free)      (void *);
typedef void * (_RTLENTRY *HeapRedirect_malloc)    (size_t);
typedef void * (_RTLENTRY *HeapRedirect_realloc)   (void *, size_t);
typedef void   (_RTLENTRY *HeapRedirect_terminate) (void);

typedef enum
{
  hrfVirgin,
  hrfInternal,
  hrfBorlndmm,
  hrfOldBorlndmm,
  hrfVCLSystem,
  hrfDgbAlloc,
  hrfOther
} HeapRedirectFlag;

typedef struct
{
  size_t                  size;
  unsigned int            allocated;
  HeapRedirectFlag        flags;
  HeapRedirect_free       free;
  HeapRedirect_malloc     malloc;
  HeapRedirect_realloc    realloc;
  HeapRedirect_terminate  terminate;
} HeapRedirector;

typedef struct HeapRedirectorStoreStruct
{
  HeapRedirector Data;
  HMODULE Module;
  void * PatchAddress;
  TRelativeJmp32 PatchBackup;
  struct HeapRedirectorStoreStruct *Next;
} HeapRedirectorStore, *HeapRedirectorStorePtr;

extern HeapRedirector * _RTLENTRY _EXPFUNC _get_heap_redirector_info(void);
typedef HeapRedirector * _RTLENTRY _EXPFUNC (* rtl_get_heap_redirector_info_func)(void);

#pragma option pop

HeapRedirector * pHRDir = NULL;
HeapRedirector Old_heap_redirector;

HeapRedirectorStorePtr HeapRedirectorStoreListHeader = NULL;

//#endif //!_RTLDLL


#define UseHeap

#ifdef UseHeap
HANDLE ProcessHeapHandle = NULL;
#endif

void __fastcall InitFinalMemMgr(void)
{
  #ifdef UseHeap
  if (!ProcessHeapHandle)
  {
    ProcessHeapHandle = GetProcessHeap();
  }
  #endif
}

void * __fastcall FinalGetMem(unsigned ASize)
{
  #ifdef UseHeap
  return HeapAlloc(ProcessHeapHandle, HEAP_GENERATE_EXCEPTIONS, ASize);
  #else
  return malloc(ASize);
  #endif
}

void __fastcall FinalFreeMem(void * ABlock)
{
  #ifdef UseHeap
  HeapFree(ProcessHeapHandle, 0, ABlock);
  #else
  free(ABlock);
  #endif
}

void * __fastcall FinalReallocMem(void * ABlock, unsigned ANewSize)
{
  #ifdef UseHeap
  return HeapReAlloc(ProcessHeapHandle, HEAP_GENERATE_EXCEPTIONS, ABlock, ANewSize);
  #else
  return realloc(ABlock, ANewSize);
  #endif
}

void __fastcall FinalizeHeapRedirectorStoreList(void)
{
   if (HeapRedirectorStoreListHeader)
   {
     HeapRedirectorStorePtr next, ptr = HeapRedirectorStoreListHeader;
     HeapRedirectorStoreListHeader = NULL;

     while (ptr)
     {
       next = ptr->Next;
       
       FinalFreeMem(ptr);

       ptr = next;
     }
   }
}

typedef bool __fastcall (* EnumModuleCallback)(HMODULE AModule, void *AParam);

#define PSAPI _TEXT("psapi")

bool __fastcall EnumModulesWinNT(EnumModuleCallback ACallback, void *AParam)
{
  typedef BOOL (__stdcall * EnumProcessModulesType)(HANDLE hProcess,
                                                  HMODULE* lphModule,
                                                  DWORD cb,
                                                  LPDWORD lpcbNeeded
                                                 );

  if (!ACallback)
  {
    return false;
  }

  EnumProcessModulesType EnumProcessModules;
  bool DynamicLoaded;

  HMODULE PsapiLib = GetModuleHandle(PSAPI);
  if (!PsapiLib)
  {
    PsapiLib = LoadLibrary(PSAPI);
    if (!PsapiLib)
    {
      return false;
    }
    DynamicLoaded = true;
  }
  else {
    DynamicLoaded = false;
  }

  InitFinalMemMgr();

  bool ret = false;

  try
  {
    EnumProcessModules = (EnumProcessModulesType)GetProcAddress(PsapiLib,
      "EnumProcessModules");

    if (EnumProcessModules)
    {
      HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
        FALSE, GetCurrentProcessId());
      if (hProcess)
      {
        try
        {
          DWORD cbNeeded = 0;
          if (EnumProcessModules(hProcess, NULL, 0, &cbNeeded))
          {
            HMODULE * hMod = (HMODULE *)FinalGetMem(cbNeeded);
            try
            {
              if (EnumProcessModules(hProcess, hMod, cbNeeded, &cbNeeded))
              {
                for (unsigned int i = 0; i < (cbNeeded / sizeof(HMODULE)); i++)
                {
                  if (!ACallback(hMod[i], AParam))
                  {
                    break;
                  }
                }
                ret = true;
              }
            }
            __finally
            {
              FinalFreeMem(hMod);
            }
          }
        }  
        __finally
        {
          CloseHandle(hProcess);
        }
      }
    }
  }
  __finally
  {
    if (DynamicLoaded)
    {
      FreeLibrary(PsapiLib);
    }
  }

  return ret;
}

#define KERNEL32 _TEXT("kernel32")

bool __fastcall EnumModulesWin9x(EnumModuleCallback ACallback, void *AParam)
{
#define MAX_MODULE_NAME32 255
#define TH32CS_SNAPMODULE   0x00000008

  typedef struct tagMODULEENTRY32
  {
      DWORD   dwSize;
      DWORD   th32ModuleID;
      DWORD   th32ProcessID;
      DWORD   GlblcntUsage;
      DWORD   ProccntUsage;
      BYTE  * modBaseAddr;
      DWORD   modBaseSize;
      HMODULE hModule;            
      char    szModule[MAX_MODULE_NAME32 + 1];
      char    szExePath[MAX_PATH];
  } MODULEENTRY32;
  typedef MODULEENTRY32 *  PMODULEENTRY32;
  typedef MODULEENTRY32 *  LPMODULEENTRY32;

  typedef HANDLE (__stdcall * CreateToolhelp32SnapshotType)(DWORD dwFlags,
                                                            DWORD th32ProcessID);
  typedef BOOL (__stdcall *  Module32FirstType)(HANDLE hSnapshot, LPMODULEENTRY32 lpme);
  typedef BOOL (__stdcall * Module32NextType)(HANDLE hSnapshot, LPMODULEENTRY32 lpme);

  if (!ACallback)
  {
    return false;
  }

  HMODULE Kernel32Lib;
  HANDLE hSnapshot;
  CreateToolhelp32SnapshotType CreateToolhelp32Snapshot;
  Module32FirstType Module32First;
  Module32NextType Module32Next;
  bool ret = false;

  Kernel32Lib = GetModuleHandle(KERNEL32);
  if (Kernel32Lib)
  {
    CreateToolhelp32Snapshot = (CreateToolhelp32SnapshotType)GetProcAddress(Kernel32Lib,
      "CreateToolhelp32Snapshot");
    Module32First = (Module32FirstType)GetProcAddress(Kernel32Lib, "Module32First");
    Module32Next = (Module32NextType)GetProcAddress(Kernel32Lib, "Module32Next");
    if ((CreateToolhelp32Snapshot) && (Module32First) && (Module32Next))
    {
      hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, GetCurrentProcessId());
      if (hSnapshot != INVALID_HANDLE_VALUE)
      {
        try
        {
          MODULEENTRY32 ModuleInfo = {0};
          ModuleInfo.dwSize = sizeof(ModuleInfo); 

          while (Module32First(hSnapshot, &ModuleInfo))
          {
            if (!ACallback(ModuleInfo.hModule, AParam))
              break;
          }
          ret = true;
        }
        __finally
        {
          CloseHandle(hSnapshot);
        }
      }
    }
  }
  return ret;
}

bool __fastcall EnumModules(EnumModuleCallback ACallback, void *AParam)
{
  if (ACallback)
  {
    OSVERSIONINFO OSVersionInfo;

    OSVersionInfo.dwOSVersionInfoSize = sizeof(OSVersionInfo);
    if (GetVersionEx(&OSVersionInfo))
    {
      if (OSVersionInfo.dwPlatformId == VER_PLATFORM_WIN32_NT)
      {
        return EnumModulesWinNT(ACallback, AParam);
      }
      else {
        return EnumModulesWin9x(ACallback, AParam);
      }
    }
  }
  return false;
}

#ifdef CheckCppObjectTypeEnabled

typedef struct {
  DWORD CodeSecStart;
  DWORD DataSecStart;
  DWORD DataSecEnd;
} ModuleCodeDataRanges, * PModuleCodeDataRanges;

int ModuleCodeDataRangesCount = 0;
int ModuleCodeDataRangesCapacity = 0;
PModuleCodeDataRanges gpModuleCodeDataRanges = NULL;
unsigned LowestDataAddr = NULL;
unsigned HighestDataAddr = NULL;

bool __fastcall FindCodeDataRangeByDataAddr(DWORD ADataAddr, int * Index,
  PModuleCodeDataRanges * ARange)
{
  bool ret = false;
  int L, H, I;
  L = 0;
  H = ModuleCodeDataRangesCount - 1;
  while (L <= H)
  {
    I = (L + H) / 2;
    DWORD AStart = gpModuleCodeDataRanges[I].DataSecStart;
    DWORD AEnd = gpModuleCodeDataRanges[I].DataSecEnd;
    if (ADataAddr < AStart)
    {
      H = I - 1;
    }
    else if (ADataAddr >= AEnd)
    {
      L = I + 1;
    }
    else {
      if (ARange)
      {
        *ARange = &(gpModuleCodeDataRanges[I]);
      }
      L = I;
      ret = true;
      break;
    }

  }

  if (Index)
  {
    *Index = L;
  }

  return ret;
}

bool __fastcall FindCodeDataRangeByCodeAddr(DWORD ACodeAddr, int * Index,
  PModuleCodeDataRanges * ARange)
{
  bool ret = false;
  int L, H, I;
  L = 0;
  H = ModuleCodeDataRangesCount - 1;
  while (L <= H)
  {
    I = (L + H) / 2;
    DWORD AStart = gpModuleCodeDataRanges[I].CodeSecStart;
    DWORD AEnd = gpModuleCodeDataRanges[I].DataSecStart;
    if (ACodeAddr < AStart)
    {
      H = I - 1;
    }
    else if (ACodeAddr >= AEnd)
    {
      L = I + 1;
    }
    else {
      if (ARange)
      {
        *ARange = &(gpModuleCodeDataRanges[I]);
      }
      L = I;
      ret = true;
      break;
    }
  }

  if (Index)
  {
    *Index = L;
  }

  return ret;
}

PIMAGE_SECTION_HEADER __fastcall GetImageFirstSection(PIMAGE_NT_HEADERS ntheader)
{
   return (PIMAGE_SECTION_HEADER)((unsigned)&(ntheader->OptionalHeader)
     + ntheader->FileHeader.SizeOfOptionalHeader);
}

#define DefaultCodeSectionName _TEXT(".text")
#define DefaultDataSectionName _TEXT(".data")

bool __fastcall AddModuleCodeDataRange(HMODULE AModule, void *AParam)
{
  if ((FindResource(AModule, DVCLALResName, RT_RCDATA))
    /*&& (GetProcAddress(AModule, CPPdebugHookExport))*/)
  {
    PIMAGE_NT_HEADERS ntheader = (PIMAGE_NT_HEADERS)((unsigned)AModule
      + ((PIMAGE_DOS_HEADER)AModule)->e_lfanew);
    PIMAGE_SECTION_HEADER CodeSecHeader = GetImageFirstSection(ntheader);
                                        //= IMAGE_FIRST_SECTION(ntheader);
    PIMAGE_SECTION_HEADER DataSecHeader = CodeSecHeader + 1;
    if (((memcmp(DefaultCodeSectionName, CodeSecHeader->Name, 5)) == 0)
      && (CodeSecHeader->Characteristics == (IMAGE_SCN_MEM_EXECUTE 
        | IMAGE_SCN_MEM_READ | IMAGE_SCN_CNT_CODE))
      && ((memcmp(DefaultDataSectionName, DataSecHeader->Name, 5)) == 0)
      && (DataSecHeader->Characteristics == (IMAGE_SCN_MEM_WRITE
        | IMAGE_SCN_MEM_READ | IMAGE_SCN_CNT_INITIALIZED_DATA)))
    {

      int Index;
      if (!FindCodeDataRangeByDataAddr((unsigned)AModule   
        + DataSecHeader->VirtualAddress, &Index, NULL))
      {

        int NewCount = ModuleCodeDataRangesCount + 1;
        if (NewCount >= ModuleCodeDataRangesCapacity)
        {
          //Realloc
          int NewCapacity = ModuleCodeDataRangesCapacity
            + (ModuleCodeDataRangesCapacity / 4);
          gpModuleCodeDataRanges =
            (PModuleCodeDataRanges)FinalReallocMem(gpModuleCodeDataRanges,
            sizeof(ModuleCodeDataRanges) * NewCapacity);
          ModuleCodeDataRangesCapacity = NewCapacity;
        }

        ModuleCodeDataRangesCount = NewCount;
        
        gpModuleCodeDataRanges[Index].CodeSecStart = (unsigned)AModule
          + CodeSecHeader->VirtualAddress;
        gpModuleCodeDataRanges[Index].DataSecStart = (unsigned)AModule
          + DataSecHeader->VirtualAddress;
        gpModuleCodeDataRanges[Index].DataSecEnd = (unsigned)AModule
          + DataSecHeader->VirtualAddress + DataSecHeader->Misc.VirtualSize;
      }
    }
  }

  return true;
}

void __fastcall FinalizeModuleCodeDataRanges(void)
{
  if ((unsigned)gpModuleCodeDataRanges > 1)
  {
    FinalFreeMem(gpModuleCodeDataRanges);
    gpModuleCodeDataRanges = NULL;
    ModuleCodeDataRangesCount = 0;
    ModuleCodeDataRangesCapacity = NULL;
  }
}

#define InitialCodeDataRangeCount 256

bool __fastcall FillModuleCodeDataRanges(void)
{
  if (!gpModuleCodeDataRanges)
  {
    InitFinalMemMgr();

    gpModuleCodeDataRanges =
      (PModuleCodeDataRanges)FinalGetMem(sizeof(ModuleCodeDataRanges)
      * InitialCodeDataRangeCount);
    ModuleCodeDataRangesCapacity = InitialCodeDataRangeCount;
    
    bool ret = EnumModules(AddModuleCodeDataRange, NULL);
    if ((!ret) || (!ModuleCodeDataRangesCount))
    {
      FinalizeModuleCodeDataRanges();
      gpModuleCodeDataRanges = (PModuleCodeDataRanges)1;
      
      return false;
    }

    if (ret)
    {
      LowestDataAddr = gpModuleCodeDataRanges->DataSecStart;
      HighestDataAddr =
        gpModuleCodeDataRanges[ModuleCodeDataRangesCount - 1].DataSecEnd
        - sizeof(void *);
    }
    return ret;
  }
  else {
    return false;
  }
}

#pragma option  push    -a1

struct  TypeDescriptor;
typedef TypeDescriptor * TypeDescriptorPtr;

struct TypeDescriptor
{
  unsigned        Size;
  unsigned short  Mask;
  unsigned short  Name;

  union
  {
    struct
    {
      unsigned        VTablePtrOffset;
      unsigned        Flags;
    }
      Class;
  };
};


//TypeDescriptor.Mask flags

#define TYPE_MASK_IS_STRUCT    0x0001
#define TYPE_MASK_IS_CLASS     0x0002

#define CLASS_FLAG_HAS_VTABPTR  0x00000010
#define CLASS_FLAG_HAS_RTTI     0x00000040

#pragma option  pop


TypeDescriptorPtr __fastcall GetCppVirtualObjectTypeIdPtrByVTablePtr(void * AVTablePtr,
  unsigned AVTablePtrOffset)
{
  if (AVTablePtr)
  {
    if ((!((unsigned)AVTablePtr & (sizeof(void *) - 1)))
      && (!((unsigned)AVTablePtrOffset & (sizeof(void *) - 1))))
    {
      if (!gpModuleCodeDataRanges)
      {
        if (!FillModuleCodeDataRanges())
        {
          return NULL;
        }
      }

      if (((unsigned)AVTablePtr >= LowestDataAddr) && ((unsigned)AVTablePtr <= HighestDataAddr))
      {
        PModuleCodeDataRanges ADataRange, ACodeRange;

        if (FindCodeDataRangeByDataAddr((unsigned)AVTablePtr
          - (sizeof(unsigned) * 4), NULL, &ADataRange))
        {
          //maybe vtableptr
          unsigned * vftPtr = (unsigned *)AVTablePtr;
          unsigned VMFuncAddr = *vftPtr;
          if (((VMFuncAddr >= ADataRange->CodeSecStart)
            && (VMFuncAddr < ADataRange->DataSecStart))
            || (FindCodeDataRangeByCodeAddr(VMFuncAddr, NULL, &ACodeRange)))
          {
            //address of virtual member function is valid
            unsigned varOffset = vftPtr[-2];
            unsigned rttiPtrOffset = vftPtr[-1];
            if (varOffset <= AVTablePtrOffset)
            {
              unsigned rttiPtr = (unsigned)((char *)vftPtr - rttiPtrOffset);
              if ((rttiPtr >= ADataRange->DataSecStart)
                && (((unsigned *)rttiPtr)[-1] == 0))
              { //rtti Ptr is valid
                TypeDescriptorPtr mdtpidPtr = *((TypeDescriptorPtr *)((unsigned *)rttiPtr - 2) - 1);
                if (((unsigned)mdtpidPtr > ADataRange->CodeSecStart)
                  && (((unsigned)mdtpidPtr + (sizeof(TypeDescriptor) - sizeof(GUID)))
                  < ADataRange->DataSecStart))
                { //tpid data in code section
                  if ((mdtpidPtr->Size >= (AVTablePtrOffset + sizeof(void *)))
                    && (mdtpidPtr->Class.VTablePtrOffset == AVTablePtrOffset)
                    && (mdtpidPtr->Mask & (TYPE_MASK_IS_STRUCT | TYPE_MASK_IS_CLASS))
                    && (mdtpidPtr->Class.Flags & (CLASS_FLAG_HAS_VTABPTR | CLASS_FLAG_HAS_RTTI)))
                  { //tpid data valid ?
                    unsigned char * TypeName = (unsigned char *)mdtpidPtr
                                               + mdtpidPtr->Name;
                    if ((((unsigned)TypeName + sizeof(unsigned char) * 2)
                      < ADataRange->DataSecStart) && (*TypeName <= 'z'))
                    {
                      return mdtpidPtr;
                    }
                  }
                }
              }
            }
          }

        }
      }
    }
  }
  return NULL; 
}

//#define CheckVirtualRootBaseFirst //Returned may not be the most derived type

TypeDescriptorPtr __fastcall GetCppVirtualObjectTypeIdPtr(void * APointer, unsigned ASize)
{
  if ((APointer) && (ASize >= sizeof(void *)))
  {
    if (!((unsigned)APointer & (sizeof(void *) - 1)))
    {
      if (!gpModuleCodeDataRanges)
      {
        if (!FillModuleCodeDataRanges())
        {
          return NULL;
        }
      }
      #ifdef CheckVirtualRootBaseFirst
      TypeDescriptorPtr ret = GetCppVirtualObjectTypeIdPtrByVTablePtr(*((void **)APointer), 0);
      if (ret)
      {
        return ret;
      }
      #endif
      PModuleCodeDataRanges ADataRange, ACodeRange;
      unsigned ObjectSize = ASize;
      
      ASize = ASize - (ASize & (sizeof(void *) - 1)) - sizeof(void *);

      unsigned * DataPtr = (unsigned *)((char *)APointer + ASize);

      #ifdef CheckVirtualRootBaseFirst
      while (DataPtr > (unsigned *)APointer)
      #else
      while (DataPtr >= (unsigned *)APointer)
      #endif
      {
        unsigned Data = *DataPtr;
        if ((Data >= LowestDataAddr) && (Data <= HighestDataAddr))
        {
          if (FindCodeDataRangeByDataAddr(Data - (sizeof(unsigned) * 4),
            NULL, &ADataRange))
          {
            //maybe vtableptr
            unsigned * vftPtr = (unsigned *)Data;
            unsigned VMFuncAddr = *vftPtr;
            if (((VMFuncAddr >= ADataRange->CodeSecStart)
              && (VMFuncAddr < ADataRange->DataSecStart))
              || (FindCodeDataRangeByCodeAddr(VMFuncAddr, NULL, &ACodeRange)))
            {
              //address of virtual member function is valid
              unsigned varOffset = vftPtr[-2];
              unsigned rttiPtrOffset = vftPtr[-1];
              unsigned vftPtrOffset = (char *)DataPtr - (char *)APointer;
              if (varOffset <= vftPtrOffset)
              {
                unsigned rttiPtr = (unsigned)((char *)vftPtr - rttiPtrOffset);
                if ((rttiPtr >= ADataRange->DataSecStart)
                  && (((unsigned *)rttiPtr)[-1] == 0))
                { //rtti Ptr is valid
                  TypeDescriptorPtr mdtpidPtr = *((TypeDescriptorPtr *)((unsigned *)rttiPtr - 2) - 1);
                  if (((unsigned)mdtpidPtr > ADataRange->CodeSecStart)
                    && (((unsigned)mdtpidPtr + (sizeof(TypeDescriptor) - sizeof(GUID)))
                    < ADataRange->DataSecStart))
                  { //tpid data in code section
                    if ((mdtpidPtr->Size <= ObjectSize)
                      && (mdtpidPtr->Class.VTablePtrOffset == vftPtrOffset)
                      && (mdtpidPtr->Mask & (TYPE_MASK_IS_STRUCT | TYPE_MASK_IS_CLASS))
                      && (mdtpidPtr->Class.Flags & (CLASS_FLAG_HAS_VTABPTR | CLASS_FLAG_HAS_RTTI)))
                    { //tpid data valid ?
                      unsigned char * TypeName = (unsigned char *)mdtpidPtr
                                                 + mdtpidPtr->Name;
                      if ((((unsigned)TypeName + sizeof(unsigned char) * 2)
                        < ADataRange->DataSecStart) && (*TypeName <= 'z'))
                      {
                        return mdtpidPtr;
                      }
                    }
                  }
                }
              }
            }

          }
        }
        DataPtr--;
      } 
    }
  }
  return NULL;
}


char * __fastcall GetCppVirtualObjectTypeName(void * APointer, unsigned ASize)
{
  TypeDescriptorPtr AtpidPtr = GetCppVirtualObjectTypeIdPtr(APointer, ASize);
  if (AtpidPtr)
  {
    return (char *)AtpidPtr + AtpidPtr->Name;
  }
  else {
    return NULL;
  }
}

char * __fastcall GetCppVirtualObjectTypeNameByVTablePtr(void * AVTablePtr,
  unsigned AVTablePtrOffset)
{
  TypeDescriptorPtr AtpidPtr = GetCppVirtualObjectTypeIdPtrByVTablePtr(AVTablePtr,
                       AVTablePtrOffset);
  if (AtpidPtr)
  {
    return (char *)AtpidPtr + AtpidPtr->Name;
  }
  else {
    return NULL;
  }
}

unsigned __fastcall GetCppVirtualObjectSizeByTypeIdPtr(TypeDescriptorPtr AtpidPtr)
{
  if ((AtpidPtr)
    && (AtpidPtr->Mask & (TYPE_MASK_IS_STRUCT | TYPE_MASK_IS_CLASS))
    && (AtpidPtr->Class.Flags & (CLASS_FLAG_HAS_VTABPTR | CLASS_FLAG_HAS_RTTI)))
  {
    return AtpidPtr->Size;
  }
  else {
    return 0;
  }
}

char * __fastcall GetCppVirtualObjectTypeNameByTypeIdPtr(TypeDescriptorPtr AtpidPtr)
{
  if (AtpidPtr)
  {
    return (char *)AtpidPtr + AtpidPtr->Name;
  }
  else {
    return NULL;
  }
}

#endif //CheckCppObjectTypeEnabled

#define BORLANDMM _TEXT("borlndmm")

#define CRTL_MEM_SIGNATURE_EXPORT "___CRTL_MEM_GetBorMemPtrs"
#define CRTL_GET_HEAP_REDIRECTOR_INFO "__get_heap_redirector_info"

bool __fastcall TryHookRTLHeapRedirector(HMODULE AModule, void *AParam)
{
  if ((FindResource(AModule, DVCLALResName, RT_RCDATA))
    /*&& (GetProcAddress(AModule, CPPdebugHookExport))*/
    && (GetProcAddress(AModule, CRTL_MEM_SIGNATURE_EXPORT)))
  {
    rtl_get_heap_redirector_info_func rtl_get_heap_redirector_info;
    rtl_get_heap_redirector_info
      = (rtl_get_heap_redirector_info_func)GetProcAddress(AModule, CRTL_GET_HEAP_REDIRECTOR_INFO);
    if (rtl_get_heap_redirector_info)
    {
      HeapRedirector * pHRDir = (*rtl_get_heap_redirector_info)();
      if (pHRDir)
      {
        if ((pHRDir->flags < hrfBorlndmm) || (pHRDir->flags == hrfVCLSystem))
        {
          void * PatchAddr;

          HeapRedirectorStorePtr node = (HeapRedirectorStorePtr)FinalGetMem(sizeof(HeapRedirectorStore));
          node->Data = *pHRDir;
          node->Module = AModule;
          
          //insert node into store list
          node->Next = HeapRedirectorStoreListHeader;
          HeapRedirectorStoreListHeader = node;

          pHRDir->malloc = &Cpp_malloc_Stub;
          pHRDir->free = &Cpp_free_Stub;
          pHRDir->realloc = &Cpp_realloc_Stub;
          pHRDir->terminate = &Cpp_terminate_Stub;
          pHRDir->flags = hrfOther;

          pHRDir->allocated = 1;

          //patch RTL _terminate of this module
          PatchAddr = GetProcAddress(AModule, _terminateExport);
          if ((PatchAddr) && (((PRelativeJmp32)PatchAddr)->JmpInst != RelativeJmp32Inst)
            && (!PatchProc(PatchAddr, &New_terminate, &node->PatchBackup)))
          {
            node->PatchAddress = PatchAddr;
          }
          else
          {
            node->PatchAddress = NULL;
          }
        }
      }
    }
  }
  
  return true;
}

bool __fastcall TryUnhookRTLHeapRedirector(HMODULE AModule, void *AParam)
{
  if ((FindResource(AModule, DVCLALResName, RT_RCDATA))
    /*&& (GetProcAddress(AModule, CPPdebugHookExport))*/
    && (GetProcAddress(AModule, CRTL_MEM_SIGNATURE_EXPORT)))
  {
    rtl_get_heap_redirector_info_func rtl_get_heap_redirector_info;
    rtl_get_heap_redirector_info
      = (rtl_get_heap_redirector_info_func)GetProcAddress(AModule, CRTL_GET_HEAP_REDIRECTOR_INFO);
    if (rtl_get_heap_redirector_info)
    {
      HeapRedirector * pHRDir = (*rtl_get_heap_redirector_info)();
      if (pHRDir)
      {
        //restore and remove store node
        {
          HeapRedirectorStorePtr prev, node;

          prev = NULL;
          node = HeapRedirectorStoreListHeader;
          while (node)
          {
            if (node->Module == AModule)
            {
              //restore original heap redirector
              if ((pHRDir->flags == hrfOther)
                && (pHRDir->malloc == &Cpp_malloc_Stub)
                && (pHRDir->free == &Cpp_free_Stub)
                && (pHRDir->realloc == &Cpp_realloc_Stub)
                && (pHRDir->terminate == &Cpp_terminate_Stub)
                )
              {
              #ifdef DetectMMOperationsAfterUninstall
                if ((bool)AParam)
                {
                  pHRDir->malloc = &Cpp_Invalid_malloc_Stub;
                  pHRDir->free = &Cpp_Invalid_free_Stub;
                  pHRDir->realloc = &Cpp_Invalid_realloc_Stub;
                }
                else
              #endif
                  *pHRDir = node->Data;
              }

              //restore RTL _terminate of this module
              if (node->PatchAddress) 
              {
                UnPatchProc(node->PatchAddress, &New_terminate, &node->PatchBackup);
              }

              //remove node from store list
              if (prev)
              {
                prev->Next = node->Next;
              }
              else
              {
                HeapRedirectorStoreListHeader = node->Next;
              }

              FinalFreeMem(node);

              break;
            }
            else
            {
              prev = node;
              node = node->Next;
            }
          }
        }
      }
    }
  }

  return true;
}

#endif //PatchBCBTerminate


void BCBInstallFastMM()
{
//#ifdef __DLL__ //not defined even with -tWD ?
//#endif

//#if ((!defined(_NO_VCL)) && defined(__DLL__) && defined(_RTLDLL))
   //borlndmm.dll will linked in
//#else
  InitializeMemoryManager();
  #if __BORLANDC__ >= 0x582
  //>= BDS2006 ?
    //CheckCanInstallMemoryManager will finally call System.GetHeapStatus which is the
    //internal shipped copy of FastGetHeapStatus routine, but the InitializeMemoryManager
    //routine of that copy is not called yet at this point, and thus System.GetHeapStatus
    //will generate an access violation exception.
    //Currently avoid this exception by skip the check
    #ifndef _NO_VCL
    if (CheckCanInstallMemoryManager())
    #endif //!_NO_VCL
  #else
  if (CheckCanInstallMemoryManager())
  #endif //< BDS2006
  {
    #ifdef PatchBCBTerminate
      #if defined(__DLL__) && defined(FullDebugMode) && defined(LoadDebugDLLDynamically)
      //if FastMM_FullDebugMode.dll receive DLL_PROCESS_DETACH before
      //calling FinalizeMemoryManager, exception will occur when calling
      //LogStackTrace in FastMM_FullDebugMode.dll, the following call
      //will delay the processing of DLL_PROCESS_DETACH in DllMain of
      //FastMM_FullDebugMode.dll
      if (!TryHookFullDebugModeDllEntry())
      {
        return;
      }
      #endif
    #endif

    #ifdef FullDebugMode
      #ifdef ClearLogFileOnStartup
        DeleteEventLog();
      #endif //ClearLogFileOnStartup
    #endif //FullDebugMode

    #ifdef PatchBCBTerminate
    #if __BORLANDC__ >= 0x582
    //>= BDS2006 ?
    System::TMemoryManagerEx AMemoryManager;
    #else
    System::TMemoryManager AMemoryManager;
    #endif
    System::GetMemoryManager(AMemoryManager);
    StockGetMemPtr = AMemoryManager.GetMem;
    #endif

    InstallMemoryManager();

#if __BORLANDC__ < 0x0560
  #if !defined(PURE_CPLUSPLUS)
    #if !defined(PatchBCBTerminate)
    #if __BORLANDC__ >= 0x582
    //>= BDS2006 ?
    System::TMemoryManagerEx AMemoryManager;
    #else
    System::TMemoryManager AMemoryManager;
    #endif
    #endif
    System::GetMemoryManager(AMemoryManager);

    GetMemPtr = AMemoryManager.GetMem;
    FreeMemPtr = AMemoryManager.FreeMem;
    ReallocMemPtr = AMemoryManager.ReallocMem;
  #endif
#endif

  #ifdef PatchBCBTerminate
    IsMMInstalled = true;
  #endif

  #ifdef PatchBCBTerminate

    HMODULE ThisModule = (HMODULE)System::FindHInstance(&BCBInstallFastMM);
    HMODULE MainModule = GetModuleHandle(0);

    //#ifndef _RTLDLL
    HMODULE BorlandMM_Module = GetModuleHandle(BORLANDMM);
    if (!BorlandMM_Module)
    {
      pHRDir = _get_heap_redirector_info();
      if (pHRDir)
      {
        if ((pHRDir->flags < hrfBorlndmm) || (pHRDir->flags == hrfVCLSystem))
        {
          Old_heap_redirector = *pHRDir;

          pHRDir->malloc = &Cpp_malloc_Stub;
          pHRDir->free = &Cpp_free_Stub;
          pHRDir->realloc = &Cpp_realloc_Stub;
          pHRDir->terminate = &Cpp_terminate_Stub;
          pHRDir->flags = hrfOther;

          pHRDir->allocated = 1;
        }
        else {
          pHRDir = NULL;
        }
      }
    }
    else
    {
      if (BorlandMM_Module == ThisModule)
      {
        IsBorlandMMDLL = true;
        //Try hook heap redirector of RTL modules
        EnumModules(TryHookRTLHeapRedirector, NULL);
      }
    }
    //#endif //!_RTLDLL

    pCppDebugHook = (int *)(GetProcAddress(MainModule, CPPdebugHookExport));
    if (!pCppDebugHook)
    {
      pCppDebugHook = &__CPPdebugHook;
    }
    #ifdef CheckCppObjectTypeEnabled
    GetCppVirtObjSizeByTypeIdPtrFunc =
      (TGetCppVirtObjSizeByTypeIdPtrFunc)&GetCppVirtualObjectSizeByTypeIdPtr;

    GetCppVirtObjTypeIdPtrFunc =
      (TGetCppVirtObjTypeIdPtrFunc)&GetCppVirtualObjectTypeIdPtr;

    GetCppVirtObjTypeNameFunc =
      (TGetCppVirtObjTypeNameFunc)&GetCppVirtualObjectTypeName;

    GetCppVirtObjTypeNameByTypeIdPtrFunc =
      (TGetCppVirtObjTypeNameByTypeIdPtrFunc)&GetCppVirtualObjectTypeNameByTypeIdPtr;

    GetCppVirtObjTypeNameByVTablePtrFunc =
      (TGetCppVirtObjTypeNameByVTablePtrFunc)&GetCppVirtualObjectTypeNameByVTablePtr;
    #endif

    IsInDLL = (MainModule != ThisModule);
    if (!IsInDLL)
    {
      if (Patch_terminate())
      {
          terminatePatched = true;

        #ifdef EnableMemoryLeakReporting
          #if __BORLANDC__ >= 0x582
          //>= BDS2006 ?
          //"ios.cpp", line 136, ios_base::_Init(), "locale" leaks
          RegisterExpectedMemoryLeak(20, 8);
          //"locale0.cpp", line 167, locale::_Init(), "_Locimp" leak due to above leaks
          RegisterExpectedMemoryLeak(68, 1);
          #endif
        #endif
      }
    }
    #ifndef _RTLDLL
    else
    {
    #ifdef EnableMemoryLeakReporting
      #if __BORLANDC__ >= 0x582
      //>= BDS2006 ?
      //"ios.cpp", line 136, ios_base::_Init(), "locale" leaks
      RegisterExpectedMemoryLeak(20, 8);
      //"locale0.cpp", line 167, locale::_Init(), "_Locimp" leak due to above leaks
      RegisterExpectedMemoryLeak(68, 1);

      RegisterExpectedMemoryLeak(228, 1);
      #endif
    #endif
    }
    #endif //_RTLDLL
    
    #endif //PatchBCBTerminate
  }
//#endif  
}
#pragma startup BCBInstallFastMM 0

#ifdef PatchBCBTerminate

void BCBUninstallFastMM()
{
  //Sadly we cannot uninstall here since there are still live pointers.
//#if ((!defined(_NO_VCL)) && defined(__DLL__) && defined(_RTLDLL))

//#else
  if (IsMMInstalled && (!terminatePatched))
  {
    //Delphi MemoryManager already installed here
    FinalizeMemoryManager();

    #if __BORLANDC__ >= 0x582
    //>= BDS2006 ?
    System::TMemoryManagerEx AMemoryManager;
    #else
    System::TMemoryManager AMemoryManager;
    #endif
    System::GetMemoryManager(AMemoryManager);

    //MemoryManager uninstalled ?
    bool DelphiMMUninstalled = (AMemoryManager.GetMem != InternalGetMem);
    #ifdef DetectMMOperationsAfterUninstall
    //InvalidMemoryManager get set as Delphi MemoryManager ?
    bool InvalidMMSet = (AMemoryManager.GetMem != StockGetMemPtr);
    #endif

#if __BORLANDC__ < 0x0560
  #if !defined(PURE_CPLUSPLUS)
    GetMemPtr = NULL;
    FreeMemPtr = NULL;
    ReallocMemPtr = NULL;
  #endif
#endif

    #ifdef CheckCppObjectTypeEnabled
    GetCppVirtObjSizeByTypeIdPtrFunc = NULL;
    GetCppVirtObjTypeIdPtrFunc = NULL;
    GetCppVirtObjTypeNameFunc = NULL;
    GetCppVirtObjTypeNameByTypeIdPtrFunc = NULL;
    GetCppVirtObjTypeNameByVTablePtrFunc = NULL;
    
    FinalizeModuleCodeDataRanges();
    #endif
    
    if (DelphiMMUninstalled)
    {
      if (pHRDir)
      {
        #ifdef DetectMMOperationsAfterUninstall
        if (InvalidMMSet)
        {
          InvalidGetMemPtr = AMemoryManager.GetMem;
          InvalidFreeMemPtr = AMemoryManager.FreeMem;
          InvalidReallocMemPtr = AMemoryManager.ReallocMem;

          pHRDir->malloc = Cpp_Invalid_malloc_Stub;
          pHRDir->free = Cpp_Invalid_free_Stub;
          pHRDir->realloc = Cpp_Invalid_realloc_Stub;
        }
        else
        #endif
          *pHRDir = Old_heap_redirector;
          
        pHRDir = NULL;
      }
      else
      {
        if (IsBorlandMMDLL)
        {
          //Try unhook heap redirector of RTL modules
        #ifdef DetectMMOperationsAfterUninstall
          EnumModules(TryUnhookRTLHeapRedirector, (void *)InvalidMMSet);
        #else
          EnumModules(TryUnhookRTLHeapRedirector, NULL);
        #endif
          FinalizeHeapRedirectorStoreList();
        }
      }
    }

    #if defined(__DLL__) && defined(FullDebugMode) && defined(LoadDebugDLLDynamically)
    CallOldFullDebugModeDllEntry();
    #endif
  }
//#endif  
}
#pragma exit BCBUninstallFastMM 0

#endif //PatchBCBTerminate

#ifdef __cplusplus
} // extern "C"
#endif

#pragma option pop

//#endif //!_NO_VCL 
