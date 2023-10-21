// +-------------------------------------------------------------------------+
// |     LTE Frequency Bid Simulation (fbid)                                 |
// |     readme                                                              |
// |     Copyright (C) Yves Caseau, 2011-2023                                |
// +-------------------------------------------------------------------------+

VERSION : V0.2 

1. Project Description 
======================

This is a super simplified version of applying GTES to simulate the bid for 2011 LTE licences (first round)

2. Version Description:  (V0.2)
======================

this version has been ported to CLAIRE 4

3. Installation:
===============

this is a standard module, look at init.cl in wk.
	
4. Claire files
===============

log.cl:            as usual, the log file => where to look firt to read about the current state
problem.cl         data model: companies, simple simpulation
simul.cl           this file contains the advanced simulation methods (simple GTES, sensitivity analysis)
test1.cl           problem configuration : the four operators
	
5. Related doc
==============
unfortunately the documents that were produced together with this one week-en coding effort are proprietary

6. Data
=======
look at test1.cl for the input
the output of the simulations may be found in the data directory


7.Test and run
==============

go(e:Experiment)
Experiments are described in the test1.cl file


