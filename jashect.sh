#!/bin/bash
# Just Another Simplified Hurricane Electric Certification Tool
# Usage: $0 username password

HOST=""
IPADDR=""
PING6=`type ping6 2> /dev/null && echo "ping6" || echo "ping -6"`
PAGES_TITLE=(
  "traceroute"
  "aaaa"
  "ptr"
  "ping"
  "whois")
PAGES_ACTION=(
  "traceroute -6 <HOST>"
  "dig AAAA <HOST>"
  "dig -x <IPADDR>"
  "$PING6 -c3 <IPADDR>"
  "whois <IPADDR>")
COOKIE_FILE=`mktemp`
FAIL_RETRY=3

function getTargets {
  local sisy_feed=`curl -s http://sixy.ch/feed`
  HOST=`echo "$sisy_feed" \
  | sed -n 's/\([ ]*\)<id>http:\/\/sixy.ch\/go\/\([[:alnum:].-]*\)<\/id>/\2/p' \
  | sort -R -u`
  IPADDR=`echo "$sisy_feed" \
  | sed -n 's/IPv6 address: \([[:xdigit:]:]*\)<\/summary>/\1/p' \
  | sort -R -u`

  local host_lines=`echo "$HOST" | wc -l`
  local ipaddr_lines=`echo "$IPADDR" | wc -l`
  if (( "$host_lines" <= "1" )) || (( "$ipaddr_lines" <= "1" )); then
    echo "Could not fetch IPs and hostnames from sixy.ch"
    rm $COOKIE_FILE
    exit 1
  fi
}

# $1: No of HOST/IPADDR
function getHost()   { echo "$HOST"   | head -n $1 | tail -n 1; }
function getIPAddr() { echo "$IPADDR" | head -n $1 | tail -n 1; }

# $1: PAGES_*-ID, $2: No of HOST/IPADDR
function invokeAction {
  local target=`mktemp`
  local ipaddr=`getIPAddr $2`
  local host=`getHost $2`
  local cmnd=`echo "${PAGES_ACTION[$1]}" \
  | sed "s/<IPADDR>/$ipaddr/;s/<HOST>/$host/"`

  echo "`$cmnd`" > $target
  echo $target
}

# $1: PAGES_*-ID
function postPage() {
  for (( j=1; j<=$FAIL_RETRY; j++)); do
    echo "Invoking ${PAGES_TITLE[$1]} for the $j. time.."

    local tmp_file=`invokeAction $1 $j`
    local he_resp=`hePost ${PAGES_TITLE[$1]} $tmp_file`
    rm $tmp_file

    echo "$he_resp"
    if echo "$he_resp" | grep --quiet "succeeded"; then
      break
    fi
  done
  echo "Finished trying ${PAGES_TITLE[$1]}"
}

# $1: Username, $2: Password
function heLogin {
  local resp=`curl --silent \
                   --cookie $COOKIE_FILE --cookie-jar $COOKIE_FILE \
                   --data "f_user=$1" --data-urlencode "f_pass=$2" \
                   "https://ipv6.he.net/certification/login.php"`

  if echo $resp | grep --quiet "errorMessageBox"; then
    echo "Login for $1 failed!"
    rm $COOKIE_FILE
    exit 1
  else
    echo "Login for $1 succeeded"
  fi
}

# $1: Testname, $2: Resultfile
function hePost {
  local resp=`curl --silent \
              --cookie $COOKIE_FILE --cookie-jar $COOKIE_FILE \
              --data-urlencode "input@$2" \
              --location \
              "https://ipv6.he.net/certification/daily.php?test=$1"`

  if echo $resp | grep --quiet "errorMessageBox"; then
    local err_msg=`echo "$resp" \
    | sed -n 's/<div class=\"errorMessageBox\">\(.*\)<\/div>/\1/p'`
    echo "Posting $1 failed: $err_msg"
  else
    echo "Posting $1 succeeded"
  fi
}


[ "$#" != "2" ] && echo "Usage: $0 username password" && exit 1

heLogin "$1" "$2"
getTargets

for (( i=0; i<${#PAGES_TITLE[@]}; i++ )); do
  postPage $i #&
done

rm $COOKIE_FILE
