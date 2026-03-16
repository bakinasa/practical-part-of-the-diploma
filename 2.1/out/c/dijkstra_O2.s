	.file	"dijkstra.c"
	.text
	.p2align 4
	.def	fscanf;	.scl	3;	.type	32;	.endef
	.seh_proc	fscanf
fscanf:
	subq	$56, %rsp
	.seh_stackalloc	56
	.seh_endprologue
	movq	%r8, 80(%rsp)
	leaq	80(%rsp), %r8
	movq	%r9, 88(%rsp)
	movq	%r8, 40(%rsp)
	call	__mingw_vfscanf
	addq	$56, %rsp
	ret
	.seh_endproc
	.p2align 4
	.def	printf;	.scl	3;	.type	32;	.endef
	.seh_proc	printf
printf:
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	subq	$56, %rsp
	.seh_stackalloc	56
	.seh_endprologue
	leaq	88(%rsp), %rsi
	movq	%rdx, 88(%rsp)
	movq	%rcx, %rbx
	movl	$1, %ecx
	movq	%r8, 96(%rsp)
	movq	%r9, 104(%rsp)
	movq	%rsi, 40(%rsp)
	call	*__imp___acrt_iob_func(%rip)
	movq	%rsi, %r8
	movq	%rbx, %rdx
	movq	%rax, %rcx
	call	__mingw_vfprintf
	addq	$56, %rsp
	popq	%rbx
	popq	%rsi
	ret
	.seh_endproc
	.section .rdata,"dr"
.LC0:
	.ascii "Failed to read graph from %s\12\0"
	.text
	.p2align 4
	.def	fprintf.constprop.0;	.scl	3;	.type	32;	.endef
	.seh_proc	fprintf.constprop.0
fprintf.constprop.0:
	subq	$56, %rsp
	.seh_stackalloc	56
	.seh_endprologue
	leaq	.LC0(%rip), %rdx
	movq	%r8, 80(%rsp)
	leaq	80(%rsp), %r8
	movq	%r9, 88(%rsp)
	movq	%r8, 40(%rsp)
	call	__mingw_vfprintf
	addq	$56, %rsp
	ret
	.seh_endproc
	.p2align 4
	.def	heap_up;	.scl	3;	.type	32;	.endef
	.seh_proc	heap_up
heap_up:
	pushq	%rbp
	.seh_pushreg	%rbp
	pushq	%rdi
	.seh_pushreg	%rdi
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	.seh_endprologue
	testl	%ecx, %ecx
	jle	.L5
	leaq	heap(%rip), %rdx
	movslq	%ecx, %rax
	leaq	heap_dist(%rip), %rsi
	movslq	(%rdx,%rax,4), %rdi
	leaq	heap_pos(%rip), %r11
	movsd	(%rsi,%rdi,8), %xmm0
	movq	%rdi, %rbp
	jmp	.L8
	.p2align 4,,10
	.p2align 3
.L10:
	movslq	%eax, %rbx
	movl	%ecx, (%r11,%rdi,4)
	movl	%r8d, (%rdx,%rbx,4)
	movl	%eax, (%r11,%r8,4)
	movl	%ebp, (%rdx,%r9,4)
	testl	%ecx, %ecx
	je	.L5
.L8:
	movl	%ecx, %eax
	leal	-1(%rcx), %ecx
	sarl	%ecx
	movslq	%ecx, %r9
	movslq	(%rdx,%r9,4), %r8
	comisd	(%rsi,%r8,8), %xmm0
	jb	.L10
.L5:
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	ret
	.seh_endproc
	.def	__main;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
.LC1:
	.ascii "graph.txt\0"
.LC3:
	.ascii "r\0"
.LC4:
	.ascii "%d %d %d\0"
.LC5:
	.ascii "%d %d %lf\0"
.LC9:
	.ascii "avg_time_ms: %.2f\12\0"
.LC10:
	.ascii "checksum: %.6f\12\0"
.LC11:
	.ascii "runs: %d\12\0"
	.section	.text.startup,"x"
	.p2align 4
	.globl	main
	.def	main;	.scl	2;	.type	32;	.endef
	.seh_proc	main
main:
	pushq	%r15
	.seh_pushreg	%r15
	pushq	%r14
	.seh_pushreg	%r14
	pushq	%r13
	.seh_pushreg	%r13
	pushq	%r12
	.seh_pushreg	%r12
	pushq	%rbp
	.seh_pushreg	%rbp
	pushq	%rdi
	.seh_pushreg	%rdi
	pushq	%rsi
	.seh_pushreg	%rsi
	pushq	%rbx
	.seh_pushreg	%rbx
	subq	$168, %rsp
	.seh_stackalloc	168
	movups	%xmm6, 128(%rsp)
	.seh_savexmm	%xmm6, 128
	movups	%xmm7, 144(%rsp)
	.seh_savexmm	%xmm7, 144
	.seh_endprologue
	leaq	.LC1(%rip), %r14
	movl	%ecx, %esi
	movq	%rdx, %rbx
	call	__main
	cmpl	$1, %esi
	jle	.L12
	movq	8(%rbx), %r14
