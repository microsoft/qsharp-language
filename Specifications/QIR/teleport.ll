define void Microsoft.Quantum.Tutorial.PrepareBellState-body(%TuplePointer %capture, %TuplePointer %args, %TuplePointer %result)
{
entry:
    %0 = type { %TupleHeader, %Qubit, %Qubit }
    %1 = bitcast %TuplePointer %args to %0*
    ; %2 points to the first qubit
    %2 = getelementptr %Qubit*, %0* %1, i64 0, i32 1
    %q1 = load %Qubit, %Qubit* %2
    ; %3 points to the second qubit
    %3 = getelementptr %Qubit*, %0* %1, i64 0, i32 2
    %q2 = load %Qubit, %Qubit* %3
    call void quantum.h(%Qubit %q1)
    call void quantum.cnot(%Qubit %q1, %Qubit %q2)
    ret void
}

define void Microsoft.Quantum.Tutorial.PrepareBellState-adj(%TuplePointer %capture, %TuplePointer %args, %TuplePointer %result)
{
entry:
    %0 = type { %TupleHeader, %Qubit, %Qubit }
    %1 = bitcast %TuplePointer %args to %0*
    ; %2 points to the first qubit
    %2 = getelementptr %Qubit*, %0* %1, i64 0, i32 1
    %q1 = load %Qubit, %Qubit* %2
    ; %3 points to the second qubit
    %3 = getelementptr %Qubit*, %0* %1, i64 0, i32 2
    %q2 = load %Qubit, %Qubit* %3
    call void quantum.cnot(%Qubit %q1, %Qubit %q2)
    call void quantum.h(%Qubit %q1)
    ret void
}

define void Microsoft.Quantum.Tutorial.PrepareBellState-ctl(%TuplePointer %capture, %TuplePointer %args, %TuplePointer %result)
{
    ; ...
}

define void Microsoft.Quantum.Tutorial.PrepareBellState-ctladj(%TuplePointer %capture, %TuplePointer %args, %TuplePointer %result)
{
    ; ...
}

@Microsoft.Quantum.Tutorial.PrepareBellState = constant %CallableImplTable
  [
    %CallableImpl* @Microsoft.Quantum.Tutorial.PrepareBellState-body,
    %CallableImpl* @Microsoft.Quantum.Tutorial.PrepareBellState-adj,
    %CallableImpl* @Microsoft.Quantum.Tutorial.PrepareBellState-ctl,
    %CallableImpl* @Microsoft.Quantum.Tutorial.PrepareBellState-ctladj
  ]

; This is a generated operation that implements the partial application of Measure inside Teleport
; Note that, in principle, because the captured value is a compile-time constant, the language-specific
; phase could simply insert the constant value and ignore the capture tuple.
; We don't perform this optimization here in order to provide an example of capture tuple usage.
define void Microsoft.Quantum.Tutorial.Teleport-lambda1-body(%TuplePointer %capture, %TuplePointer %args, %TuplePointer %result)
{
entry:
    ; Get the Pauli array value from the capture tuple
    %0 = type { %TupleHeader, %ArrayPointer }
    %1 = bitcast %TuplePointer %capture to %0*
    %2 = getelementptr %ArrayPointer*, %0* %1, i64 0, i32 1
    %3 = load %ArrayPointer, %ArrayPointer* %2

    ; Get the qubit array from the args tuple
    ; Since the type is the same as for the capture tuple, we can reuse the type
    %4 = bitcast %TuplePointer %args to %0*
    %5 = getelementptr %ArrayPointer*, %0* %4, i64 0, i32 1
    %6 = load %ArrayPointer, %ArrayPointer* %5

    ; Prepare the argument tuple for the call to Measure
    %7 = type { %TupleHeader, %ArrayPointer, %ArrayPointer }
    %8 = alloca %7
    %9 = bitcast %7* %8 to %TuplePointer
    call void quantum.rt.tuple_init_stack(%TuplePointer %9)
    %10 = getelementptr %ArrayPointer*, %7* %8, i64 0, i32 1
    store %ArrayPointer %3, %ArrayPointer* %10
    %11 = getelementptr %ArrayPointer*, %7* %8, i64 0, i32 2
    store %ArrayPointer %7, %ArrayPointer* %11

    ; Call Measure. Note the re-use of the result tuple; this is essentially a tail call
    call void Microsoft.Quantum.Intrinsics.Measure-body(%TuplePointer null, %TuplePointer %9, %TuplePointer %result)

    ret void
}

