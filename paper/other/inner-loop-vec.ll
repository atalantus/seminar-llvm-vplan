; ModuleID = 'slm.ll'
source_filename = "slm.ll"

define void @inner_loop_conditional(i32 %N, ptr %x, ptr %y, ptr %z) {
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

vector.body:                                      ; preds = %pred.store.continue11, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %pred.store.continue11 ]
  %1 = add i64 %index, 0
  %2 = getelementptr inbounds i8, ptr %z, i64 %1
  %3 = getelementptr inbounds i8, ptr %2, i32 0
  %wide.load = load <4 x i8>, ptr %3, align 1, !alias.scope !0
  %4 = icmp eq <4 x i8> %wide.load, zeroinitializer
  %5 = xor <4 x i1> %4, splat (i1 true)
  %6 = extractelement <4 x i1> %5, i32 0
  br i1 %6, label %pred.store.if, label %pred.store.continue

pred.store.if:                                    ; preds = %vector.body
  %7 = getelementptr inbounds float, ptr %y, i64 %1
  %8 = load float, ptr %7, align 4, !alias.scope !3
  %9 = getelementptr inbounds float, ptr %x, i64 %1
  %10 = load float, ptr %9, align 4, !alias.scope !5, !noalias !7
  %11 = fadd float %8, %10
  store float %11, ptr %9, align 4, !alias.scope !5, !noalias !7
  br label %pred.store.continue

pred.store.continue:                              ; preds = %pred.store.if, %vector.body
  %12 = extractelement <4 x i1> %5, i32 1
  br i1 %12, label %pred.store.if6, label %pred.store.continue7

pred.store.if6:                                   ; preds = %pred.store.continue
  %13 = add i64 %index, 1
  %14 = getelementptr inbounds float, ptr %y, i64 %13
  %15 = load float, ptr %14, align 4, !alias.scope !3
  %16 = getelementptr inbounds float, ptr %x, i64 %13
  %17 = load float, ptr %16, align 4, !alias.scope !5, !noalias !7
  %18 = fadd float %15, %17
  store float %18, ptr %16, align 4, !alias.scope !5, !noalias !7
  br label %pred.store.continue7

pred.store.continue7:                             ; preds = %pred.store.if6, %pred.store.continue
  %19 = extractelement <4 x i1> %5, i32 2
  br i1 %19, label %pred.store.if8, label %pred.store.continue9

pred.store.if8:                                   ; preds = %pred.store.continue7
  %20 = add i64 %index, 2
  %21 = getelementptr inbounds float, ptr %y, i64 %20
  %22 = load float, ptr %21, align 4, !alias.scope !3
  %23 = getelementptr inbounds float, ptr %x, i64 %20
  %24 = load float, ptr %23, align 4, !alias.scope !5, !noalias !7
  %25 = fadd float %22, %24
  store float %25, ptr %23, align 4, !alias.scope !5, !noalias !7
  br label %pred.store.continue9

pred.store.continue9:                             ; preds = %pred.store.if8, %pred.store.continue7
  %26 = extractelement <4 x i1> %5, i32 3
  br i1 %26, label %pred.store.if10, label %pred.store.continue11

pred.store.if10:                                  ; preds = %pred.store.continue9
  %27 = add i64 %index, 3
  %28 = getelementptr inbounds float, ptr %y, i64 %27
  %29 = load float, ptr %28, align 4, !alias.scope !3
  %30 = getelementptr inbounds float, ptr %x, i64 %27
  %31 = load float, ptr %30, align 4, !alias.scope !5, !noalias !7
  %32 = fadd float %29, %31
  store float %32, ptr %30, align 4, !alias.scope !5, !noalias !7
  br label %pred.store.continue11

pred.store.continue11:                            ; preds = %pred.store.if10, %pred.store.continue9
  %index.next = add nuw i64 %index, 4
  %33 = icmp eq i64 %index.next, %n.vec
  br i1 %33, label %middle.block, label %vector.body, !llvm.loop !8

middle.block:                                     ; preds = %pred.store.continue11
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
  %34 = load i8, ptr %arrayidx, align 1
  %tobool.not = icmp eq i8 %34, 0
  br i1 %tobool.not, label %for.inc, label %if.then

if.then:                                          ; preds = %for.body
  %arrayidx2 = getelementptr inbounds float, ptr %y, i64 %indvars.iv
  %35 = load float, ptr %arrayidx2, align 4
  %arrayidx4 = getelementptr inbounds float, ptr %x, i64 %indvars.iv
  %36 = load float, ptr %arrayidx4, align 4
  %add = fadd float %35, %36
  store float %add, ptr %arrayidx4, align 4
  br label %for.inc

for.inc:                                          ; preds = %if.then, %for.body
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond.not = icmp eq i64 %indvars.iv.next, %wide.trip.count
  br i1 %exitcond.not, label %for.cond.cleanup.loopexit, label %for.body, !llvm.loop !11
}

!0 = !{!1}
!1 = distinct !{!1, !2}
!2 = distinct !{!2, !"LVerDomain"}
!3 = !{!4}
!4 = distinct !{!4, !2}
!5 = !{!6}
!6 = distinct !{!6, !2}
!7 = !{!1, !4}
!8 = distinct !{!8, !9, !10}
!9 = !{!"llvm.loop.isvectorized", i32 1}
!10 = !{!"llvm.loop.unroll.runtime.disable"}
!11 = distinct !{!11, !9}
