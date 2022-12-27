#!/bin/sh
set -e
luarocks install --local busted
luarocks install --local luacov
luarocks install --local luacov-reporter-lcov

curl -s https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh | bash -s -- -d -z

cp -r .release/LibClassicSpecs/Lib .