@Microsoft.Quantum.Tutorial.Teleport-lambda1 = constant %CallableImplTable
  [
    %CallableImpl* @Microsoft.Quantum.Tutorial.Teleport-lambda1-body,
    %CallableImpl* null,
    %CallableImpl* null,
    %CallableImpl* null
  ]

define void Microsoft.Quantum.Tutorial.Teleport-body(%TuplePointer %capture, %TuplePointer %args, %TuplePointer %result)
{
entry:
    %0 = type { %TupleHeader, %Int, %TuplePointer, %Callable* }
    %1 = bitcast %TuplePointer %args to %0*
    ; %2 points to the repetition count
    %2 = getelementptr %Int*, %0* %1, i64 0, i32 1
    %nrReps = load %Int, %Int* %2
    ; %3 points to the pointer to the target/msg tuple, %4 to the tuple itself, and %6 to the tuple properly typed
    ; Then, %7 points to target and %8 to msg
    %3 = getelementptr %TuplePointer*, %0* %1, i64 0, i32 2
    %4 = load %TuplePointer, %TuplePointer* %3
    %5 = type { %TupleHeader,  %Qubit, %Qubit }
    %6 = bitcast %TuplePointer %4 to %5*
    %7 = getelementptr %Qubit*, %5* %6, i64 0, i32 1
    %target = load %Qubit, %Qubit* %7
    %8 = getelementptr %Qubit*, %5* %6, i64 0, i32 2
    %msg = load %Qubit, %Qubit* %8
    ; %9 points to the initialize pointer
    %9 = getelementptr %Callable**, %0* %1, i64 0, i32 3
    %initialize = load %Callable*, %Callable** %9

    ; Get the results array handle from the result tuple and initialize it as a 1-dimensional array of %Results.
    ; We rrepresent each %Result as the low-order bit of a byte, rather than worrying about packing bits into bytes
    ; more densely. If such packing is required, it could be added.
    %10 = type { %TupleHeader, %ArrayPointer }
    %11 = bitcast %TuplePointer %result to %10*
    %12 = getelementptr %ArrayPointer*, %10* %11, i64 0, i32 1
    %results = load %ArrayPointer, %ArrayPointer* %12
    call void quantum.rt.array_create(%ArrayPointer %results, i32 1, %Destructor null, i32 1, [ %Int %nrReps ])

preheader-1:
    ; Here we've constant-folded, rather than creating and then disassembling the
    ; 1..nrReps Range. We've also constant-folded below, so we skip the various start and step symbols here.
    br label header-1

header-1:
    %iter = phi %Int [ 1, %preheader-1 ], [ %nextindex-1, %exiting-1 ]
    ; We've pre-done the select here since we know the loop direction statically
    %13 = icmp sle %iter, %nrReps
    br %13, label body-1, label exit-1

body-1:
    ; Implement the using statement
    %14 = alloca [1 x %Qubit]
    %15 = bitcast [1 x %Qubit]* %14 to [0 x %Qubit]*
    call void @quantum.alloc(i64 1, [0 x %Qubit]* %15)
    %16 = getelementptr %Qubit*, [1 x %Qubit]* %14, i64 0
    %source = load %Qubit, %Qubit* %16

    ; Create the argument tuple for initialize
    %17 = type { %TupleHeader, %Qubit }
    %18 = alloca %17
    %19 = bitcast %17* %18 to %TuplePointer
    call void quantum.rt.tuple_init_stack(%TuplePointer %19)
    %20 = getelementptr %Qubit*, %17* %18, i64 0, i32 1
    store %Qubit %source, %Qubit* %20
    ; Call through the initialize callable pointer, with a null result pointer
    ; because the initialize callable returns Unit
    call void quantum.rt.invoke_callable(%Callable* %initialize, %TuplePointer %19, %TuplePointer null)

    ; Create the argument tuple for PrepareBellState
    %21 = type { %TupleHeader, %Qubit, %Qubit }
    %22 = alloca %21
    %22 = bitcast %21* %22 to %TuplePointer
    call quantum.rt.tuple_init_stack(%TuplePointer %22)
    %23 = getelementptr %Qubit*, %21* %22, i64 0, i32 1
    store %Qubit %source, %Qubit* %23
    %24 = getelementptr %Qubit*, %21* %22, i64 0, i32 2
    store %Qubit %target, %Qubit* %24
    ; Call PrepareBellState, optimizing to just call it directly
    call void Microsoft.Quantum.Tutorial.PrepareBellState-body(%TuplePointer null, %TuplePointer %22, %TuplePointer null)

    ; Reuse the PrepareBellState argument tuple for Adjoint PrepareBellState
    store %Qubit %msg, %Qubit* %24
    ; Call Adjoint PrepareBellState, optimizing to just call it directly
    call void Microsoft.Quantum.Tutorial.PrepareBellState-adj(%TuplePointer null, %TuplePointer %22, %TuplePointer null)

    ; Generate the callable value for the partial application, starting with the capture tuple
    ; Note that we've already declared %10 as the LLVM type for a tuple containing a single array,
    ; so we just reuse that type definition here and below.
    ; This could obviously be hoisted from the loop, but we omit that optimization here to make the
    ; LLVM code easier to match with the Q# source.
    %25 = alloca %10
    %26 = bitcast %10* %25 to %TuplePointer
    call void quantum.rt.tuple_init_stack(%TuplePointer %26)
    %27 = extractvalue %10* %25, i32 1
    call void quantum.rt.array_create(%ArrayPointer %27, i32 1, %Destructor null, i32 1, [ i64 1 ])
    %28 = call i8* quantum.rt.array_get_element(%ArrayPointer %27, [i64 0])
    ; We know there are no other handles to this array, so we can write directly to the element
    store %Pauli @Pauli.Z, i8* %28
    %measureZ = alloca %Callable
    call void quantum.rt.callable_init(%Callable* %measureZ,
                                       %CallableImplTable* @Microsoft.Quantum.Tutorial.Teleport-lambda1,
                                       %TuplePointer %26)

    ; Create the argument tuple for calling measureZ([source])
    %29 = alloca %10
    %30 = bitcast %10* %29 to %TuplePointer
    call void quantum.rt.tuple_init_stack(%TuplePointer %30)
    ; And initialize the qubit array, assuming a %Qubit takes 8 bytes
    %31 = extractvalue %10* %29, i32 1 
    call void quantum.rt.array_create(%ArrayPointer %31, i32 8, %Destructor null, i32 1, [ i64 1 ])
    %32 = call i8* quantum.rt.array_get_element(%ArrayPointer %31, [i64 0])
    ; We know there are no other handles to this array, so we can write directly to the element
    %33 = bitcast i8* %32 to %Qubit*
    store %Qubit %source, %Qubit* %33

    ; And now the result tuple
    %34 = type { %TupleHeader, %Result }
    %35 = alloca %34
    %36 = bitcast %34* %35 to %TuplePointer
    call void quantum.rt.tuple_init_stack(%TuplePointer %36)

    ; Call measureZ
    call void quantum.rt.callable_invoke(%Callable* %measureZ, %TuplePointer %30, %TuplePointer %36)

    ; And get the result out
    %37 = getelementptr %Result*, %34* %35, i64 0, i32 1
    %38 = load %Result, %Result* %37

    ; Is the result One?
    %39 = icmp eq %38, %Result.One
    br %39, label %true-1, label %continue-1
true-1:
    call quantum.z(%target)
    br label %continue-1
continue-1:

    ; We know that the result tuple from the previous call is not going to be used, so we can reuse it here.
    ; Indeed, this is also true of the qubit array it uses, so all we need to do is update the qubit in the array
    ; and call measureZ again. The key here is that all of this information is available to the compiler.
    store %Qubit %msg, %Qubit* %33
    call void quantum.rt.callable_invoke(%Callable* %measureZ, %TuplePointer %30, %TuplePointer %36)
    %40 = load %Result, %Result* %37
    %41 = icmp eq %40, %Result.One
    br %41, label %true-2, label %continue-2
true-2:
    call quantum.z(%target)
    br label %continue-2
continue-2:

    ; Create the adjoint of initialize.
    ; This could obviously be hoisted from the loop, but we omit that optimization here to make the
    ; LLVM code easier to match with the Q# source.
    %40 = alloca %Callable
    call void quantum.rt.callable_copy(%Callable* %40, %Callable* %initialize)
    call void quantum.rt.callable_adjoint(%Callable* %40)

    ; And call it. Again, we re-use the tuple from earlier (the call to initialize) because we know
    ; that it isn't used any more.
    store %Qubit %target, %Qubit* %20
    call void quantum.rt.invoke_callable(%Callable* %40, %TuplePointer %19, %TuplePointer null)

    ; Measure the target and update the results array. The compiler can statically determine that there
    ; are no other references to the results array and that the old value is discarded immediately, so
    ; the array can safely be updated in place.
    %41 = call %Result quantum.mz(%target)
    %42 = call i8* quantum.rt.array_get_element(%results, [%Int %iter])
    store %Result %41, i8* %42

    ; Our partial application is going out of scope, so we need to unreference the array we created for it.
    call void quamtum.rt.array_unreference(%ArrayPointer %27)

    ; Finish the using statement by releasing the allocated qubit
    call quantum.release i32 1, [0 x %Qubit]* %15

exiting-1:
    %nextindex = add %Int %iter, %Int 1
    br label %header-1

exit-1:

    ; The results array is already stored in the result tuple, so there's nothing else to do before returning.
    ret void
}

