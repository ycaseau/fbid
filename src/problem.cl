// ********************************************************************
// *       FBID: Frequency (lte) BID Simulation                       *
// *       copyright (C) 2011 Yves Caseau                             *
// *       file: problem.cl                                           *
// ********************************************************************

// this file contains the simple problem
// (a tiny knapsack with a few side constraints)
// Version 0.2 : 800 MHz
// 4 bands A,B,C,D and 5 combinations
Version :: 0.2
Percent :: float

// ********************************************************************
// *    Part 1: Data model                                            *
// *    Part 2: Bid Resolution                                        *
// ********************************************************************

// ********************************************************************
// *    Part 1: Data model                                            *
// ********************************************************************

Measure <: ephemeral_object

// a Bid (each player may present a collection of bids)
Bid <: object
Pattern <: object

// defines a player strategy
Strategy <: object(
   mhz:integer,            // 5,10 or 15
   upto:float)           // max amount dispo for player

// there are 4 or 5 player (NEW may play 0,0,0,0)
Player <: thing(
   strategy:Strategy,       // new in v0.2 : represent the strategy :)
   bids:list<Bid>,          //
   index:(0 .. 10),          // current bid that is evaluated
   seeds:list<Pattern>,            // select by hand
   pool:list<Pattern>,      // list of bids which are used as a pattern
   satisfaction:Percent,    // player satisfaction w.r.t his strategy
   bandwidth:Measure,
   scoring:Measure)         //

Bid <: object(
    player:Player,
    mvno?:boolean = true,   // do we accept mvno ?
    adt?:boolean = true,    // Am�nagement du Territoire
    code:(1 .. 9),         // code 1->4 = A to D, 5->9 combinaisons
    index:(1 .. 9),         // position of the bid in the bid list
    mhz:integer,            // amount of frequency
    cost:float,             // money that is bid
    value:float)

// a pattern is a list of bids that reprensent a possible play for a player
// the price is dynamically adjusted during the search for a Nash Equilibrium
// hence only the structure (which bands, which options)
Pattern <: object(
    player:Player,
    bids:list<Bid>,
    mhz:Measure,               // average Mhz assigned when this pattern is played in a Nash equilibrium
    amounts:list<Measure>,      // money that is spend for this bid when its participates to a Nash E
    maxBids:list<float>,      // money that is spend for this bid when its participates to a Nash E
    scoring:Measure)            // average scoring that we get with this bid

// One game is a collection of players' bids : keep the value, the selected bids and
Game <: object(
    bids:list<Bid>,             // all bids for this scenario
    picked:list<Bid>,           // bids that get selected when applying ARCEP rules
    wins:list<integer>,         // winning bids
    generation:list<Pattern>,   // optional : tracability when game is generated
    nmax:integer,               // number of players
    nCandidate:integer = 0,     // number of players that made a bid
    nServed:integer = 0,        // number of players in the winning solution
    cost:float,                 // sum of costs
    value:float,                // sum of value
    ties?:boolean = false)

// scenario is a set of strategy
Scenario <: thing(strategies:list[Strategy])     // one strategy by player

// a micro GTES experiment  (simple but this is a one-week-end experiment)
Experiment <: thing(
   players:list[Player],          // which players are concerned
   games:list<Game>,              // list of games, generated from pool combinations
   nGames:integer,                // number of iterations = of solutions
   pool:list<Pattern>,            // randomly generated
   seeds:list<Pattern>,            // select by hand
   poolSize:integer,              // max size of pool
   poolShort:integer,             // concentration phase: shorter pools
   nashCut:integer,               // time-out in fixed point search
   pool:list<Pattern>,            // list of best patterns
   results:list<float>)           // list of player satisfactions


// constraints
// C1: each band is served once
LNAME :: list<string>("A","B","C","D","B+C","A+B","A+C","B+D","C+D")
LSIZE :: list<integer>(10,5,5,10,10,15,15,15,15)
RESERVE :: list<float>(400.0,300.0,300.0,800.0,600.0,700.0,700.0,1100.0,1100.0)
CONTENT :: list<set>({1},{2},{3},{4},{2,3},{1,2},{1,3},{2,4},{3,4})
LCODE :: list<integer>{integer!(s) | s in CONTENT}                     // integer representation of short sets

[self_print(x:Bid) : void
   -> printf("~S:~S~A~A~A",x.player,integer!(x.cost),LNAME[x.code],(if x.mvno? "" else "-M"),(if x.mvno? "" else "-A")) ]
