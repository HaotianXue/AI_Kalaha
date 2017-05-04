--
-- Uwe R. Zimmer
-- Australia 2015
--

import Commandline.Options (args_to_options, Options (time_limit, human_player))
import Data.Board (Board (turn), initial_board_Player_A, initial_board_Player_B, bank_A, bank_B, Pebbles, Pond_Ix, pond_first, pond_last, Players (Finished), Lookahead, pick_n_distribute)
import Data.Char (isDigit)
import Data.Time.Clock (NominalDiffTime, getCurrentTime, diffUTCTime)
import Make_Move (make_move)
import System.Environment (getArgs)
import System.Mem (performGC)
import System.Timeout (timeout)
import Text.Printf (printf)

--
-- This is a very ugly piece of code - please do not attempt to read on, 
-- unless you consider yourself brave beyond belief.
--

main :: IO ()
main = do
   args <- getArgs
   let options = args_to_options args
   
   putStrLn ""
   putStrLn "First game (first move goes to player A):"
   putStr (show initial_board_Player_A)
   (point_first, pebbles_first) <- play_game initial_board_Player_A options
   putStrLn "-----------------------------------------------------------------------"
   putStrLn ("# First result for player A: " ++ show (point_first) ++ " point with a pebble difference of " ++ show (pebbles_first))
   putStrLn "-----------------------------------------------------------------------"
   putStrLn ""
   putStrLn "Second game (first move goes to player B):"
   putStr (show initial_board_Player_B)
   (point_second, pebbles_second) <- play_game initial_board_Player_B options
   putStrLn "-----------------------------------------------------------------------"
   putStrLn ("# Second result for player A: " ++ show (point_second) ++ " point with a pebble difference of " ++ show (pebbles_second))
   putStrLn "-----------------------------------------------------------------------"
   putStrLn ""
   putStrLn "-----------------------------------------------------------------------"
   putStrLn ("# Total result for player A: " ++ show (point_first + point_second) ++ " points with a pebble difference of " ++ show (pebbles_first + pebbles_second))
   putStrLn "-----------------------------------------------------------------------"
   putStrLn ""
      
      where
         play_game :: Board -> Options -> IO (Int, Pebbles)
         play_game board options = do
            next_board <- case human_player options of
               Nothing     -> find_next_in_time board
               Just player -> case turn board == player of
                  True  -> find_next_from_human board
                  False -> find_next_in_time    board
            
            putStrLn ">"
            putStr (show next_board)
            case turn next_board of
               Finished -> do 
                  putStrLn " End of game"
                  case compare (bank_A next_board) (bank_B next_board) of
                     EQ -> return ( 0, bank_diff)
                     GT -> return ( 1, bank_diff)
                     LT -> return (-1, bank_diff)
                     
                     where
                        bank_diff = (bank_A next_board) - (bank_B next_board)
                        
               _ -> case next_board == board of
                  True  -> error (show (turn board) ++ " failed to make a move in time")
                  False -> play_game next_board options
            
            where
               world_time_timeout = floor (2.0 * (time_limit options) * 10 ^ (6 :: Int))
               max_cpu_time_per_move = time_limit options
               
               find_next_from_human :: Board -> IO Board
               find_next_from_human current_board = do
                  putStrLn ("Enter move for " ++ show (turn current_board) ++ " (1-6): ")
                  move <- read_next_move
                  return (pick_n_distribute current_board move)
               
               read_next_move :: IO Pond_Ix
               read_next_move = do
                  move <- getLine
                  case move of 
                     [d] -> case isDigit d of
                        True -> case (read move) `elem` [pond_first .. pond_last] of
                           True  -> return (read move)
                           False -> error "No such pond"
                        False -> error "You did not enter a digit"
                     _ -> error "You entered more than a single character"
                                                
               find_next_in_time :: Board -> IO Board
               find_next_in_time current_board = do
                  performGC
                  performGC -- need to be done thoroughly
                  performGC -- seriously
                  start_time <- getCurrentTime 
                  next_board <- timeout world_time_timeout (return $! (make_move current_board 1))
                  stop_time  <- getCurrentTime 
                  let elapsed_time = diffUTCTime stop_time start_time
                  look_deeper current_board current_board elapsed_time next_board 2 0 0
                                    
                  where
                     look_deeper :: Board -> Board -> NominalDiffTime -> Maybe Board -> Lookahead -> Int -> Int -> IO Board
                     look_deeper start_board last_board last_elapsed_time maybe_board lookahead stalls timeouts = case maybe_board of
                        Nothing          -> return last_board -- first timeout
                        Just valid_board -> do
                           putStr "-"
                           performGC
                           performGC -- need to be done thoroughly
                           performGC -- seriously
                           start_time <- getCurrentTime
                           next_board <- timeout world_time_timeout (return $! (make_move start_board (lookahead + 1)))
                           stop_time  <- getCurrentTime 
                           let elapsed_time = diffUTCTime stop_time start_time
                           putStr (show_1_3_digit_float (realToFrac elapsed_time :: Float))
                           case ((realToFrac elapsed_time :: Float) <= max_cpu_time_per_move,
                                 (realToFrac elapsed_time :: Double) < time_increase_considered_stall * (realToFrac last_elapsed_time :: Double)) of
                              (True, True) 
                                 | stalls == last_tolerated_stall -> return valid_board
                                 | otherwise   -> look_deeper start_board valid_board last_elapsed_time next_board (lookahead + 1) (stalls + 1) timeouts
                              (True, False) -> look_deeper start_board valid_board elapsed_time next_board (lookahead + 1) 0 timeouts
                              (False, _) -> return last_board
                              
                           where
                              time_increase_considered_stall = 1.1 -- Less than 10% time increase per iteration.
                              last_tolerated_stall           = 2   -- Third stall in runtime will lead to break out.
                              
                              show_1_3_digit_float :: Float -> String
                              show_1_3_digit_float f = printf "%1.3f" f