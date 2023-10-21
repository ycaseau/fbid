// ********************************************************************
// *       FBID: Frequency (lte) BID Simulation                       *
// *       copyright (C) 2011 Yves Caseau                             *
// *       file: simul.cl                                             *
// ********************************************************************

// this file contains the simulation methods & test cases

// ********************************************************************
// *    Part 1: Sensitivity Analysis                                  *
// *    Part 2: simple equilibriums                                   *
// *    Part 3: Experiments : microGTES                               *
// ********************************************************************


// ********************************************************************
// *    Part 1: Sensitivity Analysis                                  *
// ********************************************************************

MAXPRICE:integer :: 5000               // noOne would ever bid more than 5Ge

// (1) find the min prices for all bids
[delta(s:Game,p:Player) : void
   -> for b in s.bids
         (if (b.player = p)
           let c := minPrice(s,b) in printf("~S:~AMe -> ~A\n",b,c,score(s,b,float!(c)))) ]

// find the minPrice through dichotomic search (naive !)
[minPrice(s:Game,b:Bid) : integer
   -> if tryPrice(s,b,MAXPRICE)  dicoSearch(s,b,0,MAXPRICE)
      else 1000000]                                   // means impossible !

[dicoSearch(s:Game,b:Bid,x:integer,y:integer) : integer
  -> let z := (x + y) / 2 in
       (if (z = x | z = y) y
        else if tryPrice(s,b,z) dicoSearch(s,b,x,z)
        else dicoSearch(s,b,z,y))]

// tells is a bid is selected at price v
[tryPrice(s:Game,b:Bid,v:integer) : boolean
   -> if (float!(v) < RESERVE[b.code]) false          // cannot bid under reserve price
      else let c := b.cost, answer := false in
        (setCost(b,float!(v)),
         resolve(s),
         if (b % s.picked) answer := true,
         setCost(b,c),
         answer) ]

// re-launch of simulation loop
[resolve(s:Game)
  -> for b in s.bids b.player.bids :add b,
     s.nServed := 0, s.value := 0.0, s.cost := 0.0, s.ties? := false,
     shrink(s.picked,0),
     solve(s,1,0.0,0.0,0,0),
     for i in (1 .. s.nmax)
         let p := Player.instances[i], j := s.wins[i] in
           (if (j > 0) s.picked :add p.bids[j]),
     for p in Player shrink(p.bids,0) ]


// ********************************************************************
// *    Part 2: Analysis                                              *
// ********************************************************************

[analyze(s:Game) : void
  -> for b in s.picked printf("**~S(~A):~A - ~A\n",b,b.value,regret(s,b),score(b)) ]

[analyze(s:Game,p:Player) : void
  -> for b in s.bids
       (if (b.player = p)
            (if (b % s.picked) princ("**"),
             printf("~S(~A):~A - ~A\n",b,b.value,regret(s,b),score(b)))) ]

[regret(s:Game,b:Bid) : float
  -> when b2 := some(y in s.bids | (y.player = b.player & y.index = (b.index - 1))) in
        (b.value - b2.value) / float!(LSIZE[b.index] - LSIZE[b2.index])
     else b.value / float!(LSIZE[b.index]) ]

[score(b:Bid) : float  
  -> b.value / float!(LSIZE[b.index]) ]


// ********************************************************************
// *    Part 3: Simple GTES                                           *
// ********************************************************************


// give a satisfaction to a player
[score(s:Game,b:Bid) : float 
  -> score(s,b,b.cost)]

[score(s:Game,b:Bid,c:float) : float
  -> let p := b.player, target := p.strategy.upto in
        (float!(min(b.mhz,p.strategy.mhz)) / float!(p.strategy.mhz)) *
         (1.0 - (1.0 + c - RESERVE[b.code]) / (3.0 * (1.0 + target - RESERVE[b.code]))) ]

