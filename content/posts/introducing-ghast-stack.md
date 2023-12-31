---
author: M. Semjan
date: "2023-08-11T18:12:17+02:00"
draft: false
summary: GHAST stack is a new tech-stack for developing web applications without excessive
  use of Javascript. In this article I describe why I am suggesting usage of this
  tech-stack and what technologies it uses.
tags:
- Tech-stack
- GHAST-Stack
- Golang
- HTMX
- Alpine.js
- SQL
- Tailwind
- Front-end development
- Back-end development
- Fullstack development
- Programming
title: Introducing GHAST Stack
---
# Introducing GHAST Stack

GHAST stack is a new tech-stack for developing web applications without excessive use of Javascript. In this article I describe why I am suggesting usage of this tech-stack and what technologies it uses.

## Why A New Tech-Stack?

Modern web app development heavily relies on Javascript libraries, such as [React](https://react.dev/), [Vue](https://vuejs.org/), [Angular](https://angular.io/), [Svelte](https://svelte.dev/), or some other lesser-known emerging players. Moreover, in 2009 Javascript also invaded the back-end world in a form of [Node.js](https://nodejs.org/).

Over the years the Javascript ecosystem became a hot mess with a large number of packages, modules, libraries, and frameworks, which makes it difficult for the newcomers to navigate. The sheer volume of choices is overwhelming. Last year I've decided that I'll learn a little bit of front-end, and I found it hard to decide what to learn. If you want to land a job in a front-end position, React is a solid choice, but I didn't like it. I found Vue to be prettier than React, but that means that I still have to write Javascript. The same with Angular, plus in the recent years it was on a steady decline in terms of popularity.

What are options do you have? If you are a back-end developer, like myself, you will quickly realize that your favorite back-end language is more or less good only for writing APIs or at the best case scenario server-side rendering, which allows you to create dynamic webpages, but if you want to change only a part of the website, the user needs to make a HTTP request that will cause a re-render of the entire web page.

However, there is a light at the end of the tunnel. It is HTMX, which can be thought of as an extension of HTML, and it gives you an access to AJAX, CSS transitions, WebSockets, and Server Sent Events directly in HTML. With HTMX, you can sprinkle islands of interactivity into your web page, that dynamically change when user interacts with your web page. Since most back-end languages, such as Python, Golang, Ruby, PHP, etc., have a templating engines, you can render parts of the web page, and send them to front-end, where HTMX will swap the original content with your snippet of HTML.

This means that you can don't have to use Javascript for changing only a small part of the website, and you don't have to re-render the entire web page, when the user interacts with it. Moreover, you can use your favorite back-end language that you are familiar with and don't have to sink countless hours into learning (and relearning, since the Javascript landscape is constantly changing, and what was the hottest thing last year is painfully outdated today) front-end Javascript framework.

![You're fullstack now](https://htmx.org/img/memes/fullstack.jpg)

_Source: [HTMX Official Website](https://htmx.org/essays/#memes)_

## What Is GHAST Stack?

GHAST Stack is comprised of five technologies:
- [Golang](https://go.dev/learn/) programming language
- [HTMX](https://htmx.org/)
- [Alpine.js](https://alpinejs.dev/)
- SQL (e.g. [PostgreSQL](https://www.postgresql.org/), [MySQL](https://www.mysql.com/), [SQLite](https://www.sqlite.org/index.html), ...)
- [Tailwind](https://tailwindcss.com/)

The core of the GHAST stack is Golang programming language (mostly because I like it at the moment, but also to have a cool acronym 😅). Golang is among younger programming language, but it is growing in popularity. In the [Stack Overflow Developer Survey 2023](https://survey.stackoverflow.co/2023/) it ranked 13-th in the most popular programming technology list. It is simple to learn, but has a large standard library that allows you to accomplish most common tasks without a need for third-party dependencies. Additionally, there is a growing community of Golang developers (who call themselves Gophers), who are writing useful libraries and frameworks, which will benefit your future projects. Since it is backed by large companies, such as Google, we can expect that Golang will only become more popular in the coming years.

As discussed in the previous section, we want to use a back-end programming language and still have some interactivity in our application. Therefore, we will use HTMX to do the heavy lifting. Parts of the website that should change will be swapped with the snippets of HTML generated by our Golang server. This can be easily done with the built-in [`template`](https://pkg.go.dev/text/template) package. Since we are working directly with HTML, we can also avoid the need to transform JSON into something that can be displayed on the front-end as is often the case when using Javascript libraries, such as React.

Alpine.js is another front-end library. It may seem that including it in our stack goes against everything said against the usage of Javascript. However, I think it is okay to use a little bit of Javascript for small things such as animations, transitions, and other small tasks that are not the best fit for the back-end server. Even the official website of HTMX features an [essay](https://htmx.org/essays/hypermedia-friendly-scripting/) that argues that some Javascript scripting is HTMX-friendly. It mostly comes down to avoiding changes to the state of your application using Javascript (in HTMX, the state is stored in the HTML). I recommend reading the essay for better understanding of when it is suitable to use Javascript in your application. When using Alpine.js, you probably should also consider using the [alpine-morph extension/plugin](https://htmx.org/docs/#included-extensions).

I think that the choice of SQL is fairly self-explanatory. Using databases for data-persistence is an industry standard. Since I wanted that cool acronym, I left the specific implementation of SQL free to the user's preference. Use whatever you like and what makes sense in your use-case.

The last technology used in the GHAST stack is Tailwind, a utility CSS framework that will make styling of our application much easier than using pure CSS. It defines a large set of small, constrained utility classes, which can be combined to achieve the desired look.

## When To Use GHAST Stack?

GHAST stack is intended for smaller applications, which don't have very complex front-ends. The interactivity should be contained within well-defined "islands" of interactivity. It is great for UIs that are mostly text and images. It is also great if you need a good first-render performance. Basically, this stack is mostly limited by the same [things as HTMX](https://htmx.org/essays/when-to-use-hypermedia/) itself.

## When Not To Use GHAST Stack?

GHAST is not ideal for applications that have complex UI with dynamic inter-dependencies, where a change in one place causes updates all over the web page. If the interactivity is not localized in smaller blocks, a more standard approach using one of the popular Javascript libraries is more suitable.

Also, hypermedia approach is not ideal if the state of the application changes very frequently (e.g. in a games), since a lot of syncing between the client and the server is required. You can however, embed a _single page application_ (SPA) component within a larger hypermedia architecture.

The last reason not to use the GHAST stack is when you need to hire developers (or be hired) to work on a web application, since technologies, such as React, are much more popular there are more developers who can work with them. The same is true, if your existing team isn't on board.

## Conclusions

In this post I've introduced a new tech-stack, which is built around Golang, HTMX, Alpine.js, SQL, and Tailwind. It is an alternative to the more popular approaches to building web application based on Javascript. GHOST stack is suitable for smaller applications that have smaller interactive parts that don't update very frequently. The majority of the work is done on our Golang server and the generated snippets that return from the Golang app are inserted into our front-end. Alpine.js can be used to enhance our website with small amount of inline Javascript. These tools provide everything necessary to build a well-functioning web application.
