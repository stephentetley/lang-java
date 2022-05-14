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

namespace LangJava/UnmarshalMonad {


    ///
    /// Codensity(Error) monad
    /// 
    /// `ka` is the continuation answer type
    ///
    pub opaque type UnmarshalMonad[ka, node, a] = node -> (a -> node -> Result[ka, String] & Impure) -> Result[ka, String] & Impure


    instance Functor[UnmarshalMonad[ka, node]] {
        pub def map(f: a -> b & ef, ma: UnmarshalMonad[ka, node, a]): UnmarshalMonad[ka, node, b] & ef =
            UnmarshalMonad((r, k) ->
                apply1(ma, r, (a, r1) -> k(f(a) as & Impure, r1))
            ) as & ef
    }

    instance Applicative[UnmarshalMonad[ka, node]] {
        pub def point(x: a): UnmarshalMonad[ka, node, a] = 
            UnmarshalMonad((r, k) -> k(x, r))

        pub def ap(mf: UnmarshalMonad[ka, node, a -> b & ef], ma: UnmarshalMonad[ka, node, a]): UnmarshalMonad[ka, node, b] & ef =
            UnmarshalMonad((r, k) ->
                apply1(mf, r, (f, r1) ->
                    apply1(ma, r1, (a, r2) ->
                        k(f(a) as & Impure, r2)))
            ) as & ef
    }

    instance Monad[UnmarshalMonad[ka, node]] {
        pub def flatMap(f: a -> UnmarshalMonad[ka, node, b] & ef, ma: UnmarshalMonad[ka, node, a]): UnmarshalMonad[ka, node, b] & ef =
            flatMap(f, ma)
    }

    ///
    /// Helper function for the implementation of `map` and `ap` etc.
    ///
    def apply1(ma: UnmarshalMonad[ka, node, a], r: node, k: a -> node -> Result[ka, String] & Impure): Result[ka, String] & Impure =
        let UnmarshalMonad(ma1) = ma;
        ma1(r, k)

    pub def flatMap(f: a -> UnmarshalMonad[ka, node, b] & ef, ma: UnmarshalMonad[ka, node, a]): UnmarshalMonad[ka, node, b] & ef =
        UnmarshalMonad((r, k) ->
            apply1(ma, r, (a, r1) ->
                apply1(f(a) as & Impure, r1, (b, r2) ->
                    k(b, r2)))
        ) as & ef

    pub def throwError(msg: String): UnmarshalMonad[ka, node, a] = 
        UnmarshalMonad((_, _) -> Err(msg) as & Impure)

    ///
    /// Returns the result (new state and answer) of applying `ma` to the initial state `st`.
    ///
    pub def runUnmarshalMonad(ma: UnmarshalMonad[a, node, a], r: node): Result[a, String] & Impure =
        let UnmarshalMonad(f) = ma;
        let cont = (a, _) -> Ok(a) as & Impure;
        f(r, cont)


    ///
    /// Always fails
    /// 
    pub def zero(): UnmarshalMonad[ka, node, a] =
        UnmarshalMonad((_, _) -> Err("zero") as & Impure)

/*
    pub def alt(ma: UnmarshalMonad[ka, node, a], mb: UnmarshalMonad[ka, node, a]): UnmarshalMonad[ka, node, a] =
        UnmarshalMonad((r, k) ->
            apply1(ma, r, a -> match k(a) {
                case Err(_)  => apply1(mb, k)
                case Ok(ans) => Ok(ans)
            })
        )
*/

    pub def withCast(f: node -> node1 & ef, ma: UnmarshalMonad[ka, node1, String]): UnmarshalMonad[ka, node, String] & ef = 
        UnmarshalMonad((r, k) ->
            try {
                let r1 = f(r) as & Impure;
                apply1(ma, r1, (ans, _) -> k(ans, r))
            } catch {
                case ex: ##java.lang.Exception => Err("Cast failed: " + FlixSandbox/Marshal.unmarshalExceptionMessage(ex))
            }
        ) as & ef

    pub def liftJavaPrim(f: node -> a & ef): UnmarshalMonad[ka, node, a] = 
        UnmarshalMonad((r, k) ->
            try {
                let ans = f(r);
                k(ans, r)
            } catch {
                case ex: ##java.lang.Exception => Err(FlixSandbox/Marshal.unmarshalExceptionMessage(ex))
            }            
        )

}
