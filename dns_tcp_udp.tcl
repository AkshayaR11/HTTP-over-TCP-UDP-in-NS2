# Create a simulator
set ns [new Simulator]

# Open trace and NAM files
set tracefile [open dns_tcp_udp.tr w]
$ns trace-all $tracefile

set namfile [open dns_tcp_udp.nam w]
$ns namtrace-all $namfile

# Define nodes for TCP-based DNS
set n0 [$ns node]  ;# Client (DNS over TCP)
set n1 [$ns node]  ;# Server (DNS over TCP)

# Define nodes for UDP-based DNS
set n2 [$ns node]  ;# Client (DNS over UDP)
set n3 [$ns node]  ;# Server (DNS over UDP)

# **Create links between nodes**
$ns duplex-link $n0 $n1 10Mb 10ms DropTail
$ns duplex-link $n2 $n3 10Mb 10ms DropTail

# **Routing**
$ns rtproto Static

# **Create TCP Connection for DNS**
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set sink_tcp [new Agent/TCPSink]
$ns attach-agent $n1 $sink_tcp
$ns connect $tcp $sink_tcp
$tcp set fid_ 1

# **Simulating DNS Requests Over TCP (CBR)**
set dns_tcp [new Application/Traffic/CBR]
$dns_tcp attach-agent $tcp
$dns_tcp set packetSize_ 128  ;# Typical DNS query size
$dns_tcp set rate_ 512Kb

# **Create UDP Connection for DNS**
set udp [new Agent/UDP]
$ns attach-agent $n2 $udp
set sink_udp [new Agent/Null]
$ns attach-agent $n3 $sink_udp
$ns connect $udp $sink_udp
$udp set fid_ 2

# **Simulating DNS Requests Over UDP (CBR)**
set dns_udp [new Application/Traffic/CBR]
$dns_udp attach-agent $udp
$dns_udp set packetSize_ 128  ;# Typical DNS query size
$dns_udp set rate_ 512Kb

# **Start and Stop Traffic**
$ns at 0.5 "$dns_tcp start"
$ns at 1.0 "$dns_udp start"
$ns at 4.0 "$dns_tcp stop"
$ns at 4.5 "$dns_udp stop"

# **End Simulation**
$ns at 10.0 "finish"

proc finish {} {
    global ns tracefile namfile
    close $tracefile
    close $namfile
    exec nam dns_tcp_udp.nam &
    exit 0
}

$ns run
