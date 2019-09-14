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
$IPT -A $GOODLIST -s $ipsubnet -j ACCEPT
done
done

# Allow all good addresses
$IPT -I INPUT -j $GOODLIST
$IPT -I OUTPUT -j $GOODLIST
$IPT -I FORWARD -j $GOODLIST
$IPT -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT



# Disallow everything else
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT DROP

exit 0
