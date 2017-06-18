# FastMM4AVX

FastMM4AVX (AVX1/AVX2/ERMS support for FastMM4)

This is a fork of the Fast Memory Manager 4.992 by Pierre le Riche
(see below for the The original FastMM4 description)

What was added to the fork:
 - if the CPU supports Enhanced REP MOVSB/STOSB (ERMS), use this feature
   for faster memory copy (under 32 bit or 64-bit);
 - if the CPU supports AVX or AVX2, use the 32-byte YMM registers
   for faster memory copy, but only if EnableAVX is defined (Off by default)
 - if EnableAVX is defined, all memory blocks are aligned by 32 bytes;
 - memory copy is secure - all XMM/YMM registers used to copy memory
   are cleared by vxorps/vpxor, so the leftovers of the copied memory are not
   exposed in the XMM/YMM registers;
 - properly handle AVX-SSE transitions to not incur the transition penalties,
   only call vzeroupper under AVX1, but not under AVX2 since it slows down
   subsequent SSE code under Kaby Lake;
 - names assigned to a couple of magic constants.


AVX1/AVX2/ERMS support Copyright (C) 2017 RITLABS S.R.L. All rights reserved.
https://www.ritlabs.com/
AVX1/AVX2/ERMS support is written by Maxim Masiutin <max@ritlabs.com>

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
