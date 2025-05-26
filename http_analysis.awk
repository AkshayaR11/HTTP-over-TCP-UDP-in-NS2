{
    if ($1 == "r" && tolower($5) ~ /tcp/) {
        tcp_count++;
        tcp_bytes += $6;
        if (tcp_start == 0) tcp_start = $2;
        tcp_end = $2;
    }
    if ($1 == "r" && tolower($5) ~ /cbr/) {
        udp_count++;
        udp_bytes += $6;
        if (udp_start == 0) udp_start = $2;
        udp_end = $2;
    }
}
END {
    tcp_duration = tcp_end - tcp_start;
    udp_duration = udp_end - udp_start;
    tcp_throughput = (tcp_bytes * 8) / tcp_duration / 1000;
    udp_throughput = (udp_bytes * 8) / udp_duration / 1000;

    print "HTTP Performance Analysis:";
    print "----------------------------------";
    print "TCP Packets Received: " tcp_count;
    print "UDP Packets Received: " udp_count;
    print "----------------------------------";
    print "TCP Total Bytes: " tcp_bytes " bytes";
    print "UDP Total Bytes: " udp_bytes " bytes";
    print "----------------------------------";
    print "TCP Duration: " tcp_duration " sec";
    print "UDP Duration: " udp_duration " sec";
    print "----------------------------------";
    print "TCP Throughput: " tcp_throughput " Kbps";
    print "UDP Throughput: " udp_throughput " Kbps";
}
