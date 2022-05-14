/*
 * Copyright 2022 Stephen Tetley
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

namespace LangJava/Unmarshal {

    use Functor.{map};
    use Applicative.{point};

    use LangJava/UnmarshalMonad.UnmarshalMonad;
    use LangJava/UnmarshalMonad.{flatMap, throwError, withCast, liftJavaPrim};


    /// TODO 
    /// for conciseness we might want to add "parser combinator" capabilities (alt) to 
    /// the UnmarshalMonad rather than use direct matching

    pub def unmarshalExpression(): UnmarshalMonad[ka, ##com.github.javaparser.ast.expr.Expression, String] = 
        binaryExpression()


        
    def binaryExpression(): UnmarshalMonad[ka, ##com.github.javaparser.ast.expr.Expression, String] = 
        import com.github.javaparser.ast.expr.BinaryExpr.getOperator(): ##com.github.javaparser.ast.expr.BinaryExpr$Operator & Pure;
        withCast(o -> o as ##com.github.javaparser.ast.expr.BinaryExpr, {
            let* rator = liftJavaPrim(getOperator) |> map(unmarshalBinaryExprOperator);
            point("BinExpr(${rator})")
        }) 

    def unmarshalBinaryExprOperator(o: ##com.github.javaparser.ast.expr.BinaryExpr$Operator): String = 
        import static get com.github.javaparser.ast.expr.BinaryExpr$Operator.AND: ##com.github.javaparser.ast.expr.BinaryExpr$Operator & Pure as get_AND;
        import static get com.github.javaparser.ast.expr.BinaryExpr$Operator.PLUS: ##com.github.javaparser.ast.expr.BinaryExpr$Operator & Pure as get_PLUS;
        match o {
            case x1 if equalsBinaryExprOperator(x1, get_AND())      => "AND"
            case x1 if equalsBinaryExprOperator(x1, get_PLUS())     => "PLUS"
            case _                                                  => bug!("Missing")
        }



    def equalsBinaryExprOperator(x: ##com.github.javaparser.ast.expr.BinaryExpr$Operator, y: ##com.github.javaparser.ast.expr.BinaryExpr$Operator): Bool =
        import java.lang.Enum.equals(##java.lang.Object): Bool & Pure;
        let x1 = x as ##java.lang.Enum;
        let y1 = y as ##java.lang.Object;
        equals(x1, y1)


    pub def getClassName(o: ##java.lang.Object): String = 
        import java.lang.Object.getClass(): ##java.lang.Class & Pure;
        import java.lang.Class.getName(): String & Pure;
        getClass(o) |> getName

}
