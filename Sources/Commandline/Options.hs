--
-- Uwe R. Zimmer
-- Australia 2015
--

module Commandline.Options (
   
   Options (time_limit, human_player),
   
   default_options,   -- :: Options
   args_to_options    -- :: [String] -> Options
   
) where
   
import Data.Board (Players (Player_A, Player_B))
import System.Console.GetOpt (getOpt, ArgOrder (Permute), usageInfo, OptDescr (Option), ArgDescr (OptArg))

data Options = Options {
   time_limit   :: Float, -- seconds
   human_player :: Maybe Players
   }

default_options :: Options
default_options = Options {
   time_limit   = 1.0, -- seconds
   human_player = Nothing
   }

data Flags = Time_Limit Float | Human_Player (Maybe Players)

header :: String
header = "Usage: Kalaha [OPTION...]"

available_options :: [OptDescr Flags]
available_options = [
   Option ['t'] ["time" ] (OptArg from_maybe_time   "<time in seconds>") "limits the available time per move",
   Option ['h'] ["human"] (OptArg from_maybe_player "A|B"              ) "selects a human player"
   ]

from_maybe_time :: Maybe String -> Flags
from_maybe_time maybe_time = case maybe_time of
   Nothing   -> Time_Limit (time_limit default_options)
   Just time -> Time_Limit (read time)
   
from_maybe_player :: Maybe String -> Flags
from_maybe_player maybe_player = case maybe_player of
   Nothing  -> Human_Player Nothing
   Just "A" -> Human_Player (Just Player_A)
   Just "B" -> Human_Player (Just Player_B)
   Just s   -> error ("No such player: " ++ s)

flags_to_options :: [Flags] -> Options
flags_to_options flags = flags_to_options' flags default_options

   where
      flags_to_options' :: [Flags] -> Options -> Options
      flags_to_options' flags' current_options = case flags' of 
         Time_Limit   time  : cs -> flags_to_options' cs (current_options {time_limit = time})
         Human_Player player: cs -> flags_to_options' cs (current_options {human_player = player})
         []                      -> current_options
         
args_to_options :: [String] -> Options
args_to_options args = case getOpt Permute available_options args of
   (flags, [], []) -> flags_to_options flags
   (_, nonOpts, []  ) -> error $ "unrecognized arguments: " ++ unwords nonOpts
   (_, _      , msgs) -> error $ concat msgs ++ usageInfo header available_options