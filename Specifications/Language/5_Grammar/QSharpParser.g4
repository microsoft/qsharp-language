parser grammar QSharpParser;

options {
    tokenVocab = QSharpLexer;
}

program : namespace* EOF;

// Namespace

namespace : 'namespace' qualifiedName BraceLeft namespaceElement* BraceRight;

qualifiedName : Identifier ('.' Identifier)*;

namespaceElement
    : openDirective
    | typeDeclaration
    | callableDeclaration
    ;

// Open Directive

openDirective : 'open' qualifiedName ('as' qualifiedName)? ';';

// Declaration

attribute : '@' expression;

access : 'internal';

declarationPrefix : attribute* access?;

// Type Declaration

typeDeclaration : declarationPrefix 'newtype' Identifier '=' underlyingType ';';

underlyingType
    : typeDeclarationTuple
    | type
    ;

typeDeclarationTuple : '(' (typeTupleItem (',' typeTupleItem)*)? ')';

typeTupleItem
    : namedItem
    | underlyingType
    ;

namedItem : Identifier ':' type;

// Callable Declaration

callableDeclaration
    : declarationPrefix ('function' | 'operation')
      Identifier typeParameterBinding? parameterTuple
      ':' type characteristics?
      callableBody
    ;

typeParameterBinding : '<' (TypeParameter (',' TypeParameter)*)? '>';

parameterTuple : '(' (parameter (',' parameter)*)? ')';

parameter
    : namedItem
    | parameterTuple
    ;

characteristics : 'is' characteristicsExpression;

characteristicsExpression
    : 'Adj'
    | 'Ctl'
    | '(' characteristicsExpression ')'
    | characteristicsExpression '*' characteristicsExpression
    | characteristicsExpression '+' characteristicsExpression
    ;

callableBody
    : BraceLeft specialization* BraceRight
    | scope
    ;

specialization : specializationName+ specializationGenerator;

specializationName
    : 'body'
    | 'adjoint'
    | 'controlled'
    ;

specializationGenerator
    : 'auto' ';'
    | 'self' ';'
    | 'invert' ';'
    | 'distribute' ';'
    | 'intrinsic' ';'
    | providedSpecialization
    ;

providedSpecialization : specializationParameterTuple? scope;

specializationParameterTuple : '(' (specializationParameter (',' specializationParameter)*)? ')';

specializationParameter
    : Identifier
    | '...'
    ;

// Type

type
    : '_'
    | TypeParameter
    | 'BigInt'
    | 'Bool'
    | 'Double'
    | 'Int'
    | 'Pauli'
    | 'Qubit'
    | 'Range'
    | 'Result'
    | 'String'
    | 'Unit'
    | qualifiedName
    | '(' (type (',' type)* ','?)? ')'
    | '(' arrowType characteristics? ')'
    | type '[' ']'
    ;

arrowType
    : '(' type ('->' | '=>') type ')'
    | type ('->' | '=>') type
    ;

// Statement

statement
    : expression ';'
    | 'return' expression ';'
    | 'fail' expression ';'
    | 'let' symbolBinding '=' expression ';'
    | 'mutable' symbolBinding '=' expression ';'
    | 'set' symbolBinding '=' expression ';'
    | 'set' Identifier updateOperator expression ';'
    | 'set' Identifier 'w/=' expression '<-' expression ';'
    | 'if' expression scope
    | 'elif' expression scope
    | 'else' scope
    | 'for' (forBinding | '(' forBinding ')') scope
    | 'while' expression scope
    | 'repeat' scope
    | 'until' expression (';' | 'fixup' scope)
    | 'within' scope
    | 'apply' scope
    | ('use' | 'using') (qubitBinding | '(' qubitBinding ')') (';' | scope)
    | ('borrow' | 'borrowing') (qubitBinding | '(' qubitBinding ')') (';' | scope)
    ;

scope : BraceLeft statement* BraceRight;

symbolBinding
    : '_'
    | Identifier
    | '(' (symbolBinding (',' symbolBinding)* ','?)? ')'
    ;

updateOperator
    : '^='
    | '*='
    | '/='
    | '%='
    | '+='
    | '-='
    | '>>>='
    | '<<<='
    | '&&&='
    | '^^^='
    | '|||='
    | 'and='
    | 'or='
    ;

forBinding : symbolBinding 'in' expression;

qubitBinding : symbolBinding '=' qubitInitializer;

qubitInitializer
    : 'Qubit' '(' ')'
    | 'Qubit' '[' expression ']'
    | '(' (qubitInitializer (',' qubitInitializer)* ','?)? ')'
    ;

// Expression

expression
    : '_'
    | qualifiedName ('<' (type (',' type)* ','?)? '>')?
    | IntegerLiteral
    | BigIntegerLiteral
    | DoubleLiteral
    | DoubleQuote stringContent* StringDoubleQuote
    | DollarQuote interpStringContent* InterpDoubleQuote
    | boolLiteral
    | resultLiteral
    | pauliLiteral
    | '(' (expression (',' expression)* ','?)? ')'
    | '[' (expression (',' expression)* ','?)? ']'
    | 'new' type '[' expression ']'
    | expression ('::' Identifier | '[' expression ']')
    | expression '!'
    | <assoc=right> 'Controlled' expression
    | <assoc=right> 'Adjoint' expression
    | expression '(' (expression (',' expression)* ','?)? ')'
    | <assoc=right> ('-' | 'not' | '~~~') expression
    | <assoc=right> expression '^' expression
    | expression ('*' | '/' | '%') expression
    | expression ('+' | '-') expression
    | expression ('>>>' | '<<<') expression
    | expression ('>' | '<' | '>=' | '<=') expression
    | expression ('==' | '!=') expression
    | expression '&&&' expression
    | expression '^^^' expression
    | expression '|||' expression
    | expression 'and' expression
    | expression 'or' expression
    | <assoc=right> expression '?' expression '|' expression
    | expression '..' expression
    | expression '...'
    | '...' expression
    | '...'
    | expression 'w/' expression '<-' expression
    ;

boolLiteral
    : 'false'
    | 'true'
    ;

resultLiteral
    : 'Zero'
    | 'One'
    ;

pauliLiteral
    : 'PauliI'
    | 'PauliX'
    | 'PauliY'
    | 'PauliZ'
    ;

stringContent
    : StringEscape
    | StringText
    ;

interpStringContent
    : InterpStringEscape
    | InterpBraceLeft expression BraceRight
    | InterpStringText
    ;