@Microsoft.Quantum.Tutorial.Teleport = constant %CallableImplTable
  [
    %CallableImpl* @Microsoft.Quantum.Tutorial.Teleport-body,
    %CallableImpl* null,
    %CallableImpl* null,
    %CallableImpl* null
  ]

; This is a generated operation that implements the partial application of Rx inside RunTests.
; Note that, in principal, because the captured value is a compile-time constant, the language-specific
; phase could simply insert the constant value and ignore the capture tuple.
; We don't perform this optimization here in order to provide an example of capture tuple usage.
define void Microsoft.Quantum.Tutorial.RunTests-lambda1-body(%TuplePointer %capture, %TuplePointer %args, %TuplePointer %result)
{
entry:
    ; Get the rotation angle value from the capture tuple
    %0 = type { %TupleHeader, %Double }
    %1 = bitcast %TuplePointer %capture to %0*
    %2 = getelementptr %Double*, %0* %1, i64 0, i32 1
    %3 = load %Double, %Double* %2

    ; Get the qubit from the args tuple
    %4 = type { %TupleHeader, %Qubit }
    %5 = bitcast %TuplePointer %capture to %4*
    %6 = getelementptr %Qubit*, %0* %5, i64 0, i32 1
    %7 = load %Qubit, %Qubit* %5

    call void quantum.rz(%3, %7)

    ret void
}

