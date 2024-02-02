#!/bin/bash

#You can run this script to start the server and start 3 clients but all the output will be in the same terminal.
#Alternatively, run the server in a terminal, and manually run the client in a terminal 3 times.

server='server.py'
client='client.py'

python3 "$server" &
for ((i=1; i<=3; i++));
do
    sleep 2
    python3 "$client" &
    sleep 5
done
