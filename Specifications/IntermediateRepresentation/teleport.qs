namespace Microsoft.Quantum.Tutorial
{
    open Microsoft.Quantum.Intrinsic;

    operation PrepareBellState(q1 : Qubit, q2 : Qubit) : Unit is Adj + Ctl {
        H(q1);
        CNOT(q1, q2);
    }

    operation Teleport (nrReps : Int, (target : Qubit, msg : Qubit), initialize : (Qubit => Unit is Adj)) : Result[] {
        mutable results = new Result[nrReps];

        for (iter in 1..nrReps) {
            using (source = Qubit()) {
                initialize(source);
                PrepareBellState(source, target);
                Adjoint PrepareBellState(source, msg);

                let measureZ = Measure([PauliZ], _);

                if (measureZ([source]) == One) {
                    Z(target);
                }
                if (measureZ([msg]) == One) {
                    X(target);
                }

                Adjoint initialize(target);

                set results w/= iter <- M(target);
            }
        }
        return results;
    }

    operation RunTests (nrReps : Int) : Bool {
        let angle = 0.5;
        let initialize = Rx(angle, _);
        mutable success = true;

        using ((target, msg) = (Qubit(), Qubit())) {
            let results = Teleport(nrReps, (target, msg), initialize);
            for (r in results) {
                if (r != Zero) {
                    set success = false;
                }
            }
        }
        return success;
    }
}
