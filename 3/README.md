### Real time quote server
This program simulates a client-server architecture that broadcasts and receives data in real time and is designed for multiple client connections, with multiple client-managed subscriptions to control what data the server broadcasts to the itself. I use Python to set up clients and server with a streaming TCP connection between them, with functionality to store data locally.

### Interface
The client-server interface is implemented using sockets to establish communication between a server and multiple clients. The data transferred between client are JSON strings seralised in UTF-8, then sent through the stream and deseralised upon reaching. This data is used to communicate sumscribe/unsubscribe instructions or send quotation data in real-time. Because this is a stream, the TCP connection cannot preserve boundaries between strings, so a newline character is used to separate string, and parsing is done at the client.

Client transmissions to server are a subscribe or unsubscribe action to a particular stock and will control what quotation data it will receive.
```python
{
'type': 'unsubscribe', 
'symbol': 'APPL'}
```

Server transmissions to client are quotation updates on the stocks that a client has subscribed to. In this proof-of-concept, the data is streamed every two seconds (only open, high, low data is generated to demonstrate the concept) with the symbol and timestamp. The data is generated randomly, but is consistent for a precise time and stock for all clients that receive it. All clients receive the same data at the same time for the stocks they are subscribed to.
```python
{
'symbol': symbol,
'price_open': round(random.uniform(0, 100), 2),
'price_high': round(random.uniform(0, 100), 2),
'price_low': round(random.uniform(0, 100), 2),
'timestamp': time.time()
}
```

### Server
The server script creates a socket and binds it to a specific host and port. It listens for incoming client connections and spawns a new thread to handle each connection. The server maintains a dictionary ```subscriptions``` that maps symbols to a list of client sockets subscribed to that symbol. The server has three main functions:

1. handle_client(client_socket): This function runs in a separate thread for each client. It continuously listens for messages from the client. If a client subscribes ('subscribe'), it adds the client's socket to the list of subscribers for that symbol. If a client unsubscribes ('unsubscribe'), it removes the client's socket from the list.

2. broadcast_update(symbol, update): Sends stock updates to all clients subscribed to a particular symbol. If a client socket fails during the update broadcast, it removes the client from the subscriptions.

3. simulate_stock_updates(): Simulates stock updates every 2 seconds for all subscribed symbols. The updates include random price data and a timestamp.

The script also starts a thread ```update_thread``` to continuously simulate stock updates. The server runs indefinitely, accepting new client connections.

### Client
The client script connects to the server, creates a socket, and starts a thread (activity_thread) to simulate subscribe and unsubscribe actions. The client has three main functions:

1. subscribe(symbol): Sends a subscribe request to the server, adding the symbol to the client's subscriptions.

2. unsubscribe(symbol): Sends an unsubscribe request to the server, removing the symbol from the client's subscriptions.

3. simulate_human_activity(): Simulates a sequence of subscribe and unsubscribe actions with a delay of 5 seconds between each action.

The client continually receives data from the server, decodes it, and processes the updates. The received data is split into lines based on newline characters. The client then parses the JSON updates and updates its quotes dictionary to replicate the data to the local machine of the client.

The client script runs indefinitely, listening for updates and processing them as they arrive.

### Improvements for server scalability
I am currently using a Python dictionary data structure to store data on client subscriptions. This is not scalable on an enterprise level. But to do so I would use a low latency  database to store data on subscriptions to send the appropriate transmissions to each client. Assuming we want to save on throughput by only sending the stock data that clients want to subscribe to.
