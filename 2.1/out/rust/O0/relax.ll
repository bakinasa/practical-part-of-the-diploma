; ModuleID = 'relax.fb9cf5c86412d100-cgu.0'
source_filename = "relax.fb9cf5c86412d100-cgu.0"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-windows-msvc"

%"core::fmt::rt::Argument<'_>" = type { %"core::fmt::rt::ArgumentType<'_>" }
%"core::fmt::rt::ArgumentType<'_>" = type { ptr, [1 x i64] }

@vtable.0 = private unnamed_addr constant <{ [24 x i8], ptr, ptr, ptr }> <{ [24 x i8] c"\00\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00", ptr @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E" }>, align 8
@alloc_8df64ffe1b5923b6b390f0ecb6f2f1b4 = private unnamed_addr constant [10 x i8] c"\C5 \00\00p\02\00\01\0A\00", align 1

; std::rt::lang_start
; Function Attrs: uwtable
define hidden i64 @_ZN3std2rt10lang_start17h7deff84bf1be1c01E(ptr %main, i64 %argc, ptr %argv, i8 %sigpipe) unnamed_addr #0 {
start:
  %_7 = alloca [8 x i8], align 8
  store ptr %main, ptr %_7, align 8
; call std::rt::lang_start_internal
  %_0 = call i64 @_ZN3std2rt19lang_start_internal17hb6bdd05d2d634367E(ptr align 1 %_7, ptr align 8 @vtable.0, i64 %argc, ptr %argv, i8 %sigpipe)
  ret i64 %_0
}

; std::rt::lang_start::{{closure}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E"(ptr align 8 %_1) unnamed_addr #1 {
start:
  %_4 = load ptr, ptr %_1, align 8
; call std::sys::backtrace::__rust_begin_short_backtrace
  call void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hd867833d5f8c2683E(ptr %_4) #6
; call <() as std::process::Termination>::report
  %self = call i32 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h628404d4dbef3971E"() #7
  ret i32 %self
}

; std::sys::backtrace::__rust_begin_short_backtrace
; Function Attrs: noinline uwtable
define internal void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hd867833d5f8c2683E(ptr %f) unnamed_addr #2 {
start:
; call core::ops::function::FnOnce::call_once
  call void @_ZN4core3ops8function6FnOnce9call_once17hbc860473d1d62b8eE(ptr %f) #7
  call void asm sideeffect "", "~{memory}"(), !srcloc !3
  ret void
}

; core::fmt::rt::Argument::new_display
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3fmt2rt8Argument11new_display17hececcaa328727a5cE(ptr sret([16 x i8]) align 8 %_0, ptr align 8 %x) unnamed_addr #1 {
start:
  %_2 = alloca [16 x i8], align 8
  store ptr %x, ptr %_2, align 8
  %0 = getelementptr inbounds i8, ptr %_2, i64 8
  store ptr @"_ZN4core3fmt5float52_$LT$impl$u20$core..fmt..Display$u20$for$u20$f64$GT$3fmt17hc255d2945fc70584E", ptr %0, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %_0, ptr align 8 %_2, i64 16, i1 false)
  ret void
}

; core::fmt::Arguments::new
; Function Attrs: inlinehint uwtable
define internal { ptr, ptr } @_ZN4core3fmt9Arguments3new17h736dd8ee778be5fdE(ptr align 1 %template, ptr align 8 %args) unnamed_addr #1 {
start:
  %0 = insertvalue { ptr, ptr } poison, ptr %template, 0
  %1 = insertvalue { ptr, ptr } %0, ptr %args, 1
  ret { ptr, ptr } %1
}

; core::ops::function::FnOnce::call_once{{vtable.shim}}
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE"(ptr %_1) unnamed_addr #1 {
start:
  %_2 = alloca [0 x i8], align 1
  %0 = load ptr, ptr %_1, align 8
; call core::ops::function::FnOnce::call_once
  %_0 = call i32 @_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E(ptr %0) #7
  ret i32 %_0
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal i32 @_ZN4core3ops8function6FnOnce9call_once17h2d49f96dd07e8109E(ptr %0) unnamed_addr #1 personality ptr @__CxxFrameHandler3 {
start:
  %_2 = alloca [0 x i8], align 1
  %_1 = alloca [8 x i8], align 8
  store ptr %0, ptr %_1, align 8
; invoke std::rt::lang_start::{{closure}}
  %_0 = invoke i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E"(ptr align 8 %_1)
          to label %bb1 unwind label %funclet_bb3

bb3:                                              ; preds = %funclet_bb3
  cleanupret from %cleanuppad unwind to caller

funclet_bb3:                                      ; preds = %start
  %cleanuppad = cleanuppad within none []
  br label %bb3

bb1:                                              ; preds = %start
  ret i32 %_0
}

; core::ops::function::FnOnce::call_once
; Function Attrs: inlinehint uwtable
define internal void @_ZN4core3ops8function6FnOnce9call_once17hbc860473d1d62b8eE(ptr %_1) unnamed_addr #1 {
start:
  %_2 = alloca [0 x i8], align 1
  call void %_1()
  ret void
}

