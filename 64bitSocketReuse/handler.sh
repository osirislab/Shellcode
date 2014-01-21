#!/bin/bash
socat TCP-LISTEN:12345,reuseaddr,fork EXEC:"strace ./testShellcode"

