;;; rv64.ss
;;; Copyright 2018, 2019 Linki Tools UG
;;; 
;;; Licensed under the Apache License, Version 2.0 (the "License");
;;; you may not use this file except in compliance with the License.
;;; You may obtain a copy of the License at
;;; 
;;; http://www.apache.org/licenses/LICENSE-2.0
;;; 
;;; Unless required by applicable law or agreed to in writing, software
;;; distributed under the License is distributed on an "AS IS" BASIS,
;;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;;; See the License for the specific language governing permissions and
;;; limitations under the License.

;;; SECTION 1: registers
;;; ABI:
;;;  Register usage:
;;;   x0 aka zero: Hardwired zero
;;;   x1 aka ra: return address
;;;   x2 aka sp: C stack pointer
;;;   x3 aka gp: global pointer
;;;   x4 aka tp: thread pointer
;;;   x5-x7,x28-x31 aka t0-t6: Temporaries
;;;   x10-x17 aka a0-a7: C argument registers where x10,x11 aka a0,a1 are return values
;;;   x7 aka s0 aka fp: frame pointer
;;;   x9,x18-x27 aka s1-s11: saved register
;;;
;;;   saved registers are preserved across a function call, temporaries are not
;;;   --------
;;;   Support for floating point comes from F and D extensions respectively
;;;   There a new 32-long registerbank for floating point registers.
;;;   f0-f7,f28-f31 aka ft0-ft11: FP temporaries (12 registers)
;;;   f8,f9,f18-f27 aka fs0-fs11: FP Saved registers (12 registers)
;;;   f10-f17 aka fa0-fa7: FP function argument, where f10 and f11 are return value (8 registers)
;;;  Alignment:
;;;   ??? RISCV
;;;   double-floats & 64-bit integers are 8-byte aligned in structs
;;;   double-floats & 64-bit integers are 8-byte aligned on the stack
;;;   stack must be 8-byte aligned at call boundaries (otherwise 4-byte)
;;;  Parameter passing:
;;;   ??? RISCV
;;;   8- and 16-bit integer arguments zero- or sign-extended to 32-bits
;;;   32-bit integer arguments passed in a1-a4, then on stack
;;;   64-bit integer arguments passed in a1 or a3, then on stack
;;;       little-endian: a1 (a3) holds lsw, a2 (a4) holds msw
;;;       big-endian: a1 (a3) holds msw, a2 (a4) holds lsw
;;;   8- and 16-bit integer return value zero- or sign-extended to 32-bits
;;;   32-bit integer return value returned in r0 (aka a1)
;;;   64-bit integer return value passed in r0 & r1 (aka a1 & a2)
;;;       little-endian: r0 holds lsw, r1 holds msw
;;;       big-endian: r0 holds msw, r1 holds lsw
;;;   single-floats passed in s0-s15
;;;   double-floats passed in d0-d7 (overlapping single)
;;;   float return value returned in s0 or d0
;;;   must allocate to a single-float reg if it's passed by for double-float alignment
;;;     (e.g., single, double, single => s0, d1, s1)
;;;   ... unless a double has been stack-allocated
;;;     (e.g., 15 singles, double => s0-s14, stack, stack)
;;;   stack grows downwards.  first stack args passed at lowest new frame address.
;;;   return address passed in LR

;; Mapping of scheme specific task registers to registers of the CPU
(define-registers
;; Use saved registers r18-r21 for %tc, %sfp, %ap and %trap
  (reserved
    ;; Three or more cols for each definition
    ;reg   alias ...         callee-save reg-mdinfo
    [%tc   %x9 %s1           #t          9] ;; thread context
    [%sfp  %x8 %s0  %fp      #t          8] ;; scheme frame pointer
    [%ap   %x10 %a0 %Carg1 %Cretval   #f         10] ;;  
    #;[%esp]                                ;; end of stack pointer
    #;[%eap]                                ;; end of allocation pointer
    [%trap %x11 %a1 %Carg2 %Cretval1  #f         11] ;; tracks when scheme should check for interrupts
    [%real-zero %x0          #f          0]);; hardwired zero - can't call it %zero
  (allocable
    [%ac0  %x12 %a2 %Carg3   #f         12] ;; argument count
    [%xp   %x13 %a3 %Carg4   #f         13] ;; used during alloc for the computed alloc spot
    [%ts   %x14 %a4 %Carg5   #f         14] ;; special temps
    [%td   %x15 %a5 %Carg6   #f         15] ;; special temps
    #;[%ret]                           ;; return pointer - stopped being used
    [%cp   %x16 %a6 %Carg7   #f         16] ;; closure pointer
    #;[%ac1]                           ;; auxiliary - undefined, use mem refed from %tc instead
    #;[%yp]                            ;; auxiliary - undefined, use mem refed from %tc instead
    ;; Extra registers - length should match asm-arg-reg-max
    [      %x1  %ra %lr               #f  1]
    [      %x3  %gp                   #f  3]
    [      %x4  %tp                   #f  4]
    [      %x5  %t0                   #f  5]
    [      %x6  %t1                   #f  6]
    [      %x7  %t2                   #f  7]
    [      %x17 %a7 %Carg8            #f 17]
    [      %x18 %s2                   #t 18]
    [      %x19 %s3                   #t 19]
    [      %x20 %s4                   #t 20]
    [      %x21 %s5                   #t 21]
    [      %x22 %s6                   #t 22]
    [      %x23 %s7                   #t 23]
    [      %x24 %s8                   #t 24]
    [      %x25 %s9                   #t 25]
    [      %x26 %s10                  #t 26]
    [      %x27 %s11                  #t 27]
    [      %x28 %t3                   #f 28]
    [      %x29 %t4                   #f 29]
    [      %x30 %t5                   #f 30]
    [      %x31 %t6                   #f 31]
  )
  (machine-dependent
   [%sp   %x2        #f         2]
   [%pc              #f        32]
   [%flreg1          #f        33]
   [      %f10 %fa0 %Cfpretval       #f 43]
   [      %f11 %fa1 %Cfpretval1      #f 44]
   ))

;;; SECTION 2: instructions
(module (md-handle-jump) ; also sets primitive handlers
  (import asm-module)

)

;;; SECTION 3: assembler
(module asm-module ()

)
  
