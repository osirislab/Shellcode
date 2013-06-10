#!/bin/bash

TARGET='/usr/include/asm-generic/unistd.h'

echo $1 in $TARGET
grep __NR_ $TARGET | grep $1 | awk '{print $2, $3}'

