### Real time quote server
This program simulates a client-server architecture that broadcasts and receives data in real time and is designed for multiple client connections, with multiple client-managed subscriptions to control what data the server broadcasts to the itself. I use Python to set up clients and server with a streaming TCP connection between them, with functionality to store data locally.

### Interface
The data transferred between client are JSON strings seralised in UTF-8. They sent through the stream, and deseralised upon receiving. This data is used to communicate instructions or send quotation data in real-time. Because this is a stream, the TCP connection cannot preserve boundaries between strings, so a newline character is used to separate string, and parsing is done at the client.

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

### Client
The client has functions for sending requests for subscribing and unsubscribing to stocks to the server. Human activity is simulated in a function in a predetermined fashion. The client subscribes to Apple, waits 5 seconds, subscribes to Amazon, waits 5 seconds, then unsubscribes to Apple. The data received by the client is reflected in the terminal when running the client python script.

### Server
The server is listening on a particular address and port for the clients to connect to. When a client makes a connection, it creates a new thread to handle the client's requests, this thread closes when the connection is closed or client disconnects. 

The server stores data in local memory on what tickers are subscribed by which clients so that it only broadcasts quote updates if a client is currently subscribed to a stock (reduce unnecessary throughput). The data is updated and changed based on client's subs and unsubs, and the appropriate logic changes occur. Stock data is updated and broadcasted every 2 seconds to simulate live streaming data, and is sent to appropriate clients in the ```simulate_stock_updates()``` function.

### Improvements for server scalability
I am currently using a Python dictionary data structure to store data on client subscriptions. This is not scalable on an enterprise level. But to do so I would use a low latency  database to store data on subscriptions to send the appropriate transmissions to each client. Assuming we want to save on throughput by only sending the stock data that clients want to subscribe to.
