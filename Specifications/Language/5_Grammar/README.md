# Grammar

A reference implementation of the Q# grammar is available in the [ANTLR4](https://www.antlr.org/) format.
The grammar source files are listed below:

* [**QSharpLexer.g4**](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/5_Grammar/QSharpLexer.g4) describes the lexical structure of Q#.
* [**QSharpParser.g4**](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/5_Grammar/QSharpParser.g4) describes the syntax of Q#.

## Target language

The ANTLR grammar contains some embedded C# code.
It looks like this (enclosed in curly braces):

```antlr
BraceRight : '}' { if (ModeStack.Count > 0) PopMode(); };
```

If you want to generate a parser for a target language other than C#, you will need to change these code snippets.
