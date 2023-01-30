
# Assymetric chat written in ruby (beta)

This project is using stdlib base64, openssl and socket.

It is a private chat between two users (so if you want to chat with another person, you need to know his name and vice versa). The first connected client #1 will wait for another client #2 until both exchange their public keys.
## Installation

Install with git clone

```bash
  git clone https://github.com/lightswisp/assymetric_chat.git
  cd assymetric_chat
  ruby server.rb  -> to start the server
  ruby client.rb  -> to connect
```
    
## Authors

- [me](https://github.com/lightswisp)

