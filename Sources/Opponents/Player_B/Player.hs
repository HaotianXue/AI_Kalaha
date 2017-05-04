module Opponents.Player_B.Player (
   select_move -- :: Board -> Lookahead -> Pond_Ix
) where

import Data.Board
import Data.Tree

--Name:Haotian Xue
--UID:U5689296
--Referencing:https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf
--Referencing:Antony Hosking's lecture code GameTree.hs
{--Referencing:Antony Hosking's Revert "AB first cut." from https://gitlab.cecs.anu.edu.au/comp1100-2016/comp1100-2016-assignment2/commit/8ffc64784ec3436d51fc810e1da445b27eedc7ce--}


{--get :: Lookahead -> Board -> [Int]
get depth board = if (getPlayers board) == Player_A
  then maximum (map max' (minimax depth board))
  else maximum (map max' (minimax' depth board))

last_into_bank :: Board -> Pond_Ix -> Bool
last_into_bank board pond = if (legal_move board pond)
  then
    if (no_of_pebbles board pond) == (7-pond)
    then True
    else False
  else False

next_turn :: Players -> Bool -> Players
next_turn current_turn last_into_bank = case last_into_bank of
         True  -> current_turn
         False -> case current_turn of
            Player_A -> Player_B
            Player_B -> Player_A
            Finished -> Finished--}

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
  | getPlayers board == Finished = if (bank_B board) > (bank_A board) then 500
       else if (bank_B board) == (bank_A board) then 0
            else -500
  | otherwise = ((bank_B board) - (bank_A board))

static' :: Board -> Int
static' board
  | getPlayers board == Finished = if (bank_B board) > (bank_B board) then 500
       else if (bank_A board) == (bank_B board) then 0
            else (-500)
  | otherwise = ((bank_B board)-(bank_A board))--}
     
