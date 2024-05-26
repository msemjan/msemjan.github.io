---
title: "Nginx Reverse Proxy for Apps"
date: 2024-05-26T19:52:00+02:00
draft: false 
toc: false
summary: "Have you ever found yourself in the following situation: You have a application that is running locally on your computer (e.g. Raspberry Pi) and you want to access it from your other devices. When you make a request on `http://localhost:PORT/SOME_ENDPOINT` from the computer on which the application runs, it is successful, but when you use other device, the website can not be found. If yes, than this is an article for you!"
tags:
  - NGINX
  - Reverse Proxy
  - REST API
---
## Introduction

Have you ever found yourself in the following situation: You have a application that is running locally on your computer (e.g. Raspberry Pi) and you want to access it from your other devices. When you make a request on `http://localhost:PORT/SOME_ENDPOINT` from the computer on which the application runs, it is successful, but when you use other device, the website can not be found.

Yes? Then you are in the right place, because I will show you how to set-up a reverse proxy on NGINX server that will forward requests from the other devices to your application. NGINX has several other functions that make it extremely useful, including reverse proxy server, a mail proxy server, a load balancer, and a generic TCP/UDP proxy server. However, we will focus on the reverse proxy and it's settings.

For simplicity, I will show an example for Raspberry Pi running Raspberry OS. However, the process would be similar for other Linux distribution.

## Installing NGINX

Since there is a package for NGINX server in the default Raspberry repository, you can simply run:
```bash
sudo apt update && sudo apt upgrade
sudo apt install nginx
```

Once installed, you can use NGINX for hosting static websites by copying the website files to `/var/www/html`, but that is not why we installed it.

It is also good idea to configure NGINX to start on the startup/reboot by running the following commands:
```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

You can than check if the NGINX is running with:
```bash
sudo systemctl status nginx
```

If it is running, you should see `active (running)` next to the `Active`.


## Setting Up Reverse Proxy

When NGINX proxies a request, it sends it to a specific server defined in a configuration file, and sends whatever response it gets back to the client. Setting up NGINX as a reverse proxy is very easy.

We will use and edit the default configuration file. Some guides suggest that you should unlink it, and create a new one, but I think it is sufficient to create a copy in case of any issues by running:

```bash
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
```

The configuration file can be found at `/etc/nginx/sites-available/default`. Open it with your favorite text editor and add a new `location` directive in the default server configuration. In the end, the configuration should looks something like this (I removed the comments that were there by default):
```nginx
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	root /var/www/html;

	index index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
		try_files $uri $uri/ =404;
	}

	location /api {
		 rewrite ^/api/(.*) /$1  break;
		 proxy_pass http://localhost:8081;
		 proxy_set_header Host $host;
		 proxy_set_header X-Real-IP $remote_addr;
		 proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		 proxy_set_header X-Forwarded-Proto $scheme;
	}
}
```

The added part was:

```nginx
	location /api {
		 rewrite ^/api/(.*) /$1  break;
		 proxy_pass http://localhost:8081;
		 proxy_set_header Host $host;
		 proxy_set_header X-Real-IP $remote_addr;
		 proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		 proxy_set_header X-Forwarded-Proto $scheme;
	}
```

Explanation:
- `server` sets configuration for a virtual server. There can be several servers in a single configuration file.
- `server_name` specifies the name of the virtual server. Several names can be specified (separated by spaces), and wildcards and regular expressions for names are allowed. In our case it is `_`
- `listen` directive sets the address and port for IP, or the path for a UNIX-domain socket on which the server will accept requests. In our case we will listen on port `80`. If there is `default_server`, than the server will become the default server for the specified address and port
- The default `location /` blog makes server try to serve files from a specified URI or return 404 HTTP status.
- The added `location /api` specifies that we want to redirect any request sent to `http://SERVER_IP/api/...` `http://localhost:8081/...` (if your application runs somewhere else, e.g. on a different port, modify the configuration).
- I've also added `rewrite ^/api/(.*) /$1  break;` line, which strictly speaking, is not necessary, but without it the forwarded requests have the `/api/...` part and I wanted to remove it. Basically, it is a regex that strips the beginning of the path (`/api`) and leaves the rest
- `proxy_pass` directive specifies the inside location. In this case it is an application that is running on the `http://127.0.0.1:8080`.
- Another option in the `location`, `proxy_set_header`, which allows us to redefine or append fields to the request header passed to the proxied server. The `proxy_set_header` is followed by the field name and the value. As you can see, we are also using variables (the values that start with `$` sign). These values are inherited from the previous configuration level, if they are not defined on the current level. Only two fields are redefined by default:
  ```nginx
  proxy_set_header Host       $proxy_host;
  proxy_set_header Connection close;
  ```
  The fields that are add in the configuration are rather self-explanatory. To prevent the header from being passed, you can set it to an empty string (e.g. `proxy_set_header Accept-Encoding "";`).

Than you can restart the NGINX server to use the updated configuration file:

```bash
sudo systemctl restart nginx
```

And finally, you can test the configuration syntax by making a HTTP request to `http://SERVER_IP/api/...`. You can get the `SERVER_IP` address by running the following command in the Raspberry Pi's terminal:

```bash
hostname -I
```

If you don't have an application to try it with, you can use this simple "Hello World" server written in Go (you need Go compiler, though). Just create a `main.go` file and paste the following code:

```go
package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", HelloServer)
	http.ListenAndServe(":8081", nil)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
		name := r.URL.Path[1:]
		if len(name) == 0 {
			fmt.Fprintf(w, "Hello World!")
			return
		}
		fmt.Fprintf(w, "Hello, %s!", name)
}
```

You can run it with:

```bash
go run main.go
```

The request made on `http://SERVER_IP/api` should return `Hello world` message. You can also add your name for a personalized message: `http://SERVER_IP/api/YOUR_NAME` 🙂.

## Conclusion

Setting up NGINX as a reverse proxy is very useful and can help you expose your services and applications to local network. NGINX is used by ordinary tech enthusiasts, small, and large business. I believe that having a basic working knowledge of setting up things like reverse proxy, load balancing, content caching, and other NGINX functionality is an amazing skill to have.

In this tutorial I showed the minimal settings needed for exposing local applications to the local network, but I left some things out for simplicity. If you need to use more advanced settings, such as configuration of buffers or choosing an outgoing IP address, check a NGINX documentation[^1] or a NGINX tutorial[^2] that goes more in-depth.

## Further Reading 📚️

[^1]: _nginx documentation_. (n.d.). https://nginx.org/en/docs/
[^2]: _NGINX Reverse Proxy_. (n.d.). NGINX Documentation. https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/
