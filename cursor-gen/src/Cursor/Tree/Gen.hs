{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE RecordWildCards #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Cursor.Tree.Gen
    (
    ) where

import Data.Maybe

import Data.GenValidity
import Data.GenValidity.Containers ()

import Test.QuickCheck

import Cursor.Tree

instance GenUnchecked TreeCursorSelection

instance GenValid TreeCursorSelection where
    genValid = genValidStructurally
    shrinkValid = shrinkValidStructurally

instance GenUnchecked a => GenUnchecked (SwapResult a)

instance GenValid a => GenValid (SwapResult a) where
    genValid = genValidStructurally
    shrinkValid = shrinkValidStructurally

instance GenUnchecked a => GenUnchecked (PromoteElemResult a)

instance GenValid a => GenValid (PromoteElemResult a) where
    genValid = genValidStructurally
    shrinkValid = shrinkValidStructurally

instance GenUnchecked a => GenUnchecked (PromoteResult a)

instance GenValid a => GenValid (PromoteResult a) where
    genValid = genValidStructurally
    shrinkValid = shrinkValidStructurally

instance GenUnchecked a => GenUnchecked (DemoteResult a)

instance GenValid a => GenValid (DemoteResult a) where
    genValid = genValidStructurally
    shrinkValid = shrinkValidStructurally

instance GenUnchecked a => GenUnchecked (CTree a) where
    genUnchecked =
        sized $ \n -> do
            (a, b) <- genSplit n
            val <- resize a genUnchecked
            for <- resize b genUnchecked
            pure $ CNode val for

instance GenValid a => GenValid (CTree a) where
    genValid =
        sized $ \n -> do
            (a, b) <- genSplit n
            val <- resize a genValid
            for <- resize b genValid
            pure $ CNode val for
    shrinkValid = shrinkValidStructurally

instance GenUnchecked a => GenUnchecked (CForest a) where
    genUnchecked =
        sized $ \n ->
            case n of
                0 -> pure EmptyCForest
                _ ->
                    oneof
                        [ ClosedForest <$> resize n genUnchecked
                        , OpenForest <$> resize n genUnchecked
                        ]
    shrinkUnchecked EmptyCForest = []
    shrinkUnchecked cf = EmptyCForest : genericShrinkUnchecked cf

instance GenValid a => GenValid (CForest a) where
    genValid =
        sized $ \n ->
            case n of
                0 -> pure EmptyCForest
                _ ->
                    oneof
                        [ ClosedForest <$> resize n genValid
                        , OpenForest <$> resize n genValid
                        ]
    shrinkValid EmptyCForest = []
    shrinkValid cf = EmptyCForest : shrinkValidStructurally cf

instance (GenUnchecked a, GenUnchecked b) => GenUnchecked (TreeCursor a b) where
    genUnchecked =
        sized $ \n -> do
            (a, b, c, d) <- genSplit4 n
            treeAbove <- resize (a + b) genUnchecked
            treeCurrent <- resize c genUnchecked
            treeBelow <- resize d genUnchecked
            pure TreeCursor {..}
    shrinkUnchecked tc =
        let opts =
                catMaybes
                    [ do ta <- treeAbove tc
                         pure $ tc {treeAbove = treeAboveAbove ta}
                    ]
        in opts ++ genericShrinkUnchecked tc

instance (GenValid a, GenValid b) => GenValid (TreeCursor a b) where
    genValid =
        sized $ \n -> do
            (a, b, c, d) <- genSplit4 n
            treeAbove <- resize (a + b) genValid
            treeCurrent <- resize c genValid
            treeBelow <- resize d genValid
            pure TreeCursor {..}

instance GenUnchecked b => GenUnchecked (TreeAbove b) where
    genUnchecked =
        sized $ \n -> do
            (a, b, c, d) <- genSplit4 n
            treeAboveLefts <- resize a genUnchecked
            treeAboveAbove <- resize b genUnchecked
            treeAboveNode <- resize c genUnchecked
            treeAboveRights <- resize d genUnchecked
            pure TreeAbove {..}

instance GenValid b => GenValid (TreeAbove b) where
    genValid =
        sized $ \n -> do
            (a, b, c, d) <- genSplit4 n
            treeAboveLefts <- resize a genValid
            treeAboveAbove <- resize b genValid
            treeAboveNode <- resize c genValid
            treeAboveRights <- resize d genValid
            pure TreeAbove {..}
