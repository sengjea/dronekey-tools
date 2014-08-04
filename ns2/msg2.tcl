global ns_ tracefd config agents nodes
set base_time 4.00 

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
proc setloc {} {
  global ns_ tracefd config agents nodes
  $nodes(0) set X_ 16.608377307314
  $nodes(0) set Y_ 49.446991827566
  $nodes(0) set Z_ 0.000000000000
  $nodes(1) set X_ 49.337311778721
  $nodes(1) set Y_ 08.582820874924
  $nodes(1) set Z_ 20.000000000000
}
#setup
$ns_ at $base_time "setloc"
$ns_ at $base_time "$agents(0) send 3 Ho!" 
$ns_ at [expr {$base_time + 0.05 }] "$ns_ flush-trace" 
$ns_ at [expr {$base_time + 0.05 }] "flush $tracefd" 
$ns_ at [expr {$base_time + 0.05 }] "$ns_ halt" 
$ns_ resume