.L12:
	leaq	.LC3(%rip), %rdx
	movq	%r14, %rcx
	call	fopen
	movq	%rax, %rbx
	testq	%rax, %rax
	je	.L13
	leaq	source(%rip), %rax
	leaq	m(%rip), %r9
	movq	%rbx, %rcx
	movq	%rax, 32(%rsp)
	leaq	n(%rip), %r8
	leaq	.LC4(%rip), %rdx
	call	fscanf
	cmpl	$3, %eax
	jne	.L78
	movslq	n(%rip), %rcx
	movl	$4, %edx
	call	calloc
	movq	%rax, %r12
	testq	%rax, %rax
	je	.L78
	movl	m(%rip), %eax
	testl	%eax, %eax
	jle	.L17
	xorl	%esi, %esi
	leaq	112(%rsp), %rbp
	leaq	104(%rsp), %rdi
	leaq	120(%rsp), %r15
	leaq	.LC5(%rip), %r13
	jmp	.L16
.L18:
	movslq	104(%rsp), %rax
	addl	$1, %esi
	addl	$1, (%r12,%rax,4)
	movl	m(%rip), %eax
	cmpl	%eax, %esi
	jge	.L17
.L16:
	movq	%r15, 32(%rsp)
	movq	%rbp, %r9
	movq	%rdi, %r8
	movq	%r13, %rdx
	movq	%rbx, %rcx
	call	fscanf
	cmpl	$3, %eax
	je	.L18
.L20:
	movq	%r12, %rcx
	call	free
.L78:
	movq	%rbx, %rcx
	call	fclose
.L13:
	movl	$2, %ecx
	call	*__imp___acrt_iob_func(%rip)
	movq	%r14, %r8
	leaq	.LC0(%rip), %rdx
	movq	%rax, %rcx
	call	fprintf.constprop.0
	movl	$1, %eax
.L11:
	movups	128(%rsp), %xmm6
	movups	144(%rsp), %xmm7
	addq	$168, %rsp
	popq	%rbx
	popq	%rsi
	popq	%rdi
	popq	%rbp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	ret
.L17:
	xorl	%edx, %edx
	movl	%edx, out_start(%rip)
	movslq	n(%rip), %rdx
	cmpl	$1, %edx
	jle	.L23
	leal	-1(%rdx), %r11d
	xorl	%ecx, %ecx
	leaq	4+out_start(%rip), %r9
	xorl	%r8d, %r8d
.L22:
	addl	(%r12,%rcx,4), %r8d
	movl	%r8d, (%r9,%rcx,4)
	addq	$1, %rcx
	cmpq	%rcx, %r11
	jne	.L22
.L23:
	leaq	out_start(%rip), %rsi
	movq	%rbx, %rcx
	movl	%eax, (%rsi,%rdx,4)
	call	rewind
	leaq	100(%rsp), %rax
	movq	%rbx, %rcx
	leaq	96(%rsp), %r9
	movq	%rax, 32(%rsp)
	leaq	92(%rsp), %r8
	leaq	.LC4(%rip), %rdx
	call	fscanf
	movslq	n(%rip), %rcx
	movl	$4, %edx
	call	calloc
	movq	%rax, 56(%rsp)
	testq	%rax, %rax
	je	.L20
	cmpl	$0, m(%rip)
	jle	.L79
	xorl	%r14d, %r14d
	leaq	112(%rsp), %rbp
	leaq	104(%rsp), %rdi
	leaq	120(%rsp), %r15
	leaq	.LC5(%rip), %r13
.L24:
	movq	%r15, 32(%rsp)
	movq	%rdi, %r8
	movq	%r13, %rdx
	movq	%rbx, %rcx
	movq	%rbp, %r9
	addl	$1, %r14d
	call	fscanf
	movslq	104(%rsp), %rdx
	movq	56(%rsp), %rax
	leaq	edges(%rip), %r11
	movsd	120(%rsp), %xmm0
	leaq	(%rax,%rdx,4), %rcx
	movl	(%rcx), %eax
	leal	1(%rax), %r8d
	addl	(%rsi,%rdx,4), %eax
	movl	112(%rsp), %edx
	cltq
	movl	%r8d, (%rcx)
	salq	$4, %rax
	addq	%r11, %rax
	cmpl	m(%rip), %r14d
	movl	%edx, (%rax)
	movsd	%xmm0, 8(%rax)
	jl	.L24
