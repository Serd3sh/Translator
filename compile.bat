@echo off
cls
flex L.l
bison -dy -v Y.y
gcc -Wno-implicit-function-declaration lex.yy.c y.tab.c -o run
run