; ModuleID = 'slm.ll'
source_filename = "/mnt/c/Users/Jonas/Documents/TUM/NPIC/seminar-llvm-vplan/code/simple_loop.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: mustprogress nofree norecurse nosync nounwind memory(argmem: readwrite)
define dso_local void @inner_loop_conditional(i32 noundef %N, ptr nocapture noundef %x, ptr nocapture noundef readonly %y, ptr nocapture noundef readonly %z) local_unnamed_addr #0 {
entry:
  %cmp9 = icmp sgt i32 %N, 0
  br i1 %cmp9, label %for.body.preheader, label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %wide.trip.count = zext nneg i32 %N to i64
  %min.iters.check = icmp ult i64 %wide.trip.count, 4
  br i1 %min.iters.check, label %scalar.ph, label %vector.memcheck

vector.memcheck:                                  ; preds = %for.body.preheader
  %0 = shl nuw nsw i64 %wide.trip.count, 2
  %scevgep = getelementptr i8, ptr %x, i64 %0
  %scevgep1 = getelementptr i8, ptr %z, i64 %wide.trip.count
  %scevgep2 = getelementptr i8, ptr %y, i64 %0
  %bound0 = icmp ult ptr %x, %scevgep1
  %bound1 = icmp ult ptr %z, %scevgep
  %found.conflict = and i1 %bound0, %bound1
  %bound03 = icmp ult ptr %x, %scevgep2
  %bound14 = icmp ult ptr %y, %scevgep
  %found.conflict5 = and i1 %bound03, %bound14
  %conflict.rdx = or i1 %found.conflict, %found.conflict5
  br i1 %conflict.rdx, label %scalar.ph, label %vector.ph

vector.ph:                                        ; preds = %vector.memcheck
  %n.mod.vf = urem i64 %wide.trip.count, 4
  %n.vec = sub i64 %wide.trip.count, %n.mod.vf
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %1 = add i64 %index, 0
  %2 = getelementptr inbounds i8, ptr %z, i64 %1
  %3 = getelementptr inbounds i8, ptr %2, i32 0
  %wide.load = load <4 x i8>, ptr %3, align 1, !tbaa !2, !alias.scope !6
  %4 = icmp eq <4 x i8> %wide.load, zeroinitializer
  %5 = xor <4 x i1> %4, splat (i1 true)
  %6 = getelementptr float, ptr %y, i64 %1
  %7 = getelementptr float, ptr %6, i32 0
  %wide.masked.load = call <4 x float> @llvm.masked.load.v4f32.p0(ptr %7, i32 4, <4 x i1> %5, <4 x float> poison), !tbaa !9, !alias.scope !11
  %8 = getelementptr float, ptr %x, i64 %1
  %9 = getelementptr float, ptr %8, i32 0
  %wide.masked.load6 = call <4 x float> @llvm.masked.load.v4f32.p0(ptr %9, i32 4, <4 x i1> %5, <4 x float> poison), !tbaa !9, !alias.scope !13, !noalias !15
  %10 = fadd <4 x float> %wide.masked.load, %wide.masked.load6
  call void @llvm.masked.store.v4f32.p0(<4 x float> %10, ptr %9, i32 4, <4 x i1> %5), !tbaa !9, !alias.scope !13, !noalias !15
  %index.next = add nuw i64 %index, 4
  %11 = icmp eq i64 %index.next, %n.vec
  br i1 %11, label %middle.block, label %vector.body, !llvm.loop !16

middle.block:                                     ; preds = %vector.body
  %cmp.n = icmp eq i64 %wide.trip.count, %n.vec
  br i1 %cmp.n, label %for.cond.cleanup.loopexit, label %scalar.ph

scalar.ph:                                        ; preds = %middle.block, %vector.memcheck, %for.body.preheader
  %bc.resume.val = phi i64 [ %n.vec, %middle.block ], [ 0, %for.body.preheader ], [ 0, %vector.memcheck ]
  br label %for.body

for.cond.cleanup.loopexit:                        ; preds = %middle.block, %for.inc
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond.cleanup.loopexit, %entry
  ret void

for.body:                                         ; preds = %scalar.ph, %for.inc
  %indvars.iv = phi i64 [ %bc.resume.val, %scalar.ph ], [ %indvars.iv.next, %for.inc ]
  %arrayidx = getelementptr inbounds i8, ptr %z, i64 %indvars.iv
  %12 = load i8, ptr %arrayidx, align 1, !tbaa !2, !range !20, !noundef !21
  %tobool.not = icmp eq i8 %12, 0
  br i1 %tobool.not, label %for.inc, label %if.then

if.then:                                          ; preds = %for.body
  %arrayidx2 = getelementptr inbounds float, ptr %y, i64 %indvars.iv
  %13 = load float, ptr %arrayidx2, align 4, !tbaa !9
  %arrayidx4 = getelementptr inbounds float, ptr %x, i64 %indvars.iv
  %14 = load float, ptr %arrayidx4, align 4, !tbaa !9
  %add = fadd float %13, %14
  store float %add, ptr %arrayidx4, align 4, !tbaa !9
  br label %for.inc

for.inc:                                          ; preds = %if.then, %for.body
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond.not = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond.not, label %for.cond.cleanup.loopexit, label %for.body, !llvm.loop !22
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: read)
declare <4 x float> @llvm.masked.load.v4f32.p0(ptr nocapture, i32 immarg, <4 x i1>, <4 x float>) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.masked.store.v4f32.p0(<4 x float>, ptr nocapture, i32 immarg, <4 x i1>) #2

attributes #0 = { mustprogress nofree norecurse nosync nounwind memory(argmem: readwrite) "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="znver4" "target-features"="+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vpopcntdq,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+crc32,+cx16,+cx8,+evex512,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+mwaitx,+pclmul,+pku,+popcnt,+prfchw,+rdpid,+rdpru,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+wbnoinvd,+x87,+xsave,+xsavec,+xsaveopt,+xsaves" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: read) }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"Ubuntu clang version 18.1.8 (++20240731025043+3b5b5c1ec4a3-1~exp1~20240731145144.92)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"bool", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7}
!7 = distinct !{!7, !8}
!8 = distinct !{!8, !"LVerDomain"}
!9 = !{!10, !10, i64 0}
!10 = !{!"float", !4, i64 0}
!11 = !{!12}
!12 = distinct !{!12, !8}
!13 = !{!14}
!14 = distinct !{!14, !8}
!15 = !{!7, !12}
!16 = distinct !{!16, !17, !18, !19}
!17 = !{!"llvm.loop.mustprogress"}
!18 = !{!"llvm.loop.isvectorized", i32 1}
!19 = !{!"llvm.loop.unroll.runtime.disable"}
!20 = !{i8 0, i8 2}
!21 = !{}
!22 = distinct !{!22, !17, !18}
