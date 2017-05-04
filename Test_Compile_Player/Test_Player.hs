module Test_Player (test_move) where

import Candidate.Player (select_move)
import Data.Board

test_move :: Board -> Lookahead -> Pond_Ix
test_move board lookahead = select_move board lookahead