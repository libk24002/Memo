# Network Diagnostics and Troubleshooting Guide

Comprehensive manual for network diagnostic tools, connectivity testing, and troubleshooting.

---

## Table of Contents

1. [Overview](#overview)
2. [Connectivity Testing](#connectivity-testing)
3. [DNS Resolution](#dns-resolution)
4. [Port and Service Testing](#port-and-service-testing)
5. [Network Routing](#network-routing)
6. [Network Interface Management](#network-interface-management)
7. [Packet Analysis](#packet-analysis)
8. [Bandwidth and Performance](#bandwidth-and-performance)
9. [Troubleshooting Workflows](#troubleshooting-workflows)
10. [Best Practices](#best-practices)

---

## Overview

Network diagnostics involves testing connectivity, resolving DNS issues, analyzing traffic, and identifying bottlenecks or failures.

### Core Tools

- **ping** - Test basic connectivity and measure latency
- **traceroute/tracepath** - Trace network paths and identify routing issues
- **nslookup/dig/host** - DNS resolution and troubleshooting
- **netstat/ss** - Display network connections and statistics
- **telnet/nc (netcat)** - Test TCP/UDP connectivity
- **tcpdump** - Packet capture and analysis
- **ip/ifconfig** - Network interface configuration
- **arp** - Address Resolution Protocol management
- **iptables/firewalld** - Firewall configuration and troubleshooting
- **nmap** - Network scanning and service discovery

---

## Connectivity Testing

### ping - Test Reachability

**Basic Syntax:**
```bash
ping [options] <host>
```

**Common Usage:**
```bash
# Basic ping
ping google.com

# Send specific number of packets
ping -c 4 8.8.8.8

# Set packet size (bytes)
ping -s 1024 example.com

# Set interval between packets (seconds)
ping -i 0.2 192.168.1.1

# Flood ping (requires root, for testing)
sudo ping -f 10.0.0.1

# Ping with timestamp
ping -D google.com

# Set timeout (seconds)
ping -W 2 unreachable.host

# Quiet output (summary only)
ping -q -c 10 example.com

# IPv6 ping
ping6 google.com
```

**Interpreting Results:**
```bash
# Good connectivity
64 bytes from example.com (93.184.216.34): icmp_seq=1 ttl=56 time=15.2 ms

# Packet loss indicator
10 packets transmitted, 8 received, 20% packet loss

# High latency (>100ms typically problematic)
time=250 ms

# Destination unreachable
From 192.168.1.1 icmp_seq=1 Destination Host Unreachable
```

**Use Cases:**
- Test if a host is reachable
- Measure round-trip time (latency)
- Detect packet loss
- Verify network stability over time

---

## DNS Resolution

### nslookup - Query DNS Servers

**Basic Syntax:**
```bash
nslookup [options] <domain> [dns-server]
```

**Common Usage:**
```bash
# Basic DNS lookup
nslookup example.com

# Query specific DNS server
nslookup example.com 8.8.8.8

# Reverse DNS lookup
nslookup 93.184.216.34

# Query specific record type
nslookup -query=MX example.com
nslookup -query=NS example.com
nslookup -query=TXT example.com

# Interactive mode
nslookup
> server 1.1.1.1
> set type=A
> example.com
> exit
```

### dig - Advanced DNS Queries

**Basic Syntax:**
```bash
dig [options] <domain> [record-type]
```

**Common Usage:**
```bash
# Basic query
dig example.com

# Query specific record type
dig example.com A
dig example.com MX
dig example.com NS
dig example.com TXT
dig example.com AAAA    # IPv6

# Short answer only
dig +short example.com

# Query specific DNS server
dig @8.8.8.8 example.com

# Reverse DNS lookup
dig -x 93.184.216.34

# Trace DNS resolution path
dig +trace example.com

# Query all record types
dig example.com ANY

# No recursion
dig +norecurse example.com

# Show query time
dig example.com | grep "Query time"
```

### host - Simple DNS Lookup

**Common Usage:**
```bash
# Basic lookup
host example.com

# Verbose output
host -v example.com

# Query specific record type
host -t MX example.com
host -t NS example.com

# Reverse lookup
host 93.184.216.34

# Use specific DNS server
host example.com 8.8.8.8
```

---

## Port and Service Testing

### telnet - Test TCP Connections

**Basic Syntax:**
```bash
telnet <host> <port>
```

**Common Usage:**
```bash
# Test HTTP port
telnet example.com 80

# Test HTTPS port
telnet example.com 443

# Test SSH port
telnet 192.168.1.100 22

# Test custom application port
telnet api.example.com 8080

# Success output:
Trying 93.184.216.34...
Connected to example.com.
Escape character is '^]'.

# Failure output:
telnet: Unable to connect to remote host: Connection refused
```

### nc (netcat) - Network Swiss Army Knife

**Basic Syntax:**
```bash
nc [options] <host> <port>
```

**Common Usage:**
```bash
# Test TCP port
nc -zv example.com 80

# Test UDP port
nc -zuv example.com 53

# Scan port range
nc -zv 192.168.1.100 20-100

# Set timeout (seconds)
nc -zv -w 3 example.com 443

# Listen on port (server mode)
nc -l 8080

# Transfer file
# Receiver:
nc -l 9999 > received_file.txt
# Sender:
nc 192.168.1.100 9999 < file.txt

# Create simple chat
# Server:
nc -l 12345
# Client:
nc 192.168.1.100 12345

# Port forwarding
nc -l 8080 | nc remote-host 80
```

### nmap - Network Scanner

**Basic Syntax:**
```bash
nmap [options] <target>
```

**Common Usage:**
```bash
# Basic host scan
nmap 192.168.1.100

# Scan specific ports
nmap -p 22,80,443 192.168.1.100

# Scan port range
nmap -p 1-1000 192.168.1.100

# Scan all ports
nmap -p- 192.168.1.100

# Fast scan (top 100 ports)
nmap -F 192.168.1.100

# Service version detection
nmap -sV 192.168.1.100

# OS detection
sudo nmap -O 192.168.1.100

# Aggressive scan
sudo nmap -A 192.168.1.100

# Scan network range
nmap 192.168.1.0/24

# Ping scan (no port scan)
nmap -sn 192.168.1.0/24

# Output to file
nmap -oN scan_results.txt 192.168.1.100
```

---

## Network Routing

### traceroute - Trace Network Path

**Basic Syntax:**
```bash
traceroute [options] <host>
```

**Common Usage:**
```bash
# Basic trace
traceroute google.com

# Use ICMP instead of UDP
sudo traceroute -I google.com

# Use TCP SYN
sudo traceroute -T -p 443 google.com

# Set max hops
traceroute -m 20 example.com

# Set number of queries per hop
traceroute -q 5 example.com

# Wait timeout (seconds)
traceroute -w 2 example.com

# IPv6 trace
traceroute6 google.com
```

### tracepath - Trace Path and MTU

**Common Usage:**
```bash
# Basic trace
tracepath example.com

# Specify port
tracepath example.com:80

# Show numerical addresses
tracepath -n example.com

# Set max hops
tracepath -m 15 example.com
```

**Interpreting Results:**
```bash
# Normal hop
 1: gateway (192.168.1.1)  0.5ms
 2: isp-router (10.0.0.1)  5.2ms
 3: backbone (203.0.113.1) 15.8ms

# Timeout (packet loss or filtering)
 4: * * *

# High latency (potential bottleneck)
 5: slow-hop (198.51.100.1) 250ms

# Asymmetric routing
 6: asym-path (198.51.100.50) asymm 12
```

### ip route - Routing Table Management

**Common Usage:**
```bash
# Show routing table
ip route show

# Show specific route
ip route get 8.8.8.8

# Add static route
sudo ip route add 192.168.100.0/24 via 192.168.1.254

# Delete route
sudo ip route del 192.168.100.0/24

# Add default gateway
sudo ip route add default via 192.168.1.1

# Change default gateway
sudo ip route change default via 192.168.1.254

# Flush routing cache
sudo ip route flush cache
```

---

## Network Interface Management

### ip - Modern Network Configuration

**Show Information:**
```bash
# Show all interfaces
ip addr show
ip a

# Show specific interface
ip addr show eth0

# Show link status
ip link show

# Show statistics
ip -s link show eth0

# Show brief summary
ip -br addr show
```

**Configure Interfaces:**
```bash
# Bring interface up/down
sudo ip link set eth0 up
sudo ip link set eth0 down

# Add IP address
sudo ip addr add 192.168.1.100/24 dev eth0

# Delete IP address
sudo ip addr del 192.168.1.100/24 dev eth0

# Change MAC address
sudo ip link set eth0 address 00:11:22:33:44:55

# Set MTU
sudo ip link set eth0 mtu 1400
```

### netstat - Network Statistics (Legacy)

**Common Usage:**
```bash
# Show all connections
netstat -a

# Show listening ports
netstat -l

# Show TCP connections
netstat -t

# Show UDP connections
netstat -u

# Show process using port
sudo netstat -tulpn

# Show routing table
netstat -r

# Show interface statistics
netstat -i

# Continuous monitoring
netstat -c
```

### ss - Modern Socket Statistics

**Common Usage:**
```bash
# Show all sockets
ss -a

# Show listening sockets
ss -l

# Show TCP sockets
ss -t

# Show UDP sockets
ss -u

# Show process using socket
ss -p

# Show detailed information
ss -e

# Combined (listening TCP with processes)
sudo ss -tlnp

# Filter by port
ss -t state established '( dport = :80 or sport = :80 )'

# Show socket memory usage
ss -tm

# Show internal TCP information
ss -ti
```

---

## Packet Analysis

### tcpdump - Packet Capture

**Basic Syntax:**
```bash
sudo tcpdump [options] [filter]
```

**Common Usage:**
```bash
# Capture on interface
sudo tcpdump -i eth0

# Capture to file
sudo tcpdump -i eth0 -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# Capture specific number of packets
sudo tcpdump -i eth0 -c 100

# Show packet contents (hex and ASCII)
sudo tcpdump -i eth0 -XX

# Don't resolve hostnames
sudo tcpdump -i eth0 -n

# Don't resolve ports
sudo tcpdump -i eth0 -nn

# Verbose output
sudo tcpdump -i eth0 -v
sudo tcpdump -i eth0 -vv
sudo tcpdump -i eth0 -vvv
```

**Filtering:**
```bash
# Capture specific host
sudo tcpdump -i eth0 host 192.168.1.100

# Capture specific network
sudo tcpdump -i eth0 net 192.168.1.0/24

# Capture specific port
sudo tcpdump -i eth0 port 80

# Capture port range
sudo tcpdump -i eth0 portrange 8000-9000

# Capture TCP traffic
sudo tcpdump -i eth0 tcp

# Capture UDP traffic
sudo tcpdump -i eth0 udp

# Capture ICMP traffic
sudo tcpdump -i eth0 icmp

# Combine filters (AND)
sudo tcpdump -i eth0 'host 192.168.1.100 and port 80'

# Combine filters (OR)
sudo tcpdump -i eth0 'port 80 or port 443'

# Capture traffic to/from host
sudo tcpdump -i eth0 'src host 192.168.1.100'
sudo tcpdump -i eth0 'dst host 192.168.1.100'

# Capture HTTP GET requests
sudo tcpdump -i eth0 -s 0 -A 'tcp[((tcp[12:1] & 0xf0) >> 2):4] = 0x47455420'

# Capture SYN packets
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0'
```

**Practical Examples:**
```bash
# Debug HTTP traffic
sudo tcpdump -i eth0 -A -s 0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

# Capture DNS queries
sudo tcpdump -i eth0 -n port 53

# Monitor ARP
sudo tcpdump -i eth0 arp

# Capture IPv6
sudo tcpdump -i eth0 ip6
```

---

## Bandwidth and Performance

### iftop - Real-time Bandwidth Usage

**Common Usage:**
```bash
# Monitor interface
sudo iftop -i eth0

# Don't resolve hostnames
sudo iftop -i eth0 -n

# Show ports
sudo iftop -i eth0 -P

# Filter by network
sudo iftop -i eth0 -F 192.168.1.0/24
```

### iperf3 - Network Performance Testing

**Server Mode:**
```bash
# Start server
iperf3 -s

# Server on specific port
iperf3 -s -p 5555
```

**Client Mode:**
```bash
# Basic test
iperf3 -c server-ip

# Test for specific duration (seconds)
iperf3 -c server-ip -t 30

# Reverse mode (server sends)
iperf3 -c server-ip -R

# UDP test
iperf3 -c server-ip -u

# Set bandwidth (for UDP)
iperf3 -c server-ip -u -b 100M

# Parallel streams
iperf3 -c server-ip -P 4

# Test both directions
iperf3 -c server-ip --bidir
```

### mtr - Combined Ping and Traceroute

**Common Usage:**
```bash
# Basic monitoring
mtr google.com

# Report mode (run N cycles then exit)
mtr --report --report-cycles 10 google.com

# Show IP addresses only
mtr -n google.com

# Show both hostnames and IPs
mtr -b google.com

# Use TCP instead of ICMP
mtr --tcp -P 443 google.com

# Set packet size
mtr -s 1024 google.com
```

---

## Troubleshooting Workflows

### Basic Connectivity Issues

**Step 1: Check Local Interface**
```bash
ip addr show
ip link show
# Verify interface is UP and has IP address
```

**Step 2: Check Local Network**
```bash
ping -c 4 192.168.1.1  # Gateway
ping -c 4 192.168.1.255  # Broadcast (if allowed)
```

**Step 3: Check DNS Resolution**
```bash
nslookup google.com
dig google.com
# If fails, try ping by IP:
ping -c 4 8.8.8.8
```

**Step 4: Check Internet Connectivity**
```bash
ping -c 4 8.8.8.8  # Google DNS
ping -c 4 1.1.1.1  # Cloudflare DNS
```

**Step 5: Check Routing**
```bash
ip route show
traceroute google.com
```

**Step 6: Check Firewall**
```bash
sudo iptables -L -n -v
sudo firewall-cmd --list-all  # For firewalld
```

### Service Connection Issues

**Step 1: Verify Service is Running**
```bash
systemctl status service-name
sudo ss -tlnp | grep :80
```

**Step 2: Test Local Connection**
```bash
nc -zv localhost 80
curl -v http://localhost
```

**Step 3: Test from Remote Host**
```bash
nc -zv remote-host 80
telnet remote-host 80
```

**Step 4: Check Firewall Rules**
```bash
sudo iptables -L INPUT -n -v | grep 80
sudo firewall-cmd --list-ports
```

**Step 5: Capture and Analyze Traffic**
```bash
sudo tcpdump -i any -n port 80
```

### DNS Issues

**Step 1: Check resolv.conf**
```bash
cat /etc/resolv.conf
```

**Step 2: Test Different DNS Servers**
```bash
nslookup example.com
nslookup example.com 8.8.8.8
nslookup example.com 1.1.1.1
```

**Step 3: Clear DNS Cache**
```bash
# systemd-resolved
sudo systemd-resolve --flush-caches

# dnsmasq
sudo killall -HUP dnsmasq

# nscd
sudo /etc/init.d/nscd restart
```

**Step 4: Trace DNS Resolution**
```bash
dig +trace example.com
```

### Performance Issues

**Step 1: Check Bandwidth Usage**
```bash
sudo iftop -i eth0
nload eth0
```

**Step 2: Identify High-Traffic Processes**
```bash
sudo nethogs eth0
```

**Step 3: Check Network Errors**
```bash
ip -s link show eth0
netstat -i
```

**Step 4: Test Network Speed**
```bash
# Between two hosts
# Server:
iperf3 -s
# Client:
iperf3 -c server-ip
```

**Step 5: Monitor Latency and Packet Loss**
```bash
mtr --report --report-cycles 100 target-host
```

---

## Best Practices

### Diagnostic Strategy

1. **Start Simple**: Begin with basic tools (ping, nslookup)
2. **Layer Approach**: Test from Layer 1 (physical) up to Layer 7 (application)
3. **Isolate Variables**: Change one thing at a time
4. **Document Findings**: Record all test results and observations
5. **Compare Baselines**: Know what "normal" looks like for your environment

### Safety and Security

1. **Minimize Impact**
    - Avoid flood tests in production
    - Limit packet capture duration and file size
    - Be cautious with port scanning (may trigger security alerts)

2. **Protect Sensitive Data**
    - Be careful capturing traffic containing passwords or tokens
    - Encrypt packet captures if storing long-term
    - Use secure channels to transfer capture files

3. **Permission and Authorization**
    - Get approval before scanning networks you don't own
    - Document legitimate testing activities
    - Many tools require root/sudo privileges

### Performance Considerations

1. **Resource Usage**
    - Packet capture can generate large files quickly
    - Use filters to reduce capture size
    - Monitor disk space when capturing

2. **Network Load**
    - Ping floods can impact network performance
    - Be conservative with bandwidth tests
    - Schedule heavy testing during maintenance windows

### Tool Selection

1. **Modern vs Legacy**
    - Prefer `ip` over `ifconfig`
    - Prefer `ss` over `netstat`
    - Know both for compatibility

2. **Right Tool for the Job**
    - Quick tests: ping, nc
    - Detailed analysis: tcpdump, wireshark
    - Continuous monitoring: mtr, iftop
    - Automation: nmap, custom scripts

---

## Quick Reference

### Common Port Numbers

```
20/21   - FTP
22      - SSH
23      - Telnet
25      - SMTP
53      - DNS
80      - HTTP
110     - POP3
143     - IMAP
443     - HTTPS
3306    - MySQL
5432    - PostgreSQL
6379    - Redis
8080    - HTTP Alt
27017   - MongoDB
```

### Essential One-Liners

```bash
# Check if port is open
nc -zv host port

# Find process using port
sudo ss -tlnp | grep :port

# Test DNS resolution
dig +short domain

# Quick bandwidth test
iperf3 -c host

# Monitor connections
watch -n 1 'ss -tan | grep ESTAB | wc -l'

# Check route to host
ip route get host

# Show active connections by IP
ss -tan | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr
```

---

## Related Documentation

- **SSH Guide**: For secure remote access and tunneling
- **Docker Networking**: Container network troubleshooting
- **Kubernetes Networking**: Service mesh and pod connectivity
- **Firewall Configuration**: iptables and firewalld setup
- **System Monitoring**: Overall system performance analysis

---

**Last Updated**: 2025-01-08
**Version**: 1.0