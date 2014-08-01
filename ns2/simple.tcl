set config(channel)           Channel/WirelessChannel    ;# Channel Type
set config(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set config(netif)          Phy/WirelessPhy/802_15_4
set config(mac)            Mac/802_15_4
set config(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set config(ll)             LL                         ;# link layer type
set config(ant)            Antenna/OmniAntenna        ;# antenna model
set config(ifqlen)         50                         ;# max packet in ifq
set config(num_nodes)      2                          ;# number of mobilenodes
set config(rp)             AODV                       ;# routing protocol
set config(x)		50
set config(y)		50

set ns_ [new Simulator]

set tracefd [ open ./simple.tr w]
$ns_ trace-all $tracefd

set namtrace     [open ./simple.nam a]
$ns_ namtrace-all-wireless $namtrace $config(x) $config(y)

# inform nam that this is a trace file for wpan (special handling needed)
$ns_ puts-nam-traceall {# nam4wpan #}		;

# default = off (should be turned on before other 'wpanNam' commands can work)
Mac/802_15_4 wpanNam namStatus on		;

Phy/WirelessPhy set CSThresh_ 1.56962e-07 
Phy/WirelessPhy set RXThresh_ 8.54570e-07 

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $config(x) $config(y)

#set up channel object
set channel [ new $config(channel) ]

# Create God
set god_ [create-god $config(num_nodes)]

#ns configs
$ns_ node-config -adhocRouting $config(rp) \
		-llType $config(ll) \
		-macType $config(mac) \
		-ifqType $config(ifq) \
		-ifqLen $config(ifqlen) \
		-antType $config(ant) \
		-propType $config(prop) \
		-phyType $config(netif) \
		-topoInstance $topo \
		-agentTrace OFF \
		-routerTrace OFF \
		-macTrace ON \
		-movementTrace OFF \
    -channel $channel

set nodes(0) [$ns_ node]	
# disable random motion
$nodes(0) random-motion 0		;
$nodes(0) set X_ 16.608377307314
$nodes(0) set Y_ 19.446991827566
$nodes(0) set Z_ 0.000000000000
set agents(0) [new Agent/UDP]
$ns_ attach-agent $nodes(0) $agents(0)
$ns_ initial_node_pos $nodes(0) 2

set nodes(1) [$ns_ node]	
# disable random motion
$nodes(1) random-motion 0		;
$nodes(1) set X_ 19.337311778721
$nodes(1) set Y_ 18.582820874924
$nodes(1) set Z_ 0.000000000000
set agents(1) [new Agent/UDP]
$ns_ attach-agent $nodes(1) $agents(1)
$ns_ initial_node_pos $nodes(1) 2
proc tcl_poller {} {
  global ns_ tracefd nodes agents 
  while {1} { 
    source ./poll.tcl
  }
}

$ns_ at 0.05 "tcl_poller" 
$ns_ run
