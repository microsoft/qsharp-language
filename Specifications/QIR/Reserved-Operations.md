# Reserved Operation Names

As mentioned [here](Quantum-Runtime.md), we do reserve a set of quantum operation names.
While targets are not required to implement any or all of these operations,
if they define an operation with a reserved name that operation's effect is required
to match the specified action.
This ensures that quantum code that uses, say, a `CNOT` operation can rely on the
effect of that operation being consistent across targets that define it.

| Operation Name | Subroutine Name | Description | Matrix |
|----------------|-----------------|-------------|--------|
| I | __quantum__qis__I | The identity operation | ![formula](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+1+%26+0+%5C%5C+0+%26+1+%5Cend%7Bbmatrix%7D) |
| X | __quantum__qis__X | The Pauli X operation | ![formula](https://render.githubusercontent.com/render/math?math=%5Cdisplaystyle+%5Cbegin%7Bbmatrix%7D+0+%26+1+%5C%5C+1+%26+0+%5Cend%7Bbmatrix%7D) |

---
_[Back to index](README.md)_
