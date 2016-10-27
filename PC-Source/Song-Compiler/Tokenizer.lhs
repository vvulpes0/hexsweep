> {-# Language UnicodeSyntax #-}
> module Tokenizer (
>                   Error,
>                   Token (..),
>                   BaseNote (..),
>                   Accidental (..),
>                   tokenize
>                  ) where

> import Data.Char(toLower)

> tokenize ∷ String → Either Error [Token]
> tokenize = finalize . tokenize' . dropWhile (is_whitespace)
>     where tokenize' "" = []
>           tokenize' s  = let (a, b) = grab_token s in a : tokenize' b

> finalize ∷ [Either String Token] → Either Error [Token]
> finalize tokens
>     | alright tokens  = Right $ foldr insert [] tokens
>     | otherwise       = Left $ foldr make_error [] tokens
>     where insert (Left _) xs       = xs
>           insert (Right x) xs      = x:xs
>           make_error (Left s) xs   = ("Error tokenizing " ++ s ++ "\n")
>                                      ++ xs
>           make_error (Right _) xs  = xs

> type Error       = String
> data Token       = Close_Block
>                  | Identifier  String
>                  | Keyword     String
>                  | Note        BaseNote Accidental Integer
>                  | Number      Integer
>                  | Open_Block
>                    deriving (Eq, Read, Show)
> data BaseNote    = A | B | C | D | E | F | G
>                    deriving (Eq, Read, Show)
> data Accidental  = Flat | Natural | Sharp
>                    deriving (Enum, Eq, Ord, Read, Show)

> keywords ∷ [String]
> keywords = ["goto",
>             "halt",
>             "label",
>             "length",
>             "repeat",
>             "rest",
>             "sustain",
>             "track"]

> flattable, sharpable ∷ BaseNote → Bool
> flattable = flip notElem [C, F]
> sharpable = flip notElem [B, E]

> attempt ∷ (String → Maybe Token) → String → Either String Token
> attempt f s = maybe (Left s) Right $ f s

> make_keyword ∷ Either String Token → Either String Token
> make_keyword (Right t) = Right t
> make_keyword (Left s)
>     | elem s' keywords  = Right (Keyword s')
>     | otherwise         = Left s
>     where s' = map toLower s

> make_identifier ∷ Either String Token → Either String Token
> make_identifier (Right t) = Right t
> make_identifier (Left "") = Left ""
> make_identifier (Left s) = if ((all (flip elem labelChars) s) &&
>                                (all (flip elem alpha) $ take 1 s))
>                            then Right (Identifier s)
>                            else Left s
>     where labelChars = alpha ++ "0123456789"
>           alpha      = upper ++ lower
>           upper      = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
>           lower      = "abcdefghijklmnopqrstuvwxyz"

> make_note ∷ Either String Token → Either String Token
> make_note (Right t)  = Right t
> make_note (Left s)   = attempt start s
>     where start [] = Nothing
>           start (x:xs)
>               | elem x "ABCDEFG" = let n = read $ pure x
>                                    in (base_note
>                                        (flattable n)
>                                        (sharpable n)
>                                        (Note n) xs)
>               | otherwise        = Nothing
>           base_note _ _ _ [] = Nothing
>           base_note fl sh f (x:xs)
>               | elem x octaves = done (f Natural (read $ pure x)) xs
>               | otherwise      = case x of
>                                    '-' → dash (f Natural) xs
>                                    '#' → if sh
>                                          then accidental (f Sharp) xs
>                                          else Nothing
>                                    'b' → if fl
>                                          then accidental (f Flat) xs
>                                          else Nothing
>                                    _   → Nothing
>           accidental _ [] = Nothing
>           accidental f (x:xs)
>               | elem x octaves = done (f (read $ pure x)) xs
>               | x == '-'       = dash f xs
>               | otherwise      = Nothing
>           dash _ [] = Nothing
>           dash f (x:xs)
>               | elem x octaves = done (f (read $ pure x)) xs
>               | otherwise      = Nothing
>           done n [] = Just n
>           done _ _  = Nothing
>           octaves   = "01234567"

> make_number ∷ Either String Token → Either String Token
> make_number (Right t) = Right t
> make_number (Left s)  = attempt start s
>     where start []                   = Nothing
>           start (x:xs)
>               | elem x "123456789"   = decimal (read $ pure x) xs
>               | x == '0'             = oct_or_hex xs
>               | otherwise            = Nothing
>           oct_or_hex []              = Nothing
>           oct_or_hex (x:xs)
>               | elem x "1234567"     = octal (read $ pure x) xs
>               | x == 'x'             = hex 0 (map toLower xs)
>               | otherwise            = Nothing
>           octal i []                 = Just (Number i)
>           octal i (x:xs)
>               | elem x "01234567"    = octal (8 * i + read (pure x)) xs
>               | otherwise            = Nothing
>           hex i []                   = Just (Number i)
>           hex i (x:xs)
>               | elem x "0123456789"  = hex (16 * i + read (pure x)) xs
>               | elem x "abcdef"      = hex (16 * i + unhex x) xs
>               | otherwise            = Nothing
>           decimal i [] = Just (Number i)
>           decimal i (x:xs)
>               | elem x "0123456789"  = decimal (10 * i + read (pure x)) xs
>               | otherwise            = Nothing
>           unhex c                    = (10 +) .
>                                        sum .
>                                        map fst .
>                                        filter ((== c) . snd)
>                                        $ zip [0..] "abcdef"

> make_misc ∷ Either String Token → Either String Token
> make_misc (Right t) = Right t
> make_misc (Left s)
>     | s == "}"   = Right Close_Block
>     | s == "{"   = Right Open_Block
>     | otherwise  = Left s

> make_token ∷ String → Either String Token
> make_token = make_identifier .
>              make_note       .
>              make_number     .
>              make_keyword    .
>              make_misc       .
>              Left

> alright ∷ [Either a b] → Bool
> alright = and . map is_right
>     where is_right (Left _)   = False
>           is_right (Right _)  = True

> is_whitespace ∷ Char → Bool
> is_whitespace = flip elem " \t\r\n"

> grab_token ∷ String → (Either String Token, String)
> grab_token = fmap (dropWhile (is_whitespace))  .
>              map_fst make_token                .
>              break (is_whitespace)

> map_fst ∷ (a → b) → (a, c) → (b, c)
> map_fst f (x, y) = (f x, y)
