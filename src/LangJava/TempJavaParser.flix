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

namespace LangJava/TempJavaParser {

    pub def parseExpr1(): Unit & Impure = 
        import new com.github.javaparser.JavaParser(): ##com.github.javaparser.JavaParser & Impure as newJavaParser;
        import com.github.javaparser.JavaParser.parseExpression(String): ##com.github.javaparser.ParseResult & Impure;
        import com.github.javaparser.ParseResult.getResult(): ##java.util.Optional & Impure;
        let parser = newJavaParser();
        let jopt = parseExpression(parser, "2 + 4") |> getResult;
        match unmarshalOptional(o -> o as ##com.github.javaparser.ast.expr.Expression, jopt) {
            case Some(expr) => println("Answer: " + Object.toString(expr))
            case None       => println("parse failure")
        }

    pub def parseExpr2(): Unit & Impure = 
        match Result.flatMap(LangJava/UnmarshalMonad.runUnmarshalMonad(LangJava/Unmarshal.unmarshalExpression()), sampleExpr("2 + 4")) {
            case Ok(ans) => println("success: ${ans}")
            case Err(msg) => println("parse failure: ${msg}")
        }

    pub def sampleExpr(s: String): Result[##com.github.javaparser.ast.expr.Expression, String] = 
        import new com.github.javaparser.JavaParser(): ##com.github.javaparser.JavaParser & Pure as newJavaParser;
        import com.github.javaparser.JavaParser.parseExpression(String): ##com.github.javaparser.ParseResult & Pure;
        let parser = newJavaParser();
        parseExpression(parser, s) |> unmarshalParseResult(o -> o as ##com.github.javaparser.ast.expr.Expression)


    pub def unmarshalParseResult(downcast: ##java.lang.Object -> a & ef, r: ##com.github.javaparser.ParseResult): Result[a, String] & ef = 
        import com.github.javaparser.ParseResult.isSuccessful(): Bool & Pure;
        import com.github.javaparser.ParseResult.getResult(): ##java.util.Optional & Pure;
        if (isSuccessful(r))
            getResult(r) |> unmarshalOptional(downcast) |> (x -> Option.toOk(x, "Error - empty parse"))
        else 
            Err("Problems to decode...")


    pub def unmarshalOptional(downcast: ##java.lang.Object -> a & ef, opt: ##java.util.Optional): Option[a] & ef = 
        import java.util.Optional.isPresent(): Bool & Pure;
        import java.util.Optional.get(): ##java.lang.Object & Pure;
        if (isPresent(opt))
            get(opt) |> downcast |> Some
        else 
            None

    pub def marshalOptional(upcast: a -> ##java.lang.Object & ef, o: Option[a]): ##java.util.Optional & ef =
        import static java.util.Optional.of(##java.lang.Object): ##java.util.Optional & Pure;
        import static java.util.Optional.empty(): ##java.util.Optional & Pure;
        match o { 
            case Some(a) => of(upcast(a))
            case None    => empty()
        }
}
