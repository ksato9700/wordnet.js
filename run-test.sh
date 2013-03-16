#!/bin/sh
#
# tests in coffee
#
node_modules/.bin/coffee test/test.coffee

#
# tests of commands
#
bin/parse_wn test/wn_test.xml | diff - test/exp-parse_wn.txt
