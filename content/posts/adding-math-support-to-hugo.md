---
title: "Adding Math Support to Hugo"
author: "M. Semjan"
date: 2023-04-01T11:45:03+02:00
summary: "In this post I describe how I've added Math support to my template with MathJax."
draft: true
type: post 
tags:
  - Hugo
  - Math support
  - Markdown
  - MathJax
---
# Adding Math Support to Hugo

## Introduction

If you are a scientist who wants to share their research in a form of a blog post or a STEM student, who wants to convert their notes with equations into a good looking HTML, you may need to somehow render math blocks on the web page. One of the libraries that can help with this task is [MathJax](https://www.mathjax.org/). In this post I describe how I added Math support to my template with MathJax. Alternative to MathJax, which isn't discussed in this post, is [KaTeX](https://katex.org/docs/autorender.html).

## How to

You can create a Hugo website with:
```
hugo new site my-blog
cd my-blog 
git init
```

I recommend to fork the theme as described in this [guide](https://www.mrnice.dev/posts/how-to-add-math-expressions-to-hugo-blog-the-shortest-guide-possible/), but it isn't absolutely necessary. Add the theme (the forked one or the original) with:
```
git submodule add https://github.com/<repository>/<theme> themes/<theme>
echo "theme = '<theme>'" >> config.toml
```

Create a simple post with equation for testing:
```
hugo new posts/testing-math.md
```

Open the file and add the math block:
```markdown
# Testing Math


**Mass–Energy Equivalence**
$$
E = mc^2
$$

**Einstein Field Equations**
$$
R_{\mu\nu} - \frac{D}{2}Rg_{\mu\nu} - \Lambda g_{\mu\nu} = -\kappa T_{\mu\nu} 
$$

**Schrödinger Equation**
$$
i \hbar\frac{d}{dt}\ket{\psi(t)} = \hat{H}\ket{\psi(t)}
$$

**Time-dependent Schrödinger Equation**
$$
\hat{H} \psi = E \psi
$$

**Hamiltonian of the Heisenberg Model in an External Magnetic Field**
$$
\hat{H} = \sum_{i,j} \hat{s_i}\hat{s_j} - h\sum_{i}\hat{s_i}
$$
```

You need to modify the layout and add MathJax script tag. You can add it into `themes/<theme>/layouts/_default/baseof.html` if you want to enable math for all pages. But you can include JavaScript in other files if you want to (`themes/<theme>/layouts/_default/header.html`, `themes/<theme>/layouts/_default/footer.html` or `themes/<theme>/layouts/_default/single.html`). The code itself goes into the `<head>` tag, and it is:

```html
<!-- This part includes the Javascript file -->
<script type="text/javascript" id="MathJax-script" async
  src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js">
</script>

<!-- this part configures it -->
<script type="text/x-mathjax-config">
MathJax.Hub.Config({
  tex2jax: {
    inlineMath: [['\\(','\\)']],
    displayMath: [['$$','$$'], ['\[','\]']],
    processEscapes: true,
    processEnvironments: true,
    skipTags: ['script', 'noscript', 'style', 'textarea', 'pre'],
    TeX: { equationNumbers: { autoNumber: "AMS" },
         extensions: ["AMSmath.js", "AMSsymbols.js"] }
  }
});
</script>
```

If you've forked the theme, you can commit changes, otherwise, it probably isn't the best idea, since the theme is used by other people.

## Testing Changes

Now you can test if it works. Start the server:
```
hugo server --buildDrafts
```

And go to `http://localhost:1313/` in your browser.

If you did everything correctly, you should see the equations rendered as:

**Mass–Energy Equivalence**
$$
E = mc^2
$$

**Einstein Field Equations**
$$
R_{\mu\nu} - \frac{D}{2}Rg_{\mu\nu} - \Lambda g_{\mu\nu} = -\kappa T_{\mu\nu} 
$$

**Schrödinger Equation**
$$
i \hbar\frac{d}{dt}\ket{\psi(t)} = \hat{H}\ket{\psi(t)}
$$

**Time-dependent Schrödinger Equation**
$$
\hat{H} \psi = E \psi
$$

**Hamiltonian of the Heisenberg Model in an External Magnetic Field**
$$
\hat{H} = \sum_{i,j} \hat{s_i}\hat{s_j} - h\sum_{i}\hat{s_i}
$$

## Conclusion

In this post I've showed you how to add a math support to your Hugo website with MathJax Javascript library.
