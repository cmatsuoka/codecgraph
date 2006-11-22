#!/bin/sh
in="$1"
dot="$in.dot"
ps="$in.ps"
python codecgraph.py "$in" > "$dot"
dot -Tps -o "$ps" "$dot"
