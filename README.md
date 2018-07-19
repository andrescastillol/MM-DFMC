# MM-DFMC
The meta-mesh dual-failure minimum capacity (MM-DFMC) ILP design model seek to design a minimum-cost transport network that is fully restorable in the event of all degree-3 nodes dual span failure scenarios. 

## The Meta-Mesh Design
The meta-mesh approach is a form of the conventional span restoration technique that takes advantage of the existence of chains of degree-2 nodes in the network allowing a reduction in spare capacity requirements. Consider the chain of degree-2 nodes shown in Figure 1, with working and spare capacities indicated by the wi and si. Using span restoration to provide the restorability of the spans in that chain will require at least as much spare capacity on each span within the chain as the maximum working capacity value allocated within the chain (except for the span with the maximum working capacity that will need spare capacity equal to the second highest working capacity in the chain). This is due to the fact that all working capacity on a span within the chain must be restored back through all surviving spans in the chain to the anchor nodes (the degree-3 nodes on the ends of the chain), and then back to the network.

<p align="center">
  <img width="500" src="Images/Fig1.jpg">
</p>

However, a closer look at the nature of the working capacity on the spans in the chain will reveal something that it is shown in Figure 2. Only some of the working capacities on the spans within the chain will arise from working traffic that originates and/or terminates at one of the chains within the span; we call this local working flow, denoted by wLOC. The remainder of the working capacity on the chain’s spans arises from working traffic that fully transits the chain, originating and terminating elsewhere within the greater network; we call this express working flow, denoted by wEXP.

The meta-mesh approach takes advantage of this breakdown with the realization that it is only the capacity arising from the local flow that needs to be restored by looping back all the way through the interior of the chain. The capacity that arises from express flow, on the other hand, can be allowed to fail all the way back to the anchor nodes in much the same way as stub-release in path restoration. As a result, the spans within the chain only require sufficient spare capacity to restore local flow capacity, as illustrated in Figure 3, where only 45 units of spare capacity would be needed within the chain to achieve full single failure restorability. This capacity is equal to the largest amount of working flow across the chain and, therefore, the chain spans now require 35 fewer units of spare capacity investment than needed previously (in Figure 1). Those fewer 35 units are now the express working flow.

<p align="center">
  <img width="500" src="Images/Fig2.jpg">
</p>

<p align="center">
  <img width="500" src="Images/Fig3.jpg">
</p>
