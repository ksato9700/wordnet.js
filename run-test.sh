#!/bin/sh
#
# tests in coffee
#
node_modules/.bin/coffee test/test.coffee
if [ $? -ne 0 ]
then
exit 1
fi

node_modules/.bin/coffee test/test_riak.coffee
if [ $? -ne 0 ]
then
exit 1
fi

#
# tests of commands
#
bin/parse_wn test/wn_test.xml | diff - test/exp-parse_wn.txt
