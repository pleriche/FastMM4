section	.text

	global Move88AVX512
	global Move120AVX512
	global Move152AVX512
	global Move184AVX512
	global Move216AVX512
	global Move280AVX512
	global MoveX32LpAvx512WithErms

	%use smartalign
	ALIGNMODE p6, 32     ;  p6 NOP strategy, and jump over the NOPs only if they're 32B or larger.


	align		16
Move88AVX512:
	vmovdqu64	zmm0, [rcx]
	vmovdqa		xmm1, [rcx+40h]
	mov		rcx, [rcx + 50h]
	vmovdqu64	[rdx], zmm0
	vmovdqa		[rdx+40h], xmm1
	mov 		[rdx + 50h], rcx
	vpxord 		zmm0,zmm0,zmm0
	vpxor		xmm1,xmm1,xmm1
	ret

	align		16
Move120AVX512:
	vmovdqu64	zmm0, [rcx]
	vmovdqa		ymm1, [rcx+40h]
	vmovdqa		xmm2, [rcx+60h]
	mov		rcx, [rcx + 70h]
	vmovdqu64 	[rdx], zmm0
	vmovdqa 	[rdx+40h], ymm1
	vmovdqa 	[rdx+60h], xmm2
	vpxord		zmm0,zmm0,zmm0
	vpxor		ymm1,ymm1,ymm1
	vpxor		xmm2,xmm2,xmm2
	ret

	align		16
Move152AVX512:
	vmovdqu64	zmm0, [rcx+00h]
	vmovdqu64	zmm1, [rcx+40h]
	vmovdqa		xmm2, [rcx+80h]
	mov		rcx, [rcx+90h]
	vmovdqu64 	[rdx+00h], zmm0
	vmovdqu64 	[rdx+40h], zmm1
	vmovdqa 	[rdx+80h], xmm2
	mov 		[rdx+90h], rcx
	vpxord		zmm0,zmm0,zmm0
	vpxord		zmm1,zmm1,zmm1
	vpxor		xmm2,xmm2,xmm2
	ret

	align		16
Move184AVX512:
	vmovdqu64 	zmm0, [rcx+00h]
	vmovdqu64 	zmm1, [rcx+40h]
	vmovdqa 	ymm2, [rcx+80h]
	vmovdqa 	xmm3, [rcx+0A0h]
	mov 		rcx, [rcx+0B0h]
	vmovdqu64 	[rdx-00h], zmm0
	vmovdqu64 	[rdx+40h], zmm1
	vmovdqa 	[rdx+80h], ymm2
	vmovdqa 	[rdx+0A0h],xmm3
	mov 		[rdx+0B0h],rcx
	vpxord 		zmm0,zmm0,zmm0
	vpxord 		zmm1,zmm1,zmm1
	vpxor 		ymm2,ymm2,ymm2
	vpxor 		xmm3,xmm3,xmm3
	ret

	align		16
Move216AVX512:
	vmovdqu64	zmm0, [rcx+00h]
	vmovdqu64	zmm1, [rcx+40h]
	vmovdqu64	zmm2, [rcx+80h]
	vmovdqa		xmm3, [rcx+0C0h]
	mov		rcx, [rcx+0D0h]
	vmovdqu64 	[rdx+00h], zmm0
	vmovdqu64 	[rdx+40h], zmm1
	vmovdqu64 	[rdx+80h], zmm2
	vmovdqa 	[rdx+0C0h], xmm3
	mov 		[rdx+0D0h], rcx
	vpxord 		zmm0,zmm0,zmm0
	vpxord 		zmm1,zmm1,zmm1
	vpxord 		zmm2,zmm2,zmm2
	vpxor 		xmm3,xmm3,xmm3
	ret

	align		16
Move248AVX512:
	vmovdqu64 	zmm0, [rcx+00h]
	vmovdqu64 	zmm1, [rcx+40h]
	vmovdqu64 	zmm2, [rcx+80h]
	vmovdqa 	ymm3, [rcx+0C0h]
	vmovdqa		xmm4, [rcx+0E0h]
	mov 		rcx, [rcx+0F0h]
	vmovdqu64 	[rdx+00h], zmm0
	vmovdqu64 	[rdx+40h], zmm1
	vmovdqu64 	[rdx+80h], zmm2
	vmovdqa 	[rdx+0C0h], ymm3
	vmovdqa 	[rdx+0E0h], xmm4
	mov 		[rdx+0F0h], rcx
	vpxord 		zmm0,zmm0,zmm0
	vpxord 		zmm1,zmm1,zmm1
	vpxord 		zmm2,zmm2,zmm2
	vpxor 		ymm3,ymm3,ymm3
	vpxor 		xmm4,xmm4,xmm3
	ret

	align		16
Move280AVX512:
	vmovdqu64 	zmm0, [rcx+00h]
	vmovdqu64 	zmm1, [rcx+40h]
	vmovdqu64 	zmm2, [rcx+80h]
	vmovdqu64 	zmm3, [rcx+0C0h]
	vmovdqa 	xmm4, [rcx+100h]
	mov 		rcx, [rcx+110h]
	vmovdqu64 	[rdx+00h], zmm0
	vmovdqu64 	[rdx+40h], zmm1
	vmovdqu64 	[rdx+80h], zmm2
	vmovdqu64 	[rdx+0C0h], zmm3
	vmovdqa 	xmm4, [rcx+0100h]
	mov 		[rdx+110h], rcx
	vpxord 		zmm0,zmm0,zmm0
	vpxord 		zmm1,zmm1,zmm1
	vpxord 		zmm2,zmm2,zmm2
	vpxord 		zmm3,zmm3,zmm3
	vpxor 		xmm4,xmm4,xmm3
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
	cmp 		r8, -128
	jg  		@SmallAvxMove

	mov		eax, 128

	sub		rcx, rax
	sub		rdx, rax
	add		r8, rax


	lea		r9, [rdx+r8]
	test		r9b, 63
	jz              @Avx512BigMoveDestAligned

; destination is already 32-bytes aligned, so we just align by 64 bytes	
	vmovdqa		ymm0, [rcx+r8]
	vmovdqa		[rdx+r8], ymm0
	add		r8, 20h

	align		16

@Avx512BigMoveDestAligned:
	vmovdqu64	zmm0, [rcx+r8+00h]
	vmovdqu64	zmm1, [rcx+r8+40h]
	vmovdqa64	[rdx+r8+00h], zmm0
	vmovdqa64	[rdx+r8+40h], zmm1
	add		r8, rax
	js 		@Avx512BigMoveDestAligned

	sub		r8, rax
	add		rcx, rax
	add		rdx, rax

	align		16

@SmallAvxMove:

@MoveLoopAvx:
; Move a 16 byte block
	vmovdqa 	xmm0, [rcx+r8]
	vmovdqa 	[rdx+r8], xmm0

; Are there another 16 bytes to move?
	add		r8, 16
	js		@MoveLoopAvx

	vpxord		zmm0,zmm0,zmm0
	vpxord		zmm1,zmm1,zmm1

	align		8
@MoveLast8:
; Do the last 8 bytes
	mov 		rcx, [rcx + r8]
	mov		[rdx + r8], rcx
@exit:
	ret
