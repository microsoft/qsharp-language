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

callableDeclaration :
    declarationPrefix
    ('function' | 'operation')
    Identifier
    typeParameterBinding?
    parameterTuple
    ':'
    type
    characteristics?
    callableBody;

typeParameterBinding : '<' (TypeParameter (',' TypeParameter)*)? '>';

parameterTuple : '(' (parameter (',' parameter)*)? ')';

parameter
    : namedItem
    | parameterTuple
    ;

characteristics : 'is' characteristicsExpression;

characteristicsExpression
    : 'Adj' # AdjointCharacteristic
    | 'Ctl' # ControlledCharacteristic
    | '(' characteristicsExpression ')' # CharacteristicsGroup
    | characteristicsExpression '*' characteristicsExpression # IntersectCharacteristics
    | characteristicsExpression '+' characteristicsExpression # UnionCharacteristics
    ;

callableBody
    : BraceLeft specialization* BraceRight # CallableSpecialization
    | scope # CallableScope
    ;

specialization : specializationName+ specializationGenerator;

specializationName
    : 'body'
    | 'adjoint'
    | 'controlled'
    ;

specializationGenerator
    : 'auto' ';' # AutoGenerator
    | 'self' ';' # SelfGenerator
    | 'invert' ';' # InvertGenerator
    | 'distribute' ';' # DistributeGenerator
    | 'intrinsic' ';' # IntrinsicGenerator
    | providedSpecialization # ProvidedGenerator
    ;

providedSpecialization : specializationParameterTuple? scope;

specializationParameterTuple : '(' (specializationParameter (',' specializationParameter)*)? ')';

specializationParameter
    : Identifier # SpecializationNamedParameter
    | '...' # SpecializationImplicitParameter
    ;

// Type

type
    : '_' # MissingType
    | TypeParameter # TypeParameter
    | 'BigInt' # BigIntType
    | 'Bool' # BoolType
    | 'Double' # DoubleType
    | 'Int' # IntType
    | 'Pauli' # PauliType
    | 'Qubit' # QubitType
    | 'Range' # RangeType
    | 'Result' # ResultType
    | 'String' # StringType
    | 'Unit' # UnitType
    | qualifiedName # UserDefinedType
    | '(' (type (',' type)* ','?)? ')' # TupleType
    | '(' arrowType characteristics? ')' # CallableType
    | type '[' ']' # ArrayType
    ;

arrowType
    : '(' type ('->' | '=>') type ')'
    | type ('->' | '=>') type
    ;

// Statement

statement
    : expression ';' # ExpressionStatement
    | 'return' expression ';' # Return
    | 'fail' expression ';' # Fail
    | 'let' symbolBinding '=' expression ';' # Let
    | 'mutable' symbolBinding '=' expression ';' # Mutable
    | 'set' symbolBinding '=' expression ';' # Set
    | 'set' Identifier updateOperator expression ';' # SetUpdate
    | 'set' Identifier 'w/=' expression '<-' expression ';' # SetWith
    | 'if' '(' expression ')' scope # If
    | 'elif' '(' expression ')' scope # Elif
    | 'else' scope # Else
    | 'for' '(' symbolBinding 'in' expression ')' scope # For
    | 'while' '(' expression ')' scope # While
    | 'repeat' scope # Repeat
    | 'until' '(' expression ')' (';' | 'fixup' scope) # UntilFixup
    | 'within' scope # Within
    | 'apply' scope # Apply
    | 'using' '(' symbolBinding '=' qubitInitializer ')' scope # Using
    | 'borrowing' '(' symbolBinding '=' qubitInitializer ')' scope # Borrowing
    ;

scope : BraceLeft statement* BraceRight;

symbolBinding
    : '_' # Discard
    | Identifier # Symbol
    | '(' (symbolBinding (',' symbolBinding)* ','?)? ')' # SymbolTuple
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

qubitInitializer
    : 'Qubit' '(' ')' # Qubit
    | 'Qubit' '[' expression ']' # QubitArray
    | '(' (qubitInitializer (',' qubitInitializer)* ','?)? ')' # QubitTuple
    ;

// Expression

expression
    : '_' # MissingExpression
    | qualifiedName ('<' (type (',' type)* ','?)? '>')? # Identifier
    | IntegerLiteral # Integer
    | BigIntegerLiteral # BigInteger
    | DoubleLiteral # Double
    | DoubleQuote stringContent* StringDoubleQuote # String
    | DollarQuote interpStringContent* InterpDoubleQuote # InterpolatedString
    | boolLiteral # Bool
    | resultLiteral # Result
    | pauliLiteral # Pauli
    | '(' (expression (',' expression)* ','?)? ')' # Tuple
    | '[' (expression (',' expression)* ','?)? ']' # Array
    | 'new' type '[' expression ']' # NewArray
    | expression ('::' Identifier | '[' expression ']') # ItemAccess
    | expression '!' # Unwrap
    | <assoc=right> 'Controlled' expression # ControlledFunctor
    | <assoc=right> 'Adjoint' expression # AdjointFunctor
    | expression '(' (expression (',' expression)* ','?)? ')' # Call
    | <assoc=right> ('-' | 'not' | '~~~') expression # Negate
    | <assoc=right> expression '^' expression # Power
    | expression ('*' | '/' | '%') expression # MultiplyDivideModulo
    | expression ('+' | '-') expression # AddSubtract
    | expression ('>>>' | '<<<') expression # Shift
    | expression ('>' | '<' | '>=' | '<=') expression # GreaterLess
    | expression ('==' | '!=') expression # Equal
    | expression '&&&' expression # BitwiseAnd
    | expression '^^^' expression # BitwiseXor
    | expression '|||' expression # BitwiseOr
    | expression 'and' expression # And
    | expression 'or' expression # Or
    | <assoc=right> expression '?' expression '|' expression # Conditional
    | expression '..' expression # Range
    | expression '...' # RightOpenRange
    | '...' expression # LeftOpenRange
    | '...' # OpenRange
    | expression 'w/' expression '<-' expression # With
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
    : StringEscape # StringEscape
    | StringText # StringText
    ;

interpStringContent
    : InterpStringEscape # InterpStringEscape
    | InterpBraceLeft expression BraceRight # InterpStringExpression
    | InterpStringText # InterpStringText
    ;
