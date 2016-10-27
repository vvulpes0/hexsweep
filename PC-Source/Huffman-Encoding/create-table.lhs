> {-# Language UnicodeSyntax #-}
> module Main where

> import Huffman
> import System.IO

> main ∷ IO ()
> main = do str ← getContents
>           let ws = lines str
>           hSetBinaryMode stdout True
>           (putStr . maybe "" serialize . create_table . map make_wv) ws

> make_wv ∷ String → (Integer, String)
> make_wv s = (read $ head ws,
>              (:[]) . toEnum . fromIntegral . from_hex . head $ tail ws)
>     where ws = words s

> from_hex ∷ String → Integer
> from_hex s = read ("0x" ++ s)
