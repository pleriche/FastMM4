# FastMM4AVX

FastMM4AVX (AVX1/AVX2/ERMS support for FastMM4)

Version 1.02

This is a fork of the Fast Memory Manager 4.992 by Pierre le Riche
(see below for the original FastMM4 description)

What was added to the fork:
 - if the CPU supports AVX or AVX2, use the 32-byte YMM registers
   for faster memory copy, and if the CPU supports AVX-512,
   use the 64-byte ZMM registers for even faster memory copy;
   use DisableAVX to turn AVX off completely or
   use DisableAVX1/DisableAVX2/DisableAVX512 to disable separately certain
   AVX-related instruction set from being compiled into FastMM4);
 - if EnableAVX is defined, all memory blocks are aligned by 32 bytes, but
   you can also use Align32Bytes define without AVX; please note that the memory
   overhead is higher when the blocks are aligned by 32 bytes, because some
   memory is lost by padding;
 - with AVX, memory copy is secure - all XMM/YMM/ZMM registers used to copy 
   memory are cleared by vxorps/vpxor, so the leftovers of the copied memory 
   are not exposed in the XMM/YMM/ZMM registers;
 - properly handle AVX-SSE transitions to not incur the transition penalties,
   only call vzeroupper under AVX1, but not under AVX2 since it slows down
   subsequent SSE code under Skylake / Kaby Lake;
 - improved multi-threading locking mechanism - so the testing application
   (from the FastCode challenge) works up to twitce faster when the number of
   threads is the same or larger than the number of physical cores;
 - if the CPU supports Enhanced REP MOVSB/STOSB (ERMS), use this feature
   for faster memory copy (under 32 bit or 64-bit) (see the EnableERMS define,
   on by default, use DisableERMS to turn it off);
 - support for FreePascal 1.6.4 (the original FastMM4 4.992 requires
   modifications, it doesn't work under FreePascal 1.6.4 out-of-the-box;
 - proper branch target alignment in assembly routines;
 - compare instructions + conditional jump instructions are put together
   to allow macro-op fusion (which happens since Core2 processors, when
   the first instruction is a CMP or TEST instruction and the second instruction
   is a conditional jump instruction) ;
 - names assigned to some constants that used to be "magic constants",
   i.e. unnamed numerical constants - plenty of them were present
   throughout the whole code.
 - multiplication and division by constant which is a power of 2
   replaced to shl/shr, because Delphi64 compiler doesn't replace such
   multiplications and divisions to shl/shr processor instructions,
   and, according to the Intel Optimization Guide, shl/shr is much faster
   than imul/idiv, especially on Knights Landing processors;
 - the compiler environment is more flexible now: you can now compile FastMM4
   with, for example, typed "@" operator or any other option. Almost all
   externally-set compiler directives are honored by FastMM except a few
   (currently just one) - look for the "Compiler options for FastMM4" section
   below to see what options cannot be externally set and are always
   redefined by FastMM4 for itself - even if you set up these compiler options
   differently outside FastMM4, they will be silently
   redefined, and the new values will be used for FastMM4 only;
 - those fixed-block-size memory move procedures that are not needed
   (under the current bitness and alignment compbinations) are
   explicitly excluded from compiling, to not rely on the compiler
   that is supposed to remove these function after copmpilation;
 - added length parameter do what were dangerous nul-terminated string
   operations via PAnsiChar, to prevent potential stack buffer overruns
   (or maybe even stack-based exploitation?), and there some Pascal functions
   also left, the argument is not yet checked, see the "todo" comments
   to figure out where the length is not yet checked. Anyway, since these
   memory functions are only used in Debug mode, i.e. in development
   environment, not in Release (production), the impact of this
   "vulnerability" is minimal (questionable);
 - removed some typecasts; the code is stricter to let the compiler
   do the job, check everything and mitigate probable error. You can
   even compile the code with "integer overflow checking" and
   "range checking", as well as with "typed @ operator" - for safer
   code. Also added round bracket in the places where the typed @ operator
   was used, to better emphasize on who's address is taken;
 - one-byte data types of memory areas used for locking ("lock cmpxchg" or
   "lock xchg" replaced from Boolean to Byte for stricter type checking;
 - used simpler lock instructions: "lock xchg" rather than "lock cmpxchg";
 - implemented dedicated lock and unlock procedures; before that locking
   operations were scattered throughout the code; now the locking function
   have meaningful names: AcquireLockByte and ReleaseLockByte; the values of the
   lock byte is now checked for validity when "FullDebugMode" or "DEBUG" is on,
   to detect cases when the same lock is released twice, and other improper
   use of the lock bytes;
 - added compile-time options (SmallBlocksLockedCriticalSection/
   MediumBlocksLockedCriticalSection/LargeBlocksLockedCriticalSection)
   that remove spin-loops of Sleep(0) or (Sleep(InitialSleepTime)) and
   Sleep(1) (or Sleep(AdditionalSleepTime)) and replaced them with
   EnterCriticalSection/LeaveCriticalSection to save valuable CPU cycles
   wasted by Sleep(0) and to improve speed that was affected each time by
   at least 1 millisecond by Sleep(1); on the other hand, the CriticalSections
   are much more CPU-friendly and have definitely lower latency than Sleep(1);
   besides that, it checks if the CPU supports SSE2 and thus the "pause"
   instruction, it uses "pause" spin-loop for 5000 iterations and then
   SwitchToThread() instead of critical sections; If a CPU doesn't have the
   "pause" instrcution or Windows doesn't have the SwitchToThread() API
   function, it will use EnterCriticalSection/LeaveCriticalSection.

Here are the comparison of the Original FastMM4 version 4.992, with default
options compiled for Win64 by Delphi 10.2 Tokyo (Release with Optimization),
and the current FastMM4-AVX branch. Under some scenarios, the FastMM4-AVX branch
is more than twice as fast comparing to the Original FastMM4. The tests
have been run on two different computers: one under Xeon E6-2543v2 with 2 CPU
sockets, each has 6 physical cores (12 logical threads) - with only 5 physical
core per socket enabled for the test application. Another test was done under
a i7-7700K CPU.

Used the "Multi-threaded allocate, use and free" and "NexusDB"
test cases from the FastCode Challenge Memory Manager test suite,
modified to run under 64-bit.

                     Xeon E6-2543v2 2*CPU     i7-7700K CPU
                    (allocated 20 logical  (allocated 8 logical
                     threads, 10 physical   threads, 4 physical
                     cores, NUMA)           cores)

                    Orig.  AVX-br.  Ratio   Orig.  AVX-br. Ratio
                    ------  -----  ------   -----  -----  ------
02-threads realloc   96552  59951  62.09%   65213  49471  75.86%
04-threads realloc   97998  39494  40.30%   64402  47714  74.09%
08-threads realloc   98325  33743  34.32%   64796  58754  90.68%
16-threads realloc  116708  45855  39.29%   71457  60173  84.21%
16-threads realloc  116273  45161  38.84%   70722  60293  85.25%
31-threads realloc  122528  53616  43.76%   70939  62962  88.76%
64-threads realloc  137661  54330  39.47%   73696  64824  87.96%
NexusDB 02 threads  122846  90380  73.72%   79479  66153  83.23%
NexusDB 04 threads  122131  53103  43.77%   69183  43001  62.16%
NexusDB 08 threads  124419  40914  32.88%   64977  33609  51.72%
NexusDB 12 threads  181239  55818  30.80%   83983  44658  53.18%
NexusDB 16 threads  135211  62044  43.61%   59917  32463  54.18%
NexusDB 31 threads  134815  48132  33.46%   54686  31184  57.02%
NexusDB 64 threads  187094  57672  30.25%   63089  41955  66.50%

(the tests have been done on 14-Jul-2017)

AVX1/AVX2/ERMS support Copyright (C) 2017 Ritlabs S.R.L. All rights reserved.
https://www.ritlabs.com/
AVX1/AVX2/ERMS support is written by Maxim Masiutin <max@ritlabs.com>

FastMM4AVX is released under a dual license, and you may choose to use it 
under either the Mozilla Public License 2.0 (MPL 2.1, available from
https://www.mozilla.org/en-US/MPL/2.0/) or the GNU Lesser General Public
License Version 3, dated 29 June 2007 (LGPL 3, available from
https://www.gnu.org/licenses/lgpl.html).

FastMM4AVX is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

FastMM4AVX is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with FastMM4AVX (see license_lgpl.txt and license_gpl.txt)
If not, see <http://www.gnu.org/licenses/>.


FastMM4AVX Version History:

1.02 (07 November 2017) - added and tested support of the AVX-512 
     instruction set.

1.01 (10 October 2017) - made the source code compile under Delphi5, 
     thanks to Valts Silaputnins.

1.00 (27 July 2017) - initial revision.

The original FastMM4 description follows:

# FastMM4
Fast Memory Manager

Description:
 A fast replacement memory manager for Embarcadero Delphi applications
 that scales well under multi-threaded usage, is not prone to memory
 fragmentation, and supports shared memory without the use of external .DLL
 files.

Homepage:
 https://github.com/pleriche/FastMM4

Advantages:
 - Fast
 - Low overhead. FastMM is designed for an average of 5% and maximum of 10%
   overhead per block.
 - Supports up to 3GB of user mode address space under Windows 32-bit and 4GB
   under Windows 64-bit. Add the "$SetPEFlags $20" option (in curly braces)
   to your .dpr to enable this.
 - Highly aligned memory blocks. Can be configured for either 8-byte or 16-byte
   alignment.
 - Good scaling under multi-threaded applications
 - Intelligent reallocations. Avoids slow memory move operations through
   not performing unneccesary downsizes and by having a minimum percentage
   block size growth factor when an in-place block upsize is not possible.
 - Resistant to address space fragmentation
 - No external DLL required when sharing memory between the application and
   external libraries (provided both use this memory manager)
 - Optionally reports memory leaks on program shutdown. (This check can be set
   to be performed only if Delphi is currently running on the machine, so end
   users won't be bothered by the error message.)
 - Supports Delphi 4 (or later), C++ Builder 4 (or later), Kylix 3.

Usage:
 Delphi:
  Place this unit as the very first unit under the "uses" section in your
  project's .dpr file. When sharing memory between an application and a DLL
  (e.g. when passing a long string or dynamic array to a DLL function), both the
  main application and the DLL must be compiled using this memory manager (with
  the required conditional defines set). There are some conditional defines
  (inside FastMM4Options.inc) that may be used to tweak the memory manager. To
  enable support for a user mode address space greater than 2GB you will have to
  use the EditBin* tool to set the LARGE_ADDRESS_AWARE flag in the EXE header.
  This informs Windows x64 or Windows 32-bit (with the /3GB option set) that the
  application supports an address space larger than 2GB (up to 4GB). In Delphi 6
  and later you can also specify this flag through the compiler directive
  {$SetPEFlags $20}
  *The EditBin tool ships with the MS Visual C compiler.
 C++ Builder:
  Refer to the instructions inside FastMM4BCB.cpp.
