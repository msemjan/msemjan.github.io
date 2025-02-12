---
title: "Replacing Nginx With Caddy"
date: 2025-02-08T14:27:02+01:00
draft: true
toc: false
images:
tags: 
  - Caddy
  - HTTP Server
  - NGINX
  - Load balancer
  - Application load balancer
  - REST API
  - Round Robin
  - IP Hash
  - Least connected
---
## Introduction

Last year I wrote guides on how to setup [load balancer](./nginx-load-balancer.md) and [reverse proxy](./nginx-reverse-proxy-for-apps.md) using NGINX server. As I announced in [the recent post about my plans for this year](./my-plans-for-2025.md), I've decided to try Caddy[^1] as a replacement for NGINX.

## Caddy VS NGINX

Both Caddy and NGINX are HTTP servers with various features. Both have their advantages and disadvantages. In this section we will compare these two applications.

### NGINX

**Advantages**:
- It's an industry standard
- Highly efficient - Can handle thousands of concurrent connections
- Integrates well with DevOps tools like Docker and Kubernetes
- Highly customizable for various use cases - Can be used as a simple file server, reverse proxy, or load balancer

**Disadvantages**:
- Has a steeper learning curve
- Setting up HTTPS is a bit more involved process

### Caddy

**Advantages**:
- A built-in support for automatic SSL/TLS 
- Easier to setup
- Can be extended using various plugins

**Disadvantages**:
- Smaller community and support
- NGINX has better performance

### Which One Is For You?

I would recommend Caddy for startups, smaller companies, and tech enthusiasts who want HTTPS support without any hassles. Caddy definitely beats NGINX in simplicity and ease of setup.

However, if you need the raw performance for handling thousands of concurrent requests in an enterprise-level applications, then NGINX is clearly a better choice. Moreover, it provides better support for microservices and containerized environments.

## Installation 