[score(s:Game,p:Player) : float
  -> when b := some(b in s.picked | b.player = p) in score(s,b)
     else 0.0 ]

[score(g:Game) 
  -> printf("~S: ~I\n",g, (for p in Player printf("~S:~A ",p,score(g,p)))) ]

// move (first approximation of BR)
// look at all bids and select the one with the best score (best way to get satisfaction)
// returns true if an adjustment was made
THB:boolean :: false      // THB option : allow to reduce prices
MOVE:integer :: 1
INCREMENT:float :: 4.0    // (faster convergence at the expense of precision)
[move(s:Game,p:Player) : boolean
  -> let bb := unknown, bs := score(s,p), bp := 0.0 in
       (for b in s.bids
         (if (b.player = p)
           let c := minPrice(s,b), x := score(s,b,float!(c)) in
                  (//[MOVE] try ~S:~AMe -> ~A // b,c,x,
                   if (x > bs & float!(c) <= p.strategy.upto)
                      (bb := b, bs := x, bp := float!(c)))),
        //[MOVE] move(~S) = ~S @ ~A [~A] // p,bb,bp,bs,
        if (bp > 0.0 & ((THB & bp < bb.cost - 2 * INCREMENT) | bp > bb.cost))
                      (setCost(bb,bp + INCREMENT),          // fasten the convergence (add an increment)
                       resolve(s),
                       //[MOVE] ~S moves to ~S [~A] // p,bb,p.satisfaction,
                       true)
         else (resolve(s), false)) ]


// step1 : create the pools & solutions ---------------------------------------------------------------

RX1:Percent :: 0.2             // will be called 10 times
RX2:Percent :: 0.7             // full options = 70% of the case

// generate the pool of patters for all
[generatePool(e:Experiment)
  -> for y in e.seeds e.pool :add y,
     for i in (1 .. e.poolSize)
         let y1 := randomPattern() in
            (if ((length(y1.bids) = 0) | exists(y2 in e.pool | same?(y1,y2)))  nil
             else (e.pool :add y1)),
     //[0] ~S pool -> ~S // e,e.pool,
     for p in e.players generatePool(e,p) ]


// creates the �pools� : a list of bid patterns
[generatePool(e:Experiment,p:Player)
   -> shrink(p.pool,0),
      p.scoring := Measure(),
      p.bandwidth := Measure(),
      if (length(p.seeds) > 0)
         for y in p.seeds addPattern(p,y)
      else for y in e.pool
         (if (forall(b in y.bids | RESERVE[b.code] <= p.strategy.upto) &    // affordable
              exists(b in y.bids | b.mhz >= p.strategy.mhz))                // may reach the goal
             addPattern(p,y)) ]

[addPattern(p:Player,y:Pattern) : void
  -> let y1 := Pattern(player = p, bids = list<Bid>{copy(b,p) | b in y.bids}) in
       (y1.scoring := Measure(),
        y1.mhz := Measure(),
        y1.amounts := list<Measure>{Measure() | b in y1.bids},
        y1.maxBids := list<float>{0.0 | b in y1.bids},
        p.pool :add y1) ]
  
// random Pattern generation with max budget x
// for each band we have 3 options:  decline, bid with full option, bid with no option
// for large bids (>= 10 MHz) we automatically select the option
[randomPattern() : Pattern
  -> let y := Pattern(bids = list<Bid>()) in
        (for i in (1 .. 9)
           (if random?(RX1) 
              let x2 := RESERVE[i], opt := ((i > 3) | random?(RX2)) in
                 (y.bids :add makeBid(i,opt))),
         // make sure that the "B+C => B and C" constraint is enforced
         for b in y.bids
           (if (b.code > 4)  // multiple
             (for i in CONTENT[b.code]
                (if exists(b2 in y.bids | b2.code = i) nil  // constraint is OK for i
                 else y.bids :add makeBid(i,true)))),
         y)]


