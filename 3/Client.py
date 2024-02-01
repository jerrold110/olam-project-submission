import socket
import json
import threading
import time

# server address details
HOST = '127.0.0.1'
PORT = 5000

# data structure to repliate latest quotations received from server
quotes = {}

def subscribe(symbol):
    message = {'type': 'subscribe', 'symbol': symbol}
    client_socket.send(json.dumps(message).encode('utf-8'))
    # create a new entry in persisted quotes
    if symbol not in quotes:
        quotes[symbol] = None
    print(f'Subscribe request to {symbol} sent')

def unsubscribe(symbol):
    message = {'type': 'unsubscribe', 'symbol': symbol}
    client_socket.send(json.dumps(message).encode('utf-8'))
    if symbol in quotes:
        quotes.pop(symbol)
    print(f'Unubscribe request to {symbol} sent')

def simulate_human_activity():
    """
    This function simulates client subscribe and unsubscribe activity in a predetermined fashion. The client subscribes to apple, waits 5 seconds, subscribes to amazon,
    waits 5 seconds, then unsubscribes to apple. 
    """
    subscribe('AAPL')
    time.sleep(5)
    subscribe('AMZN')
    time.sleep(5)
    unsubscribe('AAPL')

# create a client socket and connect
# connect instead of create_connection 
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client_socket.connect((HOST, PORT))

# create a thread to simulate subscribe and unsubscribe
activity_thread = threading.Thread(target=simulate_human_activity)
activity_thread.start()

# continually receive data from server
# update persisted data
while True:
    # receive up to 1024 bytes from the server using recv()
    # received data is decoded from bytes to string using utf-8
    data = client_socket.recv(1024).decode('utf-8')
    # checks if received data is empty
    if not data:
        break
    update = json.loads(data)
    print(f"Received update: {update}")
    symbol = update['symbol']
    if symbol in quotes:
        quotes['symbol'] = update