To install Caddy follow the [guide](https://caddyserver.com/docs/install) for your OS.

## Caddyfile 

Caddy is configured using a `Caddyfile`, which can be found in `/etc/caddy/Caddyfile`. To test things, we can configure Caddy as a simple file server with the following code:

```Caddyfile
{
	admin "unix//run/caddy/admin.socket"
}

example.com {
	root * /var/www
	file_server
}
```

The first block restricts the access to admin interface to a local unix file socket whose directory is restricted to `caddy:caddy`. By default the TPC socket allows arbitrary modification for any process and that has access to the local interface. Don't leave admin over TCP turned on unless you understands all the implications.

The second block that we specify is for `example.com` website. You can replace this with `localhost` or the IP address of your computer. Everything between curly braces is a block that contains configuration. If there is only a single block (that is without the global settings for `admin`), we can omit the curly braces.

The `root` directive specifies the path to the root of the site (in this case we have a wildcard `*` that matches everything, but we can specify a concrete path, such as `/index.html`), and `/var/www` is the path to the folder with the website files. Finally, `file_server` directive[^2] instructs Caddy to function as a file server.

## Setting Up Reverse Proxy

Setting up the reverse proxy with Caddy is extremely simple. All you need is to include the following block with `reverse_proxy` directive[^3]:

```Caddyfile
{
	admin "unix//run/caddy/admin.socket"
}

example.com {
    reverse_proxy localhost:8080
}
```

After restarting Caddy with `sudo systemctl restart caddy`, it should forward requests to the website running on `localhost:8080`.

If we want to setup the reverse proxy [the same way](./nginx-reverse-proxy-for-apps.md) as we did with our NGINX server (that is, we want to forward only request to `example.com/api/*`, and strip `/api` prefix), we need to modify the `Caddyfile` only slightly:

```Caddyfile
{
	admin "unix//run/caddy/admin.socket"
}

example.com {
    handle_path /api/* {
        reverse_proxy localhost:8080
    }
}
```

The `handle_path` directive[^4] will match requests starting with `/api`, and strip the `/api` prefix from the path.

We can additionally add configuration to add various headers (if required):

```Caddyfile
{
	admin "unix//run/caddy/admin.socket"
}

example.com {
    handle_path /api/* {
        reverse_proxy localhost:8080 {
            header_up Host {host}
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
        }
    }
}
```

In this example, Caddy will add `Host`, `X-Real-IP`, `X-Forwarded-For`, and `X-Forwarded-Proto` to the requests forwarded to our service.

## Setting Up Load Balancer

Setting up a load balancer is just as easy as setting up the reverse proxy. In fact, it is done with the `reverse_proxy` directive:

```Caddyfile
{
	admin "unix//run/caddy/admin.socket"
}

example.com {
    reverse_proxy localhost:8080 localhost:8081 localhost:8082
}
```

The requests to `example.com` will be load-balanced across `localhost:8080`, `localhost:8081`, and `localhost:8082`. By default, round-robin is used. If one of these services becomes unavailable, Caddy will automatically retry the next available one.

In some cases, round-robin is undesirable. For example, our service may require sticky sessions to work properly (e.g. because of caching or sessions). If we need a different load balancing method, we can specify it with `lb_policy` directive. Example for using IP hashes to select the server to forward the request to based on client's IP address:

```Caddyfile
{
	admin "unix//run/caddy/admin.socket"
}

example.com { 
    reverse_proxy {
        lb_policy ip_hash
        to localhost:8080 localhost:8081 localhost:8082
    }
}
```

The available options for `lb_policy` are summed up in the following table:

| Policy | Description |
|---------|-------------|
| `round_robin`     | Default method, distributes requests evenly across all servers |
| `random`          | Selects a random server for each request |
| `least_requests`  | Routes traffic to the server with the fewest active connections (similar to NGINX's `least_conn`) |
| `first`           | Always picks the first server in the list (useful for failover scenarios, when we want the primary server to handle all traffic unless it fails) |
| `ip_hash`         | Assigns a server based on the client's IP address, ensuring sticky sessions |
| `uri_hash`        | Assigns a server based on the request URI, ensuring consistent routing for the same resource |

Moreover, we can easily setup health checks to ensure that unhealthy servers are not used. Example:

```Caddyfile
{
	admin "unix//run/caddy/admin.socket"
}

example.com { 
    reverse_proxy {
        lb_policy least_requests    # The server with least connections will be used
        to localhost:8080 localhost:8081 localhost:8082

        health_uri /health          # Check `/health` endpoint
        health_interval 10s         # Check every 10 seconds
        health_timeout 2s           # Fail check if there is no response in 2 seconds
    }
}
```

With this setup Caddy will:
- Send traffic to the server with the least active connections
- Automatically remove unhealthy servers from the pool
- Retry failed requests on anther server

## Conclusions

The goal of this was to showcase capabilities of Caddy. We looked at the basics in an attempt to reproduce the setup that I have for NGINX (see posts about setting up [load balancer](./nginx-load-balancer.md) and [reverse proxy](./nginx-reverse-proxy-for-apps.md) with NGINX). 

I think I managed to demonstrate that we can configure the same functionality as for NGINX. The format of Caddyfile is easier to read and write than the one that the NGINX uses. We haven't gone into depth, and there are still various [Caddyfile directives](https://caddyserver.com/docs/caddyfile/directives) that you can use in your configuration.

Other interesting features to mention are support for [Prometheus metrics](https://caddyserver.com/docs/caddyfile/directives/metrics), automatic [HTTPS](https://caddyserver.com/docs/quick-starts/https), [templates](https://caddyserver.com/docs/caddyfile/directives/templates), or [PHP FastCGI](https://caddyserver.com/docs/caddyfile/directives/php_fastcgi), but these are out of scope of this post.

If you are looking for a simple HTTPS server for your home lab, give Caddy a shot. It's not as popular as NGINX, but it's easy to setup. The only disadvantage is that the community is much smaller and in case of issues it will be more difficult to find help or a guide with a fix.

## Sources

[^1]: Server, C. W. (n.d.). Caddy - _The Ultimate Server with Automatic HTTPS_. Caddy Web Server. https://caddyserver.com/
[^2]: Server, C. W. (n.d.-b). _file_server (Caddyfile directive) - Caddy Documentation_. https://caddyserver.com/docs/caddyfile/directives/file_server
[^3]: Server, C. W. (n.d.-c). _reverse_proxy (Caddyfile directive) - Caddy Documentation_. https://caddyserver.com/docs/caddyfile/directives/reverse_proxy
[^4]: Server, C. W. (n.d.-c). _handle_path (Caddyfile directive) - Caddy Documentation_. https://caddyserver.com/docs/caddyfile/directives/handle_path
