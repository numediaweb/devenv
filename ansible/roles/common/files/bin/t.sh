#!/usr/bin/env bash
tail -n 20 -f var/log/*.* | awk '
  /INFO/ {print "\033[0m" $0 "\033[0m"}
  /WARNING/ {print "\033[33m" $0 "\033[0m"}
  /ERROR/ {print "\033[31m" $0 "\033[0m"}
  /CRITICAL/ {print "\033[41;1m" $0 "\033[0m"}
  /SEVERE/ {print "\033[41;1m" $0 "\033[0m"}
'
