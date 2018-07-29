{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeFamilies #-}

module Cursor.Text
    ( TextCursor(..)
    , emptyTextCursor
    , makeTextCursor
    , makeTextCursorWithSelection
    , rebuildTextCursor
    , textCursorNull
    , textCursorLength
    , textCursorIndex
    , textCursorSelectPrev
    , textCursorSelectNext
    , textCursorSelectIndex
    , textCursorSelectStart
    , textCursorSelectEnd
    , textCursorPrevChar
    , textCursorNextChar
    , textCursorInsert
    , textCursorAppend
    , textCursorRemove
    , textCursorDelete
    , textCursorSplit
    , textCursorCombine
    ) where

import Data.Validity
import GHC.Generics (Generic)

import qualified Data.Text as T
import Data.Text (Text)

import Lens.Micro

import Cursor.List

-- | A cursor for single-line texts
newtype TextCursor = TextCursor
    { textCursorList :: ListCursor Char
    } deriving (Show, Eq, Generic)

instance Validity TextCursor

emptyTextCursor :: TextCursor
emptyTextCursor = TextCursor emptyListCursor

makeTextCursor :: Text -> TextCursor
makeTextCursor = makeTextCursorWithSelection 0

makeTextCursorWithSelection :: Int -> Text -> TextCursor
makeTextCursorWithSelection i =
    TextCursor . makeListCursorWithSelection i . T.unpack

rebuildTextCursor :: TextCursor -> Text
rebuildTextCursor = T.pack . rebuildListCursor . textCursorList

textCursorListCursorL ::
       Functor f
    => (ListCursor Char -> f (ListCursor Char))
    -> TextCursor
    -> f TextCursor
textCursorListCursorL = lens textCursorList (\tc lc -> tc {textCursorList = lc})

textCursorNull :: TextCursor -> Bool
textCursorNull = listCursorNull . textCursorList

textCursorLength :: TextCursor -> Int
textCursorLength = listCursorLength . textCursorList

textCursorIndex :: TextCursor -> Int
textCursorIndex = listCursorIndex . textCursorList

textCursorSelectPrev :: TextCursor -> Maybe TextCursor
textCursorSelectPrev = textCursorListCursorL listCursorSelectPrev

textCursorSelectNext :: TextCursor -> Maybe TextCursor
textCursorSelectNext = textCursorListCursorL listCursorSelectNext

textCursorSelectIndex :: Int -> TextCursor -> TextCursor
textCursorSelectIndex ix_ = textCursorListCursorL %~ listCursorSelectIndex ix_

textCursorSelectStart :: TextCursor -> TextCursor
textCursorSelectStart = textCursorListCursorL %~ listCursorSelectStart

textCursorSelectEnd :: TextCursor -> TextCursor
textCursorSelectEnd = textCursorListCursorL %~ listCursorSelectEnd

textCursorPrevChar :: TextCursor -> Maybe Char
textCursorPrevChar = listCursorPrevItem . textCursorList

textCursorNextChar :: TextCursor -> Maybe Char
textCursorNextChar = listCursorNextItem . textCursorList

textCursorInsert :: Char -> TextCursor -> TextCursor
textCursorInsert c = textCursorListCursorL %~ listCursorInsert c

textCursorAppend :: Char -> TextCursor -> TextCursor
textCursorAppend c = textCursorListCursorL %~ listCursorAppend c

textCursorRemove :: TextCursor -> Maybe TextCursor
textCursorRemove = textCursorListCursorL listCursorRemove

textCursorDelete :: TextCursor -> Maybe TextCursor
textCursorDelete = textCursorListCursorL listCursorDelete

textCursorSplit :: TextCursor -> (TextCursor, TextCursor)
textCursorSplit tc =
    let (lc1, lc2) = listCursorSplit $ textCursorList tc
     in (TextCursor lc1, TextCursor lc2)

textCursorCombine :: TextCursor -> TextCursor -> TextCursor
textCursorCombine (TextCursor lc1) (TextCursor lc2) =
    TextCursor {textCursorList = listCursorCombine lc1 lc2}
