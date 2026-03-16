; ModuleID = 'relax.fb9cf5c86412d100-cgu.0'
source_filename = "relax.fb9cf5c86412d100-cgu.0"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-windows-msvc"

@vtable.0 = private unnamed_addr constant <{ [24 x i8], ptr, ptr, ptr }> <{ [24 x i8] c"\00\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00\08\00\00\00\00\00\00\00", ptr @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E", ptr @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E" }>, align 8
@alloc_8df64ffe1b5923b6b390f0ecb6f2f1b4 = private unnamed_addr constant [10 x i8] c"\C5 \00\00p\02\00\01\0A\00", align 1

; std::rt::lang_start
; Function Attrs: uwtable
define hidden noundef i64 @_ZN3std2rt10lang_start17h7deff84bf1be1c01E(ptr noundef nonnull %main, i64 noundef %argc, ptr noundef %argv, i8 noundef %sigpipe) unnamed_addr #0 {
start:
  %_7 = alloca [8 x i8], align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %_7)
  store ptr %main, ptr %_7, align 8
; call std::rt::lang_start_internal
  %_0 = call noundef i64 @_ZN3std2rt19lang_start_internal17hb6bdd05d2d634367E(ptr noundef nonnull align 1 %_7, ptr noalias noundef readonly align 8 captures(address, read_provenance) dereferenceable(48) @vtable.0, i64 noundef %argc, ptr noundef %argv, i8 noundef %sigpipe)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %_7)
  ret i64 %_0
}

; std::rt::lang_start::{{closure}}
; Function Attrs: inlinehint uwtable
define internal noundef i32 @"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E"(ptr noalias noundef readonly align 8 captures(none) dereferenceable(8) %_1) unnamed_addr #1 {
start:
  %_4 = load ptr, ptr %_1, align 8, !nonnull !3, !noundef !3
; call std::sys::backtrace::__rust_begin_short_backtrace
  tail call fastcc void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hd867833d5f8c2683E(ptr noundef nonnull %_4) #7
  ret i32 0
}

; std::sys::backtrace::__rust_begin_short_backtrace
; Function Attrs: noinline uwtable
define internal fastcc void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hd867833d5f8c2683E(ptr noundef nonnull readonly captures(none) %f) unnamed_addr #2 {
start:
  tail call void %f()
  tail call void asm sideeffect "", "~{memory}"() #8, !srcloc !4
  ret void
}

; core::ops::function::FnOnce::call_once{{vtable.shim}}
; Function Attrs: inlinehint uwtable
define internal noundef i32 @"_ZN4core3ops8function6FnOnce40call_once$u7b$$u7b$vtable.shim$u7d$$u7d$17h4f757618097a3ecfE"(ptr noundef readonly captures(none) %_1) unnamed_addr #1 personality ptr @__CxxFrameHandler3 {
start:
  %0 = load ptr, ptr %_1, align 8, !nonnull !3, !noundef !3
; call std::sys::backtrace::__rust_begin_short_backtrace
  tail call fastcc void @_ZN3std3sys9backtrace28__rust_begin_short_backtrace17hd867833d5f8c2683E(ptr noundef nonnull readonly %0) #7, !noalias !5
  ret i32 0
}

; relax::main
; Function Attrs: uwtable
define hidden void @_ZN5relax4main17hd425bd9b98a4a66dE() unnamed_addr #0 {
start:
  %args = alloca [16 x i8], align 8
  %_4 = alloca [8 x i8], align 8
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %_4)
  store double 7.000000e+00, ptr %_4, align 8
  call void @llvm.lifetime.start.p0(i64 16, ptr nonnull %args)
  store ptr %_4, ptr %args, align 8
  %_6.sroa.4.0..sroa_idx = getelementptr inbounds nuw i8, ptr %args, i64 8
  store ptr @"_ZN4core3fmt5float52_$LT$impl$u20$core..fmt..Display$u20$for$u20$f64$GT$3fmt17hc255d2945fc70584E", ptr %_6.sroa.4.0..sroa_idx, align 8
