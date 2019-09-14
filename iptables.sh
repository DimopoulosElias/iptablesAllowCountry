#!/bin/bash
### Allow all traffic the UK (gb). Use ISO code. Check the DLROOT web site below for a list ###
ISO="gr"

### Set PATH ###
IPT=/sbin/iptables
WGET=/usr/bin/wget
EGREP=/bin/egrep


### No editing below ###
GOODLIST="countryallow"
ZONEROOT="/opt/iptables"
DLROOT="http://www.ipdeny.com/ipblocks/data/countries"

cleanOldRules(){
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD ACCEPT
}

# create a dir
[ ! -d $ZONEROOT ] && /bin/mkdir -p $ZONEROOT

# clean old rules
cleanOldRules

# create a new iptables list
$IPT -N $GOODLIST

for c in $ISO
do
# local zone file
tDB=$ZONEROOT/$c.zone

# get fresh zone file
$WGET -O $tDB $DLROOT/$c.zone

# get
GOODIPS=$(egrep -v "^#|^$" $tDB)
for ipsubnet in $GOODIPS
do

echo $ipsubnet
$IPT -A $GOODLIST -s $ipsubnet -j ACCEPT
#$IPT -A $GOODLIST -d $ipsubnet -j ACCEPT

done
done

#allow lo
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

#allow google DNS
#$IPT -A $GOODLIST -d 8.8.8.8 -j ACCEPT
#$IPT -A $GOODLIST -d 8.8.4.4 -j ACCEPT

#allow mirrors.digitalocean.com
#$IPT -A $GOODLIST -d  104.24.117.209 -j ACCEPT
#$IPT -A $GOODLIST -d 104.24.116.209 -j ACCEPT

#allow digital ocean DNS
#$IPT -A $GOODLIST -d 67.207.67.3 -j ACCEPT
#$IPT -A $GOODLIST -d 67.207.67.2 -j ACCEPT

#allow github
#$IPT -A $GOODLIST -d 140.82.112.0/20 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.112.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.113.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.114.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.115.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.116.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.117.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.118.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.119.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.120.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.121.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.122.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.123.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.124.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.125.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.126.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 140.82.127.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 192.30.252.0/22 -j ACCEPT
#$IPT -A $GOODLIST -d 192.30.252.0/23 -j ACCEPT
#$IPT -A $GOODLIST -d 192.30.252.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 192.30.253.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 192.30.254.0/23 -j ACCEPT
#$IPT -A $GOODLIST -d 192.30.254.0/24 -j ACCEPT
#$IPT -A $GOODLIST -d 192.30.255.0/24 -j ACCEPT

# Allow all good addresses
$IPT -I INPUT -j $GOODLIST
#$IPT -I OUTPUT -j $GOODLIST
#$IPT -I FORWARD -j $GOODLIST
#$IPT -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT



# Disallow everything else
$IPT -P INPUT DROP
$IPT -P FORWARD DROP

# Except OUTPUT
$IPT -P OUTPUT ACCEPT

exit 0
