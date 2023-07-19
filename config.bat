@echo off
mkdir .haxelib
haxelib install hmm
haxelib run hmm install
haxelib run lime test windows -debug