	.def	@feat.00;
	.scl	3;
	.type	0;
	.endef
	.globl	@feat.00
@feat.00 = 0
	.file	"relax.fb9cf5c86412d100-cgu.0"
	.def	_ZN3std2rt10lang_start17h7deff84bf1be1c01E;
	.scl	2;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN3std2rt10lang_start17h7deff84bf1be1c01E,unique,0
	.globl	_ZN3std2rt10lang_start17h7deff84bf1be1c01E
	.p2align	4
_ZN3std2rt10lang_start17h7deff84bf1be1c01E:
.seh_proc _ZN3std2rt10lang_start17h7deff84bf1be1c01E
	subq	$56, %rsp
	.seh_stackalloc 56
	.seh_endprologue
	movq	%r8, %rax
	movq	%rdx, %r8
	movq	%rcx, 48(%rsp)
	movb	%r9b, 32(%rsp)
	leaq	vtable.0(%rip), %rdx
	leaq	48(%rsp), %rcx
	movq	%rax, %r9
	callq	_ZN3std2rt19lang_start_internal17hb6bdd05d2d634367E
	nop
	.seh_startepilogue
	addq	$56, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E,unique,1
	.p2align	4
_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E:
.seh_proc _ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	movq	(%rcx), %rcx
	callq	_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hd867833d5f8c2683E
	xorl	%eax, %eax
	.seh_startepilogue
	addq	$40, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hd867833d5f8c2683E;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hd867833d5f8c2683E,unique,2
	.p2align	4
_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hd867833d5f8c2683E:
.seh_proc _ZN3std3sys9backtrace28__rust_begin_short_backtrace17hd867833d5f8c2683E
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	callq	*%rcx
	#APP
	#NO_APP
	nop
	.seh_startepilogue
	addq	$40, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE,unique,3
	.p2align	4
_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE:
.seh_proc _ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	movq	(%rcx), %rcx
	callq	_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hd867833d5f8c2683E
	xorl	%eax, %eax
	.seh_startepilogue
	addq	$40, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	_ZN5relax4main17hd425bd9b98a4a66dE;
	.scl	2;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN5relax4main17hd425bd9b98a4a66dE,unique,4
	.globl	_ZN5relax4main17hd425bd9b98a4a66dE
	.p2align	4
_ZN5relax4main17hd425bd9b98a4a66dE:
.seh_proc _ZN5relax4main17hd425bd9b98a4a66dE
	subq	$56, %rsp
	.seh_stackalloc 56
	.seh_endprologue
	movabsq	$4619567317775286272, %rax
	movq	%rax, 32(%rsp)
	leaq	32(%rsp), %rax
	movq	%rax, 40(%rsp)
	leaq	_ZN4core3fmt5float52_$LT$impl$u20$core..fmt..Display$u20$for$u20$f64$GT$3fmt17hc255d2945fc70584E(%rip), %rax
	movq	%rax, 48(%rsp)
	leaq	alloc_8df64ffe1b5923b6b390f0ecb6f2f1b4(%rip), %rcx
	leaq	40(%rsp), %rdx
	callq	_ZN3std2io5stdio6_print17h381dc97f2e78cfd6E
	nop
	.seh_startepilogue
	addq	$56, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	step;
	.scl	2;
	.type	32;
	.endef
	.section	.text,"xr",one_only,step,unique,5
	.globl	step
	.p2align	4
step:
	addsd	%xmm2, %xmm1
	minsd	%xmm0, %xmm1
	movapd	%xmm1, %xmm0
	retq

	.def	main;
	.scl	2;
	.type	32;
	.endef
	.section	.text,"xr",one_only,main,unique,6
	.globl	main
	.p2align	4
main:
.seh_proc main
	subq	$56, %rsp
	.seh_stackalloc 56
	.seh_endprologue
	movq	%rdx, %r9
	movslq	%ecx, %r8
	leaq	_ZN5relax4main17hd425bd9b98a4a66dE(%rip), %rax
	movq	%rax, 48(%rsp)
	movb	$0, 32(%rsp)
	leaq	vtable.0(%rip), %rdx
	leaq	48(%rsp), %rcx
	callq	_ZN3std2rt19lang_start_internal17hb6bdd05d2d634367E
	nop
	.seh_startepilogue
	addq	$56, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.section	.rdata,"dr",one_only,vtable.0,unique,7
	.p2align	3, 0x0
vtable.0:
	.asciz	"\000\000\000\000\000\000\000\000\b\000\000\000\000\000\000\000\b\000\000\000\000\000\000"
	.quad	_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE
	.quad	_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E
	.quad	_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E

	.section	.rdata,"dr",one_only,alloc_8df64ffe1b5923b6b390f0ecb6f2f1b4,unique,8
alloc_8df64ffe1b5923b6b390f0ecb6f2f1b4:
	.asciz	"\305 \000\000p\002\000\001\n"

	.globl	_fltused
