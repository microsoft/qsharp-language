# Quantum Intermediate Representation Specification

## Flow of Control Representation

To make constructs easier for later passes to recognize and optimize,
we require that compilers follow the templates in this section and that
optimization passes preserve these templates.

### If/then/else statements

Conditional statements (if/then/else) get implemented using conditional branches.

If there is no `else` block, then the conditional branch should branch around the
`then` block.
The following template should be used:

```LLVM
  ; compute condition into %0
  br i1 %0, label true-123, label continue-123
true-123:
  ; if block goes here
  br continue-123
continue-123:
```

If there are both `if` and `else` blocks, the compiler should place the `then` block
before the `else` block.
The following template should be used:

```LLVM
  ; compute condition into %0
  br i1 %0, label true-123, label false-123
true-123:
  ; if block goes here
  br label continue-123
false-123:
  ; else block goes here
continue-123:
```

### Indefinite Loops (while and repeat/until/fixup)

Indefinite loops get implemented using conditional branches.

For `repeat ... until ... fixup` loops, the following template should be used:

```LLVM
preheader-123:
  br label body-123
body-123:
  ; repeat block goes here
until-123:
  ; compute until condition into %cond-123
  br i1 %cond-123, label exit-123, label fixup-123
fixup-123:
  ; fixup block goes here
  br label body-123
exit-123:
```

For `while` loops, the following template should be used:

```LLVM
preheader-123:
  ; compute initial condition into %initcond-123
  br label header-123
header-123:
  %cond-123 = phi i1 [ %initcond-123, %preheader-123], [ %nextcond-123, %exiting-123 ]
  br i1 %cond-123, label body-123, label exit-123
body-123:
  ; while block goes here
exiting-123:
  ; compute loop condition into %nextcond-123
  br label header-123
exit-123:
```

### Definite Loops (for)

Definite loops should follow the canonical LLVM `for` loop structure.

The following template should be used:

```LLVM
preheader-123:
  ; Start of range
  %init-123 = extractvalue %Range %range, 0
  %step-123 = extractvalue %Range %range, 1
  %end-123 = extractvalue %Range %range, 2
  %dir-123 = icmp sgt %step-123, 0
  br label header-123
header-123:  
  %index-123 = phi i64 [ %init-123, %preheader-123], [ %nextindex-123, %exiting-123 ]
  ; %2 tells us if we continue; we need to check <= or >= depending on whether the step is > or < 0
  %0 = icmp sle %index-123, %end-123
  %1 = icmp sge %index-123, %end-123
  %2 = select %dir-123, %0, %1
  br %2, label body-123, label exit-123
body-123:
  ; for block goes here
exiting-123:
  %nextindex-123 = add i64 %index-123, %step-123
  br label %header-123
exit-123:
```

A loop through an array, rather than through a range of integers, should be converted to
a loop through the appropriate range of indices.
The start of the body of the loop should extract the current array element (the original
loop variable) from the array using the current index.

### Qubit Management

Qubit management constructs in Q# have clean-up processing that must be run even if a
`return` statement appears within the construct.
This is a standard need and there are several ways a compiler can handle this;
we demonstrate two here.

For the following Q# code snippet:

```qsharp
using (q1 = Qubit()) {
  // block 1
  using (qs = Qubit[5]) {
    // block 2
    if (flag) {
      return 3;
    }
    // block 3
  }
  // block 4
  if (flag2) {
    return 4;
  }
  // block 5
}
```

The compiler can generate the following LLVM code, building a clean-up block with multiple
entry labels:

```LLVM
using-1:
    %0 = call [0 x %Qubit]* @quantum.alloca(i32 1)
    %1 = getelemptr %Qubit*, [0 x %Qubit]* %0, i64 0
    %q1 = load %Qubit, %Qubit*  %1
    ; block 1 goes here
using-2:
    %2 = call [0 x %Qubit]* @quantum.alloca(i32 5)
    ; build %qs as a Q# array from %2
    ; block 2 goes here
    br i1 %flag, label true-1, label false-1
true-1:
    ; we assume %result holds the return value
    %result = i64 3
    call quantum.release i32 5, [0 x %Qubit]* %2
return-2:
    call quantum.release i32 1, [0 x %Qubit]* %0
    ret i64 %result
false-1:
    ; block 3 goes here
    call quantum.release i32 5, [0 x %Qubit]* %2
    ; block 4 goes here
    br i1 %flag2, label true-2, label false-2
true-2:
    %result = i64 4
    br label return-2
false-2:
    ; block 5 goes here
    call quantum.release i32 1, [0 x %Qubit]* %0
```

Alternatively, the compiler could generate the following, with a separate clean-up block
for each Q# `return` statement.
This version creates more LLVM code, but is easier to map to the Q# code.

```LLVM
using-1:
    %0 = call [0 x %Qubit]* @quantum.alloca(i32 1)
    %1 = getelemptr %Qubit*, [0 x %Qubit]* %0, i64 0
    %q1 = load %Qubit, %Qubit*  %1
    ; block 1 goes here
using-2:
    %2 = call [0 x %Qubit]* @quantum.alloca(i32 5)
    ; build %qs as a Q# array from %2
    ; block 2 goes here
    br i1 %flag, label true-1, label false-1
true-1:
    call quantum.release i32 5, [0 x %Qubit]* %2
    call quantum.release i32 1, [0 x %Qubit]* %0
    ret i64 3
false-1:
    ; block 3 goes here
    call quantum.release i32 5, [0 x %Qubit]* %2
    ; block 4 goes here
    br i1 %flag2, label true-2, label false-2
true-2:
    call quantum.release i32 1, [0 x %Qubit]* %0
    ret i64 4
false-2:
    ; block 5 goes here
    call quantum.release i32 1, [0 x %Qubit]* %0
```

> **TODO**: Pick one of these two as the standard.
