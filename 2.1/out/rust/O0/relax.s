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
	movb	%r9b, %al
	movq	%r8, %r9
	movq	%rdx, %r8
	movq	%rcx, 48(%rsp)
	leaq	48(%rsp), %rcx
	leaq	vtable.0(%rip), %rdx
	movb	%al, 32(%rsp)
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
	callq	_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h628404d4dbef3971E
	nop
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
	callq	_ZN4core3ops8function6FnOnce9call_once17hbc860473d1d62b8eE
	#APP
	#NO_APP
	nop
	.seh_startepilogue
	addq	$40, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	_ZN4core3fmt2rt8Argument11new_display17hececcaa328727a5cE;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN4core3fmt2rt8Argument11new_display17hececcaa328727a5cE,unique,3
	.p2align	4
_ZN4core3fmt2rt8Argument11new_display17hececcaa328727a5cE:
.seh_proc _ZN4core3fmt2rt8Argument11new_display17hececcaa328727a5cE
	subq	$16, %rsp
	.seh_stackalloc 16
	.seh_endprologue
	movq	%rcx, %rax
	movq	%rdx, (%rsp)
	leaq	_ZN4core3fmt5float52_$LT$impl$u20$core..fmt..Display$u20$for$u20$f64$GT$3fmt17hc255d2945fc70584E(%rip), %rdx
	movq	%rdx, 8(%rsp)
	movq	(%rsp), %rdx
	movq	%rdx, (%rcx)
	movq	8(%rsp), %rdx
	movq	%rdx, 8(%rcx)
	.seh_startepilogue
	addq	$16, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	_ZN4core3fmt9Arguments3new17h736dd8ee778be5fdE;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN4core3fmt9Arguments3new17h736dd8ee778be5fdE,unique,4
	.p2align	4
_ZN4core3fmt9Arguments3new17h736dd8ee778be5fdE:
	movq	%rcx, %rax
	retq

	.def	_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE,unique,5
	.p2align	4
_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE:
.seh_proc _ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	movq	(%rcx), %rcx
	callq	_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E
	nop
	.seh_startepilogue
	addq	$40, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E,unique,6
	.p2align	4
_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E:
.Lfunc_begin0:
.seh_proc _ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E
	.seh_handler __CxxFrameHandler3, @unwind, @except
	pushq	%rbp
	.seh_pushreg %rbp
	subq	$64, %rsp
	.seh_stackalloc 64
	leaq	64(%rsp), %rbp
	.seh_setframe %rbp, 64
	.seh_endprologue
	movq	$-2, -8(%rbp)
	movq	%rcx, -16(%rbp)
.Ltmp0:
	leaq	-16(%rbp), %rcx
	callq	_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E
.Ltmp1:
	movl	%eax, -20(%rbp)
	jmp	.LBB6_2
.LBB6_2:
	movl	-20(%rbp), %eax
	.seh_startepilogue
	addq	$64, %rsp
	popq	%rbp
	.seh_endepilogue
	retq
	.seh_handlerdata
	.long	$cppxdata$_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E@IMGREL
	.section	.text,"xr",one_only,_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E,unique,6
	.seh_endproc
	.def	"?dtor$1@?0?_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E@4HA";
	.scl	3;
	.type	32;
	.endef
	.p2align	4
"?dtor$1@?0?_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E@4HA":
.seh_proc "?dtor$1@?0?_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E@4HA"
.LBB6_1:
	movq	%rdx, 16(%rsp)
	pushq	%rbp
	.seh_pushreg %rbp
	subq	$32, %rsp
	.seh_stackalloc 32
	leaq	64(%rdx), %rbp
	.seh_endprologue
	.seh_startepilogue
	addq	$32, %rsp
	popq	%rbp
	.seh_endepilogue
	retq
.Lfunc_end0:
	.seh_handlerdata
	.section	.text,"xr",one_only,_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E,unique,6
	.seh_endproc
	.section	.xdata,"dr",associative,_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E,unique,0
	.p2align	2, 0x0
$cppxdata$_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E:
	.long	429065506
	.long	1
	.long	$stateUnwindMap$_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E@IMGREL
	.long	0
	.long	0
	.long	3
	.long	$ip2state$_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E@IMGREL
	.long	56
	.long	0
	.long	1
$stateUnwindMap$_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E:
	.long	-1
	.long	"?dtor$1@?0?_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E@4HA"@IMGREL
$ip2state$_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E:
	.long	.Lfunc_begin0@IMGREL
	.long	-1
	.long	.Ltmp0@IMGREL+1
	.long	0
	.long	.Ltmp1@IMGREL+1
	.long	-1
	.section	.text,"xr",one_only,_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E,unique,6

	.def	_ZN4core3ops8function6FnOnce9call_once17hbc860473d1d62b8eE;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN4core3ops8function6FnOnce9call_once17hbc860473d1d62b8eE,unique,7
	.p2align	4
_ZN4core3ops8function6FnOnce9call_once17hbc860473d1d62b8eE:
.seh_proc _ZN4core3ops8function6FnOnce9call_once17hbc860473d1d62b8eE
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	callq	*%rcx
	nop
	.seh_startepilogue
	addq	$40, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h628404d4dbef3971E;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h628404d4dbef3971E,unique,8
	.p2align	4