// check if two patterns are similar
[same?(y1:Pattern,y2:Pattern) : boolean
   -> forall(b in y1.bids | match?(b, y2)) & forall(b in y2.bids | match?(b,y1)) ]

[match?(b:Bid,y:Pattern) : boolean
    -> exists(b2 in y.bids | (b2.code = b.code & b2.mvno? = b.mvno?)) ]    // either no or full options
  
  
// create a given number of �problems� (i.e. Games) to be evaluated
[generateGames(e:Experiment) : void
   -> shrink(e.games,0),
      for i in (1 .. e.nGames)
        let lp := list<Pattern>(), n := size(e.players),
            s := Game(nmax = n, nCandidate = n, wins = list<integer>{0 | i in (1 .. n)}) in
         (for p in e.players
            let y := randomIn(p.pool) in
              (lp :add y,
               for b in y.bids s.bids :add b),   // warning : shared bid objects => reinit needed
          s.generation := lp,                    // tracability: know which patterns were selected
          e.games :add s) ]
  
  
// step 2: search for Nash equilibrium -----------------------------------------------
[evaluate(e:Experiment,talk?:boolean)
  -> let i := 1, n := 0 in
       for s in e.games
         (n :=  nashLoop(e,s),
          if talk? printf("[~A] === Nash (~A iter) -> ~I",i,n,score(s)),
          i :+ 1,
          // record scores (player satisfaction and bid relevance -> pattern)
          for p in e.players
              (when b := some(b in s.picked | b.player = p) in
                 when y := some(y in s.generation | y.player = p) in
                   (for i in (1 .. length(y.bids))
                      (if (y.bids[i] = b)
                          (y.maxBids[i] :max b.cost,
                           add(y.mhz,float!(LSIZE[b.code])),
                           add(y.amounts[i],b.cost)))),             // store costs
               when b := some(b in s.picked | b.player = p) in
                  (p.satisfaction := score(s,b),
                   add(p.bandwidth,float!(LSIZE[b.code])))         // store bandwidth
               else (when y := some(y in s.generation | y.player = p) in add(y.mhz,0.0),
                     p.satisfaction := 0.0,
                     add(p.bandwidth,0.0)),
               add(p.scoring,p.satisfaction)),                     // store statisfaction
          for y in s.generation
            add(y.scoring,y.player.satisfaction)) ]
  
// run a loop for search of Nash equilibrium
// this is a crude version since price may only go up and are bounded � hence the fixed point must exist
// the result is the 4-up of satisfaction (%1,%2 ..) stored in player.satisfaction
// note: there must be a time-out to get a controlled behavior
NASH:integer :: 2
[nashLoop(e:Experiment,s:Game) : integer
    -> reinit(e,s),                       // reset cost/values of bids (shared objects)
       let ct1 := 0, ct2 := 0 in
          (while (ct1 < e.nashCut)
            let n := length(e.players), i := randomIn(1,4) in
             (//[5] [~A] Nash Loop .. (~A) // ct1,ct2,
              for j in (0 .. 3)
                let k := 1 + ((i + j) mod n), p := e.players[k] in
                  (ct1 :+ 1,
                   if move(s,p)
                      (//[NASH] [~A] === ~S moves (~S) -> ~A // ct1, p, some(b in s.picked | b.player = p), p.satisfaction,
                       ct2 := 0)
                    else (ct2 :+ 1)),
              if (ct2 > length(e.players))
                  break(true)),
           if (ct1 = e.nashCut) trace(0,">>> time-out in Nash loop .. \n"),
           ct1) ]

        

// prepare the game for the solve/resolve routine
[reinit(e:Experiment,s:Game)
  -> for p in e.players shrink(p.bids,0),
     for b in s.bids
        let p := b.player, n := length(p.bids) in
           (setCost(b, RESERVE[b.code]),
            p.bids :add b,
            b.index := n + 1) ]

