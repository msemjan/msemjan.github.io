---
author: M. Semjan
date: "2023-03-26T21:58:30+02:00"
draft: false
summary: Hugo is a fast framework for building websites written in Go. With this post,
  you will learn how to create a simple blog with Hugo.
tags:
- Hugo
- Blog
- Writing
title: Creating a blog with Hugo
---
# Creating a blog with Hugo

## What is Hugo?

[Hugo](https://gohugo.io/getting-started/configuration/) is a vary fast framework for building websites written in Go programming language. It is also one of the most popular open-source static site generators with amazing flexibility. It allows its users to write your content in Markdown, which is simple to use and easy learn. Since it support plugins, you have access to unlimited content types, taxonomies, menus, dynamic API-driven content, and more via plugins.

Because of these features, it is ideal for creating a simple blog.

## Preliminary steps

Before you can start with Hugo, you need to complete these two steps:
1. Install [Hugo](https://gohugo.io/installation/)
2. Install [Git](https://git-scm.com/downloads)

## How to create a site with Hugo

Create a Hugo website:
```bash
hugo new site my-blog
```

Go into the generated directory:
```bash
cd my-blog 
```

Initialize Git repository:
```bash
git init
```

We will use [Anake](https://github.com/theNewDynamic/gohugo-theme-ananke) theme, which we can add into our project with the following command:
```bash
git submodule add https://github.com/theNewDynamic/gohugo-theme-ananke themes/ananke
```

You can learn more about this theme in its [documentation](https://github.com/theNewDynamic/gohugo-theme-ananke#readme).

Once Git adds the submodule, and clones the repository into your folder. Now we can update the `config.toml` file, telling Hugo that we are using Anake theme:
```bash
echo "theme = 'ananke'" >> config.toml
```

At this point the website is created and read, you can check if everything went correctly by starting a server:
```bash
hugo server
```

You can access your website in your browser at `http://localhost:1313`. To stop the server, press `CTRL + C`.

## Adding content

Our new website is amazing, but there is something missing. We need to add content. To add a new page to your website, run the command:
```bash
hugo new posts/my-first-post.md
```

This will create a file that can be found in the `content/posts` directory. If we open it in the editor of our choice, we can see inside something along lines:
```markdown
---
title: "My First Post"
date: 2023-01-22T04:03:20-08:00
draft: true
---
```

This is so-called front-matter, and it contains meta-data about our page. Notice that `draft` is equal to `true`. By default, Hugo does not publish draft content when you build the site. If you want to know more about draft, future, and expired content, click [here](https://gohugo.io/getting-started/usage/#draft-future-and-expired-content).

Let's add some content:
```markdown
---
title: "My First Post"
date: 2023-01-22T04:03:20-08:00
draft: true
---

# My First Post

This is my **first**  post. *Welcome to my blog*.
```

The `#` and asterisks are part of Markdown syntax. If you want to use Hugo, you should learn more about [Markdown](https://www.markdownguide.org/basic-syntax).

Once you've completed your changes, save the file and start Hugo's development server:
```bash
# Run this
hugo server --buildDrafts

# Or
hugo server -D
```

This will start a development server, which will keep updating the content of your webpage, while you are modifying it. Feel free to add or change the file.

## Additional configuration

You can specify more details by changing `config.toml`, which can be found in the root folder of your project.
```toml
baseURL = 'http://example.org/'
languageCode = 'en-us'
title = 'My New Hugo Site'
theme = 'ananke'
```

Change `baseURL` to your production URL, `languageCode` to your language and region, and set the title to your production site. Don't forget to start the production server with `hugo server -D` to see drafts. 

# Publishing website

Publishing means that Hugo will create the entire static site in the `public` directory, which you can then deploy to your web server. This folder will include HTML files, CSS style sheets, and all the necessary JavaScript. Typically, you want to exclude [drafts, futures, and expired content](https://gohugo.io/getting-started/usage/#draft-future-and-expired-content). The command to publish your site is a simple:
```
hugo
```

The next step is [hosting and deployment](https://gohugo.io/hosting-and-deployment/).

## Conclusion

In this post we created a Hugo project, we added own page, and published the page. 

## Sources 

1. [Hugo Documentation](https://gohugo.io/hosting-and-deployment://gohugo.io/getting-started/quick-start/)
