# Comments

Comments begin with two forward slashes (`//`) and continue until the end of line.
Such end-of-line comments may appear anywhere in the source code.
Q# does not currently support block comments.

## Documentation Comments

Comments that begin with three forward slashes, `///`,
are treated specially by the compiler when they appear before a type or callable declaration.
In that case, their contents are taken as documentation for the defined
type or callable, as for other .NET languages.

Within `///` comments, text to appear as a part of API documentation is
formatted as [Markdown](https://daringfireball.net/projects/markdown/syntax),
with different parts of the documentation indicated by specially-named
headers.
As an extension to Markdown, cross-references to operations, functions, and
user-defined types in Q# can be included using `@"<ref target>,"`
where `<ref target>` is replaced by the fully qualified name of the
code object being referenced.
Optionally, a documentation engine may also support additional
Markdown extensions.

For example:

```qsharp
/// # Summary
/// Given an operation and a target for that operation,
/// applies the given operation twice.
///
/// # Input
/// ## op
/// The operation to be applied.
/// ## target
/// The target to which the operation is to be applied.
///
/// # Type Parameters
/// ## 'T
/// The type expected by the given operation as its input.
///
/// # Example
/// ```Q#
/// // Should be equivalent to the identity.
/// ApplyTwice(H, qubit);
/// ```
///
/// # See Also
/// - Microsoft.Quantum.Intrinsic.H
operation ApplyTwice<'T>(op : ('T => Unit), target : 'T) : Unit {
    op(target);
    op(target);
}
```

Q# recognizes the following names as documentation comment headers.

- **Summary**: A short summary of a function or operation's behavior
  or the purpose of a type. The first paragraph of the summary is used
  for hover information. It should be plain text.
- **Description**: A description of a function or operation's behavior
  or the purpose of a type. The summary and description are concatenated to
  form the generated documentation file for the function, operation, or type.
  The description may contain in-line LaTeX-formatted symbols and equations.
- **Input**: A description of the input tuple for an operation or function.
  May contain additional Markdown subsections indicating each element of the input tuple.
- **Output**: A description of the tuple returned by an operation or function.
- **Type Parameters**: An empty section that contains one additional
  subsection for each generic type parameter.
- **Named Items**: A description of the named items in a user-defined type.
  May contain additional Markdown subsections with the description for each named item.
- **Example**: A short example of the operation, function, or type in use.
- **Remarks**: Miscellaneous prose describing some aspect of the operation,
  function, or type.
- **See Also**: A list of fully qualified names indicating related functions,
  operations, or user-defined types.
- **References**: A list of references and citations for the documented item.