define void Microsoft.Quantum.Tutorial.RunTests-lambda1-adj(%TuplePointer %capture, %TuplePointer %args, %TuplePointer %result)
{
    ; Get the rotation angle value from the capture tuple
    %0 = type { %TupleHeader, %Double }
    %1 = bitcast %TuplePointer %capture to %0*
    %2 = getelementptr %Double*, %0* %1, i64 0, i32 1
    %3 = load %Double, %Double* %2

    ; Get the qubit from the args tuple
    %4 = type { %TupleHeader, %Qubit }
    %5 = bitcast %TuplePointer %capture to %4*
    %6 = getelementptr %Qubit*, %0* %5, i64 0, i32 1
    %7 = load %Qubit, %Qubit* %5

    ; The adjoint of a rotation is a rotation through the negative of the angle
    %8 = fneg %3

    call void quantum.rz(%8, %7)

    ret void
}

define void Microsoft.Quantum.Tutorial.RunTests-lambda1-ctl(%TuplePointer %capture, %TuplePointer %args, %TuplePointer %result)
{
    ; ... elided ...
}

define void Microsoft.Quantum.Tutorial.RunTests-lambda1-ctladj(%TuplePointer %capture, %TuplePointer %args, %TuplePointer %result)
{
    ; ... elided ...
}

@Microsoft.Quantum.Tutorial.RunTests-lambda1 = constant %CallableImplTable
  [
    %CallableImpl* @Microsoft.Quantum.Tutorial.RunTests-lambda1-body,
    %CallableImpl* @Microsoft.Quantum.Tutorial.RunTests-lambda1-adj,
    %CallableImpl* @Microsoft.Quantum.Tutorial.RunTests-lambda1-ctl,
    %CallableImpl* @Microsoft.Quantum.Tutorial.RunTests-lambda1-ctladj
  ]


