{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE FlexibleInstances #-}

module Papa.Base.Implement.Data.Bool(
  GetBool(..)
, IsBool(..)
, true
, false
, if'
, ifB
, (?.)
, (?<>)
, (?<*>)
, (?@)
, (!?.)
, (!?<>)
, (!?<*>)
, (!?@)
) where

import Control.Applicative(Applicative(pure), Const)
import Control.Category(Category(id, (.)))
import Control.Lens(Iso', Identity, Optic', Profunctor, Contravariant, Getter, (^.), from, view, iso, _Wrapped, to)
import Data.Bool(Bool(False, True), bool)
import Data.Eq(Eq((==)))
import Data.Functor(Functor)
import Data.Functor.Bind(Bind((>>-)))
import Data.Maybe(maybe, Maybe(Nothing, Just))
import Data.Monoid(Monoid(mempty), First(First), Last(Last), Dual, All, Any, Sum, Product)
import Prelude(Double, Float, Word, Int, Integer, Num)

class GetBool a where
  _GetBool ::
    Getter a Bool

instance GetBool Bool where
  _GetBool =
    id

instance GetBool Any where
  _GetBool =
    _Wrapped

instance GetBool All where
  _GetBool =
    _Wrapped

instance GetBool (Dual Bool) where
  _GetBool =
    _Wrapped

instance GetBool (First ()) where
  _GetBool =
    to (\(First x) -> maybe False (\() -> True) x)

instance GetBool (Last ()) where
  _GetBool =
    to (\(Last x) -> maybe False (\() -> True) x)

-- not exported
cprogrammer :: 
  (Contravariant f, Profunctor p, Num a, Functor f, Eq a) =>
  Optic' p f a Bool
cprogrammer = 
  to (== 0)

instance GetBool Int where
  _GetBool =
    cprogrammer

instance GetBool Integer where
  _GetBool =
    cprogrammer

instance GetBool Word where
  _GetBool =
    cprogrammer

instance (Eq a, Num a) => GetBool (Identity a) where
  _GetBool =
    cprogrammer

instance (Eq a, Num a) => GetBool (Const a b) where
  _GetBool =
    cprogrammer

instance (Eq a, Num a) => GetBool (Sum a) where
  _GetBool =
    cprogrammer

instance GetBool Float where
  _GetBool =
    cprogrammer

instance GetBool Double where
  _GetBool =
    cprogrammer

class GetBool a => IsBool a where
  _Bool ::
    Iso' a Bool

instance IsBool Bool where
  _Bool =
    id

instance IsBool Any where
  _Bool =
    _Wrapped

instance IsBool All where
  _Bool =
    _Wrapped

instance IsBool (Dual Bool) where
  _Bool =
    _Wrapped

instance IsBool (First ()) where
  _Bool =
    iso
      (view _GetBool)
      (First . bool Nothing (Just ()))

instance IsBool (Last ()) where
  _Bool =
    iso
      (view _GetBool)
      (Last . bool Nothing (Just ()))

true ::
  IsBool a =>
  a
true =
  True ^. from _Bool
  
false ::
  IsBool a =>
  a
false =
  False ^. from _Bool

if' ::
  GetBool a =>
  x
  -> x
  -> a
  -> x
if' f t a =
  if a ^. _GetBool then t else f

ifB ::
  (GetBool a, Bind f) =>
  f x
  -> f x
  -> f a
  -> f x
ifB f t a =
  a >>- if' f t

(?.) ::
  (Category c, IsBool a) =>
  c x x
  -> a
  -> c x x
(?.) =
  if' id

(?<>) ::
  (Monoid x, IsBool a) =>
  x
  -> a
  -> x
(?<>) =
  if' mempty

(?<*>) ::
  (Applicative f, GetBool a) => 
  (x -> f x)
  -> a
  -> x
  -> f x
(?<*>) =
  if' pure

(?@) ::
  (Applicative f, GetBool a) =>
  f ()
  -> a
  -> f ()
(?@) =
  if' (pure ())

(!?.) ::
  (Category c, IsBool a) =>
  c x x
  -> a
  -> c x x
(!?.) =
  (`if'` id)

(!?<>) ::
  (Monoid x, IsBool a) =>
  x
  -> a
  -> x
(!?<>) =
  (`if'` mempty)

(!?<*>) ::
  (Applicative f, GetBool a) => 
  (x -> f x)
  -> a
  -> x
  -> f x
(!?<*>) =
  (`if'` pure)

(!?@) ::
  (Applicative f, GetBool a) =>
  f ()
  -> a
  -> f ()
(!?@) =
  (`if'` (pure ()))
