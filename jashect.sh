#!/bin/bash
# Just Another Simplified Hurricane Electric Certification Tool
# Usage: $0 username password

SIXY_FEED=`curl -s http://sixy.ch/feed`
HOST=`echo "$SIXY_FEED"| \
  sed -n 's/\([ ]*\)<id>http:\/\/sixy.ch\/go\/\([[:alnum:].-]*\)<\/id>/\2/p' | \
  sort -R | head -n 1`
IPADDR=`echo "$SIXY_FEED" | \
  sed -n 's/IPv6 address: \([[:xdigit:]:]*\)<\/summary>/\1/p' | \
  sort -R | head -n 1`
PING6=`type ping6 2> /dev/null && echo "ping6" || echo "ping -6"`

PAGES_TITLE=(
  "traceroute"
  "aaaa"
  "ptr"
  "ping"
  "whois")
PAGES_ACTION=(
  "traceroute -6 $HOST"
  "dig AAAA $HOST"
  "dig -x $IPADDR"
  "$PING6 -c3 $IPADDR"
  "whois $IPADDR")
PAGES_FILES=()
COOKIE_FILE=`mktemp`

function invokeAction {
  for (( i=0; i<${#PAGES_ACTION[@]}; i++ )); do
    local target=`mktemp`
    echo "`${PAGES_ACTION[i]}`" > $target
    PAGES_FILES[$i]=$target
  done
}

# $1: Username, $2: Password
function heLogin {
  local resp=`curl --silent \
                   --cookie $COOKIE_FILE --cookie-jar $COOKIE_FILE \
                   --data "f_user=$1" --data-urlencode "f_pass=$2" \
                   "https://ipv6.he.net/certification/login.php"`

  if echo $resp | grep --quiet "errorMessageBox"; then
    >&2 echo "Login for $1 failed!"
    cleanUp
    exit 1
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
    local err_msg=`echo "$resp" | \
      sed -n 's/<div class=\"errorMessageBox\">\(.*\)<\/div>/\1/p'`
    >&2 echo "Posting $1 failed: $err_msg"
  else
    echo "Posting $1 succeeded"
  fi
}

function cleanUp {
  rm $COOKIE_FILE
  for f in "${PAGES_FILES[@]}"; do
    rm $f
  done
}


[ "$#" != "2" ] && >&2 echo "Usage: $0 username password" && exit 1

heLogin "$1" "$2"
invokeAction

for (( i=0; i<${#PAGES_TITLE[@]}; i++ )); do
  hePost ${PAGES_TITLE[i]} ${PAGES_FILES[i]}
done

cleanUp