_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h628404d4dbef3971E:
	xorl	%eax, %eax
	retq

	.def	_ZN5relax4main17hd425bd9b98a4a66dE;
	.scl	2;
	.type	32;
	.endef
	.globl	__real@4024000000000000
	.section	.rdata,"dr",discard,__real@4024000000000000
	.p2align	3, 0x0
__real@4024000000000000:
	.quad	0x4024000000000000
	.globl	__real@4008000000000000
	.section	.rdata,"dr",discard,__real@4008000000000000
	.p2align	3, 0x0
__real@4008000000000000:
	.quad	0x4008000000000000
	.globl	__real@4010000000000000
	.section	.rdata,"dr",discard,__real@4010000000000000
	.p2align	3, 0x0
__real@4010000000000000:
	.quad	0x4010000000000000
	.section	.text,"xr",one_only,_ZN5relax4main17hd425bd9b98a4a66dE,unique,9
	.globl	_ZN5relax4main17hd425bd9b98a4a66dE
	.p2align	4
_ZN5relax4main17hd425bd9b98a4a66dE:
.seh_proc _ZN5relax4main17hd425bd9b98a4a66dE
	subq	$72, %rsp
	.seh_stackalloc 72
	.seh_endprologue
	movsd	__real@4024000000000000(%rip), %xmm0
	movsd	__real@4008000000000000(%rip), %xmm1
	movsd	__real@4010000000000000(%rip), %xmm2
	callq	step
	movsd	%xmm0, 32(%rsp)
	leaq	56(%rsp), %rcx
	leaq	32(%rsp), %rdx
	callq	_ZN4core3fmt2rt8Argument11new_display17hececcaa328727a5cE
	movq	56(%rsp), %rax
	movq	%rax, 40(%rsp)
	movq	64(%rsp), %rax
	movq	%rax, 48(%rsp)
	leaq	alloc_8df64ffe1b5923b6b390f0ecb6f2f1b4(%rip), %rcx
	leaq	40(%rsp), %rdx
	callq	_ZN4core3fmt9Arguments3new17h736dd8ee778be5fdE
	movq	%rax, %rcx
	callq	_ZN3std2io5stdio6_print17h381dc97f2e78cfd6E
	nop
	.seh_startepilogue
	addq	$72, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	_ZN5relax5relax17hd4bbadf5f933e20eE;
	.scl	3;
	.type	32;
	.endef
	.section	.text,"xr",one_only,_ZN5relax5relax17hd4bbadf5f933e20eE,unique,10
	.p2align	4
_ZN5relax5relax17hd4bbadf5f933e20eE:
.seh_proc _ZN5relax5relax17hd4bbadf5f933e20eE
	subq	$24, %rsp
	.seh_stackalloc 24
	.seh_endprologue
	movsd	%xmm0, (%rsp)
	addsd	%xmm2, %xmm1
	movsd	%xmm1, 8(%rsp)
	ucomisd	%xmm1, %xmm0
	ja	.LBB10_2
	movsd	(%rsp), %xmm0
	movsd	%xmm0, 16(%rsp)
	jmp	.LBB10_3
.LBB10_2:
	movsd	8(%rsp), %xmm0
	movsd	%xmm0, 16(%rsp)
.LBB10_3:
	movsd	16(%rsp), %xmm0
	.seh_startepilogue
	addq	$24, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	step;
	.scl	2;
	.type	32;
	.endef
	.section	.text,"xr",one_only,step,unique,11
	.globl	step
	.p2align	4
step:
.seh_proc step
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	callq	_ZN5relax5relax17hd4bbadf5f933e20eE
	nop
	.seh_startepilogue
	addq	$40, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.def	main;
	.scl	2;
	.type	32;
	.endef
	.section	.text,"xr",one_only,main,unique,12
	.globl	main
	.p2align	4
main:
.seh_proc main
	subq	$40, %rsp
	.seh_stackalloc 40
	.seh_endprologue
	movq	%rdx, %r8
	movslq	%ecx, %rdx
	leaq	_ZN5relax4main17hd425bd9b98a4a66dE(%rip), %rcx
	xorl	%r9d, %r9d
	callq	_ZN3std2rt10lang_start17h7deff84bf1be1c01E
	nop
	.seh_startepilogue
	addq	$40, %rsp
	.seh_endepilogue
	retq
	.seh_endproc

	.section	.rdata,"dr",one_only,vtable.0,unique,13
	.p2align	3, 0x0
vtable.0:
	.asciz	"\000\000\000\000\000\000\000\000\b\000\000\000\000\000\000\000\b\000\000\000\000\000\000"
	.quad	_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE
	.quad	_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E
	.quad	_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E

	.section	.rdata,"dr",one_only,alloc_8df64ffe1b5923b6b390f0ecb6f2f1b4,unique,14
alloc_8df64ffe1b5923b6b390f0ecb6f2f1b4:
	.asciz	"\305 \000\000p\002\000\001\n"

	.globl	_fltused