[self_print(x:Pattern) : void
   -> printf("[~I]",(for b in x.bids printf("~A~A ",LNAME[b.code],(if b.mvno? "" else "-M")))) ]
[self_print(s:Game) : void
   -> printf("~S/~SM$:~A~I",s.value,s.cost,s.picked, (if s.ties? princ("--TIE!")))]
[self_print(s:Strategy) : void 
   -> printf("grab(~A,~A)",s.mhz,integer!(s.upto))]

// data constructors

[A(p:Player,x:integer,b1:boolean,b2:boolean) 
   -> makeBid(p,x,1,b1,b2) ]
[B(p:Player,x:integer,b1:boolean,b2:boolean) 
   -> makeBid(p,x,2,b1,b2) ]
[C(p:Player,x:integer,b1:boolean,b2:boolean) 
   -> makeBid(p,x,3,b1,b2) ]
[D(p:Player,x:integer,b1:boolean,b2:boolean) 
   -> makeBid(p,x,4,b1,b2) ]
[BC(p:Player,x:integer,b1:boolean,b2:boolean) 
   -> makeBid(p,x,5,b1,b2) ]
[AB(p:Player,x:integer,b1:boolean,b2:boolean) 
   -> makeBid(p,x,6,b1,b2) ]
[AC(p:Player,x:integer,b1:boolean,b2:boolean) 
   -> makeBid(p,x,7,b1,b2) ]
[BD(p:Player,x:integer,b1:boolean,b2:boolean) 
   -> makeBid(p,x,8,b1,b2) ]
[CD(p:Player,x:integer,b1:boolean,b2:boolean) 
   -> makeBid(p,x,9,b1,b2) ]

[A(p:Player,x:integer) 
   -> A(p,x,true,true)]
[B(p:Player,x:integer) 
   -> B(p,x,true,true)]
[C(p:Player,x:integer) 
   -> C(p,x,true,true)]
[D(p:Player,x:integer) 
  -> D(p,x,true,true)]
[BC(p:Player,x:integer) 
  -> BC(p,x,true,true)]
[AB(p:Player,x:integer) 
  -> AB(p,x,true,true)]
[AC(p:Player,x:integer) 
  -> AC(p,x,true,true)]
[BD(p:Player,x:integer) 
  -> BD(p,x,true,true)]
[CD(p:Player,x:integer) 
  -> CD(p,x,true,true)]

// create a Bid if price is acceptable
[makeBid(p:Player,x:integer,i:integer,b1:boolean,b2:boolean)
  -> let c := float!(x) in
       (if (c >= RESERVE[i])
           let n := length(p.bids),
               b := Bid(player = p, index = n + 1, code = i, mhz = LSIZE[i], mvno? = b1, adt? = b2) in
              (setCost(b,c),
               p.bids :add b)) ]

// recomputes the value when the cost is set
[setCost(b:Bid,v:float) : void
  -> b.cost := v,
     b.value := v * (if b.mvno? (1.0 + 1.0 / float!(b.mhz / 5)) else 1.0)
                  * (if b.adt? (1.0 + 1.0 / float!(b.mhz / 5)) else 1.0) ]


// create a strategy object
[grab(x:integer,y:integer) : Strategy 
   -> Strategy(mhz = x, upto = float!(y)) ]

// create a list of patterns
[patterns(l:listargs) : list<Pattern>
  -> let lp := list<Pattern>() in
      (for s in l
         case s (set
            let y := Pattern(bids = list<Bid>()) in
               (lp :add y,
                for i in s y.bids :add makeBid(i,true))),
       lp)  ]

// simple constructor
[makeBid(i:integer,opt:boolean) : Bid
   -> Bid(code = i, mhz = LSIZE[i], mvno? = opt, adt? = opt) ]

// copy that adds the player
[copy(b:Bid,p:Player) : Bid
   -> Bid(player = p, code = b.code, mhz = b.mhz, mvno? = b.mvno?, adt? = b.adt?) ]


// utility code ------------------------------------------------------------------------------

[randomIn(l:list) : any 
   -> let n := length(l) in l[1 + random(n)]]
[randomIn(a:integer,b:integer) : integer 
   -> a + random(b + 1 - a) ]

[random?(x:Percent) : boolean
  -> random(1000) < integer!(x * 1000.0) ]

