; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-- -mattr=+sse4.1 | FileCheck %s

; Test that when we don't -enable-unsafe-fp-math, we don't do the optimization
; -0 - (A - B) to (B - A) because A==B, -0 != 0

define float @negfp(float %a, float %b) nounwind {
; CHECK-LABEL: negfp:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushl %eax
; CHECK-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    subss {{[0-9]+}}(%esp), %xmm0
; CHECK-NEXT:    xorps {{\.LCPI.*}}, %xmm0
; CHECK-NEXT:    movss %xmm0, (%esp)
; CHECK-NEXT:    flds (%esp)
; CHECK-NEXT:    popl %eax
; CHECK-NEXT:    retl
entry:
	%sub = fsub float %a, %b		; <float> [#uses=1]
	%neg = fsub float -0.000000e+00, %sub		; <float> [#uses=1]
	ret float %neg
}

; This may infinite loop if isNegatibleForFree and getNegatedExpression are conflicted.

define double @negation_propagation(double* %arg, double %arg1, double %arg2) nounwind {
; CHECK-LABEL: negation_propagation:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushl %ebp
; CHECK-NEXT:    movl %esp, %ebp
; CHECK-NEXT:    andl $-8, %esp
; CHECK-NEXT:    subl $8, %esp
; CHECK-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-NEXT:    divsd 12(%ebp), %xmm0
; CHECK-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; CHECK-NEXT:    mulsd %xmm0, %xmm1
; CHECK-NEXT:    movapd %xmm0, %xmm2
; CHECK-NEXT:    mulsd %xmm0, %xmm2
; CHECK-NEXT:    mulsd %xmm0, %xmm2
; CHECK-NEXT:    subsd %xmm2, %xmm1
; CHECK-NEXT:    movsd %xmm1, (%esp)
; CHECK-NEXT:    fldl (%esp)
; CHECK-NEXT:    movl %ebp, %esp
; CHECK-NEXT:    popl %ebp
; CHECK-NEXT:    retl
  %t = fdiv double 1.0, %arg1
  %t7 = fmul double %t, %arg2
  %t10 = fneg double %t7
  %t11 = fmul double %t, %t
  %t13 = fsub double %t11, %t
  %t14 = fneg double %t
  %t15 = fmul double %t, %t14
  %t16 = fmul double %t, %t15
  %t18 = fadd double %t16, %t7
  ret double %t18
}
