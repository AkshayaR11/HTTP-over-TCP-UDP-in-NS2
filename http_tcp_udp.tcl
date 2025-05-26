# Create the simulator
set ns [new Simulator]

# Open trace and NAM files
set tracefile [open http_tcp_udp.tr w]
$ns trace-all $tracefile

set namfile [open http_tcp_udp.nam w]
$ns namtrace-all $namfile

# Create nodes
set n0 [$ns node]  ;# HTTP Client over TCP
set n1 [$ns node]  ;# HTTP Server over TCP
set n2 [$ns node]  ;# HTTP Client over UDP
set n3 [$ns node]  ;# HTTP Server over UDP

# Create links
$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n2 $n3 10Mb 10ms DropTail

# Enable static routing
$ns rtproto Static

# TCP agents for HTTP
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set sink_tcp [new Agent/TCPSink]
$ns attach-agent $n1 $sink_tcp
$ns connect $tcp $sink_tcp
$tcp set fid_ 1

# Simulate HTTP over TCP using CBR
set http_tcp [new Application/Traffic/CBR]
$http_tcp attach-agent $tcp
$http_tcp set packetSize_ 1024   ;# Bigger packet like HTTP
$http_tcp set rate_ 1Mb

# UDP agents for HTTP
set udp [new Agent/UDP]
$ns attach-agent $n2 $udp
set sink_udp [new Agent/Null]
$ns attach-agent $n3 $sink_udp
$ns connect $udp $sink_udp
$udp set fid_ 2

# Simulate HTTP over UDP using CBR
set http_udp [new Application/Traffic/CBR]
$http_udp attach-agent $udp
$http_udp set packetSize_ 1024
$http_udp set rate_ 1Mb

# Start and stop traffic
$ns at 0.5 "$http_tcp start"
$ns at 1.0 "$http_udp start"
$ns at 4.0 "$http_tcp stop"
$ns at 4.5 "$http_udp stop"

# End simulation
$ns at 10.0 "finish"

proc finish {} {
    global ns tracefile namfile
    close $tracefile
    close $namfile
    exec nam http_tcp_udp.nam &
    exit 0
}

$ns run
