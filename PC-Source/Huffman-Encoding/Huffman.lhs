> {-# Language UnicodeSyntax #-}
> module Huffman where

The algorithm described herein requires that the input list of
weighted values be sorted.  A friendly merge-sort implementation
is defined for this purpose:

> sort ∷ Ord a ⇒ [a] → [a]
> sort []      = []
> sort (x:[])  = x : []
> sort xs      = merge (sort $ evens xs) (sort $ odds xs)

> odds ∷ [a] → [a]
> odds []        = []
> odds (x:[])    = []
> odds (x:y:xs)  = y : odds xs

> evens ∷ [a] → [a]
> evens []        = []
> evens (x:[])    = x : []
> evens (x:y:xs)  = x : evens xs

> merge ∷ Ord a ⇒ [a] → [a] → [a]
> merge xs [] = xs
> merge [] ys = ys
> merge (x:xs) (y:ys)
>     | x < y      = x : merge xs (y : ys)
>     | otherwise  = y : merge (x : xs) ys

Then, we will define our data types.

> type WeightedValue a = (Integer, a)
> data Tree a = Leaf (WeightedValue a)
>             | Node (Tree a) (Tree a)
>               deriving (Read, Show, Eq, Ord)

> class Weightable a where
>     weight ∷ a → Integer

> instance Integral a ⇒ Weightable ((,) a b) where
>     weight (w, _) = toInteger w

> instance Weightable (Tree a) where
>     weight (Leaf wv)   = weight wv
>     weight (Node x y)  = weight x + weight y

> value = snd

> combine ∷ Tree a → Tree a → Tree a
> combine x y
>     | weight y < weight x  = Node y x
>     | otherwise            = Node x y

> step ∷ [Tree a] → [Tree a] → ([Tree a], [Tree a])
> step q1 q2 = (q1'', q2'' ++ [combine s1 s2])
>     where grab_lightest xs ys
>               | null xs        = (head ys, xs, tail ys)
>               | null ys        = (head xs, tail xs, ys)
>               | wh ys < wh xs  = (head ys, xs, tail ys)
>               | otherwise      = (head xs, tail xs, ys)
>              where wh = weight . head
>           (s1, q1', q2')    = grab_lightest q1 q2
>           (s2, q1'', q2'')  = grab_lightest q1' q2'

> create_table ∷ [WeightedValue a] → Maybe (Tree a)
> create_table [] = Nothing
> create_table vs
>     | null table  = Nothing
>     | otherwise   = Just (head table)
>     where table        = snd $ until done (uncurry step) (values, [])
>           done (a, b)  = null a && (null . drop 1) b
>           values       = map Leaf vs

> serialize ∷ Tree String → String
> serialize (Leaf wv) = toEnum 0 : value wv
> serialize (Node x y) = toEnum size_of_left : serialize x ++ serialize y
>     where size_of_left = length $ serialize x

> representation_map ∷ Tree a → [(a, String)]
> representation_map = represent ""
>     where represent s (Leaf wv)  = [(value wv, reverse s)]
>           represent s (Node x y) = represent ('0':s) x ++
>                                    represent ('1':s) y

> compress_with_map ∷ Eq a ⇒ [(a, String)] → [a] → String
> compress_with_map m = make_small . foldr (++) "" . concatMap find
>     where find x      = map snd . take 1 $ filter ((== x) . fst) m
>           magnitudes  = iterate (* 2) 1
>           f m '1'     = m
>           f m _       = 0
>           make_small xs
>               | null xs    = ""
>               | otherwise  = make_byte xs ++ make_small (drop 8 xs)
>               where make_byte      = (:[]) . toEnum . make_byte'
>                     make_byte' as  = sum $ zipWith f magnitudes as'
>                         where as' = reverse . take 8 $ as ++ repeat '0'

> rle_encode ∷ String → String
> rle_encode ""      = ""
> rle_encode (x:xs)  = rle_encode' x 0 xs
>     where rle_encode' x i "" = (toEnum i) : [x]
>           rle_encode' x i (y:ys)
>               | i >= 256   = '\255' : x : rle_encode ys
>               | y == x     = rle_encode' x (i + 1) ys
>               | otherwise  = (toEnum i) : x : rle_encode (y : ys)

> frequencies ∷ (Ord a) ⇒ [a] → [WeightedValue a]
> frequencies = frequencies' . sort
>     where frequencies' []       = []
>           frequencies' (x:xs)   = frequencies'' x 1 xs
>           frequencies'' a i []  = (i, a) : []
>           frequencies'' a i (b:bs)
>               | b == a     = frequencies'' a (i + 1) bs
>               | otherwise  = (i, a) : frequencies' (b : bs)

> serialized_table_for ∷ String → String
> serialized_table_for = maybe "" serialize  .
>                        create_table        .
>                        frequencies         .
>                        map (:[])
