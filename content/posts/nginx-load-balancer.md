---
title: "Using NGINX As A Load Balancer"
date: 2024-06-15T11:09:40+02:00
draft: false 
toc: false
summary: "Load balancing is a process of distributing a set of tasks to multiple resources (e.g. processing units or servers) with a goal of increasing efficiency of processing, maximizing throughput, reducing latency, and ensuring fault tolerant configuration. In this post we will take a look at how to configure load balancing with NGINX server."
tags:
  - NGINX
  - Load balancer
  - Application load balancer
  - REST API
  - Round Robin
  - IP Hash
  - Least connected
---
## What Is A Load Balancer And Why Do I need It?

Load balancing is a process of distributing a set of tasks across multiple resources (processing units on a single computer or several separate servers) with a goal of increasing efficiency of processing, maximizing throughput, reducing latency, and ensuring fault tolerant configuration.

In this post I will show you how to configure a NGINX server as a load balancer. I also have a guide on how to [configure NGINX as a reverse proxy](./nginx-reverse-proxy-for-apps), that includes steps on how to install NGINX server on Raspberry Pi.

## Load Balancing Methods

There are three common load balancing methods supported by NGINX server:
- **Round-Robin**: All requests are evenly distributed across the application servers in a round Robin fashion.
- **Least Connected**: An in-comming request is forwarded to the server with the least number of active connections.
- **IP Hash**: The server to which the requests go is determined with a hash-function of the client's IP address.

## Simple Load Balancer Configuration

The simplest configuration of load balancing in NGINX would look something like this:

```nginx
http {
    upstream my-app {
        server server1.com;
        server server2.com;
        server server3.com;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://my-app;
        }
    }
}
```

In this example there are three instances running on `server1.com`, `server2.com`, and `server3.com`. Since the load balancing method was not specified, the load balancer defaults to round-robin, which distributes the requests to all the servers evenly. The requests are proxied to the server group `my-app` and NGINX applies HTTP load balancing to distribute the requests.

Load balancing can be applied to HTTPS instead of HTTP if you specify `https` as the protocol.

>
> **Note**: The servers can be multiple instances of some application running on a single computer, e.g. when we are running multiple instances of a Node.js application on a single server. This way we can overcome the single-threaded nature of Node.js. The instances would be differentiated by ports:
> ```nginx
> http {
>       upstream my-app {
>           server http://localhost:8000;
>           server http://localhost:8001;
>           server http://localhost:8002;
>           server http://localhost:8003;
>      }
>      # Rest of the configuration
> }
> ```
>

## Least Connected Load Balancer

The configuration above is not ideal in all situations, e.g. some requests may take longer to finish than others. In such case it is better to use the least-connected method. With this option, NGINX will not send requests to the busy servers, which could overload them. Instead the least busy server is selected.

If you want to use the least-connected method, simply add `least_conn` directive in the server group configuration:

```nginx
http {
    upstream my-app {
        least_conn; # <=== This was added
        server server1.com;
        server server2.com;
        server server3.com;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://my-app;
        }
    }
}
```

## Session Persistence

There is no guarantee, either with the round-robin, or with the least-connected method, that all the requests from the same client will be forwarded to the same server. This may pose a significant problem to some applications, but it is easy to mitigate the issue by using the IP hash method. Since the hash function is deterministic, hashing a given IP address will result in the requests being forwarded to the same server.

To configure the IP hash method, add `ip_hash` directive into the server group configuration:

```nginx
http {
    upstream my-app {
        ip_hash; # <=== This was added
        server server1.com;
        server server2.com;
        server server3.com;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://my-app;
        }
    }
}
```

## Weighted Load Balancing

In addition to the configurations above, it is also possible to further influence load balancing by adding server weights to the configuration. When no weights are specified, it means that all servers are treated equally. When the round-robin is used, all requests are distributed (more or less) uniformly to all servers.

However, we may want to change the distribution and send more requests to some of the servers.

In the example below we increased the weight of the `server1.com`. With this configuration for every five requests, three will go to the `server1.com`, one to the `server2.com` and one to the `server3.com`.

```nginx
http {
    upstream my-app {
        server server1.com weight=3;
        server server2.com;
        server server3.com;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://my-app;
        }
    }
}
```

In the recent versions of NGINX weights can be used with the least-connected and the IP hash as well.

## Health Checking And Other Settings

Reverse proxy implementation in NGINX includes health checks. If a server fails with an error, NGINX will consider this server as failed and avoid sending subsequent requests to this server.

This behavior can be tailored to your specific needs with the following directives:
- [`max_fails`](https://nginx.org/en/docs/http/ngx_http_upstream_module.html#server) - Specifies a number of unsuccessful requests that should happen during a `fail_timeout`. The default value is `1`. When set to `0`, the health checks will be disabled for this server.
- [`fail_timeout`](https://nginx.org/en/docs/http/ngx_http_upstream_module.html#server) - Specifies for how long will the server be marked as failed. After this period, NGINX will probe the server with the live client's requests. If the requests are successful, the server is marked as a live one.

In addition to the directives above, there are other directives and parameters that can modify and control load balancing in NGINX. For example, you may want to look at:
- [`proxy_next_upstream`](https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_next_upstream) - Specifies in which cases the requests should be passed to the next server.
- [`backup`](https://nginx.org/en/docs/http/ngx_http_upstream_module.html#server) - Marks the server as a backup server. The requests will be passed to this server, when the primary servers become unavailable.
- [`down`](https://nginx.org/en/docs/http/ngx_http_upstream_module.html#server) - Marks the server as permanently unavailable.
- [`keepalive`](https://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive) - Activates a cache for the connections to upstream servers.

If you need more information take a look at NGINX documentation[^1].

## Conclusion

In this post I showed how to configure load balancing with NGINX server. It is more important than ever to know how to use load balancers. Modern applications have to process large amounts of text, videos, images and other traffic in a fast and reliable manner. To handle such volume of data, several instances of applications are running and requested data is distributed by load balancers that sit between the internet and the applications.

## References

[^1]: _nginx documentation_. (n.d.). https://nginx.org/en/docs/
