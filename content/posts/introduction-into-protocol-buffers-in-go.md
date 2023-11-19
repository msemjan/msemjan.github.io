---
date: "2023-08-26T09:14:53+02:00"
draft: true
summary: Protocol buffers are a language-agnostic and platform-independent mechanism
  for serialization of data created by Google. Protocol buffers can be used as a replacement
  for older formats, such as JSON or XML, but they are designed to be much smaller,
  faster and simpler.
tags:
- Protocol Buffers
- Golang
- Go
- Data Serialization
title: Introduction Into Protocol Buffers in Go
---
## Introduction

Protocol buffers[^1] are a language-agnostic and platform-independent mechanism for serialization of data created by Google. Protocol buffers can be used as a replacement for older formats, such as JSON or XML, but they are designed to be much smaller, faster and simpler. The speed is achieved by the fact that protocol buffers encode information into a binary format, which both increases the speed of parsing and reduces the size of the message, which in turn improves the transmission speeds.

Before using them, one has to specify how the data is structured, and then the language-specific code can be automatically generated. Currently protocol buffers are supported in the following languages: Java, Python, Objective-C, and C++, and in `proto3` version you can also use Kotlin, Dart, Go, Ruby, PHP, and C#.

The most notable application of protocol buffers is in [gRPC](../introduction-into-grpc-in-go), which is a high-performance framework that can run in any environment and can be used as a more efficient replacement for REST APIs in some applications[^2].

One of the main benefits of protocol buffers is that they are language-independent and therefore the producer of a message can be written in a different language than the consumer.

In this blog post I'll show you how to get started with protocol buffers in Go programming language[^3].

## Preparation

In this tutorial we will be using `proto3` version of protocol buffers[^4]. Before we start working with the protocol buffers, you need to install the compiler. Head to the [download page](https://protobuf.dev/downloads), get the package and follow the instructions in the README. In my case, I was able to download the package using my Linux distribution package manager.

First, we need the `go.mod` file, which can be generated with:
```
go mod init github.com/msemjan/protobuf-tutorial
```

You also need to install a couple of packages:
```bash
go get github.com/golang/protobuf
go get github.com/golang/protobuf/proto
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
```

Finally, make sure that you've exported `$GOPATH/bin`:
```bash
export PATH=$PATH:$GOPATH/bin
```

## Specifying the message structure

As an example, I've decided to create a message for posts with several common fields: id, author, title, body, and an array of tags.

As I've mentioned before, the protocol buffers require you to specify the message structure in a `.proto` file. So let's create a `types` folder and inside it a `post.proto` file with the following content:
```proto
syntax = "proto3";

package pb;
option go_package = "./pb";

message Post {
  int64 id = 1;
  string author = 2;
  string title = 3;
  string body = 4;
  repeated string tags = 5;
}
```

The first line says that we are using the version 3 of the protocol buffers. We also declared a package `pb`. The third line is necessary when we want to work with protocol buffers in Go. Basically, this will cause the code generator to create a `pb` folder in the root of our project and put all the generated files there.

As you can see the message itself has several fields that have types. Protocol buffers support several types that are similar to those used by Go. A full list of scalar types can be found in the [documentation](https://protobuf.dev/programming-guides/proto3/#scalar). The only field that is not scalar in our example is the `tags` field. Each post can have several tags, and you can create something like an array with `repeated` keyword.

Also notice that we are giving each field a unique identifier (`= 1`, `= 2`, ...) that is used in the binary encoding. Tag numbers 1-15 require one less byte to encode than higher numbers, so as an optimization you can decide to use those tags for the commonly used or repeated elements, leaving tags 16 and higher for less-commonly used optional elements. This is particularly important for the repeated fields, since they require re-encoding of the tag number. But in our case, it is not necessary, since we don't have so many fields.

Once you've created all your `.proto` files, you can compile them with this command:
```bash
protoc --go_out=. types/*.proto
```

This will generate Go code automatically. You can check the compiled files in the `pb` folder. It will contain a Go `struct` that represents the `Post` message and several functions necessary for the protocol buffers. Do not modify these files manually!

## Marshaling and unmarshaling

Now that we've created a specification of the message structure, and generated Go code, we can start using protocol buffers inside of our Go applications. 

Below is a full example with comments that shows how to marshal your `struct`s, save them into a file, read them, and finally, how to unmarshal them.
```go
package main

import (
	"fmt"
	"io/ioutil"
	"log"

	"github.com/golang/protobuf/proto"
	"github.com/msemjan/protobuf-tutorial/pb"
)

func PrintPost(post pb.Post) {
	fmt.Printf("Id:     %v\n", post.Id)
	fmt.Printf("Author: %v\n", post.Author)
	fmt.Printf("Title:  %v\n", post.Title)
	fmt.Printf("Body:   %v\n", post.Body)
	fmt.Printf("Tags:   %v\n", post.Tags)
}

func main() {
	filename := "posts.data"

	// Create a post - this is a standard Go structure
	post := pb.Post{
		Id:     1234,
		Author: "Jon Doe",
		Title:  "Protobufs",
		Body:   "Protobufs are amazing :)",
		Tags:   []string{"protobufs", "golang", "data", "serialization"},
	}

	// Marshaling the data
	marshaledPost, err := proto.Marshal(&post)
	if err != nil {
		log.Fatalln("Failed to marshal the post: ", err)
	}

	// Writing the data into a file
	if err := ioutil.WriteFile(filename, marshaledPost, 0644); err != nil {
		log.Fatalln("Failed to write the post into a file:", err)
	}

	// Reading the data from a file
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Fatalln("Failed to read the post into a file:", err)
	}

	// Unmarshaling the data
	readPost := pb.Post{}
	if err := proto.Unmarshal(data, &readPost); err != nil {
		log.Fatalln("Failed to unmarshal the post: ", err)
	}

	PrintPost(readPost)
}
```

We can run the code with:
```bash
go run main.go
```

And we should get the following output:
```
Id:     1234
Author: Jon Doe
Title:  Protobufs
Body:   Protobufs are amazing :)
Tags:   [protobufs golang serializations]
```

## Conclusion

In this blog post I demonstrated how to create a simple message with protocol buffers in Go programming language. Their main use is as a serialization format for gRPC, which can be used as a replacement for REST APIs. I consider protocol buffers to be a technology that will become more desired in future, especially for communication between various back-end services, low-powered and mobile devices. Protocol buffers and gRPC are relatively simple to set up and work with, and offers various benefits, such as increased speed and efficiency. They definitely require a little more setup than using JSON, but if you are transmitting a large quantity of messages, it's worth it. It probably won't replace JSON or XML soon, because at the moment HTTP/2 required by the gRPC is not supported by any of the major browsers. Protocol buffers can also be used to store data on the hard drive, and due to their use of binary encoding, the saved files will take up less space then the same data encoded in JSON or XML.

## Sources 📚️

[^1]: _Protocol buffers_. (n.d.). https://protobuf.dev/
[^2]: _GRPC_. (n.d.). gRPC. https://grpc.io/
[^3]: _Protocol buffer Basics: Go_. (n.d.). Protocol Buffers Documentation. https://protobuf.dev/getting-started/gotutorial/
[^4]: _Language Guide (proto 3)_. (n.d.). Protocol Buffers Documentation. https://protobuf.dev/programming-guides/proto3
