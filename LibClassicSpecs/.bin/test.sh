#!/bin/sh
set -e
rm -f lcov.info
~/.luarocks/bin/busted --verbose --coverage --shuffle .
~/.luarocks/bin/luacov -r lcov LibClassicSpecs
mv luacov.report.out lcov.info # for vscode coverage-gutters plugin
rm -f luacov.stats.out