; call std::io::stdio::_print
  call void @_ZN3std2io5stdio6_print17h381dc97f2e78cfd6E(ptr noundef nonnull @alloc_8df64ffe1b5923b6b390f0ecb6f2f1b4, ptr noundef nonnull %args)
  call void @llvm.lifetime.end.p0(i64 16, ptr nonnull %args)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %_4)
  ret void
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef double @step(double noundef %old, double noundef %du, double noundef %w) unnamed_addr #3 {
start:
  %0 = fadd double %du, %w
  %_4 = fcmp olt double %0, %old
  %_0.sroa.0.0 = select i1 %_4, double %0, double %old
  ret double %_0.sroa.0.0
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #4

; std::rt::lang_start_internal
; Function Attrs: uwtable
declare noundef i64 @_ZN3std2rt19lang_start_internal17hb6bdd05d2d634367E(ptr noundef nonnull align 1, ptr noalias noundef readonly align 8 captures(address, read_provenance) dereferenceable(48), i64 noundef, ptr noundef, i8 noundef) unnamed_addr #0

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #4

declare i32 @__CxxFrameHandler3(...) unnamed_addr #5

; core::fmt::float::<impl core::fmt::Display for f64>::fmt
; Function Attrs: uwtable
declare noundef zeroext i1 @"_ZN4core3fmt5float52_$LT$impl$u20$core..fmt..Display$u20$for$u20$f64$GT$3fmt17hc255d2945fc70584E"(ptr noalias noundef readonly align 8 captures(address, read_provenance) dereferenceable(8), ptr noalias noundef align 8 dereferenceable(24)) unnamed_addr #0

; std::io::stdio::_print
; Function Attrs: uwtable
declare void @_ZN3std2io5stdio6_print17h381dc97f2e78cfd6E(ptr noundef nonnull, ptr noundef nonnull) unnamed_addr #0

define noundef i32 @main(i32 %0, ptr %1) unnamed_addr #6 {
top:
  %_7.i = alloca [8 x i8], align 8
  %2 = sext i32 %0 to i64
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %_7.i)
  store ptr @_ZN5relax4main17hd425bd9b98a4a66dE, ptr %_7.i, align 8
; call std::rt::lang_start_internal
  %_0.i = call noundef i64 @_ZN3std2rt19lang_start_internal17hb6bdd05d2d634367E(ptr noundef nonnull align 1 %_7.i, ptr noalias noundef readonly align 8 captures(address, read_provenance) dereferenceable(48) @vtable.0, i64 noundef %2, ptr noundef %1, i8 noundef 0)
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %_7.i)
  %3 = trunc i64 %_0.i to i32
  ret i32 %3
}

attributes #0 = { uwtable "target-cpu"="x86-64" "target-features"="+cx16,+sse,+sse2,+sse3,+sahf" }
attributes #1 = { inlinehint uwtable "target-cpu"="x86-64" "target-features"="+cx16,+sse,+sse2,+sse3,+sahf" }
attributes #2 = { noinline uwtable "target-cpu"="x86-64" "target-features"="+cx16,+sse,+sse2,+sse3,+sahf" }
attributes #3 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable "target-cpu"="x86-64" "target-features"="+cx16,+sse,+sse2,+sse3,+sahf" }
attributes #4 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { "target-cpu"="x86-64" }
attributes #6 = { "target-cpu"="x86-64" "target-features"="+cx16,+sse,+sse2,+sse3,+sahf" }
attributes #7 = { noinline }
attributes #8 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 7, !"PIE Level", i32 2}
!2 = !{!"rustc version 1.94.0 (4a4ef493e 2026-03-02)"}
!3 = !{}
!4 = !{i64 5415090473090268}
!5 = !{!6}
!6 = distinct !{!6, !7, !"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E: %_1"}
!7 = distinct !{!7, !"_ZN3std2rt10lang_start28_$u7b$$u7b$closure$u7d$$u7d$17h442bf49f82629946E"}