// <start code fragment - Measure - CGS v0.0 > -------------------------------------------------------
// what we measure for one run
Measure <: ephemeral_object(
  sum:float = 0.0,
  square:float = 0.0,           // used for standard deviation
  num:float = 0.0)          // number of experiments

// simple methods add, mean, stdev
[add(x:Measure, f:float) : Measure 
   -> x.num :+ 1.0, x.sum :+ f, x.square :+ f * f, x ]
[mean(x:Measure) : float 
   -> if (x.num = 0.0) 0.0 else x.sum / x.num]
[stdev(x:Measure) : float
   -> let y := ((x.square / x.num) - ((x.sum / x.num) ^ 2.0)) in
         (if (y > 0.0) sqrt(y) else 0.0) ]
[stdev%(x:Measure) : Percent 
   -> stdev(x) / mean(x) ]
[reset(x:Measure) : void 
   -> x.square := 0.0, x.num := 0.0, x.sum := 0.0 ]

// <end code fragment> ------------------------------------------------------------------------------------------


// ********************************************************************
// *    Part 2: Simulations                                           *
// ********************************************************************

// assemble the pieces into one bid scenario
[bid(l:listargs) : any
 -> let s := Game(nmax = size(Player),
                      wins = list<integer>{0 | p in Player},
                      nCandidate = size({p in Player | length(p.bids) > 0})) in
      (for p in Player for b in p.bids s.bids :add b,
       solve(s,1,0.0,0.0,0,0),
       for i in (1 .. s.nmax)
         let p := Player.instances[i], j := s.wins[i] in
           (if (j > 0) s.picked :add p.bids[j]),
       for p in Player shrink(p.bids,0),
       s) ]

// this is a debug mechanism: TRACEV is a list of bids that we want to see explored :)
TRACEV :: list(10,10,10,10,10) //  list(1,1,0,4,4)

// simple recursive iteration
// no forward-checking nor any bounds
// uf represents the use of frequencies : an integer that represents a set (cf. make_set)
// ns is the number of players served (used for ties)
[solve(s:Game,i:integer,sumVal:float,sumCost:float,ns:integer,uf:integer) : void
  -> //[5] solve(~A,~S,~S,~A,~S) // i, sumVal, sumCost, ns, make_set(uf),
    ; if (i = 5 & list{p.index | p in Player} = TRACEV)
    ;    trace(0,"visit good conf at ~S ~S ~A ~S ---\n",sumVal,sumCost,ns,make_set(uf)),
     if (i <= s.nmax)
        let p := Player.instances[i] in
          (p.index := 0,
     ;      if (i > 1 & forall(j in (1 .. (i - 1)) | (Player.instances[j]).index = TRACEV[j]))
     ;         trace(0,"--- [~A] ok -> ~S:~S ~S\n",i - 1,make_set(uf),p,p.bids),
           solve(s,i + 1, sumVal, sumCost, ns, uf),                  // ignore p
           for b in p.bids
              (if ((LCODE[b.code] and uf) = 0)                      // C1
               (p.index := b.index,
                solve(s, i + 1, sumVal + b.value, sumCost + b.cost,ns + 1,uf + LCODE[b.code]))))
     else if (sumVal > s.value) registers(s,sumVal,sumCost,ns)                       // sort by total value
     else if (sumVal = s.value &  ns > s.nServed) registers(s,sumVal,sumCost,ns)     // sort ties - Rule 1
     else if (sumVal = s.value & ns = s.nServed & sumCost > s.cost)
             registers(s,sumVal,sumCost,ns)    // sort ties - Rule 2
     else if (sumVal = s.value & ns = s.nServed & sumCost = s.cost) tie(s)] // would require a random drawing


// register a solution
[registers(s:Game,sumVal:float,sumCost:float,ns:integer) : void
  -> //[5] found a solution of value ~A : ~S  // sumVal,list{p.index | p in Player},
     s.value := sumVal,
     s.cost := sumCost,
     s.nServed := ns,
     s.ties? := false,
     for i in (1 .. s.nmax)
       let p := Player.instances[i] in s.wins[i] := p.index ]

// registers a tie solution (to differenciate between sure and not)
// wins = sure solution (intersection of ties)
[tie(s:Game) : void
  -> //[5] found a tie at ~A: ~S // s.value,list{p.index | p in Player},
     if not(s.ties?) s.ties? := true,      // we could keep a copy of first solution
     for i in (1 .. s.nmax)
         let p := Player.instances[i] in
            (if (s.wins[i] != p.index) s.wins[i] := 0) ]


