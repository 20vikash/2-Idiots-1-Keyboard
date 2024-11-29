import socket
import threading

clients = []

def listen_to_shit(c):
    while True:
        data = c.recv(1024).decode()
        if (data):
            send_shit(c, data)
            print(data)

def send_shit(c, content):
    for i in clients:
        if c != i:
            i.send(content.encode())

s = socket.socket()

port = 8081

s.bind(('', port))

s.listen()
print("Socket is listening")

while True:
    c, addr = s.accept()
    print("Client connected")
    clients.append(c)
    
    threading.Thread(target=listen_to_shit, args=(c,)).start()
