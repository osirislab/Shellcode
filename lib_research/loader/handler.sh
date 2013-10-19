#!/bin/bash
ulimit -c unlimited
socat TCP-LISTEN:12345,reuseaddr,fork EXEC:"./testShellcode"

