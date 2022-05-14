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

    // Types

    pub enum Type {
        case PrimType(PrimType),
        case RefType(RefType)
    }

    pub enum RefType {
        case ClassRefType(ClassType),    
        case ArrayType(Type)
    }

    pub enum ClassType {
        case ClassType(List[(Identifier, List[TypeArgument])])
    }

    pub enum TypeArgument {
        case Wildcard(Option[WildcardBound]),
        case ActualType(RefType)
    }

    pub enum TypeDeclSpecifier {
        case TypeDeclSpecifier(ClassType),
        case TypeDeclSpecifierWithDiamond(ClassType, Identifier, Diamond)
        case TypeDeclSpecifierUnqualifiedWithDiamond(Identifier, Diamond)
    }

    pub enum Diamond { 
        case Diamond
    }
  
    pub enum WildcardBound {
        case ExtendsBound(RefType)
        case SuperBound(RefType)
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

    pub enum TypeParam { 
        case TypeParam(Identifier, List[RefType])
    }


    /// Names

    pub enum Identifier {
        case Identifier(String)
    }

    pub enum Name { 
        case Name(List[Identifier])
    }

    // Literals

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

    // Operators 

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
        case EqualA
        case MultA 
        case DivA 
        case RemA
        case AddA
        case SubA
        case LShiftA
        case RShiftA
        case RRShiftA
        case LogAndA 
        case LogXorA 
        case LogOrA
    }

    
    /// Packages

    pub enum CompilationUnit {
        case CompilationUnit(Option[PackageDecl], List[ImportDecl], List[TypeDecl])
    }

    pub enum PackageDecl { 
        case PackageDecl(Name)
    }

    type alias ImportDecl = { isStatic :: Bool, name :: Name, importAll :: Bool }

    /// Declarations

    pub enum TypeDecl {
        case ClassTypeDecl(ClassDecl)
        case InterfaceTypeDecl(InterfaceDecl)
    }

    pub enum ClassDecl {
        case ClassDeclTODO
    }

    pub enum ClassBody {
        case ClassBody(List[Decl])
    }

    pub enum EnumBody {
        case EnumBody(List[EnumConstant], List[Decl])
    }

    pub enum EnumConstant { 
        case EnumConstant(Identifier, List[Argument], Option[ClassBody])
    }

    pub enum InterfaceDecl {
        case InterfaceDecl(InterfaceKind, List[Modifier], Identifier, List[TypeParam], List[RefType], InterfaceBody)
    }

    pub enum InterfaceKind {
        case InterfaceNormal,
        case InterfaceAnnotation
    }

    pub enum InterfaceBody {
        case InterfaceBody(List[MemberDecl])
    }

    pub enum Decl {
        case MemberDecl(MemberDecl)
        case InitDecl(Bool, Block)
    }

    pub enum MemberDecl {
        case FieldDecl(List[Modifier], Type, List[VarDecl])
        case MethodDecl(List[Modifier], List[TypeParam], Option[Type], Identifier, List[FormalParam], List[ExceptionType], Option[Exp], MethodBody)
        case ConstructorDecl(List[Modifier], List[TypeParam], Identifier, List[FormalParam], List[ExceptionType], ConstructorBody)
        case MemberClassDecl(ClassDecl),
        case MemberInterfaceDecl(InterfaceDecl)
    }

    pub enum ExceptionType {
        case ExceptionTypeTODO
    }
    
    pub enum VarDecl {
        case VarDecl(VarDeclId, Option[VarInit])
    }

    pub enum VarDeclId {
        case VarId(Identifier)
        case VarDeclArray(VarDeclId)
    }

    pub enum VarInit {
        case InitExp(Exp)
        case InitArray(ArrayInit)
    }

    pub enum FormalParam { 
        case FormalParam(List[Modifier], Type, Bool, VarDeclId)
    }

    pub enum MethodBody {
        case MethodBody(Option[Block])
    }

    pub enum ConstructorBody {
        case ConstructorBody(Option[ExplConstrInv], List[BlockStmt])
    }

    pub enum ExplConstrInv {
        case ThisInvoke(Option[RefType], Option[Argument])
        case SuperInvoke(Option[RefType], Option[Argument])
        case PrimarySuperInvoke(Exp, Option[RefType], Option[Argument])
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


    // Statements

    pub enum Block {
        case Block(List[BlockStmt])
    }

    pub enum BlockStmt {
        case BlockStmtTODO
    }

    type alias Argument = Exp

    pub enum Exp {
        case Lit(Literal)
        case This
        case ThisClass(Name)
        case InstanceCreation(List[TypeArgument], TypeDeclSpecifier, List[Argument],  Option[ClassBody])
        case ExpName(Name)
        case PostIncrement(Exp)
        case PostDecrement(Exp)
        case PreIncrement(Exp)
        case PreDecrement(Exp)
        case PrePlus(Exp)
        case PreMinus(Exp)
        case PreBitwiseComp(Exp)
        case PreLogicalComp(Exp)
        case BinOp(Exp, BinOp, Exp)
        case Cond(Exp, Exp, Exp),
        case Assign(AssignmentLhs, AssignOp, Exp)
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