define void Microsoft.Quantum.Tutorial.RunTests-body(%TuplePointer %capture, %TuplePointer %args, %TuplePointer %result)
{
entry:
    ; Get nrReps from the argument tuple
    %0 = type { %TupleHeader, %Int }
    %1 = bitcast %args to %0*
    %2 = getelementptr %Int*, %0* %1, i64 0, i32 1
    %nrReps = load %Int, %Int* %2

    %angle = double 0.5

    ; Generate the callable value for the partial application pr Rx, starting with the capture tuple
    %3 = type { %TupleHeader, %Double }
    %4 = alloca %3
    %5 = bitcast %3* %4 to %TuplePointer
    call void quantum.rt.tuple_init_stack(%TuplePointer %5)
    %6 = getelementptr %Double*, %3* %4, i64 0, i32 1
    store %Double %angle, %Double* %6
    %initialize = alloca %Callable
    call void quantum.rt.callable_init(%Callable* %initialize,
                                       %CallableImplTable* @Microsoft.Quantum.Tutorial.RunTests-lambda1,
                                       %TuplePointer %5)

    ; Allocate space for the mutable variable. A compiler would normally nore that this value is actually
    ; part of the result tuple, and so just use that space directly. We don't do that here so we can give
    ; an example of how mutable values are dealt with.
    %success = alloca %Bool
    store %Bool true, %Bool* %success

    ; Implement the using statement.
    %7 = alloca [2 x %Qubit]
    %8 = bitcast [2 x %Qubit]* %7 to [0 x %Qubit]*
    call void @quantum.alloc(i64 2, [0 x %Qubit]* %8)
    %9 = getelementptr %Qubit*, [2 x %Qubit]* %7, i64 0
    %target = load %Qubit, %Qubit* %9
    %10 = getelementptr %Qubit*, [2 x %Qubit]* %7, i64 1
    %msg = load %Qubit, %Qubit* %10

    ; Build the argument tuple for the call to Teleport
    %11 = type { %TupleHeader, %Int, %TuplePointer, %Callable* }
    %12 = alloca %11
    %13 = bitcast %11* %12 to %TuplePointer
    call void quantum.rt.tuple_init_stack(%TuplePointer %13)
    %14 = getelementptr %Int*, %11* %12, i64 0, i32 1
    store %Int %nrReps, %Int* %14
    %15 = getelementptr %TuplePointer*, %11* %12, i64 0, i32 2
    %16 = type { %TupleHeader,  %Qubit, %Qubit }
    %17 = alloca %16
    %18 = bitcast %16* %17 to %TuplePointer
    call void quantum.rt.tuple_init_stack(%TuplePointer %18)
    %19 = getelementptr %Qubit*, %16* %17, i64 0, i32 1
    store %Qubit %target, %Qubit* %19
    %20 = getelementptr %Qubit*, %16* %17, i64 0, i32 2
    store %Qubit %msg, %Qubit* %20
    store %TuplePointer %18, %TuplePointer* %15
    %21 = getelementptr %Callable**, %0* %1, i64 0, i32 3
    store %Callable* %initialize, %Callable** %21

    ; And the results tuple
    %22 = type { %TupleHeader, %ArrayPointer }
    %23 = alloca %22
    %24 = bitcast %22* %23 to %TuplePointer
    call void quantum.rt.tuple_init_stack(%TuplePointer %24)
    ; We don't have to initialize the array -- that will happen in the called operation

    call void Microsoft.Quantum.Tutorial.Teleport-body(%TuplePointer null, %TuplePointer %13, %TuplePointer %24)

    ; For this loop, we use the template without any constant folding or other optimizations,
    ; so we have an example that's easy to compare to the spec.
preheader-1:
    %25 = getelementptr %ArrayPointer*, %22* %23, i64 0, i32 1
    %26 = load %ArrayPointer, %ArrayPointer* %25
    %init-1 = %Int 0
    %step-1 = %Int 1
    %end-1 = call quantum.rt.array_get_length(%ArrayPointer %26, i32 0)
    %dir-1 = icmp sgt %step-1, 0
    br label header-1
header-1:
    %index-1 = phi %Int [ %init-1, %preheader-1], [ %nextindex-1, %exiting-1 ]
    ; %2 tells us if we continue; we need to check <= or >= depending on whether the step is > or < 0
    %27 = icmp sle %index-1, %end-1
    %28 = icmp sge %index-1, %end-1
    %29 = select %dir-1, %27, %28
    br %2, label %body-1, label %exit-1
body-1:
    %30 = call i8* quantum.rt.array_get_element(%ArrayPointer %26, [ %Int %index-1 ])
    %31 = load i8, i8* %30
    %32 = trunc i8 %31 to %Result
    %33 = icmp ne %32, %Result.Zero
    br %33, label %true-1, label %false-1
true-1:
    store %Bool 0, %Bool* %success
false-1:
exiting-1:
    %nextindex-1 = add i64 %index-1, %step-1
    br label %header-1
exit-1:

    ; Unreference the results array to finish the using statement
    call void Quantum.rt.array_unreference(%26)

    ; Fill in our result tuple
    %34 = type { %TupleHeader, %Bool }
    %35 = bitcast %TuplePointer %result to %34*
    %36 = getelementptr %Bool*, %34* %35, i64 0, i32 1
    store %Bool %success, %Bool* %36

    ; Everything else is stack-allocated, so no need to unreference anything

    ret void;
}

@Microsoft.Quantum.Tutorial.RunTests = constant %CallableImplTable
  [
    %CallableImpl* @Microsoft.Quantum.Tutorial.RunTests-body,
    %CallableImpl* null,
    %CallableImpl* null,
    %CallableImpl* null
  ]
