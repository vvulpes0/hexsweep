> {-# Language UnicodeSyntax #-}
> module Main where

> import Tokenizer
> import Parser
> import Control.Monad ((>=>))
> import System.IO (stdout, hSetBinaryMode)

> main ∷ IO ()
> main = hSetBinaryMode stdout True >>
>        (interact $
>         either id id  .
>         (tokenize     >=>
>          parse        >=>
>          run          >=>
>          coerce_bytes))

> data Code = Relocation Integer String
>           | Code Integer
>                deriving (Eq, Read, Show)
> type Env = [(String, Integer)]

> coerce_bytes ∷ [Code] → Either Error String
> coerce_bytes = foldr insert (Right []) . map coerce_byte
>     where coerce_byte (Code n)          = Right (toEnum (fromIntegral n))
>           coerce_byte (Relocation _ x)  = Left $ "Invalid label " ++ show x
>           insert a b                    = (:) <$> a <*> b

> locate ∷ (Eq a, Show a, Num b) ⇒ [(a, b)] → a → Either Error b
> locate env x 
>     | null x_loc  = Left ("Invalid label " ++ show x)
>     | otherwise   = Right (sum x_loc)
>     where x_loc = map snd $ filter ((== x) . fst) env

> relocate ∷ Env → Code → Code
> relocate env (Code x)          = Code x
> relocate env (Relocation n x)  = case locate env x of
>                                    Left s   → Relocation n x
>                                    Right p  → Code (n + 253 - p)

> run ∷ Program → Either Error [Code]
> run (Program a b c d)
>     | any is_relocation tdata = Left "Invalid label in track data"
>     | otherwise = Right (concatMap len [size, o1, o2, o3, o4] ++ tdata)
>     where (t1, t1l) = run_track a
>           (t2, t2l) = run_track b
>           (t3, t3l) = run_track c
>           (t4, t4l) = run_track d
>           o1        = 8
>           o2        = o1 + t1l
>           o3        = o2 + t2l
>           o4        = o3 + t3l
>           tdata     = t1 ++ t2 ++ t3 ++ t4
>           size      = o4 + t4l
>           len n     = Code (n `div` 256) : Code (n `mod` 256) : []
>           is_relocation (Relocation _ _ ) = True
>           is_relocation _                 = False

> run_track ∷ Track → ([Code], Integer)
> run_track (Track cl)  = run_command_list [] 0 cl

> run_command_list ∷ Env → Integer → CommandList → ([Code], Integer)
> run_command_list env pc = fixup . foldr next (env, pc, []) . build_list
>     where build_list (CEnd x)        = x : []
>           build_list (CCont x xs)    = x : build_list xs
>           fixup (a, b, c)            = (map (relocate a) c, b)
>           next c (e, p, xs)          = merge (e, p, xs) (run_command e p c)
>           merge (a, b, c) (x, y)     = (x,
>                                         b + fromIntegral (length y),
>                                         y ++ c)

> run_command ∷ Env → Integer → Command → (Env, [Code])
> run_command env pc (Label x) = ((x, pc) : env, [])
> run_command env pc (Goto x)  = (env, Code 0xe1 : Relocation pc x : [])
> run_command env _  (RepeatSection n is) = (env, loop $ run_icommand_list is)
>     where loop xs = Code (0xf0 + n) : xs ++ Code 0xe0 : []
> run_command env _  (Basic i) = (env, run_icommand i)

> run_icommand_list ∷ ICommandList → [Code]
> run_icommand_list = concatMap run_icommand . build_list
>     where build_list (IEnd x)        = x : []
>           build_list (ICont x xs)    = x : build_list xs

> run_icommand ∷ ICommand → [Code]
> run_icommand Halt              = Code 0xe2 : []
> run_icommand (Length n)        = Code 0xd0 : Code n : []
> run_icommand (PlayNote b a o)  = Code note : []
>     where notes        = zip [C, D, E, F, G, A, B] [0, 2, 4, 5, 7, 9, 11]
>           accidentals  = zip [Flat, Natural, Sharp] [-1, 0, 1]
>           lookup x     = sum . map snd . filter ((== x) . fst)
>           note         = o * 16 + lookup b notes + lookup a accidentals
> run_icommand Rest              = Code 0x80 : []
> run_icommand Sustain           = Code 0xef : []
