## Executable Code Generation

There are several areas where a code generator may want to significantly deviate
from a simple rewrite of basic intrinsics to target machine code:

- The intermediate representation assumes that the runtime does not perform
  garbage collection, and thus carefully tracks stack versus heap allocation
  and reference counting for heap-allocated structures. A runtime that provides
  full garbage collection may wish to remove the reference count field from several
  intermediate representation structures and elide calls to `__quantum__rt__free`
  and the various `unreference` functions.
- Many types are defined as pointers to opaque structures. The code generator
  will need to either provide a concrete realization of the structure or replace
  the pointer type with some other representation entirely.
- Depending on the characteristics of the target architecture, the code generator
  may prefer to use different representations for the various types given concrete
  types here. For instance, on some architectures it will make more sense to represent
  small types as bytes rather than as single or double bits.
- The primitive quantum operations provided by a particular target architecture
  may differ significantly from the intrinsics defined in this specification.
  It is expected that code generators will significantly rewrite sequences of
  quantum intrinsics into sequences that are optimal for the specific target.

---
_[Back to index](README.md)_