.L26:
	movq	%r12, %rcx
	pxor	%xmm7, %xmm7
	leaq	dist(%rip), %r13
	call	free
	movq	56(%rsp), %rcx
	leaq	heap_dist(%rip), %r12
	call	free
	movq	%rbx, %rcx
	leaq	heap(%rip), %rbx
	call	fclose
	movq	%rdi, %rcx
	leaq	edges(%rip), %rdi
	call	*__imp_QueryPerformanceFrequency(%rip)
	movq	__imp_QueryPerformanceCounter(%rip), %rax
	movq	%rbp, %rcx
	leaq	heap_pos(%rip), %rbp
	movq	%rax, 64(%rsp)
	call	*%rax
	movl	$50, 56(%rsp)
	movl	n(%rip), %ecx
	movq	%r15, 72(%rsp)
	movsd	.LC6(%rip), %xmm6
	.p2align 4,,10
	.p2align 3
.L25:
	movl	source(%rip), %r15d
	testl	%ecx, %ecx
	jle	.L80
	movslq	%ecx, %rdx
	leaq	dist(%rip), %rax
	leaq	0(%r13,%rdx,8), %rdx
	.p2align 4,,10
	.p2align 3
.L28:
	movsd	%xmm6, (%rax)
	addq	$8, %rax
	cmpq	%rdx, %rax
	jne	.L28
	movslq	%r15d, %r14
	movl	%ecx, %ecx
	movl	$255, %edx
	movq	$0x000000000, 0(%r13,%r14,8)
	leaq	0(,%rcx,4), %r8
	movq	%rbp, %rcx
	call	memset
.L30:
	movq	$0x000000000, (%r12,%r14,8)
	xorl	%ecx, %ecx
	pxor	%xmm3, %xmm3
	movl	$0, 0(%rbp,%r14,4)
	movl	%r15d, (%rbx)
	call	heap_up
	movl	$1, %ecx
	.p2align 4,,10
	.p2align 3
.L47:
	subl	$1, %ecx
	movslq	(%rbx), %r9
	movslq	%ecx, %r8
	movl	%ecx, heap_len(%rip)
	movslq	(%rbx,%r8,4), %rdx
	movl	%ecx, 0(%rbp,%r9,4)
	movq	%r9, %rax
	movl	%edx, (%rbx)
	movl	$0, 0(%rbp,%rdx,4)
	xorl	%edx, %edx
	movl	%r9d, (%rbx,%r8,4)
	jmp	.L38
	.p2align 4,,10
	.p2align 3
.L81:
	movslq	%r8d, %r11
	movslq	%edx, %r15
	movslq	(%rbx,%r11,4), %r14
	movslq	(%rbx,%r15,4), %r15
	movsd	(%r12,%r15,8), %xmm0
	comisd	(%r12,%r14,8), %xmm0
	jbe	.L31
	cmpl	%r10d, %ecx
	jg	.L33
.L34:
	cmpl	%r8d, %edx
	je	.L37
	movslq	%edx, %r15
	movslq	%r8d, %r14
	movslq	(%rbx,%r15,4), %r11
	movslq	(%rbx,%r14,4), %r10
	movl	%r10d, (%rbx,%r15,4)
	movl	%r11d, (%rbx,%r14,4)
	movl	%r8d, 0(%rbp,%r11,4)
	movl	%edx, 0(%rbp,%r10,4)
	movl	%r8d, %edx
.L38:
	leal	(%rdx,%rdx), %r10d
	leal	1(%r10), %r8d
	addl	$2, %r10d
	cmpl	%r8d, %ecx
	jg	.L81
.L31:
	cmpl	%r10d, %ecx
	jle	.L37
	movl	%edx, %r8d
	movslq	%edx, %r11
.L33:
	movslq	%r10d, %r14
	movslq	(%rbx,%r11,4), %r11
	movslq	(%rbx,%r14,4), %r14
	movsd	(%r12,%r11,8), %xmm0
	ucomisd	(%r12,%r14,8), %xmm0
	cmova	%r10d, %r8d
	jmp	.L34
	.p2align 4,,10
	.p2align 3
.L37:
	addl	$1, %eax
	movl	(%rsi,%r9,4), %edx
	movsd	0(%r13,%r9,8), %xmm2
	cltq
	movl	(%rsi,%rax,4), %r10d
	cmpl	%r10d, %edx
	jge	.L39
	movslq	%edx, %rax
	subl	%edx, %r10d
	movl	heap_len(%rip), %ecx
	movq	%rax, %r14
	addq	%rax, %r10
	salq	$4, %r14
	salq	$4, %r10
	addq	%rdi, %r14
	addq	%rdi, %r10
	.p2align 4,,10
	.p2align 3
.L46:
	movslq	(%r14), %rax
	movsd	8(%r14), %xmm0
	movsd	0(%r13,%rax,8), %xmm1
	addsd	%xmm2, %xmm0
	movq	%rax, %rdx
	comisd	%xmm1, %xmm3
	ja	.L40
	comisd	%xmm0, %xmm1
	jbe	.L41
