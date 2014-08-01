global ns_ namtrace config agents nodes
set base_time 2.00 
$ns_ at $base_time "$ns_ connect $agents(0) $agents(1)"
$ns_ at $base_time "$agents(0) send 3 Hi!" 
$ns_ at [expr {$base_time + 0.5 }] "$ns_ flush-trace" 
$ns_ at [expr {$base_time + 0.5 }] "flush $namtrace" 
$ns_ at [expr {$base_time + 0.5 }] "$ns_ halt" 
$ns_ resume
