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

namespace LangJava/Syntax {

    pub enum Identifier {
        case Identifier(String)
    }

    pub enum Name { 
        case Name(List[Identifier])
    }

    pub enum Literal {
        case Byte(Int8),
        case Short(Int16),
        case Int(Int32),
        case Long(Int64),
        case Float(Float32),
        case Double(Float64),
        case Boolean(Bool),
        case Char(Char),
        case Str(String),
        case Null
    }

    pub enum BinOp {
        case Mult,
        case Div, 
        case Rem, 
        case Add, 
        case Sub, 
        case LShift,
        case RShift, 
        case RRShift,
        case LThan,
        case GThan,
        case LThanEq,
        case GThanEq,
        case Equal,
        case NotEq,
        case LogAnd,
        case LogXor,
        case LogOr,
        case CondAnd,
        case CondOr
    }

    pub enum AssignOp {
        case EqualA, 
        case MultA, 
        case DivA, 
        case RemA,
        case AddA,
        case SubA,
        case LShiftA,
        case RShiftA,
        case RRShiftA,
        case LogAndA, 
        case LogXorA, 
        case LogOrA
    }

    pub enum PrimType {
        case BooleanTy,
        case ByteTy,
        case ShortTy
        case IntTy,
        case LongTy,
        case CharTy,
        case FloatTy,
        case DoubleTy
    }

    
    pub enum VarInit {
        case InitExp(Exp)
        case InitArray(ArrayInit)
    }

    pub enum Modifier {
        case Public,
        case Private,
        case Protected,
        case Abstract,
        case Final,
        case Static,
        case StrictFP,
        case Transient,
        case Volatile,
        case Native,
        case Annotation(Annotation),
        case Synchronized
    }

    pub enum Annotation {
        case NormalAnnotation(Name, List[(Identifier, ElementValue)]),
        case SingleElementAnnotation(Name, ElementValue),
        case MarkerAnnotation(Name)
    }

    pub enum ElementValue {
        case ElementValueValue(VarInit),
        case ElementValueAnno(Annotation)
    }

    pub enum Exp {
        case Lit(Literal),
        case This,
        case ThisClass(Name),
        case ExpName(Name),
        case PostIncrement(Exp),
        case PostDecrement(Exp),
        case PreIncrement(Exp),
        case PreDecrement(Exp),
        case PrePlus(Exp),
        case PreMinus(Exp),
        case PreBitwiseComp(Exp),
        case PreLogicalComp(Exp),
        case BinOp(Exp, BinOp, Exp),
        case Cond(Exp, Exp, Exp),
        case Assign(AssignmentLhs, AssignOp, Exp),
        case MethodRef(Name, Identifier)        
    }

    pub enum AssignmentLhs {
        case NameLhs(Name),
        case FieldLhs(FieldAccess),
        case ArrayLhs(ArrayIndex)
    }

    pub enum ArrayIndex { 
        case ArrayIndex(Exp, List[Exp])
    }

    pub enum FieldAccess {
        case PrimaryFieldAccess(Exp, Identifier),
        case SuperFieldAccess(Identifier),
        case ClassFieldAccess(Name, Identifier)
    }


    pub enum ArrayInit {
        case ArrayInit(List[VarInit])
    }

}