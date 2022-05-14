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

    use Applicative.{point};

    use LangJava/UnmarshalMonad.UnmarshalMonad;
    use LangJava/UnmarshalMonad.{flatMap, throwError};


    pub def unmarshalExpression(e: ##com.github.javaparser.ast.expr.Expression): UnmarshalMonad[ka, String] = 
        match getClassName(e as ##java.lang.Object) {
            case "com.github.javaparser.ast.expr.BinaryExpr" => point("BinExpr(..)")
            case clsname                                     => throwError("Unrecognized Expression type: ${clsname}")
        }
        



    pub def getClassName(o: ##java.lang.Object): String = 
        import java.lang.Object.getClass(): ##java.lang.Class & Pure;
        import java.lang.Class.getName(): String & Pure;
        getClass(o) |> getName

}
