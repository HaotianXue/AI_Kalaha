# Making the Right Move

## Pre-Assignment Checklist

- **Knowledge: You understand algebraic data structures and can form new ones based on the given requirements.**
- **Skills: You can write and handle recursive functions and data structures. Specifically, you have experience with trees from the lectures and this weeks lab.**
- **You can write a technical report.**
- **You have read the assignment text below in full.**

## Setup

1. **Fork this assignment repository on gitlab.**
2. **Share your fork with your lab tutor as reporter.**
3. **Clone the repository to your personal workspace to begin work.**

**WE EXPECT ALL STUDENTS TO PROPERLY SHARE THEIR ASSIGNMENT WITH THEIR TUTOR
  AS REPORTER TO RECEIVE ANY MARKS!**

---

### Outline
- [The Assignment](#the-assignment)
- [The board](#the-board)
- [The initial state](#the-initial-state)
- [The move](#the-move)
- [End of game](#end-of-game)
- [Evaluation](#evaluation)
- [Example moves](#example-moves)
- [Your task](#example-moves)
- [Relation to trees](#example-moves)
- [The refined player](#example-moves)
- [The matches](#the-matches)
- [Report your design concepts and findings](#report-your-design-concepts-and-findings)
- [Deliverables and deadlines](#deliverables-and-deadlines)
- [Marking](#marking)
- [Kalaha Servers](#kalaha-servers)
- [What to do if you have a problem](#what-to-do-if-you-have-a-problem)
- [Acknowledgements](#acknowledgements)

## The Assignment

This assignment is meant to offer you plenty of chances to apply what you learned in the course so far and to give you direct feedback on how well your programming compares to your fellow students. To do that you will implement a computer player for a simple (or maybe not so simple) board game. When you upload your player it will automatically participate in a class wide tournament. This not only gives you feedback whether your code works under rigorous testing conditions, but also on how well your concepts and code works compare to your colleagues. You will be able to upload as many incarnations of your player code as you wish, until your player works as great as you hope for. The game which your code (and probably you) will be playing for a while is Kalaha (aka “Kalah”, a game from the family of Mancala games).

### The board
![](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Kalaha-board-Legend.png)

The (usually wooden) board features 14 pits, which are distributed according to this layout. The 12 smaller pits are called **ponds** and the two larger pits are called **banks** (or **Kalaha**). The ponds and banks are associated with each of the two players as the diagram indicates.

### The initial state
![](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Kalaha-board-Initial-board.png)

The game starts with an equal number of **seeds** in each pond and no seeds in the banks. The larger the number of initial seeds, the longer and more complex the game will be. We will use six seeds in each pond, which would require significant computational power and memory to solve directly (meaning that you would provide an unbeatable player) — certainly more than what you will have available during a first semester assignment in 2016.

### The move
![](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Kalaha-board-Distribution.png)

The player whose turn it is has to make a move according to the following sequence:

1. The player needs to pick a non-empty pond of his/her own (one out of maximally six).
2. The player empties the chosen pond (takes the seeds into his/her hand).
3. Starting from the next pit to the right of the chosen pond, the player will place one seed out of his/her hand into the following ponds counterclockwise, as shown here. This includes the own bank but skips the opponent’s bank.

With the last seed being placed, the player’s turn usually ends (and the opponent has his/her turn), but there are two special cases:

- *The last seed is placed in the player’s bank*: The player keeps 
the turn and will make another move. This can go on as long as the player manages to distribute seeds in a way such that the last seed always ends in the own bank. 
- *The last seed is placed in an empty, own pond* **and** *the directly opposing pond is not empty*: This last seed as well as all seeds in the directly opposing pond of the other player are “captured” and placed in the own bank. The game continues with the opposing player’s turn. Note that this case is guaranteed if the player distributes a pond with 13 seeds, and it is impossible when the player distributes a pond with more than 13 seeds.

### End of game

The game ends when one player no longer has any seeds in any of his/her own ponds. In this case all remaining seeds from each pond are moved to the corresponding player's bank (seeds from ponds of player A go to player A’s bank and accordingly for player B).

### Evaluation

At the end of the game, the player with the most seeds in his/her bank wins. Draws (both players have 36 seeds) are possible.

### Example moves
![](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Kalaha-board-Initial-board.png)

From the initial board, and assuming that player A has the first move, there are six possible moves to choose from. Only one will lead to the last seed ending in the own bank, so let’s try this just for demonstration. As the number of seeds is not sufficient to loop around and fill the same pond from which we started (which will only happen with 13 or more seeds in a pond), naturally there will be an empty pond left.

The second move cannot end in the own bank any more, and after a lot of deep thought we choose the second to last pond for distribution next.

![](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Kalaha-board-1st-move.png)

Was that clever and will it eventually lead to player A winning? Hard to say for sure as one would need to calculate all possible subsequent counter moves and own moves from here on out to find out whether this starting move will lead to an overall win or loss.

![](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Kalaha-board-2nd-move.png)

To develop a feel for the game it might be a good idea to pick a partner and just go for a few rounds to see what is a potentially good or decidedly disastrous move.

As a human player you will automatically develop an idea what a “good” board looks like. This is usually the first step in developing a player algorithm: Play a number of moves in your head and ultimately choose the one which leads to the “best” board for you. For the board above one could argue in multiple ways. First, player A has two seeds in the own bank while player B has none. Also player B will only achieve exactly one seed for his/her own bank in the next move. So this seems good for player A. But then player A has only five possibly moves to choose from in his/her next turn and in total less seeds on his/her side than player B. This seems perhaps not so good for player A.

One common method is to write an **evaluation function** based on your insights into the mechanics of the game which produces a single scalar value for a given board, such that any reachable board can be compared and the path to the best one can be chosen.

Ideally your board evaluation function is simple to calculate and reflects a general trend towards more chances of winning reliably. Simple to calculate means that you can run it faster and test more possible moves in the same amount of time. A more complex evaluation function might mean that it measures the chances for winning more precisely, but it also takes more time to calculate so that you can only test a smaller number of moves.

As a simplistic player, one could just try all (maximally) six own moves, evaluate each of the resulting boards, and choose the one with the highest score. Soon the idea of “looking further ahead” will come to mind, recursion kicks in, and we will see trees (below).

### Your task

You only have to provide a single function:

```haskell
select_move :: Board -> Lookahead -> Pond_Ix
```

where

```haskell
type Pebbles = Int
type Pond_Ix = Int -- range: 1 .. 6
pond_first = 1 :: Pond_Ix
pond_last  = 6 :: Pond_Ix
type Ponds = [Pebbles]
type Bank  = Pebbles
type Lookahead = Int -- range: 1 ..
data Players = Player_A | Player_B | Finished
   deriving (Show, Eq)
data Board = Board {turn :: Players, ponds_A :: Ponds, bank_A :: Bank, 
                                     ponds_B :: Ponds, bank_B :: Bank}
   deriving (Show, Eq)
```

(All the above definitions are found in the module `Data.Board` which you will import.)

With both players sitting at the board, opposing each other, `pond_first` is always the left-most, own pond, and `pond_last` is always the right-most, own pond (closest to their own bank).

The `Lookahead` parameter is used to indicate how far into the future you should “look ahead”, before you make your decision about the best move. You do not need to use this parameter — e.g. if you can come up with a great move instantly and without testing a large number of moves.

In matches between two computer players, this parameter is used to find the deepest look ahead search that your algorithm can manage within a given time. Thus your `select_move` function will actually be called multiple times with an increasing value for `Lookahead`, until your function fails to return a value before the deadline, or subsequent calls with higher values for `Lookahead` will no longer extend the computational time taken. Once this happens, the last move that was produced within the deadline will be accepted as your selected move. The timer is always reset before the next call, thus you will have had the full time available for the move that has been selected. While this sounds tricky, you do not really need to concern yourself with the technicalities of implementing this (all this is provided), yet you simply should make your algorithm try harder with increasing values for `Lookahead`.

Functions to transform a board from one state to the next one, given a certain movement choice as well as a simple test-function for legal moves are provided. In other words: the full set of rules has already been translated into code, and thus you only need to worry about making a movement choice when provided with a certain board configuration.

Put your function `select_move` in a file which you call “Player.hs” and which starts like this:

```haskell
module Player (
   select_move -- :: Board -> Lookahead -> Pond_Ix
) where
import Data.Board
```

It is important that your file name as well as the name and the parameters of your move selection function are exactly as above — otherwise the tournament server will not be able to use it.

You will find more useful functions in `Data.Board`:

* `legal_move :: Board -> Pond_Ix -> Bool`  
  helps you to check whether the move you consider (`Pond_Ix`) is a legal move to make on a specific board (`Board`).

* `no_of_pebbles :: Board -> Pond_Ix -> Pebbles`  
  provides you directly with the number of pebbles which you will find in a specific pond of your own (`Pond_Ix`) on a specific board (`Board`).

* `pick_n_distribute :: Board -> Pond_Ix -> Board`  
  is probably the most important function for you to look at. It executes a move for the current player and provides you with the resulting board. All Kalaha rules will have been applied. On the resulting board you will see whether the turn changed to the other player, or whether the game is over, as well as of course all new ponds and banks values. While the exact same function is later used to actually execute your provided move, it also serves for you as a “look ahead” feature to test what consequences your currently considered move would have.

### Relation to trees

That’s all reasonable so far, but where do trees come in exactly, and what kind of tree specifically?

Every time a move has to be chosen, the total number of reachable boards multiplies by the number of possible moves, maximally six. In other words: maximally six more potential branches of the game play will need to be taken into account. For each of those branches there will be a maximal number of six possible follow-up moves, which will be added to the leaves of the previous branches. … do you see it already? You most likely will want to draw yourself a little diagram with all the possible ways in which a game can develop. Do this now.

So far it is clear that you need a tree with a maximal degree of six for the game of Kalaha.

If you read up a bit on computer algorithms for any kind of two player board game, you will soon stumble over the term **Minimax Tree**. This is because you want to find the interesting path in the game play, where the players are always choosing the best move (for themselves) at each turn. To express it from your perspective:

* You will always choose what’s best for you.
* Your opponent will always choose what’s worst for you.

Every time you can make a move you will thus choose the path that promises the maximum value of your evaluation function — i.e., you will choose what’s best for you.

On the other hand, every time your opponent makes a move you will always choose the path with the minimum value of your evaluation function — i.e., you assume that your opponent will choose to minimize your chances.

Thus, depending on whose turn it is, the nodes in your tree will either take the maximum or the minimum of the evaluations of their sub-trees. Hence this is called a **Minimax Tree**. At this point you will most certainly need to draw yourself a diagram to see what is going on (… shuffling for crayons, colourful diagrams appear in front of you …). Make sure you fully understood this search strategy before proceeding.

You can build such a search tree as an explicit data-structure (using an algebraic type and apply recursive functions to it as you did before), or you can create such a search tree by recursive functions alone where the returned expression of each function is the value of a node in your tree. The former has the advantage that you can pass the whole tree along to other functions and can process the tree in multiple passes without building it each time. The latter has the advantage that information is only held as long as needed (using less memory over time), since once a node function has received the required value from a sub-node function, this sub-node will be forgotten<sup>[1](#footnote-1)</sup>.

### The refined player

Beyond Minimax Trees lies plenty of further optimization. Keep in mind that a simple, “lightweight” implementation will potentially run a lot faster than a sophisticated and complex implementation. As your player is compared in terms of the best move it can come up with in a given time, speed can give you the edge. Reducing overall complexity (by for instance ignoring whole branches that might not be worth following) will almost always improve things considerably. Keep in mind that the number of possibilities in this game “explodes” swiftly and the total number of possible games is estimated<sup>[2](#footnote-2)</sup> at 2.12&nbsp;&times;&nbsp;10<sup>33</sup>. Any form of “not following up on a specific path” or “pruning the game tree” will significantly limit the magnitude of this explosion. A good place to start is **Alpha-Beta Pruning**.

P.S. To keep the playing field level, only side-effect free functions are allowed in this assignment.

### The matches

Since the first move might bring an advantage or disadvantage for a player, each match always consists of a pair of games with each player having the first turn once. In the code framework provided you will find two directories inside `Sources/Opponents`: `Player_A` and `Player_B`. You can place your `Player.hs` into each of these directories if you want to make it play against itself. Or you can place two alternative versions of your player in those, if you want to test whether your latest tweak and improvement is actually an improvement in terms of a better performing player.

The provided script `make_Kalaha` will (besides producing an executable file) rename the module names of both players such that Haskell can distinguish them. So be careful when moving your players around after they have been renamed (just make sure if you copy a player from those spots after compilation that you rename the module back to a plain “`Player`”).

The transcripts of your matches will have a series of ‘`-`’s combined with measured runtimes after each new board configuration. The number of ‘-’s in there indicates how far the `Lookahead` parameter was increased before a deadline violation was detected<sup>[3](#footnote-3)</sup>. You can play matches between your own player(s), using the provided code. To compete with your friends (and everybody else), use the tournament server via the Gitlab repository.

The executable program can be provided with additional settings from the command line:

```
Usage: Kalaha [OPTION...]
  -t[<time in seconds>]  --time[=<time in seconds>]  limits the time per move
  -h[A|B]                --human[=A|B]               selects a human player
```

The individual options are:
* `-t` or `--time`: changes the maximal time which is allocated to computer players, like in ./Kalaha --time=2.0 for instance. By default 1.0 s will be set.
* `-h` or `--human`: Changes one of the two players to be operated by you, like in `./Kalaha --human=B`. By default both opponents are operated by your `Player.hs` modules.

Or you can submit your `Player.hs` module (following the submit instructions below), in which case it is exercised successively against all other students in the course and the results can be seen on-line (on a page which will turn up on the course site in time). The tournament server will select opponents for your player according to a dynamic version of a Swiss Tournament<sup>[4](#footnote-4)</sup>: players with small numbers of matches will be played against players that they did not encounter yet, and are of a similar ranking. You can also see the full transcripts of all played games which might give you:

- Information as to in which situations your player did something extraordinary clever, or specifically dumb.
- General ideas how to better play Kalaha.

### Report your design concepts and findings

Go back to all your notes and hand-drawn diagrams and document how you came up with your player implementation. Provide concise answers to the following questions:

* What made you evaluate the board in your specific way?
* What made you try or submit a specific search method?
* What problems did you encounter and how do you overcome them?
* Did you go through a sequence of players while you wrote your assignment?
* In which ways did they “evolve”?
* Why do you think your player triumphed (or not) in the class wide tournament?
* Which programming language features did you employ in your coding and why (e.g. recursion, higher order functions, etc.)?
* What was the hardest concept during your assignment?

You can structure your report in whichever form you see fit (and use any program you like) as long as you address the requested items and the output is of reasonably professional quality. Keep in mind the purpose of such reports: namely “to inform your reader efficiently” … which includes structure, writing, readability and soundness. All recommendations (including coding standards) from assignment one still apply. If you require hints or support for technical writing in general, come to us for assistance.

Your must reference your reading, any in-person discussions with colleagues (including anybody you helped), as well as any on-line exchanges, etc.

There are a number of on-line resources to help you with technical writing.<sup>[5](#footnote-5)</sup> <sup>[6](#footnote-6)</sup>

### Deliverables and deadlines

Your report need to be saved as a pdf file. Call this `Assignment_2.pdf`. Make sure that the fonts that are used in your report are embedded.

Submit both via the gitlab repository, replacing the `Player.hs` file at `Sources/Opponents/Player_A/Player.hs`, and the `Assignment_2.pdf`.

While you are usually encouraged to split your code into modules as appropriate, your player will need to be implemented in one file (`Player.hs`) for this assignment. This is due to the level of automation on the tournament server which will copy your code over multiple computers for distributed execution — this is just easier with a single program file rather than a whole tree of dependent modules for each student. On the other hand, we did not manage to write a player complicated enough to warrant multiple modules.

Important: the Gitlab repository allows you to re-submit as often as you want before the deadline. Make use of that: submit early versions for two reasons: first you know that your submit command works (if you will get a success message as response to your command) and second you are safe from last minute glitches, as you already got a version in — even if your computer explodes on the last day or your hamster catches the flu. Arrange your time management in order to submit one or two days before the actual deadline — submitting close to the deadline is usually a sign of a high risk strategy and bad time management and you should be concerned about this.

The assignment has three deadlines:

- **Monday Week 10, 2nd May at 17:00**
    - all students must have uploaded a Kalaha player which at least: *Compiles and Delivers a valid move within one second for all possible boards*
- **Monday Week 11, 9th May at 17:00**
    - all student must have uploaded a Kalaha player which at least: *Has a higher win ratio than the reference player 90 (a simple robot which blindly always chooses the right-most, legal pond)*.
- **Sunday Week 12, 22nd May at 17:00**
    - *Final submission of Kalaha Player and Report.*

The “late policy” for this course is: “tell us in advance or don’t be late”. If you see that a deadline will pose a problem for you, then please contact us with a reason for the delay, and we will work something out — otherwise just plan to submit everything a day or two in advance and you will be fine. The submission system will lock down after the deadline.

### Marking

The marking is divided roughly into 60% for the code and 40% for the report. For exceptional reports or code fragments we might take the liberty to shift those percentages slightly to acknowledge extra efforts.

Marks in the code will be awarded for functionality (i.e., it works), clarity of code (i.e., we immediately understand why it works), and efficiency (i.e., it transitions at a reasonable pace).

Marks in the report will be awarded to concise writing, completeness of the report, and your understanding of your own designs and findings.

Here is a breakdown of example student cases with different marks awarded:

- *Pass*: The code compiles and delivers a valid move at all times. The game strategy is noticeably different from “do the first valid move you find”. The report shows basic understanding of the problem and explains the submitted code.
- *Credit*: The code compiles without warnings and delivers a valid move at all times and in time. The minimax tree is fully functional. The code is well structured and well supported in the report.
- *Distinction*: The code is well structured, efficient and implements a fully working minimax tree utilizing a well thought out board evaluation function. The report is excellently written and addresses all items.
- *High Distinction*: The submitted solution significantly exceeds the expected performance of a plain minimax tree design. The report is excellently written and explains in detail which additional measures have been taken
and how they have been implemented.

Roughly: you can expect to be able to reach a distinction level mark with an excellent submission of a minimax tree based solution, and a high distinction mark with an excellent submission which goes beyond that. Again: keep in mind that addressing a more complicated assignment part does not guarantee you any kind of mark — it only shifts the upper end for the potential mark.

Any plagiarism which is detected in any part of the assignment will lead to zero marks for the whole assignment and an investigation. So be strict with comments in your code and report any collaboration and your sources. Name anybody with whom you collaborated (and name the form and scope of the collaboration — e.g., “this function has been developed in a joint session with John von Neumann”) and name any sources from which you drew inspiration for a specific part of the assignment (e.g. “this function is based on the example in section 4.3 of the course textbook”). Never directly exchange source code or reports as files — collaborate on paper or white boards and make sure you do not leave anything behind in the room after you leave. If your code or report (or any part of it) is found in somebody else’s submission, you will become part of a plagiarism case. More details about plagiarism can be found on the course web-site.

Submissions that sustain a rank higher than our designated player in the tournament will immediately gain a high distinction (assuming that the report is on the same level). If there are too many of those, we will silently withdraw from the tournament in shame and delete this section out of the assignment text.

Exceptionally elegant solutions, common programming mistakes and complete disaster submissions may be discussed in class (with your name removed of course).

### Kalaha Servers

The game servers match opponents by a system similar to a [Swiss tournament](http://en.wikipedia.org/wiki/Swiss-system_tournament), which ensures that an approximate ranking for a new player is found swiftly. Players with smaller numbers of matches will be drawn first and set against a player of similar rank and against whom the player hasn't previously competed. Eventually all players will compete against everybody else. Thus, this system does not prevent full evaluation, yet ensures early feedback for everybody. In the current distributed server setup, up to 16 simultaneous matches are executed at any time.

Once you submit a new player all your results will be deleted and a fresh round of matches will be performed with this new player. Submitting a player works by using `git push` to push a new player to your fork of the assignment on gitlab.cecs.anu.edu.au. You can submit a new player any time — even if your player is currently engaged in a dramatic match. A new player will be recognized in about 1-2 minutes, its status will change to "New submission" and all its scores are deleted. To run all tests for a new player will take 5-7 minutes and the status for the player will be displayed as "Test execution" during this phase. After that, the status of the player will change to either "Compilation error", "Execution error" or "Executing".

For privacy reasons, your name and university uid are never displayed on the server pages, but instead each player is identified by a number. Your player number has been e-mailed to you. It is perfectly fine to reveal your player number to anybody you like — but this is your decision, not ours. You can take your own player out of the tournament by submitting the dummy player which comes with your student code template.

**Important**: the rank has no influence on your mark! The tournament has been set up to give you feedback and for fun. This feedback will be important for your code development: How else do you know that the strategy x which you chose to follow is actually working? You may have a very clever strategy in mind, but if you find that your player loses out to the preset robots which are blindly choosing the first legal move they see, then your code may actually implement something less clever than you planned. A description of the pre-set players will be kept up to date on the forums.

All pages are automatically updating on a 15 seconds basis. There is little point pressing reload more frequently as the pages are also only pushed to the web server (maximally) every 15 seconds.

#### [The tournament matrix](https://cs.anu.edu.au/courses/comp1100/kalaha/Match_Status.html)

The Kalaha game server status is displayed in a number of ways. An overview of all completed matches of players which rank in the top 40 is given by the [tournament matrix page](https://cs.anu.edu.au/courses/comp1100/kalaha/Match_Status.html) which is also fully linked to all other information about your players. The entry in the matrix indicates the outcome of the game between the player in a given row against the player in a given column. The matrix is kept sorted by player ranks at all times. Thus the top right part of the matrix will have more wins in it. You can click on a player number and the current status for this player will appear. You can also click on an individual match (indicated according to its outcome by either: <img src="http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Win.png" width="14" height="14" alt="Win" /> Win, <img src="http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Tie.png" width="14" height="14" alt="Tie" /> Tie or <img src="http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Loss.png" width="14" height="14" alt="Loss" /> Loss) and see the full transcript for this match. Matches that are currently running (<img src="http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Running.png" width="14" height="14" alt="Running" />) or ended in an error state (<img src="http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Error.png" width="14" height="14" alt="Error" />) do not provide a current transcript.

#### Typical stages of the [tournament matrix](https://cs.anu.edu.au/courses/comp1100/kalaha/Match_Status.html)

Early on, as well as during the middle part of the tournament, most matches are played amongst players of similar ranks. Since players usually change ranks after each match there is always a chain of matches where players move to a new rank and then are matched to an opponent close to this new rank. Hence the active games (<img src="http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Running.png" width="14" height="14" alt="Running" />) are clustered around the diagonal for the best part of the tournament:

![Early Matrix](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Early-matrix.png)

During the later phase of the tournament, players are matched more and more against oppoenents that are of distant ranks. Hence the active games are now more spread out across the whole matrix:

![Mid Game Matrix](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Mid-game-matrix.png)

New (and re-submitted) players will (after test compilations and test executions) enter the game matrix with a large number of matches being played simultaneously:

![New Player](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/New-player-injected.png)

A completed tournament usually sets most players to rather similar ranks compared to earlier during the tournament:

![Complete Matrix](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Complete-matrix.png)

#### Player focus pages

By clicking on a player number you can bring up a page which focuses on just one player:

![Player Focus](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Player-focus-page.png)

This can be useful to quickly analyse where most pebbles have been lost. Like in the tournament matrix, clicking on the "Win", "Loss" or "Tie" fields will bring up the according match transcripts.

#### [Player ranks and statistics](https://cs.anu.edu.au/courses/comp1100/kalaha/Student_Status.html)

The complete list of all players and their statistics is found on the [overall ranking page](https://cs.anu.edu.au/courses/comp1100/kalaha/Student_Status.html).

![Ranking](http://cs.anu.edu.au/courses/comp1100/kalaha/graphics/Ranking.png)

Players with equal win ratios are distinguished by the number of pebbles which they conquered.

### What to do if you have a problem

If you can’t get it to run on your own computer &rarr; Ask a friendly (CSSA) student for help or post on the forums.

If you’re stuck and can’t work out what to do &rarr; Take a break and do something else; staring at the screen is only going to frustrate you &rarr; Join a PAL session or ask your tutor for help &rarr; Take another break &rarr; Panic (and send an e-mail to your favourite tutor/lecturer).

In the last two weeks of the assignment your tutor will also ask you how you are fairing and whether any last minute hints might help.

In all cases: if you have a problem that you cannot work out in reasonable time on your own, you **must** contact somebody. This can be your fellow students, the students and mentors in your PAL session, the students and tutors in your lab session, or the lecturer. All of us react to e-mail (eventually!) and forum posts — usually much faster than you think.

### Acknowledgements

Revised by Jan Zimmer, based on material by Uwe R. Zimmer, with feedback from
Tony Hosking and the COMP1100 tutors.

The project avatar is an image available under Creative Commons BY license:
https://www.brooklynmuseum.org/opencollection/objects/12712/Mancala_Game_Board.
(Possibly Bullom. Mancala Game Board, 19th century. Wood, 8 1/4 x 23 1/4 x 5
1/8 in. (21 x 59.1 x 13 cm). Brooklyn Museum, Museum Expedition 1922, Robert
B. Woodward Memorial Fund, 22.239. Creative Commons-BY (Photo: Brooklyn
Museum, 22.239_SL1.jpg))

#### Footnotes

<a name="footnote-1">1.</a> The full “under the hood” story in Haskell is more involved, but to consider the actual memory management in Haskell in your algorithm would lead too far, and would limit the universality of your algorithm. As we use Haskell in this course, all your algorithms can be directly translated to most other programming languages — which we (for the purpose of this course) consider preferable to forms of programming that are tailored to a specific language environment.

<a name="footnote-2">2.</a> Irving, G., Donkers, J., & Uiterwijk, J., “Solving Kalah”, ICGA Journal, 2000

<a name="footnote-3">3.</a>Due to limitations of time measurements inside Haskell while running on top of a desktop OS and fighting with garbage collection, the number of indicated look-ahead steps during end-games can be too high. This does not affect the outcome of the tournaments.

<a name="footnote-4">4.</a> http://en.wikipedia.org/wiki/Swiss-system_tournament

<a name="footnote-5">5.</a> Zimmer, U., [Typesetting for Technical Writing](http://courses.cecs.anu.edu.au/courses/old/COMP1100.2015/Assignments/Typesetting%20for%20technical%20writing.pdf)

<a name="footnote-6">6.</a> Tischler, M. (ed.), [Scientific Writing Booklet](http://cbc.arizona.edu/sites/default/files/marc/Sci-Writing.pdf)
