%Problem_1_DFS

threeSum(Nums,Goal,Output):-
	dfs(Nums,[],Possibles),
	compute(Possibles,Goal,[],Final),
	Final \= [],!,
	member(Output,Final).

dfs([],List0,List0).
dfs([H|T],List0,Output0):-
	dfs1(T,[H],[],Output1),
	addTo(List0,Output1,NewList0),
	dfs(T,NewList0,Output0).

dfs1([],_,List1,List1).
dfs1([H|T],[A],List1,Output1):-
	dfs2(T,[A,H],[],Output2),
	addTo(List1,Output2,NewList1),
	dfs1(T,[A],NewList1,Output1).

dfs2([],_,List2,List2).
dfs2([H|T],[A,B],List2,Output2):-
	append(List2,[[A,B,H]],NewList2),
	dfs2(T,[A,B],NewList2,Output2).
	
addTo(Inisial,[],Inisial).	
addTo(Inisial , [H|T] , Target):-
	append(Inisial,[H],NewInisial),
	addTo(NewInisial,T,Target).


compute([],_,List,List).
compute([H|T],Goal,List,Final):-
	isOkay(H,Goal),
	append(List,[H],NewList),
	compute(T,Goal,NewList,Final);
	not(isOkay(H,Goal)),
	compute(T,Goal,List,Final).
	
isOkay([A,B,C],Goal):-
	Goal =:= A+B+C.
	
	
%Problem_1_Greedy
threeSum(Items, Goal, Output):-
	getInital(Items, Goal, NewItems),
	greedy(Items, NewItems, [], [], TmpOut),
	member(Output,TmpOut).

		

% get initial state
getInital([], _, []):-!.
getInital([H|T], Goal, NewItems):-
	getInital(T, Goal, TmpItems),
	Hn is Goal - H,
	(
		Hn >= 0 ->
		append( [ [ [H] ,Hn] ], TmpItems,NewItems)
		; append( [], TmpItems, NewItems ) 
	).	

	
greedy(_, [], _, SolutionList, SolutionList):-!.


greedy(Items, [H|T], ClosedList, SolutionList, Output):-
	H = [State, Hn],
	Hn = 0,
	length(State, Size),
	Size = 3,
	append(SolutionList,[State], NewSolutionList),
	append([H], ClosedList, NewClosedList),!,
	greedy(Items, T, NewClosedList, NewSolutionList, Output).


greedy(Items, [H|T], ClosedList, SolutionList, Output):-
	H = [State, Hn],
	Hn > 0, %edit
	append([], SolutionList, NewSolutionList),
	length(State, Size),
	Size<3,
	getChildren(Items, T, ClosedList, H , NewOpenList),
	append([H], ClosedList, NewClosedList),!,
	greedy(Items, NewOpenList, NewClosedList, NewSolutionList, Output).
		
greedy(Items, [_|T], ClosedList, SolutionList, Output):-
	greedy(Items, T, ClosedList, SolutionList, Output).


	
getChildren([], OpenList, _,  _ , OpenList).

getChildren([Head|Tail], OpenList, ClosedList, H , NewOpenList):-
	H = [State, Hn],
	not(member(Head, State)),
	NewHn is Hn - Head,
	NewHn >= 0,
	append(State, [Head], TmpState), 
	sort(TmpState, NewState), 
	NewHead = [NewState,NewHn],
	not(member(NewHead,OpenList)),
	not(member(NewHead,ClosedList)),
	append([NewHead], OpenList, TmpOpenList),!,
	getChildren(Tail, TmpOpenList, ClosedList, H , NewOpenList).
	
getChildren([Head|_], OpenList, ClosedList, H , NewOpenList):-
	H = [_, Hn],
	NewHn is Hn - Head,
	NewHn < 0,!,
	getChildren([], OpenList, ClosedList,_, NewOpenList).

