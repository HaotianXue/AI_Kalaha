--
-- Uwe R. Zimmer
-- Australia 2015
--

module Make_Move (
    make_move -- :: Board -> Lookahead -> Board
) where

import Data.Board (Board (turn), Players (Player_A, Player_B, Finished), Lookahead, pick_n_distribute)

import qualified Opponents.Player_A.Player (select_move)
import qualified Opponents.Player_B.Player (select_move)

make_move :: Board -> Lookahead -> Board
make_move board lookahead = case turn board of
    Player_A -> pick_n_distribute board (Opponents.Player_A.Player.select_move board lookahead)
    Player_B -> pick_n_distribute board (Opponents.Player_B.Player.select_move board lookahead)
    Finished -> board