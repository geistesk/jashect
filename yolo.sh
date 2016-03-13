#!/bin/bash
# You Only Loop Once
#  Dumb way to execute it 100 (or less) times :^)
#  jashect.sh must be stored in the same directory
# Usage: $0 username password loop-times

[ "$#" != "3" ] && >&2 echo "Usage: $0 username password loop-times" && exit 1

for i in `seq 1 $3`; do
  ./jashect.sh $1 $2
  sleep 86520
done
