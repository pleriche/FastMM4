
; This file is needed to enable AVX-512 code for FastMM4-AVX.
; Use "nasm.exe -Ox -f win64 FastMM4_AVX512.asm" to compile this file
; You can get The Netwide Assembler, NASM, from http://www.nasm.us/

; This file is a part of FastMM4-AVX.
; FastMM4-AVX is a fork of the Fast Memory Manager 4.992 by Pierre le Riche

; FastMM4-AVX Copyright (C) 2017 Ritlabs S.R.L. All rights reserved.
; https://www.ritlabs.com/
; AVX1/AVX2/ERMS support is written by Maxim Masiutin <max@ritlabs.com>

; FastMM4-AVX is released under a dual license, and you may choose to use it
; under either the Mozilla Public License 2.0 (MPL 2.1, available from
; https://www.mozilla.org/en-US/MPL/2.0/) or the GNU Lesser General Public
; License Version 3, dated 29 June 2007 (LGPL 3, available from
; https://www.gnu.org/licenses/lgpl.html).

; This code uses zmm26 - zmm31 registers to avoid AVX-SSE transition penalty.
; These regsters (zmm16 - zmm31) have no non-VEX counterpart. According to the 
; advise of Agner Fog, there is no state transition and no penalty for mixing 
; zmm16 - zmm31 with non-VEX SSE code. By using these registers (zmm16 - zmm31)
; rather than zmm0-xmm15 we save us from calling "vzeroupper".
; Source: 
; https://stackoverflow.com/questions/43879935/avoiding-avx-sse-vex-transition-penalties/54587480#54587480
 

%define	EVEXR512N0	zmm31
%define	EVEXR512N1	zmm30
%define	EVEXR512N2	zmm29
%define	EVEXR512N3	zmm28
%define	EVEXR512N4	zmm27
%define	EVEXR512N5	zmm26
%define	EVEXR256N0	ymm31
%define	EVEXR256N1	ymm30
%define	EVEXR256N2	ymm29
%define	EVEXR256N3	ymm28
%define	EVEXR256N4	ymm27
%define	EVEXR256N5	ymm26
%define	EVEXR128N0	xmm31
%define	EVEXR128N1	xmm30
%define	EVEXR128N2	xmm29
%define	EVEXR128N3	xmm28
%define	EVEXR128N4	xmm27
%define	EVEXR128N5	xmm26


section	.text

	global		Move88AVX512
	global		Move120AVX512
	global		Move152AVX512
	global		Move184AVX512
	global		Move216AVX512
	global		Move280AVX512
	global		MoveX32LpAvx512WithErms

	%use		smartalign
	ALIGNMODE	p6, 32     ;  p6 NOP strategy, and jump over the NOPs only if they're 32B or larger.


	align		16
Move88AVX512:
	vmovdqu64	EVEXR512N0, [rcx]
	vmovdqa64	EVEXR128N1, [rcx+40h]
	mov		rcx, [rcx + 50h]
	vmovdqu64	[rdx], EVEXR512N0
	vmovdqa64	[rdx+40h], EVEXR128N1
	mov 		[rdx + 50h], rcx
	vpxord		EVEXR512N0,EVEXR512N0,EVEXR512N0
	vpxord		EVEXR128N1,EVEXR128N1,EVEXR128N1
	ret

	align		16
Move120AVX512:
	vmovdqu64	EVEXR512N0, [rcx]
	vmovdqa64	EVEXR256N1, [rcx+40h]
	vmovdqa64	EVEXR128N2, [rcx+60h]
	mov		rcx, [rcx + 70h]
	vmovdqu64 	[rdx], EVEXR512N0
	vmovdqa64 	[rdx+40h], EVEXR256N1
	vmovdqa64 	[rdx+60h], EVEXR128N2
	mov		[rdx+70h], rcx
	vpxord		EVEXR512N0,EVEXR512N0,EVEXR512N0
	vpxord		EVEXR256N1,EVEXR256N1,EVEXR256N1
	vpxord		EVEXR128N2,EVEXR128N2,EVEXR128N2
	ret

	align		16
Move152AVX512:
	vmovdqu64	EVEXR512N0, [rcx+00h]
	vmovdqu64	EVEXR512N1, [rcx+40h]
	vmovdqa64	EVEXR128N2, [rcx+80h]
	mov		rcx, [rcx+90h]
	vmovdqu64 	[rdx+00h], EVEXR512N0
	vmovdqu64 	[rdx+40h], EVEXR512N1
	vmovdqa64 	[rdx+80h], EVEXR128N2
	mov 		[rdx+90h], rcx
	vpxord  	EVEXR512N0,EVEXR512N0,EVEXR512N0
	vpxord  	EVEXR512N1,EVEXR512N1,EVEXR512N1
	vpxord		EVEXR128N2,EVEXR128N2,EVEXR128N2
	ret

	align		16
Move184AVX512:
	vmovdqu64 	EVEXR512N0, [rcx+00h]
	vmovdqu64 	EVEXR512N1, [rcx+40h]
	vmovdqa64 	EVEXR256N2, [rcx+80h]
	vmovdqa64 	EVEXR128N3, [rcx+0A0h]
	mov 		rcx, [rcx+0B0h]
	vmovdqu64 	[rdx-00h], EVEXR512N0
	vmovdqu64 	[rdx+40h], EVEXR512N1
	vmovdqa64 	[rdx+80h], EVEXR256N2
	vmovdqa64 	[rdx+0A0h],EVEXR128N3
	mov 		[rdx+0B0h],rcx
	vpxord 		EVEXR512N0,EVEXR512N0,EVEXR512N0
	vpxord 		EVEXR512N1,EVEXR512N1,EVEXR512N1
	vpxord 		EVEXR256N2,EVEXR256N2,EVEXR256N2
	vpxord 		EVEXR128N3,EVEXR128N3,EVEXR128N3
	ret

	align		16
Move216AVX512:
	vmovdqu64	EVEXR512N0, [rcx+00h]
	vmovdqu64	EVEXR512N1, [rcx+40h]
	vmovdqu64	EVEXR512N2, [rcx+80h]
	vmovdqa64	EVEXR128N3, [rcx+0C0h]
	mov		rcx, [rcx+0D0h]
	vmovdqu64 	[rdx+00h], EVEXR512N0
	vmovdqu64 	[rdx+40h], EVEXR512N1
	vmovdqu64 	[rdx+80h], EVEXR512N2
	vmovdqa64 	[rdx+0C0h], EVEXR128N3
	mov 		[rdx+0D0h], rcx
	vpxord  	EVEXR512N0,EVEXR512N0,EVEXR512N0
	vpxord  	EVEXR512N1,EVEXR512N1,EVEXR512N1
	vpxord  	EVEXR512N2,EVEXR512N2,EVEXR512N2
	vpxord 		EVEXR128N3,EVEXR128N3,EVEXR128N3
	ret

	align		16
Move248AVX512:
	vmovdqu64 	EVEXR512N0, [rcx+00h]
	vmovdqu64 	EVEXR512N1, [rcx+40h]
	vmovdqu64 	EVEXR512N2, [rcx+80h]
	vmovdqa64	EVEXR256N3, [rcx+0C0h]
	vmovdqa64	EVEXR128N4, [rcx+0E0h]
	mov 		rcx, [rcx+0F0h]
	vmovdqu64 	[rdx+00h], EVEXR512N0
	vmovdqu64 	[rdx+40h], EVEXR512N1
	vmovdqu64 	[rdx+80h], EVEXR512N2
	vmovdqa64 	[rdx+0C0h], EVEXR256N3
	vmovdqa64 	[rdx+0E0h], EVEXR128N4
	mov 		[rdx+0F0h], rcx
	vpxord 		EVEXR512N0,EVEXR512N0,EVEXR512N0
	vpxord 		EVEXR512N1,EVEXR512N1,EVEXR512N1
	vpxord 		EVEXR512N2,EVEXR512N2,EVEXR512N2
	vpxord		EVEXR256N3,EVEXR256N3,EVEXR256N3
	vpxord		EVEXR128N4,EVEXR128N4,EVEXR128N4
	ret

	align		16
Move280AVX512:
	vmovdqu64 	EVEXR512N0, [rcx+00h]
	vmovdqu64 	EVEXR512N1, [rcx+40h]
	vmovdqu64 	EVEXR512N2, [rcx+80h]
	vmovdqu64 	EVEXR512N3, [rcx+0C0h]
	vmovdqa64 	EVEXR128N4, [rcx+100h]
	mov 		rcx, [rcx+110h]
	vmovdqu64 	[rdx+00h], EVEXR512N0
	vmovdqu64 	[rdx+40h], EVEXR512N1
	vmovdqu64 	[rdx+80h], EVEXR512N2
	vmovdqu64 	[rdx+0C0h], EVEXR512N3
	vmovdqa64 	[rdx+100h], EVEXR128N4
	mov 		[rdx+110h], rcx
	vpxord 		EVEXR512N0,EVEXR512N0,EVEXR512N0
	vpxord 		EVEXR512N1,EVEXR512N1,EVEXR512N1
	vpxord 		EVEXR512N2,EVEXR512N2,EVEXR512N2
	vpxord 		EVEXR512N3,EVEXR512N3,EVEXR512N3
	vpxord		EVEXR128N4,EVEXR128N4,EVEXR128N4
	ret

	align		16
Move312AVX512:
	vmovdqu64 	EVEXR512N0, [rcx+00h]
	vmovdqu64 	EVEXR512N1, [rcx+40h]
	vmovdqu64 	EVEXR512N2, [rcx+80h]
	vmovdqu64 	EVEXR512N3, [rcx+0C0h]
	vmovdqa64 	EVEXR256N4, [rcx+100h]
	vmovdqa64 	EVEXR128N5, [rcx+120h]
	mov 		rcx, [rcx+130h]
	vmovdqu64 	[rdx+00h], EVEXR512N0
	vmovdqu64 	[rdx+40h], EVEXR512N1
	vmovdqu64 	[rdx+80h], EVEXR512N2
	vmovdqu64 	[rdx+0C0h], EVEXR512N3
	vmovdqa64 	[rdx+100h], EVEXR256N4
	vmovdqa64 	[rdx+120h], EVEXR128N5
	mov 		[rdx+130h], rcx
	vpxord 		EVEXR512N0,EVEXR512N0,EVEXR512N0
	vpxord 		EVEXR512N1,EVEXR512N1,EVEXR512N1
	vpxord 		EVEXR512N2,EVEXR512N2,EVEXR512N2
	vpxord 		EVEXR512N3,EVEXR512N3,EVEXR512N3
	vpxord 		EVEXR256N4,EVEXR256N4,EVEXR256N4
	vpxord 		EVEXR128N5,EVEXR128N5,EVEXR128N5
	ret

	align		16
Move344AVX512:
	vmovdqu64 	EVEXR512N0, [rcx+00h]
	vmovdqu64 	EVEXR512N1, [rcx+40h]
	vmovdqu64 	EVEXR512N2, [rcx+80h]
	vmovdqu64 	EVEXR512N3, [rcx+0C0h]
	vmovdqu64 	EVEXR512N4, [rcx+100h]
	vmovdqa64 	EVEXR128N5, [rcx+140h]
	mov 		rcx, [rcx+150h]
	vmovdqu64 	[rdx+00h], EVEXR512N0
	vmovdqu64 	[rdx+40h], EVEXR512N1
	vmovdqu64 	[rdx+80h], EVEXR512N2
	vmovdqu64 	[rdx+0C0h], EVEXR512N3
	vmovdqu64 	[rdx+100h], EVEXR512N4
	vmovdqa64 	[rdx+140h], EVEXR128N5
	mov 		[rdx+150h], rcx
	vpxord 		EVEXR512N0,EVEXR512N0,EVEXR512N0
	vpxord 		EVEXR512N1,EVEXR512N1,EVEXR512N1
	vpxord 		EVEXR512N2,EVEXR512N2,EVEXR512N2
	vpxord 		EVEXR512N3,EVEXR512N3,EVEXR512N3
	vpxord 		EVEXR512N4,EVEXR512N4,EVEXR512N4
	vpxord		EVEXR128N5,EVEXR128N5,EVEXR128N5
	ret


	align		16	
MoveX32LpAvx512WithErms:

; Make the counter negative based: The last 24 bytes are moved separately

	mov		eax, 8
	sub		r8, rax
	add		rcx, r8
	add		rdx, r8
	neg		r8
	jns		@MoveLast8

	cmp 		r8, -2048  ; According to the Intel Manual, rep movsb outperforms AVX copy on blocks of 2048 bytes and above
	jg		@DontDoRepMovsb

	align		4

@DoRepMovsb:
	mov		r10, rsi
	mov		r9, rdi
	lea		rsi, [rcx+r8]
	lea		rdi, [rdx+r8]
	neg		r8
	add		r8, rax
	mov		rcx, r8
	cld
	rep		movsb
	mov		rdi, r9
	mov		rsi, r10
	jmp		@exit

	align		16

@DontDoRepMovsb:
	cmp 		r8, -(128+64)
	jg  		@SmallAvxMove

	mov		eax, 128

	sub		rcx, rax
	sub		rdx, rax
	add		r8, rax


	lea		r9, [rdx+r8]
	test		r9b, 63
	jz              @Avx512BigMoveDestAligned

; destination is already 32-bytes aligned, so we just align by 64 bytes	
	vmovdqa64	EVEXR256N0, [rcx+r8]
	vmovdqa64	[rdx+r8], EVEXR256N0
	add		r8, 20h

	align		16

@Avx512BigMoveDestAligned:
	vmovdqu64	EVEXR512N0, [rcx+r8+00h]
	vmovdqu64	EVEXR512N1, [rcx+r8+40h]
	vmovdqa64	[rdx+r8+00h], EVEXR512N0
	vmovdqa64	[rdx+r8+40h], EVEXR512N1
	add		r8, rax
	js 		@Avx512BigMoveDestAligned

	sub		r8, rax
	add		rcx, rax
	add		rdx, rax

	align		16

@SmallAvxMove:

@MoveLoopAvx:
; Move a 16 byte block
	vmovdqa64 	EVEXR128N0, [rcx+r8]
	vmovdqa64 	[rdx+r8], EVEXR128N0

; Are there another 16 bytes to move?
	add		r8, 16
	js		@MoveLoopAvx

	vpxord		EVEXR512N0,EVEXR512N0,EVEXR512N0
	vpxord		EVEXR512N1,EVEXR512N1,EVEXR512N1

	align		8
@MoveLast8:
; Do the last 8 bytes
	mov 		rcx, [rcx+r8]
	mov		[rdx+r8], rcx
@exit:
	ret
