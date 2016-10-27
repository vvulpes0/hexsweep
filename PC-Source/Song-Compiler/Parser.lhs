> {-# Language UnicodeSyntax #-}
> module Parser (
>                Program (..),
>                Track (..),
>                CommandList (..),
>                Command (..),
>                ICommandList (..),
>                ICommand (..),
>                parse
>               ) where

> import Tokenizer

> data Program = Program Track Track Track Track
>                deriving (Eq, Read, Show)
> data Track = Track CommandList
>              deriving (Eq, Read, Show)
> data CommandList = CEnd Command
>                  | CCont Command CommandList
>                    deriving (Eq, Read, Show)
> data Command = RepeatSection Integer ICommandList
>              | Label String
>              | Goto String
>              | Basic ICommand
>                deriving (Eq, Read, Show)
> data ICommandList = IEnd ICommand
>                   | ICont ICommand ICommandList
>                     deriving (Eq, Read, Show)
> data ICommand = PlayNote BaseNote Accidental Integer
>               | Rest
>               | Length Integer
>               | Sustain
>               | Halt
>                 deriving (Eq, Read, Show)

> parse ∷ [Token] → Either Error Program
> parse ts
>     | null ts4   = program t1 t2 t3 t4
>     | otherwise  = Left "Invalid track count"
>     where remaining = either id snd . parse_track
>           track     = either (const Nothing) (Just . fst) . parse_track
>           (t1, ts1) = (track ts, remaining ts)
>           (t2, ts2) = (track ts1, remaining ts1)
>           (t3, ts3) = (track ts2, remaining ts2)
>           (t4, ts4) = (track ts3, remaining ts3)
>           program (Just a) (Just b) (Just c) (Just d) = Right $ Program a b c d
>           program _ _ _ _ = syntax_error
>           syntax_error = Left "Syntax error"

> parse_track ∷ [Token] → Either [Token] (Track, [Token])
> parse_track ts@(Keyword "track" : Open_Block : ts') =
>     fmap make_track   .
>     take_close_block  $
>     parse_command_list ts'
>     where take_close_block (Left ss) = Left ss
>           take_close_block (Right (is, (Close_Block : ss))) = Right (is, ss)
>           take_close_block _         = Left ts
>           make_track (cs, ss)        = (Track cs, ss)
> parse_track ts = Left ts

> parse_command_list ∷ [Token] → Either [Token] (CommandList, [Token])
> parse_command_list ts =
>     case p of
>       Right (c, ts') →
>            case parse_command ts' of
>              Right _ → fmap (insert c) $ parse_command_list ts'
>              _       → Right (CEnd c, ts')
>       _              → Left ts
>     where p                  = parse_command ts
>           insert x (xs, ss)  = (CCont x xs, ss)

> parse_command ∷ [Token] → Either [Token] (Command, [Token])
> parse_command ts@(Keyword "repeat" : Number x : Open_Block : ts') =
>     fmap (make_repeat x) .
>     take_close_block     $
>     parse_icommand_list ts'
>     where take_close_block (Left ss) = Left ss
>           take_close_block (Right (is, (Close_Block : ss))) = Right (is, ss)
>           take_close_block _         = Left ts
>           make_repeat n (is, ss) = (RepeatSection n is, ss)
> parse_command (Keyword "label" : Identifier x : ts) = Right (Label x, ts)
> parse_command (Keyword "goto" : Identifier x : ts) = Right (Goto x, ts)
> parse_command ts = fmap make_basic $ parse_icommand ts
>     where make_basic (i, ss) = (Basic i, ss)

> parse_icommand_list ∷ [Token] → Either [Token] (ICommandList, [Token])
> parse_icommand_list ts =
>     case p of
>       Right (c, ts') →
>            case parse_icommand ts' of
>              Right _ → fmap (insert c) $ parse_icommand_list ts'
>              _       → Right (IEnd c, ts')
>       _              → Left ts
>     where p                  = parse_icommand ts
>           insert x (xs, ss)  = (ICont x xs, ss)

> parse_icommand ∷ [Token] → Either [Token] (ICommand, [Token])
> parse_icommand (Note b a o : ts) = Right (PlayNote b a o, ts)
> parse_icommand (Keyword "rest" : ts) = Right (Rest, ts)
> parse_icommand (Keyword "length" : Number n : ts) = Right (Length n, ts)
> parse_icommand (Keyword "sustain" : ts) = Right (Sustain, ts)
> parse_icommand (Keyword "halt" : ts) = Right (Halt, ts)
> parse_icommand ts = Left ts
