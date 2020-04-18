/*
 * Copyright 2020 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

use Pretty.Doc;
use Pretty.{text, character, squotes, dquotes, hcat, punctuate, dot, beside, besideSpace, parens};

use LangJava/Syntax.Annotation;
use LangJava/Syntax.AssignOp;
use LangJava/Syntax.AssignOp.{EqualA, MultA, DivA, RemA, AddA, SubA, LShiftA, RShiftA, RRShiftA, LogAndA, LogXorA, LogOrA};
use LangJava/Syntax.BinOp;
use LangJava/Syntax.BinOp.{Mult, Div, Rem, Add, Sub, LShift, RShift, RRShift, LThan, GThan, LThanEq, GThanEq,
                            Equal, NotEq, LogAnd, LogXor, LogOr, CondAnd, CondOr};
use LangJava/Syntax.Exp;
use LangJava/Syntax.Exp.{Lit, This, ThisClass, ExpName, PostIncrement, PostDecrement, PreIncrement, PreDecrement,
                            PrePlus, PreMinus, PreBitwiseComp, PreLogicalComp, Cond};
use LangJava/Syntax.Identifier;
use LangJava/Syntax.Identifier.{Identifier};
use LangJava/Syntax.Literal;
use LangJava/Syntax.Literal.{Byte, Short, Int, Long, Float, Double, Boolean, Char, Str, Null};
use LangJava/Syntax.Modifier;
use LangJava/Syntax.Modifier.{Public, Private, Protected, Abstract, Final, Static, StrictFP, 
                                Transient, Volatile, Native, Annotation, Synchronized};
use LangJava/Syntax.Name;
use LangJava/Syntax.Name.{Name};
use LangJava/Syntax.PrimType;
use LangJava/Syntax.PrimType.{BooleanTy, ByteTy, ShortTy, IntTy, LongTy, CharTy, FloatTy, DoubleTy};

namespace LangJava/Pretty {

    def parenPrec(interited: Int32, current: Int32, doc: Doc): Doc = match interited {
        case inh if (inh <= 0)      => doc
        case inh if (inh < current) => parens(doc)
        case _                      => doc
    }

    /// Redefine opertors from flix-pprint.
    def <>(a:Doc, b:Doc): Doc = beside(a,b)
    def <<>>(x: Doc, y:Doc): Doc = besideSpace(x,y)

    pub def ppIdentifier(ident: Identifier): Doc = match ident {
        case Identifier(s) => text(s)
    }
    
    pub def ppName(name: Name): Doc = match name {
        case Name(xs) => hcat(punctuate(dot(), List.map(ppIdentifier, xs)))
    }

    pub def ppLiteral(lit: Literal): Doc = match lit {
        case Byte(i)        => text(Int8.toString(i))
        case Short(i)       => text(Int16.toString(i))
        case Int(i)         => text(Int32.toString(i))
        case Long(i)        => text(Int64.toString(i) + "L")
        case Float(f)       => text(Float32.toString(f) + "f")
        case Double(d)      => text(Float64.toString(d) + "d")
        case Boolean(b)     => if (b) text("true") else text("false")
        case Char(c)        => squotes(character(c))     /// TODO - escaping etc.
        case Str(s)         => dquotes(text(s))     /// TODO - escaping etc.
        case Null           => text("null")
    }


    pub def binOpPrec (op: BinOp): Int32 = match op {
        case Mult       => 3
        case Div        => 3
        case Rem        => 3
        case Add        => 4
        case Sub        => 4
        case LShift     => 5
        case RShift     => 5
        case RRShift    => 5
        case LThan      => 6
        case GThan      => 6
        case LThanEq    => 6
        case GThanEq    => 6
        case Equal      => 7
        case NotEq      => 7
        case LogAnd     => 8
        case LogXor     => 9
        case LogOr      => 10
        case CondAnd    => 11
        case CondOr     => 12
    }

    pub def ppBinOp(op: BinOp): Doc = text <| match op {
        case Mult       => "*"
        case Div        => "/"
        case Rem        => "%"
        case Add        => "+"
        case Sub        => "-"
        case LShift     => "<<"
        case RShift     => ">>"
        case RRShift    => ">>>"
        case LThan      => "<"
        case GThan      => ">"
        case LThanEq    => "<="
        case GThanEq    => ">="
        case Equal      => "=="
        case NotEq      => "!="
        case LogAnd     => "&"
        case LogOr      => "|"
        case LogXor     => "^"
        case CondAnd    => "&&"
        case CondOr     => "||"
    }

    pub def ppAssignOp(op: AssignOp): Doc = text <| match op {
        case EqualA     => "="
        case MultA      => "*="
        case DivA       => "*="
        case RemA       => "*="
        case AddA       => "+="
        case SubA       => "-="
        case LShiftA    => "<<="
        case RShiftA    => ">>="
        case RRShiftA   => ">>>="
        case LogAndA    => "&="
        case LogXorA    => "^=" 
        case LogOrA     => "|="
    }

    pub def ppPrimType(ty: PrimType): Doc = match ty {
        case BooleanTy  => text("boolean")
        case ByteTy     => text("byte")
        case ShortTy    => text("short")
        case IntTy      => text("int")
        case LongTy     => text("long")
        case CharTy     => text("char")
        case FloatTy    => text("float")
        case DoubleTy   => text("double")
    }

    pub def ppModifier(mod: Modifier): Doc = match mod {
        case Public         => text("public")
        case Private        => text("private")
        case Protected      => text("protected")
        case Abstract       => text("abstract")
        case Final          => text("final")
        case Static         => text("static")
        case StrictFP       => text("strictfp")
        case Transient      => text("transient")
        case Volatile       => text("volatile")
        case Native         => text("native")
        case Annotation(a)  => ppAnnotation(a)
        case Modifier.Synchronized   => text("synchronized")
    }

    pub def ppAnnotation(_ : Annotation): Doc = text("TODO")

    pub def ppExp(p: Int32, exprn: Exp): Doc = match exprn {
        case Lit(lit)                   => ppLiteral(lit)
        case This                       => text("this")
        case ThisClass(name)            => beside(ppName(name), text(".class"))
        case ExpName(name)              => ppName(name)
        case PostIncrement(exp)         => parenPrec(p, 1, ppExp(2, exp) <> text("++"))
        case PostDecrement(exp)         => parenPrec(p, 1, ppExp(2, exp) <> text("--"))
        case PreIncrement(exp)          => parenPrec(p, 1, text("++") <> ppExp(2, exp))
        case PreDecrement(exp)          => parenPrec(p, 1, text("--") <> ppExp(2, exp))
        case PrePlus(exp)               => parenPrec(p, 2, text("+") <> ppExp(2, exp))
        case PreMinus(exp)              => parenPrec(p, 2, text("+") <> ppExp(2, exp))
        case PreBitwiseComp(exp)        => parenPrec(p, 2, text("~") <> ppExp(2, exp))
        case PreLogicalComp(exp)        => parenPrec(p, 2, text("!") <> ppExp(2, exp))
        case Cond(c, t, e)  => {
            let condD = ppExp(13, c);
            let thenD = ppExp(13, t);
            let elseD = ppExp(13, e);
            parenPrec(p, 13, condD <<>> character('?') <<>> thenD <<>> character(':') <<>> elseD)
        }
    }
}
