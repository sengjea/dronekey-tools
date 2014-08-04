set config(channel)        Channel/WirelessChannel    ;# Channel Type
set config(prop)           Propagation/Shadowing      ;# radio-propagation model
set config(netif)          Phy/WirelessPhy/802_15_4
set config(mac)            Mac/802_15_4
set config(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set config(ll)             LL                         ;# link layer type
set config(ant)            Antenna/OmniAntenna        ;# antenna model
set config(ifqlen)         5                          ;# max packet in ifq
set config(num_nodes)      2                          ;# number of mobilenodes
set config(rp)             DumbAgent                  ;# routing protocol
set config(x)		50
set config(y)		50

set ns_ [new Simulator]

set tracefd [ open ./simple.tr w]
$ns_ trace-all $tracefd

set namtrace     [open ./simple.nam w]
$ns_ namtrace-all-wireless $namtrace $config(x) $config(y)

# inform nam that this is a trace file for wpan (special handling needed)
$ns_ puts-nam-traceall {# nam4wpan #}		;

# default = off (should be turned on before other 'wpanNam' commands can work)
Mac/802_15_4 wpanNam namStatus on		;

Phy/WirelessPhy set CSThresh_ 1.56962e-07 
Phy/WirelessPhy set RXThresh_ 8.54570e-07 

#Reset Antenna location
Antenna/OmniAntenna set Z_ 0.0

#Set PHY layer attributes
puts "Phy/WirelessPhy Pt_ = [ Phy/WirelessPhy set Pt_ ]"
puts "Phy/WirelessPhy L_ = [ Phy/WirelessPhy set L_ ]"

#Set Propagation Model attributes
Propagation/Shadowing set dist0_ 1
Propagation/Shadowing set pathlossExp_ 5
Propagation/Shadowing seed predef 42

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
		-agentTrace ON \
		-routerTrace ON \
		-phyTrace ON \
		-macTrace ON \
		-movementTrace OFF \
    -channel $channel

proc tcl_poller {} {
  while {1} { 
    source ./poll.tcl
  }
}
proc setup {} {
  global ns_ tracefd config agents nodes
  set nodes(0) [$ns_ node]	
  set agents(0) [new Agent/UDP]
  $ns_ attach-agent $nodes(0) $agents(0)

  set nodes(1) [$ns_ node]	
  set agents(1) [new Agent/UDP]
  $ns_ attach-agent $nodes(1) $agents(1)

  $ns_ connect $agents(0) $agents(1)
}

setup
$ns_ at 0.05 "tcl_poller" 
$ns_ run