// step 3 : sort the best solutions -> the best patterns -------------------------------
  
// sort the patterns and shrink pools to K best
[sortPool(e:Experiment,p:Player) : void
  -> //[2] sort ~S: ~A -> ~A // p, p.pool, list{mean(y.scoring) | y in p.pool},
     sort(byScore @ Pattern,p.pool),
     shrink(p.pool,e.poolShort),
     reset(p.scoring),
     for y in p.pool reset(y.scoring) ]

// order
[byScore(y1:Pattern,y2:Pattern) : boolean 
  -> mean(y1.scoring) > mean(y2.scoring) ]
  
// microGTES algorithm for fbid: 
// assumes a set of strategies, return a result map (satisfaction %)
// and a set of preferred patterns for each player
GTES:boolean :: false
[gtes(e:Experiment,s:Scenario)  : void
  ->  time_set(),
      //[0] ==== step1 (~S) : create pools and games ================================================= // s,
      for i in (1 .. length(e.players)) (e.players[i].strategy := s.strategies[i]),
      generatePool(e),                           // create the patterns
      generateGames(e),                          // create the pattern combinations
      //[0] ==== step2 (~S): Nash evaluation [~A s] ================================================ // s,time_read() / 1000000,
      evaluate(e,GTES),                               // run the evaluation loop (Nash) for all solutions
       gtesResult(e),
      //[0] ==== step3 (~S): concentration on better patterns [~A s] ============================== // s,time_read() / 1000000,
      for p in e.players sortPool(e,p),          // select the best Pools
      generateGames(e),                          // re-run on the more plausible
      evaluate(e,GTES),
      gtesResult(e),
      logResult(e,s),
      time_show() ]
  
// display the results:
//  (1) the average satisfaction
//  (2) the more efficient pattern for each player
//  (3) its average price
[gtesResult(e:Experiment)
  -> for p in e.players
       let s := mean(p.scoring) in
       (sort(byScore @ Pattern,p.pool),
        printf("~S: ~A[~A Mhz] -> ~I\n",p,s,mean(p.bandwidth),
               (for i in (1 .. min(length(p.pool), 3))
                   printf("~S:~A[~AMHz]\n\t\t\t ",p.pool[i],mean((p.pool[i]).scoring),mean((p.pool[i]).mhz)))),
        e.results :add s,
        e.pool :add car(p.pool)) ]

// more precise display for each player
[see(p:Player) : void
  -> printf("=== ~S: ~A sat. (~A MHz [+/- ~A]) strategy:~S====== \n",p,mean(p.scoring),mean(p.bandwidth),
            stdev(p.bandwidth),p.strategy),
     for i in (1 .. min(5,length(p.pool)))
       let y := p.pool[i] in
           printf("   ~S (~A)-> ~A {~A} \n",y,mean(y.scoring),list{mean(y.amounts[i]) | i in (1 .. length(y.bids))},
                  list{y.maxBids[i] | i in (1 .. length(y.bids))}) ]

CLOUD:boolean :: false
[logResult(e:Experiment,s:Scenario) : void
  -> let p := fopen((if CLOUD (Id(*where*) /+ "\\data\\") else "") /+ string!(name(e)) /+ "-"
                    /+ string!(name(s)) /+ ".log","w") in
       // fopen( /+ string!(name(e)) /+ "-" /+ string!(name(s)),"w") in
       (use_as_output(p),
        printf("------------------ [~A s] Experiment ~S x ~S on ~A",time_read() / 1000,e,s,date!(1)),
        printf("strategie : ~I\n",for p in e.players printf("~S:~S ",p,p.strategy)),
        gtesResult(e),
        for p in e.players see(p),
        fclose(p)) ]

// we load a file of interpreter code
(#if (compiler.active? = false | compiler.loading? = true)  // load("config")
    (load(Id(*src* / "fbidv" /+ string!(Version) / "test1")))
  else nil
)


