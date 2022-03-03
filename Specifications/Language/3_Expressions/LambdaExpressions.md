# Lambda Expressions

A lambda expression consists of a symbol or a symbol tuple, followed by either
an `->` in the case of a lambda function or an `=>` in the case of a lambda
operation, and a single expression that defines the value that is returned when
the lambda is invoked. Custom implementations for adjoint and controlled
versions cannot be defined as part of a lambda expression.

The signature of the lambda, including its input type, return type, and
characteristics are inferred based on first usage. The necessary functor support
is automatically created by the compiler.

← [Back to Index](https://github.com/microsoft/qsharp-language/tree/main/Specifications/Language#index)
