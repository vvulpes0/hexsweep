> {-# Language UnicodeSyntax #-}
> module Main where

> import Huffman
> import System.Environment
> import System.IO

> main ∷ IO ()
> main = do args ← getArgs
>           weights ← readFile (head args)
>           str ← getContents
>           let ws     = lines weights
>               table  = (maybe [] representation_map .
>                         create_table . map make_wv) ws
>           hSetBinaryMode stdout True
>           (putStr .
>            compress_with_map table .
>            map ((:[]) . toEnum . fromIntegral . from_hex) .
>            words) str

> make_wv ∷ String → (Integer, String)
> make_wv s = (read $ head ws,
>              (:[]) . toEnum . fromIntegral . from_hex . head $ tail ws)
>     where ws = words s

> from_hex ∷ String → Integer
> from_hex s = read ("0x" ++ s)
