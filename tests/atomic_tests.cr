# tests/atomic_tests.cr
require "json"
require "./../src/atomic"

MTGAtomic::DB.load
MTGAtomic::DB.print_stats