{--maximise :: Board -> Pond_Ix -> Tree Int -> Int
maximise board pond (Node n []) = n
maximise board pond (Node n sub) = if next_turn (getPlayers board) (last_into_bank board pond) == getPlayers board
  then maximum (map (\(a,b)->(flip' maximise a b  (pick_n_distribute board pond) )) (zip (allLegal_Ponds (pick_n_distribute board pond)) sub))
  else maximum (map (\(a,b)->(flip' minimise a b  (pick_n_distribute board pond) )) (zip (allLegal_Ponds (pick_n_distribute board pond)) sub))

minimise :: Board -> Pond_Ix -> Tree Int -> Int
minimise board pond (Node n []) = n
minimise board pond (Node n sub) = if next_turn (getPlayers board) (last_into_bank board pond) == getPlayers board
  then minimum (map (\(a,b)->(flip' minimise a b  (pick_n_distribute board pond) )) (zip (allLegal_Ponds (pick_n_distribute board pond)) sub))
  else minimum (map (\(a,b)->(flip' maximise a b  (pick_n_distribute board pond) )) (zip (allLegal_Ponds (pick_n_distribute board pond)) sub))

minimax'' :: Lookahead -> Board -> [Int]
minimax'' depth board = map (\(a,b)->(flip' maximise a b board)) (zip (allLegal_Ponds board) (subForest (treeMap static (prune (depth) (gametree board)))))


minimax :: Lookahead -> Board -> [Int]
minimax depth board = map (\(a,b)->(flip' maximise a b board)) (zip (allLegal_Ponds board) (subForest (treeMap static' (prune (depth) (gametree board)))))--}


prune :: Int -> Tree a -> Tree a
prune 0 (Node a x) = Node a []
prune (n) (Node a x) = Node a (map (prune (n-1)) x)

flip' :: (Board->Pond_Ix->Tree Int->[Int])->Pond_Ix->Tree Int->Board->[Int]
flip' f x y z = f z x y

{--select_move :: Board -> Lookahead -> Pond_Ix
select_move board depth = if getPlayers board == Player_B 
  then snd (maximum (zip (minimax'' depth board) (allLegal_Ponds board)))
  else snd (maximum (zip (minimax depth board) (allLegal_Ponds board)))--}

{--select_move :: Board -> Lookahead -> Pond_Ix
select_move board depth = if (getPlayers board) == Player_B
   then find (get depth board) (zip (allLegal_Ponds board) (map max' (minimax' depth board)))
   else find (get depth board) (zip (allLegal_Ponds board) (map max' (minimax depth board)))


max' :: [Int] -> [Int]
max' [a] = [a]
max' (x:y:xs)
 | x >= y = max' (x:xs)
 | otherwise = max' (y:xs)

min' :: [Int] -> [Int]
min' [a] = [a]
min' (x:y:xs)
 | x <= y = min' (x:xs)
 | otherwise = min' (y:xs)

--mapmin :: [[Int]] -> [Int]
mapmin [] = []
mapmin ((:) nums rest) = (:)  (minimum nums) (omit (minimum nums) rest)

--mapmax :: [[Int]] -> [Int]
mapmax [] = []
mapmax ((:) nums rest) = (:)  (maximum nums) (omit' (maximum nums) rest)

--omit :: Int -> [Int] -> [Int]
omit pot [] = []
omit pot ((:) nums rest)
  | minleq nums pot  =  omit pot rest
  | otherwise = (:) (minimum nums) (omit (minimum nums) rest)

--omit' :: Int -> [Int] -> [Int]
omit' pot [] = []
omit' pot ((:) nums rest)
  | maxleq nums pot = omit' pot rest
  | otherwise = (:) (maximum nums) (omit' (maximum nums) rest)

minleq [] pot = False
minleq ((:) n rest) pot
  | n <= pot   =  True
  | otherwise  =  minleq rest pot

maxleq [] pot = False
maxleq ((:) n rest) pot
  | n >= pot = True
  | otherwise = maxleq rest pot

find :: (Ord a) => a -> [(b,a)] -> b
find  a [] = error "cannot find"
find  a (x:xs)
  | a == snd x = fst x
  | otherwise = find a xs

maximise' :: Board -> Pond_Ix -> Tree Int -> [Int]
maximise' board pond (Node n []) = [n]
maximise' board pond (Node n sub) = if next_turn (getPlayers board) (last_into_bank board pond) == getPlayers board
  then (max'.mapmin) (map (\(a,b)->(flip' maximise' a b  (pick_n_distribute board pond) )) (zip (allLegal_Ponds (pick_n_distribute board pond)) sub))
  else (max'.mapmax) (map (\(a,b)->(flip' minimise' a b  (pick_n_distribute board pond) )) (zip (allLegal_Ponds (pick_n_distribute board pond)) sub))

minimise' :: Board -> Pond_Ix -> Tree Int -> [Int]
minimise' board pond (Node n []) = [n]
minimise' board pond (Node n sub) = if next_turn (getPlayers board) (last_into_bank board pond) == getPlayers board
  then (min'.mapmax) (map (\(a,b)->(flip' minimise' a b  (pick_n_distribute board pond) )) (zip (allLegal_Ponds (pick_n_distribute board pond)) sub))
  else (min'.mapmin) (map (\(a,b)->(flip' maximise' a b  (pick_n_distribute board pond) )) (zip (allLegal_Ponds (pick_n_distribute board pond)) sub))

minimax :: Lookahead -> Board -> [[Int]]
minimax depth board = map (\(a,b)->(flip' maximise' a b board)) (zip (allLegal_Ponds board) (subForest (treeMap static (prune (depth) (gametree board)))))

minimax' :: Lookahead -> Board -> [[Int]]
minimax' depth board = map (\(a,b)->(flip' maximise' a b board)) (zip (allLegal_Ponds board) (subForest (treeMap static' (prune (depth) (gametree board)))))--}

select_move :: Board -> Lookahead -> Pond_Ix
select_move board depth = case (getPlayers board) of
   Player_B -> snd (maximum (zip (alpha depth board) (allLegal_Ponds board)))
   _ -> snd (maximum (zip (beta depth board) (allLegal_Ponds board)))


ab :: Tree Board -> Int
ab = ab' (minBound::Int) (maxBound::Int)

ab' :: Int -> Int -> Tree Board -> Int	 
ab' a b (Node n []) = bank_B n - bank_A n	 
ab' a b (Node n es)	 
   | turn n == Player_B = pruneMax a b es	 
   | turn n == Player_A = pruneMin a b es	 
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
ab'' a b (Node n []) = bank_A n - bank_B n	 
ab'' a b (Node n es)	 
   | turn n == Player_A = pruneMax a b es	 
   | turn n == Player_B = pruneMin a b es	 
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


alpha :: Lookahead -> Board -> [Int]
alpha depth board = map (ab' (-1000) 1000) (subForest (prune depth (gametree board)))

beta :: Lookahead -> Board -> [Int]
beta depth board = map (ab'' (-1000) 1000) (subForest (prune depth (gametree board)))









  

 		   