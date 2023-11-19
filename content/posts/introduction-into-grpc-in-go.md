---
date: "2023-11-15T18:35:15+01:00"
draft: true
title: "Introduction Into gRPC in Go"
summary: "gRPC is a modern alternative to REST APIs, which uses protocol buffers to encode messages to decrease the size of data that needs to be send over the networ and increase the speed of encoding and decoding messages. Read this post to learn more about gRPC, it's advantages and disadvantages, and how to get started with this technology."
author: "M. Semjan"
tags:
- gRPC
- Protocol Buffers
- Golang
- Go
- Data Serialization
---
## Introduction

gRPC is a modern, cross-platform Remote Procedure Call (RPC) framework created by Google and released in 2016. It is considered to be an alternative to [REST](https://en.wikipedia.org/wiki/REST) APIs, and can be used to connect various services. REST uses JSON, which is a plain-text format, while gRPC uses a [protocol buffers](../introduction-into-protocol-buffers-in-go). Protocol buffers are a binary format, which was designed to result in smaller serialized messages, which are simple to use and faster to encode and decode. This leads to a noticeable speedup when compared to REST and JSON.

Despite all the advantages, you should not immediately start rewriting all your REST services. Let's look at various advantages and disadvantages of gRPC.

## Advantages and disadvantages
### Advantages

The main benefit that gRPC promises is its speed. Because of a binary format is uses, it should be much faster to encode and decode messages. Moreover, the data that is sent over the network should be smaller, because protocol buffers are more efficient way of encoding data than JSON.

Unlike REST, which uses HTTP 1.1, gRPC is using HTTP/2, which allows for various new features, such as server-side streaming, client-side streaming, or bi-directional streaming.

### Disadvantages

The biggest disadvantage of gRPC is that it is not supported by any of the modern browsers (all are using HTTP 1.1, no HTTP/2), and therefor it is either necessary to use something like [gRPC-web](https://grpc.io/docs/platforms/web/basics/) that lets you access gRPC services built from browsers using an idiomatic API.

Other disadvantage is that protocol buffers are not human-readable and therefore it is more difficult to work with them. While a simple REST service can easily be tested with a simple request using `curl` or Postman, you will need an extra step transcode requests.

That being said, it is still an excellent choice for facilitating communication between various back-end services or when creating mobile apps.

## A simple example in Go

In this example, I'll create a simple gRPC server and a client in Go. The gRPC server will expose two endpoints to send new notifications and fetch the list of notifications.

### Setup

Let's start by creating a new directory for our project, and then running `go mod init` to create `go.mod` and `go.sum` files.

Before writing gRPC clients and servers, you need to have protocol buffer and gRPC code generator installed.
```
$ go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
$ go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
```

Also, don't forget to update your `PATH` so that your `protoc` compiler is able to find and use the plugins:
```
$ export PATH="$PATH:$(go env GOPATH)/bin"
```

### Protocol buffers

As mentioned above, gRPC uses [protocol buffers](../introduction-into-protocol-buffers-in-go). Before we start writing our Go server, we need to create a file that defines messages and available services. Let's create a folder `pb` and put in it a `message.proto` file with the following content:
```proto
syntax = "proto3";
option go_package = "./types";

// Type for notifications
message Notification  {
  string title  = 1;
  string body   = 2;
  string from   = 3;
  string for    = 4;
}

// A list of notifications
message Notifications {
  repeated Notification notifications = 1;
}

// A return type for sending notifications, the status should be non-zero,
// if there is some issue
message ServerResponse {
  int32 status = 1;
}

// An empty type
message Empty {}

// Define functions that a client can use
service NotificationService {
  rpc SendNotification(Notification) returns (ServerResponse) {};
  rpc GetNotifications(Empty) returns (Notifications) {};
}
```

The first line tells us that we are using version 3 of protocol buffers syntax. The second line specifies Go package. I haven't seen it in some examples online, but without it the compiler generates an error and no Go code, so it is necessary. The `message Something {}` specifies what the messages look like, that is what fields we can expect and what are their types. The value after the equal sign specifies a unique field number and it specifies a field in the message wire format. In the `Notifications` message you can a `repeated` keyword, which specifies that `notifications` is an array with values of type `Notification`.

The messages are similar to Go's `struct`s. You can learn more about the syntax of protocol buffers in the [protocol buffers documentation](https://protobuf.dev/programming-guides/proto3/), including supported types, enumerations, nested types, and other details.

Lastly, we define a `service` that has two remote procedure calls (RPC) - `SendNofication` and `GetNotifications`. You can think of these as REST endpoints. As you can see, the definition of these functions includes types of arguments and the return type. Unfortunately, all functions require an argument, and there is no `void` type for functions that have no arguments, so I had to create an `Empty` message with no fields to represent `void`.

We will use `SendNofication` and `GetNotifications` to create new notifications and fetch the excising ones, respectively.

Now, we need to create a `types` folder for the generated Go code.

Once you've created the `pb/message.pb` file and created a `types` folder, you can generate Go code using this command:
```
$ protoc --go_out=types --go_opt=paths=source_relative \
         --go-grpc_out=. --go-grpc_opt=paths=source_relative \
         pg/*.proto
```

If it was successful, you should see two new files in `types` folder: `message_grpc.pb.go` and `message.pb.go`. If you want to, you can check the generated code. It contains `struct`s that represent our protocol buffers messages and various functions necessary for marshaling an unmarshaling messages.

### Server

Now we are ready to create a gRPC server. Create a `server.go` file:
```go
package main

import (
	"log"
	"net"

	"github.com/msemjan/go-grpc/types"
	"google.golang.org/grpc"
)

func main() {
	// Create a TPC connection and listen on port 9000
	lis, err := net.Listen("tcp", ":9000")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	// Create a gRPC server
	grpcServer := grpc.NewServer()

	// Create a server that defines the SendNotification and GetNotifications
  // functions
	notificationServer := types.MyGRPCServer{}

  // Register our service
	types.RegisterNotificationServiceServer(grpcServer, &notificationServer)

  // Start a server
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %s", err)
	}
}
```

We also need to define `MyGRPCServer`. We will create a `types/service.go` file, and write the following code:
```go
package types

import (
	"context"
	"log"
)

// Create our server
type MyGRPCServer struct {
  // Without this, we will be getting an error
	UnimplementedNotificationServiceServer
}

// Create fake notifications, this can also be empty. In real-world example,
// this data would come from a database
var notifications = &Notifications{
	Notifications: []*Notification{
		&Notification{
        Title: "New message from 'Jerry'",
        Body: "Hi, how are you doing?",
        From: "Messenger",
        For: "User",
      },
		&Notification{
        Title: "Low batter",
        Body: "Plug in charger as soon as possible",
        From: "System",
        For: "User",
      },
		&Notification{
        Title: "Alarm",
        Body: "Wake up!",
        From: "Alarm",
        For: "User",
      },
	},
}

func (s *MyGRPCServer) SendNotification(
  ctx context.Context,
  notification *Notification,
) (*ServerResponse, error) {
  // When the client sends a new notification, we log it, append it to the list
  // of notifications, and send a status with code 0 for success. Since there
  // probably shouldn't be any issue, we are not handling any errors. In
  // real-world example, you probably would want to replace this with a database
  // insert.
	log.Printf("New notification: %s", notification.String())
	notifications.Notifications = append(notifications.Notifications, notification)
	return &ServerResponse{Status: 0}, nil
}

func (s *MyGRPCServer) GetNotifications(
  ctx context.Context,
  _ *Empty,
) (*Notifications, error) {
  // If the user requests notifications, we log that there is a request, and
  // then send all the notifications. Again, in a real-world there would be some
  // kind of database search here instead of a slice.
	log.Println("User is requesting notifications")
	return notifications, nil
}
```

These two files are enough to create a working gRPC server that allows you to send new notifications and fetch all the notifications. You can test that the code works with `go run server.go`.

### Client

To test that our server works correctly, we can create a simple client in `client.go` file:
```go
package main

import (
	ctx "context"
	"log"

	"golang.org/x/net/context"
	"google.golang.org/grpc"

	"github.com/msemjan/go-grpc/types"
)

func main() {
  // Create a gRPC connection for our client
	var conn *grpc.ClientConn

  // Create a connection to our server on the port 9000
	conn, err := grpc.Dial(":9000", grpc.WithInsecure())
	if err != nil {
		log.Fatalf("Error while connecting to the server: %s\n", err)
	}
	defer conn.Close()

  // Create a gRPC client
	client := types.NewNotificationServiceClient(conn)

  // Use SendNotification remote procedure call. This should send a new
  // notification to our server, and add it to the list of existing notifications.
	_, err = client.SendNotification(
      context.Background(),
      &types.Notification{
        Title: "Client notification",
        Body: "Hello from the client",
        From: "Client",
        For: "User"},
      )
	if err != nil {
		log.Fatalf("Error when calling SendNotification: %s\n", err)
	}

  // At this point, the notifications were sent and there was no error.
	log.Println("Notification successfully sent\n")

  // Use GetNotification remote procedure call. This should return all the
  // notifications from our server.
	notifications, err := client.GetNotifications( ctx.Background(),
    &types.Empty{})
	if err != nil {
		log.Fatalf("Error when calling GetNotifications: %s\n", err)
	}

  // If there is no error and we receive notifications, we print them out.
	log.Printf("Notifications received:")
	for _, notification := range notifications.Notifications {
		log.Printf("Title: '%s', Body: '%s', From: '%s', For: '%s'\n",
      notification.Title, notification.Body, notification.From, notification.For)
	}
}
```

Now we are ready to test our application. Start server with `go run server` and then you can run the client with `go run client.go`. It will quickly send a new notification, fetch all the notifications, and print them out and, then it will exit. In the output you should see something along lines:
```
$ go run client.go
2023/11/19 16:46:37 Notification successfully sent

2023/11/19 16:46:37 Notifications received:
2023/11/19 16:46:37 Title: 'New message from 'Jerry'', Body: 'Hi, how are you
  doing?', From: 'Messenger', For: 'User'
2023/11/19 16:46:37 Title: 'Low batter', Body: 'Plug in charger as soon as
  possible', From: 'System', For: 'User'
2023/11/19 16:46:37 Title: 'Alarm', Body: 'Wake up!', From: 'Alarm', For:
  'User'
2023/11/19 16:46:37 Title: 'Client notification', Body: 'Hello from the
  client', From: 'Client', For: 'User'
```

## Conclusions

gRPC is a faster and more efficient alternative to REST APIs that uses protocol buffers as an encoding format. It allows programmers to specify remote procedure calls (RPC) and specific format of the data that these RPC endpoints use. gRPC supports several popular languages, which means that you can have various services written in different programming languages communicate using this technology. It is mostly used on the back-end to send information between various microservices.

In this post I've discussed advantages and disadvantages of gRPC and provided an example of a simple gRPC server and a client. You can find the full example on my [Github](https://github.com/msemjan/go-grpc).
