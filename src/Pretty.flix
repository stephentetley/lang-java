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
use Pretty.{text, char, squotes, dquotes, hcat, hsep, punctuate, dot, comma, beside, besideSpace, 
            parens, brackets, braces};

use LangJava/Syntax.Annotation;
use LangJava/Syntax.Annotation.{NormalAnnotation, SingleElementAnnotation, MarkerAnnotation};
use LangJava/Syntax.ArrayIndex;
use LangJava/Syntax.ArrayIndex.{ArrayIndex};
use LangJava/Syntax.ArrayInit;
use LangJava/Syntax.ArrayInit.{ArrayInit};
use LangJava/Syntax.AssignOp;
use LangJava/Syntax.AssignOp.{EqualA, MultA, DivA, RemA, AddA, SubA, LShiftA, RShiftA, RRShiftA, LogAndA, LogXorA, LogOrA};
use LangJava/Syntax.AssignmentLhs;
use LangJava/Syntax.AssignmentLhs.{NameLhs, FieldLhs, ArrayLhs};
use LangJava/Syntax.BinOp;
use LangJava/Syntax.BinOp.{Mult, Div, Rem, Add, Sub, LShift, RShift, RRShift, LThan, GThan, LThanEq, GThanEq,
                            Equal, NotEq, LogAnd, LogXor, LogOr, CondAnd, CondOr};
use LangJava/Syntax.ElementValue;
use LangJava/Syntax.ElementValue.{ElementValueValue, ElementValueAnno};
use LangJava/Syntax.Exp;
use LangJava/Syntax.Exp.{Lit, This, ThisClass, ExpName, PostIncrement, PostDecrement, PreIncrement, PreDecrement,
                            PrePlus, PreMinus, PreBitwiseComp, PreLogicalComp, BinOp, Cond, Assign,
                            MethodRef};
use LangJava/Syntax.FieldAccess;
use LangJava/Syntax.FieldAccess.{PrimaryFieldAccess, SuperFieldAccess, ClassFieldAccess};
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
use LangJava/Syntax.VarInit;
use LangJava/Syntax.VarInit.{InitExp, InitArray};

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


    pub def ppVarInit(p: Int32, varinit: VarInit): Doc = match varinit {
        case InitExp(exp)               => ppExp(p, exp)
        case InitArray(iarr)            => { 
            let ArrayInit(vs) = iarr; 
            ppVarInits(p, vs) 
        }   
    }

    def ppVarInits(p: Int32, vs: List[VarInit]): Doc = 
        braces(hsep(punctuate(comma(), List.map(ppVarInit(p), vs))))

    pub def ppLiteral(lit: Literal): Doc = match lit {
        case Byte(i)        => text(Int8.toString(i))
        case Short(i)       => text(Int16.toString(i))
        case Int(i)         => text(Int32.toString(i))
        case Long(i)        => text(Int64.toString(i) + "L")
        case Float(f)       => text(Float32.toString(f) + "f")
        case Double(d)      => text(Float64.toString(d) + "d")
        case Boolean(b)     => if (b) text("true") else text("false")
        case Char(c)        => squotes(char(c))     /// TODO - escaping etc.
        case Str(s)         => dquotes(text(s))     /// TODO - escaping etc.
        case Null           => text("null")
    }


    pub def binOpPrecedence (op: BinOp): Int32 = match op {
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

    pub def ppModifier(p: Int32, mod: Modifier): Doc = match mod {
        case Public             => text("public")
        case Private            => text("private")
        case Protected          => text("protected")
        case Abstract           => text("abstract")
        case Final              => text("final")
        case Static             => text("static")
        case StrictFP           => text("strictfp")
        case Transient          => text("transient")
        case Volatile           => text("volatile")
        case Native             => text("native")
        case Annotation(anno)   => ppAnnotation(p, anno)
        case Synchronized       => text("synchronized")
    }

    pub def ppAnnotation(p: Int32, anno : Annotation): Doc = match anno {
        case NormalAnnotation(name, eltvals)        => char('@') <>  ppName(name) <> parens(ppElementValueList(p, eltvals))
        case SingleElementAnnotation(name, eltval)  => char('@') <>  ppName(name) <> parens(ppElementValue(p, eltval))
        case MarkerAnnotation(name)                 => char('@') <>  ppName(name)

    }

    def ppElementValueList(p: Int32, vals: List[(Identifier, ElementValue)]): Doc =
        let step = match (n,v) -> ppIdentifier(n) <<>> char('=') <<>> ppElementValue(p, v);
        hsep(punctuate(comma(), List.map(step, vals)))

    pub def ppElementValue(p: Int32, ev: ElementValue): Doc = match ev {
        case ElementValueValue(varinit)         => ppVarInit(p, varinit)
        case ElementValueAnno(anno)             => ppAnnotation(p, anno)
    }

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
        case BinOp(e1, op, e2)          => {
            let prec = binOpPrecedence(op);
            parenPrec(p, prec, ppExp(prec, e1) <<>> ppBinOp(op) <<>> ppExp(prec, e2))
        }
        case Cond(c, t, e)  => {
            let condD = ppExp(13, c);
            let thenD = ppExp(13, t);
            let elseD = ppExp(13, e);
            parenPrec(p, 13, condD <<>> char('?') <<>> thenD <<>> char(':') <<>> elseD)
        }
        case Assign(lhs, op, e)         => 
            hsep(ppAssignmentLhs(p, lhs) :: ppAssignOp(op) :: ppExp(p, e) :: Nil)

        case MethodRef(name, id)        => ppName(name) <<>> text("::") <<>> ppIdentifier(id)
    }

    pub def ppAssignmentLhs(p: Int32, lhs: AssignmentLhs): Doc = match lhs { 
        case NameLhs(name)              => ppName(name)
        case FieldLhs(fac)              => ppFieldAccess(p, fac)
        case ArrayLhs(aix)              => ppArrayIndex(p, aix)
    }

    pub def ppArrayIndex(p: Int32, aix: ArrayIndex): Doc = match aix {
        case ArrayIndex(ref, es)        => ppExp(p, ref) <> hcat(List.map(x -> brackets(ppExp(p, x)), es))
    }

    pub def  ppFieldAccess(p: Int32, fac: FieldAccess): Doc = match fac {
        case PrimaryFieldAccess(exp, ident)     => ppExp(p, exp) <> char('.') <> ppIdentifier(ident)
        case SuperFieldAccess(ident)            => text("super.") <> ppIdentifier(ident)
        case ClassFieldAccess(name, ident)      => ppName(name) <> char('.') <> ppIdentifier(ident)
    }

}
