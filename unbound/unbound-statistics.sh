#!/bin/sh
set -eu
#set -o pipefail -o posix
#shopt -s failglob
#set -x

# STATISTIC COUNTERS
# 
# From https://unbound.net/documentation/unbound-control.html
# 
# threadX.num.queries:		number of queries received by thread
# threadX.num.cachehits:	number of queries that were successfully answered using a cache lookup
# threadX.num.cachemiss:	number of queries that needed recursive processing
# threadX.num.prefetch:
# 	number of cache prefetches performed. This number is included
# 	in cachehits, as the original query had the unprefetched answer
# 	from cache, and resulted in recursive processing, taking a slot
# 	in the requestlist. Not part of the recursivereplies (or the
# 	histogram thereof) or cachemiss, as a cache response was sent.
# threadX.num.zero_ttl:		number of replies with ttl zero, because they served an expired cache entry.
# threadX.num.recursivereplies:
# 	The number of replies sent to queries that needed recursive pro-
# 	cessing. Could be smaller than threadX.num.cachemiss if due to
# 	timeouts no replies were sent for some queries.
# threadX.requestlist.avg:
# 	The average number of requests in the internal recursive pro-
# 	cessing request list on insert of a new incoming recursive pro-
# 	cessing query.
# threadX.requestlist.max:	Maximum size attained by the internal recursive processing request list.
# threadX.requestlist.overwritten:
# 	Number of requests in the request list that were overwritten by
# 	newer entries. This happens if there is a flood of queries that
# 	recursive processing and the server has a hard time.
# threadX.requestlist.exceeded:
# 	Queries that were dropped because the request list was full.
# 	This happens if a flood of queries need recursive processing,
# 	and the server can not keep up.
# threadX.requestlist.current.all:
# 	Current size of the request list, includes internally generated
# 	queries (such as priming queries and glue lookups).
# threadX.requestlist.current.user: Current size of the request list, only the requests from client queries.
# threadX.recursion.time.avg
# 	Average time it took to answer queries that needed recursive
# 	processing. Note that queries that were answered from the cache
# 	are not in this average.
# threadX.recursion.time.median
# 	The median of the time it took to answer queries that needed
# 	recursive processing. The median means that 50% of the user
# 	queries were answered in less than this time. Because of big
# 	outliers (usually queries to non responsive servers), the aver-
# 	age can be bigger than the median. This median has been calcu-
# 	lated by interpolation from a histogram.
# threadX.tcpusage
# 	The currently held tcp buffers for incoming connections. A spot
# 	value on the time of the request. This helps you spot if the
# 	incoming-num-tcp buffers are full.
# 
# total.num.queries:			summed over threads.
# total.num.cachehits:			summed over threads.
# total.num.cachemiss:			summed over threads.
# total.num.prefetch:			summed over threads.
# total.num.zero_ttl:			summed over threads.
# total.num.recursivereplies:	summed over threads.
# total.requestlist.avg:		averaged over threads.
# total.requestlist.max:		the maximum of the thread requestlist.max values.
# total.requestlist.overwritten:	summed over threads.
# total.requestlist.exceeded:	summed over threads.
# total.requestlist.current.all:	summed over threads.
# total.recursion.time.median:	averaged over threads.
# total.tcpusage:				summed over threads.
# time.now:			current time in seconds since 1970.
# time.up:			uptime since server boot in seconds.
# time.elapsed:		time since last statistics printout, in seconds.

unbound-control -c /etc/unbound/unbound.conf -s 127.0.0.1 stats_noreset
