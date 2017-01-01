#!/bin/sh

. $HOME/.profile

find voltdb-pro/examples -name run.sh -print -exec ${HOME}/update_example_hosts.sh {} \;
find voltdb-pro/examples -name  '*Benchmark.java' -print -exec ${HOME}/update_java_clients.sh  {} \;

