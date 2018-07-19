# Span-Restorable Meta-Mesh Joint Capacity Placement Network Optimization under Dual-Failure Scenario
# 17-March-2017 by Andres Castillo
# All Rights Reserved.

# ********************************************************

# University of Alberta
# DICE Building, 10th Floor 
# 9203 116 Street NW
# Edmonton, Alberta, Canada
# T6G 1R1

#****************************
# SETS
#****************************

set SPANS;
# set of all spans

set DIRECT_SPANS;
# set of spans that are not bypassed (i.e. not a part of any bypassed chain)

set BYPASS_SPANS;
# set of spans that act as bypasses for chains

set CHAIN_SPANS := {SPANS diff (DIRECT_SPANS union BYPASS_SPANS)};
# set of chain spans 

set REST_ROUTES{i in SPANS};
# set of all restoration paths for each span failure i

set DEMANDS;
# set of all demand pairs or node pairs

set WORK_ROUTES{r in DEMANDS};
# set of all working routes for each demand pair r

# ************************
# PARAMETERS
# ************************

param Bypass{i in CHAIN_SPANS} symbolic;
param Cost{j in SPANS} default 1;
# cost of a unit of capacity on span j

param DemandUnits{r in DEMANDS} default 0;
# number of demand units between node pair r

param DeltaRestRoutes{i in SPANS, j in SPANS, p in REST_ROUTES[i]} default 0;	
# equal to 1 if pth restoration route for failure of span i uses span j and 0 otherwise

param ZetaWorkRoutes{j in SPANS, r in DEMANDS, q in WORK_ROUTES[r]} default 0;
# equal to 1 if qth working route for demand between node pair r uses span k and 0 otherwise

param MaxFlow := sum {r in DEMANDS} DemandUnits[r];
# Used for upper bounds on flow and capacity variables.

# ************************
# VARIABLES
# ************************

var gwrkflow{r in DEMANDS, q in WORK_ROUTES[r]} >=0, <=10000;
# working capacity required by qth working route for demand between node pair r

var flowrest{i in SPANS, p in REST_ROUTES[i]} >=0, <=10000;
# restoration flow through pth restoration route for failure of span i

var flowrest_dual{i in SPANS, j in SPANS, p in REST_ROUTES[i]: i<>j} >= 0 integer, <=10000;
# restoration flow through pth restoration route for failure of span i when a span j has failed simultaneously

var totalDwork >=0, <= (( sum{j in SPANS} Cost[j] ) * MaxFlow);
var totalCwork >=0, <= (( sum{j in SPANS} Cost[j] ) * MaxFlow);
var totalBwork >=0, <= (( sum{j in SPANS} Cost[j] ) * MaxFlow);
var totalspare >=0, <= (( sum{j in SPANS} Cost[j] ) * MaxFlow);

var work{j in SPANS} >=0, <=100000 integer;
# number of working links placed on span j

var spare{j in SPANS} >=0, <=100000 integer;
# number of spare links place on span j

# ************************
# OBJECTIVE FUNCTION
# ************************

minimize TotalCost: totalDwork + totalCwork + totalBwork + totalspare;
# minimize totcost: sum{j in SPANS} Cost[j] * (spare[j] + work[j]);

# ************************
# CONSTRAINTS
# ************************

subject to calculate_totalDwork:
totalDwork = sum{j in DIRECT_SPANS} work[j] * Cost[j];

subject to calculate_totalCwork:
totalCwork = sum{j in CHAIN_SPANS} work[j] * Cost[j];

subject to calculate_totalBwork:
totalBwork = sum{j in BYPASS_SPANS} work[j] * Cost[j];

