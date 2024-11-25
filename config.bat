@echo off
mkdir .haxelib
haxelib install hmm
haxelib run hmm install
haxelib run lime build windows -debug