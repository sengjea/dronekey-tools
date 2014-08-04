global ns_ tracefd config agents nodes

proc setloc {} {
  global ns_ tracefd config agents nodes
  $nodes(0) set X_ 0 
  $nodes(0) set Z_ 0 
  $nodes(1) set X_ 40 
  $nodes(1) set Z_ 30 
  
  $nodes(1) set Y_ 25 
  $nodes(0) set Y_ 25 
}
set base_time 5 
$ns_ at $base_time "setloc"
$ns_ at $base_time "$agents(0) send 3 Hi!" 
$ns_ at [expr {$base_time + 0.05 }] "$ns_ flush-trace" 
$ns_ at [expr {$base_time + 0.05 }] "flush $tracefd" 
$ns_ at [expr {$base_time + 0.05 }] "$ns_ halt" 
$ns_ resume
