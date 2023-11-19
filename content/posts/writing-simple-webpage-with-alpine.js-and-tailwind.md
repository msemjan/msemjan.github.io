---
author: "M. Semjan"
date: "2023-09-04T21:21:13+02:00"
draft: true
title: Writing Simple Webpage With Alpine.js and Tailwind
summary: "Alpine.js is a lightweight Javscript framework that was designed to be a minimal tool for composing behavior directly in your markup. In this post I'll show you how to create a simple website with Alpine.js."
tags:
- Alpine.js
- Tailwind
- Frontend
---
## Introduction

In this post I'll demonstrate how to create a simple website using Alpine.js[^1] and Tailwind[^2].

## Installation

We will use CDN to install both Alpine.js and Tailwind to keep things simple. First, create an `index.html` file with the following boilerplate code:
```html
<!doctype html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--- Install Tailwind --->
    <script src="https://cdn.tailwindcss.com"></script>

    <!--- Install Alpine.js --->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>

    <!--- Customization of the Tailwind config -->
    <script>
      tailwind.config = {
        theme: {
          extend: {
            colors: {
              clifford: '#da373d',
            }
          }
        }
      }
    </script>
  </head>
  <body>
    <!--- The webpage content goes here --->
  </body>
</html>
```

It's also possible to install Alpine.js as a Node.js module[^3]. Tailwind also has a couple of alternative ways of installation[^4].

In production environment, it's recommended to hardcode the latest version of Alpine.js to improve stability. So, instead of `3.x.x`, you should put there a specific version.

## Sources 📚️

[^1]: _Alpine.js_. (n.d.). https://alpinejs.dev/
[^2]: _Tailwind CSS - Rapidly build modern websites without ever leaving your HTML_. (n.d.). Tailwind CSS. https://tailwindcss.com/
[^3]: _Installation — Alpine.js_. (n.d.). http://alpinejs.dev/essentials/installation
[^4]: _Installation - Tailwind CSS_. (n.d.). Tailwind CSS. https://tailwindcss.com/docs/installation
