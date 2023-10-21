#!/bin/bash
script=${0}
svol=${1}
spath=${2}
dvol=${3}
dpath=${4}
bscript=${5}
ifile=${6}

echo "svol is $svol"
echo "spath is $spath"
echo "dvol is $dvol"
echo "dpath is $dpath"
echo "svol is $svol"
echo "ifile is $ifile"
echo "detaching $dpath ..."
hdiutil detach $dpath
