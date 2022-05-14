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
    pub opaque type UnmarshalMonad[ka, a] = (a -> Result[ka, String] & Impure) -> Result[ka, String] & Impure


    instance Functor[UnmarshalMonad[ka]] {
        pub def map(f: a -> b & ef, ma: UnmarshalMonad[ka, a]): UnmarshalMonad[ka, b] & ef =
            UnmarshalMonad(k ->
                apply1(ma, a-> k(f(a) as & Impure))
            ) as & ef
    }

    instance Applicative[UnmarshalMonad[ka]] {
        pub def point(x: a): UnmarshalMonad[ka, a] = 
            UnmarshalMonad(k -> k(x))

        pub def ap(mf: UnmarshalMonad[ka, a -> b & ef], ma: UnmarshalMonad[ka, a]): UnmarshalMonad[ka, b] & ef =
            UnmarshalMonad(k ->
                apply1(mf, f ->
                    apply1(ma, a ->
                        k(f(a) as & Impure)))
            ) as & ef
    }

    instance Monad[UnmarshalMonad[ka]] {
        pub def flatMap(f: a -> UnmarshalMonad[ka, b] & ef, ma: UnmarshalMonad[ka, a]): UnmarshalMonad[ka, b] & ef =
            flatMap(f, ma)
    }

    ///
    /// Helper function for the implementation of `map` and `ap` etc.
    ///
    def apply1(ma: UnmarshalMonad[ka, a], k: a -> Result[ka, String] & Impure): Result[ka, String] & Impure =
        let UnmarshalMonad(ma1) = ma;
        ma1(k)

    pub def flatMap(f: a -> UnmarshalMonad[ka, b] & ef, ma: UnmarshalMonad[ka, a]): UnmarshalMonad[ka, b] & ef =
        UnmarshalMonad(k ->
            apply1(ma, a ->
                apply1(f(a) as & Impure, b ->
                    k(b)))
        ) as & ef

    pub def throwError(msg: String): UnmarshalMonad[ka, a] = 
        UnmarshalMonad(_ -> Err(msg) as & Impure)

    ///
    /// Returns the result (new state and answer) of applying `ma` to the initial state `st`.
    ///
    pub def runUnmarshalMonad(ma: UnmarshalMonad[a, a]): Result[a, String] & Impure =
        let UnmarshalMonad(f) = ma;
        let cont = a -> Ok(a) as & Impure;
        f(cont)

}