subject to calculate_totalspare:
totalspare = sum{j in SPANS} spare[j] * Cost[j];

	# Restoration of a Single-Failure with Chain-Wise Dual-Failure Sceneario
	subject to restn1{i in DIRECT_SPANS}: 
		sum{p in REST_ROUTES[i]} flowrest[i,p] = work[i];

	subject to restn12{i in CHAIN_SPANS, k in BYPASS_SPANS: k=Bypass[i]}: 
		sum{p in REST_ROUTES[i]: DeltaRestRoutes[i,k,p] = 0} flowrest[i,p] = work[i];

	subject to restn13{i in CHAIN_SPANS, k in BYPASS_SPANS: k=Bypass[i]}: 
		sum{p in REST_ROUTES[k]: DeltaRestRoutes[k,i,p] = 0} flowrest[k,p] = work[k];

	subject to sparasst1{i in DIRECT_SPANS, j in SPANS: i<>j}:
		spare[j] >= sum{p in REST_ROUTES[i]} (DeltaRestRoutes[i,j,p] * flowrest[i,p]);

	subject to sparasst12{i in CHAIN_SPANS, j in SPANS, k in BYPASS_SPANS: i<>j<>k and k=Bypass[i]}:
		spare[j] >= sum{p in REST_ROUTES[i]} DeltaRestRoutes[i,j,p] * flowrest[i,p] + 
					sum{p in REST_ROUTES[k]} DeltaRestRoutes[k,j,p] * flowrest[k,p];

	# Restoration of a Dual-Failure with Chain-Wise Triple-Logical Failure Scenario
	subject to restn2a{i in DIRECT_SPANS, j in DIRECT_SPANS: i<>j}:
		sum{p in REST_ROUTES[i]} flowrest_dual[i,j,p] = work[i];

	subject to restn22a{i in CHAIN_SPANS, j in DIRECT_SPANS, k in BYPASS_SPANS: i<>j<>k and k=Bypass[i]}:
		sum{p in REST_ROUTES[i]: DeltaRestRoutes[i,k,p] = 0} flowrest_dual[i,j,p] = work[i]; 

	subject to restn22b{i in CHAIN_SPANS, j in DIRECT_SPANS, k in BYPASS_SPANS: i<>j<>k and k=Bypass[i]}:
		sum{p in REST_ROUTES[j]: DeltaRestRoutes[j,k,p] = 0} flowrest_dual[j,i,p] = work[j];
	
	subject to restn22c{i in CHAIN_SPANS, j in DIRECT_SPANS, k in BYPASS_SPANS: i<>j<>k and k=Bypass[i]}:
		sum{p in REST_ROUTES[k]: DeltaRestRoutes[k,i,p] = 0} flowrest_dual[k,j,p] = work[k];

	subject to restn23a{i in CHAIN_SPANS, j in CHAIN_SPANS, k in BYPASS_SPANS, l in BYPASS_SPANS: i<>j and k<>l and k=Bypass[i] and l=Bypass[j]}:
		sum{p in REST_ROUTES[i]: (DeltaRestRoutes[i,k,p] = 0 and DeltaRestRoutes[i,l,p] = 0)} flowrest_dual[i,j,p] = work[i];

	subject to restn23b{i in CHAIN_SPANS, j in CHAIN_SPANS, k in BYPASS_SPANS, l in BYPASS_SPANS: i<>j and k<>l and k=Bypass[i] and l=Bypass[j]}:
		sum{p in REST_ROUTES[j]: (DeltaRestRoutes[j,l,p] = 0 and DeltaRestRoutes[j,k,p] = 0)} flowrest_dual[j,i,p] = work[j];

	subject to restn23c{i in CHAIN_SPANS, j in CHAIN_SPANS, k in BYPASS_SPANS, l in BYPASS_SPANS: i<>j and k<>l and k=Bypass[i] and l=Bypass[j]}:
		sum{p in REST_ROUTES[k]: (DeltaRestRoutes[k,i,p] = 0 and DeltaRestRoutes[k,l,p] = 0)} flowrest_dual[k,j,p] = work[k];

	subject to restn23d{i in CHAIN_SPANS, j in CHAIN_SPANS, k in BYPASS_SPANS, l in BYPASS_SPANS: i<>j and k<>l and k=Bypass[i] and l=Bypass[j]}:
		sum{p in REST_ROUTES[l]: (DeltaRestRoutes[l,j,p] = 0 and DeltaRestRoutes[l,k,p] = 0)} flowrest_dual[l,i,p] = work[l];
		
	subject to sparasst2{i in DIRECT_SPANS, j in DIRECT_SPANS, k in SPANS: i<>j<>k}:
		spare[k] >= sum{p in REST_ROUTES[i]} (flowrest_dual[i,j,p] * DeltaRestRoutes[i,k,p]) +
					sum{p in REST_ROUTES[j]} (flowrest_dual[j,i,p] * DeltaRestRoutes[j,k,p]);

	subject to sparasst22{i in CHAIN_SPANS, j in DIRECT_SPANS, l in SPANS, k in BYPASS_SPANS: i<>j<>l<>k and k=Bypass[i]}:
		spare[l] >= sum{p in REST_ROUTES[i]} (flowrest_dual[i,j,p] * DeltaRestRoutes[i,l,p]) +
					sum{p in REST_ROUTES[j]} (flowrest_dual[j,i,p] * DeltaRestRoutes[j,l,p]) +
					sum{p in REST_ROUTES[k]} (flowrest_dual[k,j,p] * DeltaRestRoutes[k,l,p]);
				
	subject to sparasst23{i in CHAIN_SPANS, j in CHAIN_SPANS, w in SPANS, k in BYPASS_SPANS, l in BYPASS_SPANS: i<>j<>k<>l<>w and k=Bypass[i] and l=Bypass[j]}:
		spare[w] >= sum{p in REST_ROUTES[i]} (flowrest_dual[i,j,p] * DeltaRestRoutes[i,w,p]) + 
					sum{p in REST_ROUTES[j]} (flowrest_dual[j,i,p] * DeltaRestRoutes[j,w,p]) +
					sum{p in REST_ROUTES[k]} (flowrest_dual[k,j,p] * DeltaRestRoutes[k,w,p]) +
					sum{p in REST_ROUTES[l]} (flowrest_dual[l,i,p] * DeltaRestRoutes[l,w,p]);

