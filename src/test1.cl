// ********************************************************************
// *       FBID: Frequency (lte) BID Simulation                       *
// *       copyright (C) 2011 Yves Caseau                             *
// *       file: test1.cl                                             *
// ********************************************************************


Free :: Player(strategy = grab(10,800))
BYT :: Player(strategy = grab(5,500))
SFR :: Player(strategy = grab(10,1000))
ORG :: Player(strategy = grab(15,1200))



// simple test files
BD1 :: bid(A(Free,510),B(Free,300),C(Free,300),
          B(BYT,300),C(BYT,300),
          A(SFR,500),B(SFR,501),C(SFR,500),BC(SFR,667),
          D(ORG,800))

// test from slide 11
BD2 :: bid(A(Free,500),B(Free,300),C(Free,300),
          A(BYT,420),B(BYT,320),C(BYT,300),
          A(SFR,400),B(SFR,300,false,false),C(SFR,300,false,false),D(SFR,900),BC(SFR,800),
          B(ORG,300,false,false),C(ORG,300,false,false),D(ORG,800),BC(ORG,850))

// test from slide 23
BD3 :: bid(A(Free,500),B(Free,300,false,false),C(Free,300,false,false),
          A(BYT,420),B(BYT,320),C(BYT,300),
          A(SFR,400),B(SFR,300,false,false),C(SFR,300,false,false),BC(SFR,703),
          D(ORG,800))


// fun test
BD4 :: bid(D(Free,1000,false,false),
          A(BYT,420),B(BYT,320),C(BYT,300),
          A(SFR,400),B(SFR,300,false,false),C(SFR,300,false,false),BC(SFR,703),
          D(ORG,800))


BD5 :: bid(A(Free,700),C(Free,600),B(Free,600),
          A(BYT,500),B(BYT,460),C(BYT,450),
          A(SFR,800),B(SFR,300,false,false),C(SFR,300,false,false),D(SFR,1300),
          AC(ORG,1600))

// scenarios -----------------------------------------------------------------------

// regular scenario - to be tuned with H de Tournadre :)
S1 :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,1000), grab(15,1200)))
S1a :: Scenario(  strategies = list(grab(10,500), grab(5,500), grab(10,1000), grab(15,1200)))   // Free is like us

// test that SFR and Free are equivalent + Orange well endowed
S2 :: Scenario(   strategies = list(grab(10,800), grab(10,500), grab(10,800), grab(10,3000)))

// variation Bytel has more money / guts
S3a :: Scenario(  strategies = list(grab(10,800), grab(5,800), grab(10,1000), grab(15,1200)))
S3b :: Scenario(  strategies = list(grab(10,800), grab(10,500), grab(10,1000), grab(15,1200)))

// sensitivity analysis wrt Free's money and ambition
S4a :: Scenario(  strategies = list(grab(5,400), grab(5,500), grab(10,1000), grab(15,1200)))
S4b :: Scenario(  strategies = list(grab(5,500), grab(5,500), grab(10,1000), grab(15,1200)))
S4c :: Scenario(  strategies = list(grab(5,600), grab(5,500), grab(10,1000), grab(15,1200)))
S4d :: Scenario(  strategies = list(grab(5,700), grab(5,500), grab(10,1000), grab(15,1200)))
S4e :: Scenario(  strategies = list(grab(10,600), grab(5,500), grab(10,1000), grab(15,1200)))
S4f :: Scenario(  strategies = list(grab(10,700), grab(5,500), grab(10,1000), grab(15,1200)))
S4g :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,1000), grab(15,1200)))
S4h :: Scenario(  strategies = list(grab(10,1000), grab(5,500), grab(10,1000), grab(15,1200)))

// sensitivity wrt to Orange
S5a :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,1000), grab(10,800)))
S5b :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,1000), grab(10,1000)))
S5c :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,1000), grab(10,1200)))
S5d :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,1000), grab(10,800)))
S5e :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,1000), grab(15,1000)))
S5f :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,1000), grab(15,1400)))
S5g :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,1000), grab(15,1600)))

// sensitivity wrt to SFR
S6a :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,600), grab(15,1200)))
S6b :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,800), grab(15,1200)))
S6c :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(10,1200), grab(15,1200)))
S6d :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(15,1000), grab(15,1200)))
S6e :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(15,1200), grab(15,1200)))
S6f :: Scenario(  strategies = list(grab(10,800), grab(5,500), grab(15,1400), grab(15,1200)))


// experiments for Herve
S7a :: Scenario(  strategies = list(grab(10,700), grab(5,500), grab(10,1000), grab(10,1200)))
S7b :: Scenario(  strategies = list(grab(10,600), grab(5,500), grab(10,1000), grab(10,1200)))
S7c :: Scenario(  strategies = list(grab(5,500), grab(5,500), grab(10,1000), grab(10,1200)))
S7d :: Scenario(  strategies = list(grab(10,700), grab(5,500), grab(15,1500), grab(15,1700)))
S7e :: Scenario(  strategies = list(grab(10,600), grab(5,500), grab(15,1500), grab(15,1700)))
S7f :: Scenario(  strategies = list(grab(5,500), grab(5,500), grab(15,1500), grab(15,1700)))

// new: list of patterns that we want to explore
SEED :: patterns({1},{2},{3},{4},{2,3,5},{1,2,3,5},{1,2,6},{1,4},{1,4,2})

// easy experiment for debug
E0 :: Experiment(
  players = list(Free,BYT,SFR,ORG),
  seeds = SEED,
  poolSize = 10,     // to be tuned
  poolShort = 3,     //
  nGames = 20,      // should be 10000 (depends on Nash)
  nashCut = 1000)    // timeOut for Nash


// real experiments
E1 :: Experiment(
  players = list(Free,BYT,SFR,ORG),
  seeds = SEED,
  poolSize = 30,     // to be tuned
  poolShort = 10,     //
  nGames = 1000,      // should be 10000 (depends on Nash)
  nashCut = 1000)    // timeOut for Nash

// big experiments
E2 :: Experiment(
  players = list(Free,BYT,SFR,ORG),
  seeds = SEED,
  poolSize = 100,     // to be tuned
  poolShort = 10,     //
  nGames = 10000,      // should be 10000 (depends on Nash)
  nashCut = 1000)    // timeOut for Nash

// reall big experiments
E3 :: Experiment(
  players = list(Free,BYT,SFR,ORG),
  seeds = SEED,
  poolSize = 200,     // to be tuned
  poolShort = 20,     //
  nGames = 30000,      // should be 10000 (depends on Nash)
  nashCut = 1000)    // timeOut for Nash


G:Game :: unknown

[go(e:Experiment,s:Scenario)
  -> for i in (1 .. length(e.players)) (e.players[i].strategy := s.strategies[i]),
      generatePool(e),     // create the patterns
      generateGames(e),    // create the pattern combinations
      G := e.games[1],
      go(e,G)]

[go(e:Experiment,s:Game)
  -> reinit(e,s),
     resolve(s) ]

// debug()
[move(g:Game) 
    -> for p in Player move(G,p) ]

[go1(e:Experiment) 
   -> evaluate(e,true) ]

[go() -> gtes(E1,S1)]
