#!/usr/bin/env ruby
#
# Executes the benchmark suite.
#
$LOAD_PATH.unshift './lib' if $0 == __FILE__

APP_ROOT    = File.dirname(__FILE__)
LOG_PATH    = File.join(APP_ROOT, 'logs')

TEST_RUNS   = 100
POOL_SIZES  = [ 1_000 ] #, 1_000 ]#, 10_000, 100_000 ]

require 'r_t_bench'
LOG         = RTBench::LOG

RTBench.load_template_engines
RTBench.load_test_objects
RTBench.load_suite
RTBench.run_suite