# Other constraints
subject to limit1a{i in DIRECT_SPANS, j in DIRECT_SPANS: i<>j}:
	sum{p in REST_ROUTES[i]: DeltaRestRoutes[i,j,p] = 1} flowrest_dual[i,j,p] = 0;

subject to limit1b{i in DIRECT_SPANS, j in DIRECT_SPANS: i<>j}:
	sum{p in REST_ROUTES[j]: DeltaRestRoutes[j,i,p] = 1} flowrest_dual[j,i,p] = 0;

subject to limit2a{i in CHAIN_SPANS, j in DIRECT_SPANS, k in BYPASS_SPANS: i<>j<>k and k=Bypass[i]}:
	sum{p in REST_ROUTES[i]: DeltaRestRoutes[i,j,p] = 1} flowrest_dual[i,j,p] = 0;

subject to limit2b{i in CHAIN_SPANS, j in DIRECT_SPANS, k in BYPASS_SPANS: i<>j<>k and k=Bypass[i]}:
	sum{p in REST_ROUTES[j]: DeltaRestRoutes[j,i,p] = 1} flowrest_dual[j,i,p] = 0;

subject to limit2c{i in CHAIN_SPANS, j in DIRECT_SPANS, k in BYPASS_SPANS: i<>j<>k and k=Bypass[i]}:
	sum{p in REST_ROUTES[k]: DeltaRestRoutes[k,j,p] = 1} flowrest_dual[k,j,p] = 0;

subject to limit3a{i in CHAIN_SPANS, j in CHAIN_SPANS, k in BYPASS_SPANS, l in BYPASS_SPANS: i<>j and k<>l and k=Bypass[i] and l=Bypass[j]}:
	sum{p in REST_ROUTES[i]: DeltaRestRoutes[i,j,p] = 1} flowrest_dual[i,j,p] = 0;

subject to limit3b{i in CHAIN_SPANS, j in CHAIN_SPANS, k in BYPASS_SPANS, l in BYPASS_SPANS: i<>j and k<>l and k=Bypass[i] and l=Bypass[j]}:
	sum{p in REST_ROUTES[j]: DeltaRestRoutes[j,i,p] = 1} flowrest_dual[j,i,p] = 0;

subject to limit3c{i in CHAIN_SPANS, j in CHAIN_SPANS, k in BYPASS_SPANS, l in BYPASS_SPANS: i<>j and k<>l and k=Bypass[i] and l=Bypass[j]}:
	sum{p in REST_ROUTES[k]: DeltaRestRoutes[k,j,p] = 1} flowrest_dual[k,j,p] = 0;

subject to limit3d{i in CHAIN_SPANS, j in CHAIN_SPANS, k in BYPASS_SPANS, l in BYPASS_SPANS: i<>j and k<>l and k=Bypass[i] and l=Bypass[j]}:
	sum{p in REST_ROUTES[l]: DeltaRestRoutes[l,i,p] = 1} flowrest_dual[l,i,p] = 0;

subject to demmet{r in DEMANDS}:
	sum{q in WORK_ROUTES[r]} gwrkflow[r,q] = DemandUnits[r];

subject to workasst{j in SPANS}:
	work[j] = sum{r in DEMANDS, q in WORK_ROUTES[r]} ZetaWorkRoutes[j,r,q] * gwrkflow[r,q];