#!/bin/sh

. /home/ubuntu/.profile

find voltdb-pro/examples -name run.sh -print -exec /home/ubuntu/update_example_hosts.sh {} \;
find voltdb-pro/examples -name  '*Benchmark.java' -print -exec /home/ubuntu/update_java_clients.sh  {} \;

