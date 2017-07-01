#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# cachesize:  cache size
# evictions:  number of names which have had to removed from the cache before they expired in order to make room for new names
# insertions: total number of names that have been inserted into the cache
# hits:       cache hits
# misses:     cache misses
# auth:       number of authoritative queries answered
# servers:    for each upstream server it gives the number of queries sent, and the number which resulted in an error
for query in cachesize insertions evictions misses hits auth servers; do
	echo -e -n "${query}\t"
	dig +short chaos txt "${query}.bind" 127.0.0.1
done