; <() as std::process::Termination>::report
; Function Attrs: inlinehint uwtable
define internal i32 @"_ZN54_$LT$$LP$$RP$$u20$as$u20$std..process..Termination$GT$6report17h628404d4dbef3971E"() unnamed_addr #1 {
start:
  ret i32 0
}

; relax::main
; Function Attrs: uwtable
define hidden void @_ZN5relax4main17hd425bd9b98a4a66dE() unnamed_addr #0 {
start:
  %_7 = alloca [16 x i8], align 8
  %args = alloca [16 x i8], align 8
  %_5 = alloca [8 x i8], align 8
  %0 = call double @step(double 1.000000e+01, double 3.000000e+00, double 4.000000e+00)
  store double %0, ptr %_5, align 8
; call core::fmt::rt::Argument::new_display
  call void @_ZN4core3fmt2rt8Argument11new_display17hececcaa328727a5cE(ptr sret([16 x i8]) align 8 %_7, ptr align 8 %_5) #7
  %1 = getelementptr inbounds nuw %"core::fmt::rt::Argument<'_>", ptr %args, i64 0
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %1, ptr align 8 %_7, i64 16, i1 false)
; call core::fmt::Arguments::new
  %2 = call { ptr, ptr } @_ZN4core3fmt9Arguments3new17h736dd8ee778be5fdE(ptr align 1 @alloc_8df64ffe1b5923b6b390f0ecb6f2f1b4, ptr align 8 %args) #7
  %_2.0 = extractvalue { ptr, ptr } %2, 0
  %_2.1 = extractvalue { ptr, ptr } %2, 1
; call std::io::stdio::_print
  call void @_ZN3std2io5stdio6_print17h381dc97f2e78cfd6E(ptr %_2.0, ptr %_2.1)
  ret void
}

; relax::relax
; Function Attrs: uwtable
define internal double @_ZN5relax5relax17hd4bbadf5f933e20eE(double %old, double %du, double %w) unnamed_addr #0 {
start:
  %_0 = alloca [8 x i8], align 8
  %alt = fadd double %du, %w
  %_5 = fcmp olt double %alt, %old
  br i1 %_5, label %bb1, label %bb2

bb2:                                              ; preds = %start
  store double %old, ptr %_0, align 8
  br label %bb3

bb1:                                              ; preds = %start
  store double %alt, ptr %_0, align 8
  br label %bb3

bb3:                                              ; preds = %bb1, %bb2
  %0 = load double, ptr %_0, align 8
  ret double %0
}

; Function Attrs: uwtable
define dso_local double @step(double %old, double %du, double %w) unnamed_addr #0 {
start:
; call relax::relax
  %_0 = call double @_ZN5relax5relax17hd4bbadf5f933e20eE(double %old, double %du, double %w)
  ret double %_0
}

; std::rt::lang_start_internal
; Function Attrs: uwtable
declare i64 @_ZN3std2rt19lang_start_internal17hb6bdd05d2d634367E(ptr align 1, ptr align 8, i64, ptr, i8) unnamed_addr #0

; core::fmt::float::<impl core::fmt::Display for f64>::fmt
; Function Attrs: uwtable
declare zeroext i1 @"_ZN4core3fmt5float52_$LT$impl$u20$core..fmt..Display$u20$for$u20$f64$GT$3fmt17hc255d2945fc70584E"(ptr align 8, ptr align 8) unnamed_addr #0

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: readwrite)
declare void @llvm.memcpy.p0.p0.i64(ptr noalias writeonly captures(none), ptr noalias readonly captures(none), i64, i1 immarg) #3

declare i32 @__CxxFrameHandler3(...) unnamed_addr #4

; std::io::stdio::_print
; Function Attrs: uwtable
declare void @_ZN3std2io5stdio6_print17h381dc97f2e78cfd6E(ptr, ptr) unnamed_addr #0

define i32 @main(i32 %0, ptr %1) unnamed_addr #5 {
top:
  %2 = sext i32 %0 to i64
; call std::rt::lang_start
  %3 = call i64 @_ZN3std2rt10lang_start17h7deff84bf1be1c01E(ptr @_ZN5relax4main17hd425bd9b98a4a66dE, i64 %2, ptr %1, i8 0)
  %4 = trunc i64 %3 to i32
  ret i32 %4
}

attributes #0 = { uwtable "target-cpu"="x86-64" "target-features"="+cx16,+sse,+sse2,+sse3,+sahf" }
attributes #1 = { inlinehint uwtable "target-cpu"="x86-64" "target-features"="+cx16,+sse,+sse2,+sse3,+sahf" }
attributes #2 = { noinline uwtable "target-cpu"="x86-64" "target-features"="+cx16,+sse,+sse2,+sse3,+sahf" }
attributes #3 = { nocallback nofree nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { "target-cpu"="x86-64" }
attributes #5 = { "target-cpu"="x86-64" "target-features"="+cx16,+sse,+sse2,+sse3,+sahf" }
attributes #6 = { noinline }
attributes #7 = { inlinehint }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 7, !"PIE Level", i32 2}
!2 = !{!"rustc version 1.94.0 (4a4ef493e 2026-03-02)"}
!3 = !{i64 5415090473090268}
