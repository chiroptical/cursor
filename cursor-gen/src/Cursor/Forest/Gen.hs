{-# OPTIONS_GHC -fno-warn-orphans #-}

module Cursor.Forest.Gen
  (
  )
where

import Cursor.Forest
import Cursor.List.NonEmpty.Gen ()
import Cursor.Tree.Gen ()
import Data.GenValidity
import Data.GenValidity.Containers ()

instance (GenUnchecked a, GenUnchecked b) => GenUnchecked (ForestCursor a b) where
  genUnchecked = ForestCursor <$> genUnchecked
  shrinkUnchecked (ForestCursor ne) = ForestCursor <$> shrinkUnchecked ne

instance (GenValid a, GenValid b) => GenValid (ForestCursor a b) where
  genValid = ForestCursor <$> genValid
  shrinkValid (ForestCursor ne) = ForestCursor <$> shrinkValid ne
