# Grammar

A reference implementation of the Q# grammar is available in the [ANTLR4](https://www.antlr.org/) format.
The grammar source files are listed below:

* [**QSharpLexer.g4**](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/5_Grammar/QSharpLexer.g4) describes the lexical structure of Q#.
* [**QSharpParser.g4**](https://github.com/microsoft/qsharp-language/blob/main/Specifications/Language/5_Grammar/QSharpParser.g4) describes the syntax of Q#.

The Q# grammar uses [*actions*](https://github.com/antlr/antlr4/blob/master/doc/actions.md) and [*semantic predicates*](https://github.com/antlr/antlr4/blob/master/doc/predicates.md).
These features allow grammars to include custom source code in the ANTLR-generated parser, which means that the code needs to be written in the same language as the ANTLR target language.
If you are using the Q# grammar to generate parsers in a language other than Java, you may need to update the code used by the actions and semantic predicates to match the target language.
