module Opponents.Player_A.Player (
   select_move  -- :: Board -> Lookahead -> Pond_Ix
) where

import Data.Board
import Data.Tree

--Name:Haotian Xue
--UID:U5689296
--Referencing:https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf
--Referencing:Antony Hosking's lecture code GameTree.hs
{--Referencing:Antony Hosking's Revert "AB first cut." from https://gitlab.cecs.anu.edu.au/comp1100-2016/comp1100-2016-assignment2/commit/8ffc64784ec3436d51fc810e1da445b27eedc7ce--}


select_move :: Board -> Lookahead -> Pond_Ix
select_move board depth = case (getPlayers board) of
  Player_A -> snd (maximum (zip (alpha depth board) (allLegal_Ponds board)))
  _ -> snd (maximum (zip (beta depth board) (allLegal_Ponds board)))

{--select_move :: Board -> Lookahead -> Pond_Ix
select_move board depth = snd (maximum (zip (alpha depth board) (allLegal_Ponds board)))--}

ab :: Tree Board -> Int
ab = ab' (minBound::Int) (maxBound::Int)

ab' :: Int -> Int -> Tree Board -> Int	 
ab' a b (Node n []) = if (getPlayers n) == Finished then((bank_A n) + sum (ponds_A n)) - ((bank_B n) + sum (ponds_B n)) else bank_A n - bank_B n
ab' a b (Node n es)	 
   | turn n == Player_A = pruneMax a b es	 
   | turn n == Player_B = pruneMin a b es	 
   where	 
     pruneMax a b [] = a	 
     pruneMax a b (e:es)	 
        | v >= b = b
	| v > a = pruneMax v b es	 
        | otherwise = pruneMax a b es
        where v = ab' a b e
     pruneMin a b [] = b	 
     pruneMin a b (e:es)	 
        | v <= a = a	 
        | v < b = pruneMin a v es	 
        | otherwise = pruneMin a b es	 
        where v = ab' a b e

ab'' :: Int -> Int -> Tree Board -> Int	 
ab'' a b (Node n []) = if (getPlayers n) == Finished then((bank_B n) + sum (ponds_B n)) - ((bank_A n) + sum (ponds_A n)) else bank_B n - bank_A n	 
ab'' a b (Node n es)	 
   | turn n == Player_B = pruneMax a b es	 
   | turn n == Player_A = pruneMin a b es	 
   where	 
     pruneMax a b [] = a	 
     pruneMax a b (e:es)	 
        | v >= b = b
	| v > a = pruneMax v b es	 
        | otherwise = pruneMax a b es
        where v = ab'' a b e
     pruneMin a b [] = b	 
     pruneMin a b (e:es)	 
        | v <= a = a	 
        | v < b = pruneMin a v es	 
        | otherwise = pruneMin a b es	 
        where v = ab'' a b e

{--nega :: Int -> Int ->Int -> Tree Board -> Int
nega a b color (Node n []) = color * (bank_A n - bank_B n)
nega a b color (Node n es) = (prune a b color es)
   where
     prune a b color [] = a
     prune a b color (e:es)
        | v >= b = b
	| v >=a = (prune v b color es)
	| otherwise = prune a b color es
	where v = -(nega (-b) (-a) (-color) e)

nega' :: Int -> Int ->Int -> Tree Board -> Int
nega' a b color (Node n []) = color * (bank_B n - bank_A n)
nega' a b color (Node n es) = (prune a b color es)
   where
     prune a b color [] = a
     prune a b color (e:es)
        | v >= b = b
	| v >=a = (prune v b color es)
	| otherwise = prune a b color es
	where v = -(nega'(-b) (-a) (-color) e)

alpha :: Lookahead -> Board -> [Int]
alpha depth board = map (nega (-10000) 10000 1) (subForest (prune depth (gametree board)))

beta :: Lookahead -> Board -> [Int]
beta depth board = map (nega' (-10000) 10000 1) (subForest (prune depth (gametree board)))--}

{--alpha :: Board -> [Int]
alpha board = case getPlayers board of
  Player_A -> map (ab' (-10000) 10000) (map gametree moves)
  _ -> map (ab'' (-10000) 10000) (map gametree moves)
  where moves = map (pick_n_distribute board) (allLegal_Ponds board)--}
   
alpha :: Lookahead -> Board -> [Int]
alpha depth board = map (ab' (-10000) 10000) (subForest (prune depth (gametree board)))

beta :: Lookahead -> Board -> [Int]
beta depth board = map (ab'' (-10000) 10000) (subForest (prune depth (gametree board)))

allLegal_Ponds :: Board -> [Pond_Ix]
allLegal_Ponds board = filter (legal_move board) [1,2,3,4,5,6]

getChildren :: Board -> [Board]
getChildren board = map (pick_n_distribute board) (allLegal_Ponds board)

getPlayers :: Board -> Players
getPlayers board = turn board

reptree f a = Node a (map (reptree f) (f a))

gametree p = reptree getChildren p

{--foldTree :: (a -> b -> c) -> (c -> b -> b) -> b -> Tree a -> c
foldTree f g a (Node label subtrees) = f label (foldTree' f g a subtrees)
foldTree' f g a (x:xs) = g (foldTree f g a x) (foldTree' f g a xs)
foldTree' f g a [] = a

treeMap ::  (a -> b) -> Tree a -> Tree b
treeMap f = foldTree (Node . f) (:) []


static :: Board -> Int
static board
  | getPlayers board == Finished = if (bank_A board) > (bank_B board) then 500
       else if (bank_A board) == (bank_B board) then 0
            else (-500)
  | otherwise = ((bank_A board) - (bank_B board))

static' :: Board -> Int
static' board
  | getPlayers board == Finished = if (bank_B board) > (bank_B board) then 500
       else if (bank_A board) == (bank_B board) then 0
            else (-500)
  | otherwise = ((bank_B board)-(bank_A board))--}	    
     
prune :: Int -> Tree a -> Tree a
prune 0 (Node a x) = Node a []
prune (n) (Node a x) = Node a (map (prune (n-1)) x)














  

 		   