.L40:
	movl	0(%rbp,%rax,4), %r8d
	movsd	%xmm0, 0(%r13,%rax,8)
	testl	%r8d, %r8d
	js	.L42
	cmpl	%r8d, %ecx
	jle	.L42
	movslq	%r8d, %r9
	cmpl	(%rbx,%r9,4), %edx
	je	.L43
.L42:
	movl	%ecx, 0(%rbp,%rax,4)
	movsd	%xmm0, (%r12,%rax,8)
	leal	1(%rcx), %eax
	movl	%eax, heap_len(%rip)
	movslq	%ecx, %rax
	movl	%edx, (%rbx,%rax,4)
	call	heap_up
	movl	heap_len(%rip), %ecx
.L41:
	addq	$16, %r14
	cmpq	%r14, %r10
	jne	.L46
.L39:
	testl	%ecx, %ecx
	jg	.L47
	movl	n(%rip), %ecx
	testl	%ecx, %ecx
	jle	.L58
	movslq	%ecx, %rdx
	pxor	%xmm1, %xmm1
	leaq	dist(%rip), %rax
	leaq	0(%r13,%rdx,8), %rdx
	movapd	%xmm1, %xmm2
	.p2align 4,,10
	.p2align 3
.L51:
	movsd	(%rax), %xmm0
	comisd	%xmm2, %xmm0
	jb	.L49
	addsd	%xmm0, %xmm1
.L49:
	addq	$8, %rax
	cmpq	%rax, %rdx
	jne	.L51
	subl	$1, 56(%rsp)
	addsd	%xmm1, %xmm7
	jne	.L25
.L52:
	movq	72(%rsp), %rcx
	movq	64(%rsp), %rax
	call	*%rax
	movq	120(%rsp), %rax
	pxor	%xmm1, %xmm1
	subq	112(%rsp), %rax
	pxor	%xmm0, %xmm0
	cvtsi2sdq	%rax, %xmm1
	leaq	.LC9(%rip), %rcx
	cvtsi2sdq	104(%rsp), %xmm0
	divsd	%xmm0, %xmm1
	mulsd	.LC7(%rip), %xmm1
	divsd	.LC8(%rip), %xmm1
	movq	%xmm1, %rdx
	call	printf
	movapd	%xmm7, %xmm1
	movq	%xmm7, %rdx
	leaq	.LC10(%rip), %rcx
	call	printf
	movl	$50, %edx
	leaq	.LC11(%rip), %rcx
	call	printf
	xorl	%eax, %eax
	jmp	.L11
	.p2align 4,,10
	.p2align 3
.L43:
	movsd	(%r12,%rax,8), %xmm1
	movsd	%xmm0, (%r12,%rax,8)
	comisd	%xmm0, %xmm1
	jbe	.L41
	movl	%r8d, %ecx
	call	heap_up
	movl	heap_len(%rip), %ecx
	jmp	.L41
.L58:
	subl	$1, 56(%rsp)
	pxor	%xmm1, %xmm1
	addsd	%xmm1, %xmm7
	jne	.L25
	jmp	.L52
	.p2align 4,,10
	.p2align 3
.L80:
	movslq	%r15d, %r14
	movq	$0x000000000, 0(%r13,%r14,8)
	jmp	.L30
.L79:
	leaq	112(%rsp), %rbp
	leaq	104(%rsp), %rdi
	leaq	120(%rsp), %r15
	jmp	.L26
	.seh_endproc
.lcomm heap_dist,800040,32
.lcomm heap_len,4,4
.lcomm heap_pos,400020,32
.lcomm heap,400020,32
.lcomm dist,800040,32
.lcomm out_start,400024,32
.lcomm edges,8000080,32
.lcomm source,4,4
.lcomm m,4,4
.lcomm n,4,4
	.section .rdata,"dr"
	.align 8
.LC6:
	.long	0
	.long	-1074790400
	.align 8
.LC7:
	.long	0
	.long	1083129856
	.align 8
.LC8:
	.long	0
	.long	1078525952
	.ident	"GCC: (Rev2, Built by MSYS2 project) 12.1.0"
	.def	__mingw_vfscanf;	.scl	2;	.type	32;	.endef
	.def	__mingw_vfprintf;	.scl	2;	.type	32;	.endef
	.def	fopen;	.scl	2;	.type	32;	.endef
	.def	calloc;	.scl	2;	.type	32;	.endef
	.def	free;	.scl	2;	.type	32;	.endef
	.def	fclose;	.scl	2;	.type	32;	.endef
	.def	rewind;	.scl	2;	.type	32;	.endef
	.def	memset;	.scl	2;	.type	32;	.endef
