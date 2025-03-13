#!/bin/bash
for i in {1..10}
do
    curl -H 'Cache-Control: no-cache' -v --http1.1 https://api.polysynergy.com/api/health/ 2>&1 | grep "Connected to"
done
