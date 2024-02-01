import socket
import threading
import json
import time
import random

# server config
HOST = '127.0.0.1'
PORT = 5000

# symbol to client_socket
# format of client socket: <socket.socket fd=332, family=2, type=1, proto=0, laddr=('127.0.0.1', 5000), raddr=('127.0.0.1', 51606)>
subscriptions = {}

# function to handle client connections
# keep running 
def handle_client(client_socket):
    try:
        while True:
            data = client_socket.recv(1024).decode('utf-8')
            # if data packet is empty, either client has lost connection, or error in transmission
            if not data:
                break
            message = json.loads(data)
            symbol = message['symbol']
            # create new subscription of client to symbol
            if message['type'] == 'subscribe':
                if symbol not in subscriptions:
                    subscriptions[symbol] = []
                subscriptions[symbol].append(client_socket)

            # remove client's subscription to symbol
            elif message['type'] == 'unsubscribe':
                if (symbol in subscriptions) and (client_socket in subscriptions[symbol]):
                    subscriptions[symbol].remove(client_socket)
    except ConnectionResetError:
        print(f"Connection with {client_socket} closed")
    finally:
        client_socket.close()

# function to broadcast updates to clients
def broadcast_update(symbol, update):
    if symbol in subscriptions:
        for client_socket in subscriptions[symbol]:
            # send an update for a sybol to a client
            try:
                client_socket.send(json.dumps(update).encode('utf-8'))
            except:
                subscriptions[symbol].remove(client_socket)

# function to simulate stock updates
def simulate_stock_updates():
    while True:
        time.sleep(2)
        # simulate stock updates with random data
        for symbol in subscriptions.keys():
            update = {
                'symbol': symbol,
                'price_open': round(random.uniform(0, 100), 2),
                'price_high': round(random.uniform(0, 100), 2),
                'price_low': round(random.uniform(0, 100), 2),
                'timestamp': time.time()
                }
            # broadcast the update to clients subscribed to that symbol
            broadcast_update(symbol, update)

# Start server
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind((HOST, PORT))
server_socket.listen()
print(f"Server listening on {HOST}:{PORT}")

# create stock updates thread
update_thread = threading.Thread(target=simulate_stock_updates)
update_thread.start()

# server looping. listening for connections
while True:
    client_socket, addr = server_socket.accept()
    print(f"Accepted connection from {addr[0]}:{addr[1]}")
    # start a new thread to handle the client
    client_thread = threading.Thread(target=handle_client, kwargs={'client_socket':client_socket})
    client_thread.start()