getChildren([_|Tail], OpenList, ClosedList, H, NewOpenList):-
	getChildren(Tail, OpenList, ClosedList, H , NewOpenList).

%Problem_2

%general algorithm

deletiveEditing(Initial, Initial):-!.
deletiveEditing(Initial,End):-
		getHeuristic(Initial, End, H),
		getchildren([Initial, H], [[Initial, H]], [], [], Child, End),
		append(Child , [], NewOpen),
		append([[Initial, H]], [], NewClosed),
		checkOpen(NewOpen, NewClosed, End, Found),!,
		Found = 1.
		

	
checkOpen([[Head,Heur]|T], Closed, End, Found):-
	not(Head = End),
	getchildren([Head, Heur], [[Head, Heur]|T], Closed, [], Child, End),
	delete2([[Head,Heur]|T], NewOpen),
	append([Head,Heur], Closed, NewClosed),
	append(Child,  NewOpen, NewOpen2),
	checkOpen(NewOpen2,NewClosed, End, Found).

checkOpen([[Head,_]|_], _, End, Found):-
	Head = End,
	Found is 1,!.
	
checkOpen([], _, _, Found):- Found is 2,!.
	
	
	
delete2([[_, _] | T], T):-!.

	
getchildren(State, Open, Closed, Children, Child, Goal):-
		moves(State, Open, Closed, Goal, 0, Children, Child).
getchildren(_,_,_, [],_).


removeFromList(_, [], []):-!.
removeFromList(H, [H|T], V):-
	!, removeFromList(H, T, V).
removeFromList(H, [H1|T], [H1|T1]):-
	removeFromList(H, T, T1).

getCharacter([H|_], Ind, Ind, H):-!.
getCharacter([_|T], Ind, Counter, Character):-
	NewInd is (Ind + 1),
	getCharacter(T, NewInd, Counter, Character).



removeFirstOccurence(Character, [Character|T], Next, NewNext):-
	append(Next, T,NewNext),!.
	
removeFirstOccurence(Character, [H|T], Next, Result):-	
	append(Next,[H], NewNext),
	removeFirstOccurence(Character, T, NewNext, Result).
	
	
move([H|T], Counter, Result):-
	getCharacter([H|T], 0, Counter, Character),
	removeFirstOccurence(Character, [H|T], [], Result).



  	
  	
moves(State, Open, Closed, Goal, Counter, Children, Child):-
		State = [Head,_],
		length(Head, Size),
		Counter < Size,
		move(Head, Counter, Result),
		not(member([Result, _],Open)),
		not(member([Result, _],Closed)),
		not(member([Result, _],Children)),
		getHeuristic(Result, Goal, H),
		not(H = -1),
		NewCounter is (Counter + 1),
		append([[Result, H]], Children, NewChildren),
		moves(State, Open, Closed, Goal, NewCounter, NewChildren, Child). 



moves(State, Open, Closed, Goal, Counter, Children, Child):-
		State = [Head,_],
		length(Head, Size),
		Counter < Size,
		NewCounter is (Counter + 1),
		moves(State, Open, Closed, Goal, NewCounter, Children, Child). 
		
moves(_, _, _, _, _, Children, Children):-!.




getHeuristic(Initial, End, FinalSize):-
	getHur(Initial, End,Score),
	Score = 0,
	length(Initial, Size1),
	length(End, Size2),
	FinalSize is Size1 - Size2.
	
getHeuristic(_, _, -1):-!.

getHur(_, [], 0).
getHur([], _, 1).
getHur([H|T], [H|T1], IsEmpty):-
	getHur(T, T1, IsEmpty),!. 
	
getHur([_|T], [H1 | T1], IsEmpty):-
	getHur(T, [H1|T1], IsEmpty).
	
getLen(List, Size):-
	getLength(List, 0, Size),!.
	
getLength([],Cnt,Cnt):-!.

getLength([_|T],Cnt,Ans):-
	NewCnt is Cnt+1,
	getLength(T,NewCnt,Ans).


