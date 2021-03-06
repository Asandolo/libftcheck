#!/bin/sh

printf "\e[42m\e[30m  Automated tester by efouille X afrangio  \e[39m\e[49m\n"

status=$(git status --porcelain | wc | awk {'print $1'})
if [ $status -gt 0 ]
then
	printf "\e[41m\e[30m                REPO CHANGED               \e[39m\e[49m\n"
	git status
fi


printf "\e[32mCreating /tmp/eft$(whoami) working directory\e[39m\n"
rm -rf /tmp/eft$(whoami)
mkdir -p /tmp/eft$(whoami)/files
mkdir -p /tmp/eft$(whoami)/tmp

printf "\e[32mCopying files\e[39m\n"
cp ./Makefile /tmp/eft$(whoami)/files

printf "\e[32mGoing to working dir\e[39m\n"
cd /tmp/eft$(whoami)

printf "\e[32m----------\nCloning libft into /tmp/eft$(whoami)/libft\e[39m\n"
git clone $1 libft

printf "\e[32m----------\nUsing custom Makefile (no bonuses)...\e[39m\n"
mv /tmp/eft$(whoami)/libft/Makefile /tmp/eft$(whoami)/tmp
cp /tmp/eft$(whoami)/files/Makefile /tmp/eft$(whoami)/libft

printf "\e[32m----------\nDownloading clang static analyzer into /tmp/eft$(whoami)/static_analyzer\e[39m\n"
curl -o checker-279.tar.bz2 https://clang-analyzer.llvm.org/downloads/checker-279.tar.bz2
printf "\e[32m----------\nExtracting clang static analyzer...\e[39m\n"
tar jxf checker-279.tar.bz2
rm -rf checker-279.tar.bz2
mv checker-279 static_analyzer
printf "\e[32m----------\nChecking with scan-build...\e[39m\n"
rm -rf /tmp/eft$(whoami)/reports/*
/tmp/eft$(whoami)/static_analyzer/bin/scan-build -o /tmp/eft$(whoami)/reports --html-title "efouille X afrangio libftcheck - static analyzer report" --status-bugs make -C libft
static_analyzer_errors=$(echo $?)
make -C libft fclean

printf "\e[32m----------\nRestoring original Makefile...\e[39m\n"
rm /tmp/eft$(whoami)/libft/Makefile
mv /tmp/eft$(whoami)/tmp/Makefile /tmp/eft$(whoami)/libft

printf "\e[32mDone.\e[39m\nPress enter to continue"
read

printf "\e[32m----------\nCloning 42FileChecker by jgigault into /tmp/eft$(whoami)/42fc...\e[39m\n"
git clone https://github.com/jgigault/42FileChecker 42fc
printf "\e[32m----------\nCloning libftest by jtoty (efouille fork) into /tmp/eft$(whoami)/libftest...\e[39m\n"
git clone https://github.com/edrflt/Libftest.git libftest

printf "\e[32m----------\nChecking with 42FileChecker...\e[39m\n"
cd 42fc
sh 42FileChecker.sh --project "libft" --path "/tmp/eft$(whoami)/libft"

printf "\e[32mEnd of 42fc\e[39m\nPress enter to continue"
read

printf "\e[32m----------\nChecking with libftest...\e[39m\n"
cd ../libftest
sh grademe.sh

printf "\e[32mEnd of libftest\e[39m\nPress enter to continue"
read

voidcast=$(grep --color -nr "(void)" /tmp/eft$(whoami)/libft | wc | awk {'print $1'})
if [ $voidcast -gt 0 ]
then
	printf "\e[31m(void) FOUND HERE :\e[39m\n"
	grep --color -nr "(void)" /tmp/eft$(whoami)/libft
else
	printf "\e[32mNo (void) casts found\e[39m\n"
fi

if [ $static_analyzer_errors -gt 0 ]
then
	/tmp/eft$(whoami)/static_analyzer/bin/scan-view /tmp/eft$(whoami)/reports/$(ls /tmp/eft$(whoami)/reports/)
fi