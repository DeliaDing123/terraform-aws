#!/bin/bash
sudo yum -y install lynx

lynx -dump http://127.0.0.1/ > lynx.txt
cat lynx.txt|sed 's/[[:space:]|[:punct:]]/\n/g'|sed '/^$/d'|sort|uniq -c|sort -k1r|head -1

