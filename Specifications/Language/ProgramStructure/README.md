# Program Execution

The following program gives a first glimpse at how a Q# command line application is implemented: 
```qsharp
namespace Microsoft.Quantum.Samples {
    
    open Microsoft.Quantum.Arithmetic; 
    open Microsoft.Quantum.Arrays as Array; 
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics as Diagnostics; 
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Preparation; 

    operation ApproximateQFT (a : Int, reg : LittleEndian) : Unit 
    is Adj + Ctl {
        
        let qs = reg!;        
        SwapReverseRegister(qs);
        
        for (i in Array.IndexRange(qs)) {
            for (j in 0..(i-1)) {
                if ( (i-j) < a ) {
                    Controlled R1Frac([qs[i]], (1, i - j, qs[j]));
                }
            }
            H(qs[i]);
        }
    }

    @EntryPoint() 
    operation Main(vector : Double[]) : Unit {

        let n = Floor(Log(IntAsDouble(Length(vector))) / LogOf2());
        if (1 <<< n != Length(vector)) {
            fail "Length(vector) needs to be a power of two.";
        }

        let amps = Array.Mapped(ComplexPolar(_,0.), vector);
        using (qs = Qubit[n]) {
            let reg = LittleEndian(qs);

            PrepareArbitraryState(amps, reg); 
            Message("Before QFT:");
            Diagnostics.DumpRegister((), qs);

            ApproximateQFT(n, reg); 
            Message("After QFT:");
            Diagnostics.DumpRegister((), qs);

            ResetAll(qs);
        }
    }
}
```

The operation `PrepareArbitraryState` initializes a quantum state where the amplitudes for each basis state correspond to the normalized entries of the specified vector. A quantum Fourier transformation (QFT) is then applied to that state.

The corresponding project file to build the application is the following: 
```
<Project Sdk="Microsoft.Quantum.Sdk/0.12.20070124"> 

  <PropertyGroup>
    <OutputType>Exe</OutputType> 
    <TargetFramework>netcoreapp3.1</TargetFramework>
  </PropertyGroup>

</Project>

```

Line 1 specifies the version number of the software development kit used to build the application, and line 4 indicates that the project is executable opposed to e.g. a library that cannot be invoked from the command line.

To run the application, you will need to install [.NET Core](https://docs.microsoft.com/dotnet/core/install/). Then put both files in the same folder and run `dotnet build <projectFile>`, where `<projectFile>` is to be replaced with the path to the project file. 

To execute the program after having built it, run the command
```
    dotnet run --no-build --vector 1. 0. 0. 0.
```
The invocation above will output that the amplitudes of the quantum state after application of the QFT are evenly distributed and real. Note that the reason that we can so readily output the amplitudes of the state vector is that the above program is by default executed on a full state simulator, which supports outputting the tracked quantum state via `DumpRegister` for debugging purposes. The same would not be possible if we were to execute it on quantum hardware instead, and the two calls to `DumpRegister` in that case won't do anything. This can be seen by targeting the application to a particular hardware platform by adding the project property `<ExecutionTarget>honeywell.qpu</ExecutionTarget>` after `<PropertyGroup>`.
```
