---
title: "What Front End Framework Should You Pick in 2023?"
date: 2023-08-18T19:07:26+02:00
draft: true
toc: true
tags:
  - Javascript
  - Typescript
  - Frameworks
  - React
  - Svelte
  - Angular
  - Vue
  - Front-end development
  - Fullstack development
---
## Introduction

As I've mentioned in one of my previous [posts](../introducing-ghast-stack), some time ago I've decided to learn a little bit of front-end development. At that time I already knew the basics of Javascript, so the natural question was "What front-end framework should I pick?". I'll share the results of my front-end framework investigation in the today's post.

## So many options!

The first thing that anyone dabbling in the front-end quickly finds out is that there are so many competing frameworks. It's said that a new Javascript framework is born every day. Moreover, the way things are done also change frequently. If you look at a React code that is five years old, it looks archaic. This means that newcomers are overwhelmed by countless options. And the experienced developers need to constantly learn to stay on top of things.

Fortunately, there is a smaller subset of frameworks that are being used by majority of the front-end developers. According to the [State of JavaScript survey from 2022](https://2022.stateofjs.com/en-US/), the most popular frameworks are (in this order):
1. [React](https://react.dev/)
2. [Angular](https://angularjs.org/)
3. [Vue.js](https://vuejs.org/)
4. [Svelte](https://svelte.dev/)
5. [Preact](https://preactjs.com/)
6. [Ember](https://emberjs.com/)
7. [Solid](https://www.solidjs.com/)
8. [Lit](https://lit.dev/)
9. [Alpine.js](https://alpinejs.dev/)
10. [Stencil](https://stenciljs.com/)
11. [Qwik](https://qwik.builder.io/docs/)

I'll write a brief description of each of the frameworks, mention some of its features, and when to use it.

> **⚠️ Quick disclaimer**
>
> I am definitely not an expert on front-end and I haven't used all of the frameworks on this list, so take this post with a grain of salt. This is mostly my opinion based on the information I've gathered, while trying to pick a front-end framework myself.


## React

As of 2023, [React](https://react.dev/) is the industry standard and the most popular Javascript framework. If you've ever googled anything related to front-end, you've likely heard about it. It was created by Meta (formerly Facebook) and it can be used to create [single page applications (SPA)](https://en.wikipedia.org/wiki/Single-page_application). The React code is written in JSX, which is an extended Javascript syntax that allows you to embed HTML into your Javascript code.

It has two approaches to building websites based on components: the older class-based style, and the newer functional style with React [hooks](https://reactjs.org/docs/hooks-intro.html). As the name suggests, React allows you to build reactive websites, which can update many parts of its when a change occurs. To achieve this, React uses so-called virtual DOM. It is a virtual version of the website and its elements. When some value gets changed, React changes the virtual DOM and then compares it with the real DOM, and updates only the parts that were affected by this change. This can be viewed as a good and a bad thing. React updates only what needs to be updated, but you need to send the entire library to the client to handle the virtual DOM.

An another plus of React is its thriving community and a large ecosystem of various libraries that will make creation of the websites an easy task. Moreover, there are many job position for React developers.

If you decide to learn React, you should also check out [Next.js](https://nextjs.org/), a meta-framework that allows you to create fullstack applications with React.

## Angular

Another entry on the list is [Angular](https://angularjs.org/). It was created by Google, and like React, it is used for creating SPA applications. It utilizes model-view-controller and model-view-viewmodel architectures.

It is not as popular as React and it has been on a steady decline in the recent years, but there are still many jobs in some companies, which have large code bases in this framework.

## Vue.js

[Vue.js](https://vuejs.org/) is a another popular framework that uses virtual DOM and is used for creating reactive websites. However, unlike React, which uses JSX, Vue.js chose a different approach. You write `.vue` files, which have `<template>`, `<script>`, and `<style>` tags for your HTML, Javascript code, and CSS, respectively. Vue.js was created by Evan You, and is maintained by him and the rest of the active core team members. Therefore, it does not have a support of large companies, like React and Angular.

Vue.js is relatively easy to learn, and it looks more like HTML with vanilla Javascript than React. Therefore, you should pick it, if you don't like the look of JSX.

Similarly, to React's Next.js, there exists a fullstack meta-framework called [Nuxt](https://nuxt.com/).

## Svelte

[Svelte](https://svelte.dev/) is my personal favorite on this list. Unlike the previous entries on our list, Svelte isn't really a framework, but a compiler, which allows it to produce a much smaller final website. Svelte also does not use virtual DOM.

Svelte uses `.svelte` files with a syntax that looks a little bit like Vue.js, but you don't have to wrap your HTML in a `<template>` tag. Another similarity to Vue.js is that it was developed by a single man, Rich Harris. It is easy to learn, and offers many useful features, which are missing in some other frameworks, such as state management, stores, animations, etc.

If you are interested in writing fullstack applications, you can use [SvelteKit](https://kit.svelte.dev/), which is to Svelte what Next.js is to React and Nuxt.js to Vue.js.

## Preact

[Preact](https://preactjs.com/), as the name suggests, is something very similar to React. In fact, the entire frameworks aims to be an alternative to React, with the same API, but much smaller (only 3.5kb!). Preact API is as close as possible to React, but not exactly the same. It excels in the use-cases, when the goal is to make it as small as possible (e.g. when you need to embed your website). The main difference between Preact and React is that Preact does not ship its own Synthetic Event System, and instead uses the browser's native `addEventListener` for event handling internally. This can cause a subtle differences, that might catch you off guard, if you are used to working React.

The another large difference is that Preact classes accept a couple of additional attributes/properties. And there are a couple additional minor [differences](https://preactjs.com/guide/v10/differences-to-react).

I would say that if you are deciding between React and Preact, pick one based on your use-case. But since the API is so similar, it should not be difficult to learn the other framework, when needed. Additionally, Preact makes the [transition from React to Preact](https://preactjs.com/guide/v10/switching-to-preact) as easy as possible.

## Ember

[Ember](https://emberjs.com/) is another framework for creating scalable SPA applications with a component-service pattern. It utilizes [Handlebars templating language](https://handlebarsjs.com/guide/) to render data in your web applications. Ember.js comes with a handy CLI that helps you auto-generate boilerplate code for your components, controllers, and routes, as well as perform certain tasks, such as generate a project or run tests.

## Solid

[Solid](https://www.solidjs.com/) is another framework that takes a lot of inspiration from React. Solid is fairly pragmatic and highly performant, which lead to its quick raise to popularity. It uses JSX, and they syntax looks very similar, except Solid uses [Signals](https://www.solidjs.com/tutorial/introduction_signals) instead of Hooks. On the surface, they look like the same thing, but there is a huge difference between them "under the hood". Signals allow you to surgically update only the parts of the DOM that need to be updated, while maintaining the reactivity. Moreover, unlike React Hooks, Signals are executed only once.

Other differences are that Solid uses compiler, just like Svelte, and it does not ship any virtual DOM. It is also very lightweight, while still offering all the modern features you might want, such as server-side rendering, lazy loading, context, etc.

## Lit

[Lit](https://lit.dev/) is a simple library for building fast, lightweight web components.

[Web components](https://developer.mozilla.org/en-US/docs/Web/API/Web_Components) are a built-in feature of modern browsers, which have a fairly clunky API and are a pain to write manually. That's why there is a need for a framework to simplify this process. The benefit of the web components is that they are supported by the browsers, and it should (at least in theory) be possible to render them anywhere HTML is rendered.

Moreover, you should be able to use the web components in any framework (like the ones mentioned above). Lit provides reactive state, scoped styles, efficient shadow DOM support, and a declarative template system that's tiny, fast and expressive.

Lit is similar to React class syntax with lifecycle methods, properties, and attributes. It has a built-in Typescript support and uses decorators. Since it is used by several Google websites, Lit will very likely remain supported for quiet some time.

## Alpine.js

[Alpine.js](https://alpinejs.dev/) is a super simple and lightweigh Javascript library that has only 15 attributes, 6 properties, and 2 methods. Because of this reason, it is very easy to learn, and can be used to directly compose the behavior of your elements. It markets itself as a modern replacement for [jQuery](https://jquery.com/). Despite it's simplicity, it offers functionality such as reactivity, state management, templating, events, and lifecycles. Alpine.js is an amazing option, if you have an existing web page written with vanilla Javascript or jQuery and want to add a little bit of interactivity.

Since it is a minimal framework, don't expect some features that are available in other frameworks, such as hydration, server-side rendering, or SPA. You should use it with some server-side technology, such as Django, Ruby on Rails, Java with Spring, or some other server framework, that will do the heavy lifting and render the web page.

Personally, I really like this approach that mainly uses a back-end language and Javascript is used only for scripting interactivity on the front-end, and I even added it into my [GHAST tech stack](../introducing-ghast-stack).

## Stencil

Similarly to Lit, [Stencil](https://stenciljs.com/) is another framework for creating web components. It should be easy to learn, have a Typescript support, and a stable API. The Stencil components are compiled into Web components, and then can be distributed natively to React, Angular, Vue, and traditional web developers from a single, framework-agnostic codebase. Honestly, I am not sure what are the most notable differences between Stencil and Lit and which one is better, but based on the [State of JavaScript survey from 2022](https://2022.stateofjs.com/en-US/), Lit is a bit more popular.

## Qwik

[Qwik](https://qwik.builder.io/docs/) is a relatively new web framework that promises that it can deliver instant loading web applications at any size or complexity, and achieve consistent performance at scale.

Unlike other frameworks on this list, it uses a strategy called "resumability", which means that the application be can stopped, serialized, and moved to a different environment (either a server, or a browser) at any point. Then it simply resumes in a new environment from the point, when the serialization stopped.

This approach is the cornerstone of building fullstack apps with Qwik. The instant loads are a consequence of your application being HTML first. The HTML is sent to the client, and the Javascript code is streamed to the client only when needed. This is combined with speculative fetching and lazy execution, so the framework is using only the Javascript code it really needs.

This sounds pretty simple, but Qwik has to do a lot of things in the background to support the resumability.

The Qwik's syntax is inspired by React, it uses JSX, hooks, and other established ways of solving various front-end problems.

I think that Qwik definitely presents interesting ideas.

## Which framework is best for you?

As one can see, when it comes to front-end frameworks, there are many options to choose from. Some of them introduced new and fresh ideas, while the others are only trying to perfect the existing solutions. But which Javascript framework should you choose? Well, it depends...

Do you want to learn a front-end framework to get a job? Then React is a clear answer. It is the most popular framework and most companies are hiring React developers. Even though some other frameworks are gaining popularity, React will not go anywhere, since there are so many websites written in it, and companies will need developers to maintain and extend them for years to come.

Are you a back-end programmer, who enjoys the ecosystem of their language, but wants to sprinkle a little bit of interactivity to your website? Then Alpine.js sounds like a very good choice.

Do you need to create Web Components? Then choose Lit or Stencil.

Do you just want to quickly learn a front-end framework and start working on your side-project as soon as possible? Then Svelte or Vue.js are excellent choice, since both are easy to learn.

Or do you feel adventurous and want to try some new approaches to building websites? Than I can recommend Solid or Qwik.

## Conclusions

In this post I've briefly described the most popular front-end frameworks and some of their features. Hopefully, this post will help you pick a framework that suits your needs and preferences. There should be something suitable for everyone.

Ultimately, the choice is not as important as people think. Once you learn one framework, it is easier to pick up another, since some concepts are general and apply to several frameworks. Unless you have specific requirements, you will be able to build most applications with any of the popular front-end frameworks.

If you still don't know which one is best for your, I would recommend to learn the basics of each of the frameworks and try to build a simple application in all of them, and then pick the one you liked the most.
