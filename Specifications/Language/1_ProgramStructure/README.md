# Program execution

The following program gives a first glimpse at how a Q# command-line application is implemented: 

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

    operation ApplyQFT (reg : LittleEndian) : Unit 
    is Adj + Ctl {
        
        let qs = reg!;        
        SwapReverseRegister(qs);
        
        for (i in Array.IndexRange(qs)) {
            for (j in 0 .. i-1) {
                Controlled R1Frac([qs[i]], (1, i - j, qs[j]));
            }
            H(qs[i]);
        }
    }

    @EntryPoint() 
    operation RunProgram(vector : Double[]) : Unit {

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

            ApplyQFT(reg); 
            Message("After QFT:");
            Diagnostics.DumpRegister((), qs);

            ResetAll(qs);
        }
    }
}
```

The operation `PrepareArbitraryState` initializes a quantum state where the amplitudes for each basis state correspond to the normalized entries of the specified vector. A quantum Fourier transformation (QFT) is then applied to that state.

The corresponding project file to build the application is the following: 

```xml
<Project Sdk="Microsoft.Quantum.Sdk/0.12.20070124"> 

  <PropertyGroup>
    <OutputType>Exe</OutputType> 
    <TargetFramework>netcoreapp3.1</TargetFramework>
  </PropertyGroup>

</Project>
```

The first line specifies the version number of the software development kit used to build the application, and line 4 indicates that the project is executable opposed to e.g. a library that cannot be invoked from the command line.

To run the application, you will need to install [.NET Core](/dotnet/core/install/). Then put both files in the same folder and run `dotnet build <projectFile>`, where `<projectFile>` is to be replaced with the path to the project file. 

To run the program after having built it, run the command

```azurecli
    dotnet run --no-build --vector 1. 0. 0. 0.
```

The output from this invocation shows that the amplitudes of the quantum state after application of the QFT are evenly distributed and real. Note that the reason that we can so readily output the amplitudes of the state vector is that the previous program is, by default, run on a full state simulator, which supports outputting the tracked quantum state via `DumpRegister` for debugging purposes. The same would not be possible if we were to run it on quantum hardware instead, in which case the two calls to `DumpRegister` wouldn't do anything. You can see this by targeting the application to a particular hardware platform by adding the project property `<ExecutionTarget>honeywell.qpu</ExecutionTarget>` after `<PropertyGroup>`.


← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
