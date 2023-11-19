---
date: "2023-10-01T17:29:22+02:00"
draft: false
summary: Latex is a typesetting software commonly used in Academia. It allows you
  to easily create publication quality documents with beautiful equations. In this
  post I will show you the basics of Latex and teach you how to create simple documents
  with automatically generated table of contents, list of figures, and bibliography.
tags:
- Latex
- Typesetting
- Academic writing
title: Getting Started With Latex
---
## Introduction

Latex is a typesetting software based on Tex created by Donald Knuth, who was dissatisfied with a quality of his paper. Using Latex is a little bit like programming your documents. Instead of clicking buttons to add styling, like one would do when writing in Microsoft Word, in Latex you use commands to change the appearance of the text. Moreover, you don't need to worry about the aesthetic of your document, since it can easily be changed later, and instead you can focus on the text itself.

Latex is especially useful, if you need to write academic texts that include many equations, citations, and numbered figures, since Latex makes it very easy to work with these.

Once you finished writing a Latex document, you can compile it into PDF or DVI formats.

## Installing Latex

Probably the easiest way to install Latex is to use [Miktex](https://miktex.org/) distribution. Just follow the instructions on the install page. If you are using Linux, it's probably easier to install Latex using your native package manager. For example, in Arch-based distributions, you can install `texlive-latex` package.

## Minimal working example

The simplest document you can create you create a file `example.tex` with the following content:
```latex
\documentclass{article}

\begin{document}
  Your content goes here.
\end{document}
```

The first line in the example (`\documentclass{article}`) specifies that we want an `article` document class. There are several options you can use:
- `article` - Great for scientific papers, short reports, program documentations, and any other shorter document that does not require a complex division into chapters and smaller parts.
- `report` - For longer documents that have several chapters. Can also be used for shorter books and thesis.
- `book` - Used for typesetting real books that require features such as chapters and parts, two kinds of pages, a front matter, etc.
- `slides` - This allows you to create presentations, although, most people prefer to use [`beamer`](https://ctan.org/pkg/beamer?lang=en) package for this purpose.
- `letter` - This is for writing letters.

Some packages may add different classes, but for now we will stick to `article`. You can try all these options, if you want to see what they do. Here is a [comprehensive list of document classes](https://ctan.org/topic/class). For some classes, you can also specify various options between square brackets like this:
```
\documentclass[12pt,a4paper,oneside,draft]{report}
```
In this example, we create a report that is in 12pt type on A4, but printed one-sided in draft mode.

You can also see that we have a `document` environment. Environments are always defined with a begin-end pair:
```latex
\begin{...}
  Something goes here
\end{...}
```

An example of a different environment is the math environment, which allows us to typeset equations:
```latex
\begin{equation}
  E = mc^2
\end{equation}
```

The equation above would render as:
$$
  E = mc^2
$$

We will not discuss mathematics in Latex deeper, since I want to keep this relatively short. If you want to learn more about math equations in Latex, I recommend checking [this Wikipedia article](https://en.wikibooks.org/wiki/LaTeX/Mathematics).

Let's return to our example, which has a `document` environment. Every document needs to have this, and Latex will create a final document based on whatever is between the begin and the end. In our case, it would be `Your content goes here.` text.

## Comments

Sometimes you may want to add a note for yourself, that should not be in the final product. Latex allows you to add comments into your source files. Any line that starts with a `%` will be ignored by the Latex compiler.

## Formatting text

You can split your text into various sections using these commands:
- `\part{Name of part}`
- `\chapter{Name of the chapter}` - Only for books
- `\section{Name of the section}`
- `\subsection{Name of the subsection}`
- `\subsubsection{Name of the subsubsection}`
- `\paragraph{Name of the paragraph}`
- `\subparagraph{Name of the subparagraph}`

These commands also automatically add entries into the automatically generated table of contents. If you want to have an alternative text in the table of contents, you can specify it with square brackets:
```
\section[My alternative title]{The title of my section in the text}
```

By the way, you can easily add a table of contents with the `\tableofcontents` command. Similarly, you can add a list of figures (`\listoffigures`) and a list of tables (`\listoftables`).

Normally, all parts are numbered, but you can also create an unnumbered section (e.g. for a Foreword or Preface) with a star:
```latex
\subsection*{Preface}
```

However, the star will cause the subsection to be omitted from the table of contents. If you still want this line to be included, add the following line after the `\subsection*{...}`:
```latex
\addcontentsline{toc}{subsection}{Preface}
```

## Ordered lists

```latex
\begin{enumerate}
  \item First item
  \item Second item
\end{enumerate}
```

## Unordered lists

```latex
\begin{itemize}
  \item First item
  \item Second item
\end{itemize}
```

## Packages

Packages are a way to extent the core functionality of Latex. It can help you specific problem, for example aligning `=` signs in equations, or rendering source code in your document. The basic syntax for including a package is:
```latex
\usepackage[options]{package}
```

You can search for packages on CTAN website in the [Packages](https://ctan.org/pkg) section. I recommend to search for packages that add specific functionality online when you find out that you can not do something with the current setup. Eventually you will create a blueprint with several packages that solve your common problems.

## Meta-data

Usually, the documents contain various meta-data, such as author's name, address, title of the document, or date. Example:
```latex
\documentclass[11pt,a4paper]{report}

\begin{document}
  % Declare meta-data
  \title{My Amazing Latex Document}
  \author{John Doe}
  \date{February 2023}

  % This line renders a title page with a title
  \maketitle
\end{document}
```

If you omit `{...}` in `\date`, the command will use the current date when compiling the document.

## Abstract

Abstracts are an important part of scientific literature, which helps the reader to quickly identify the topic of a paper. They are so important that Latex adds a special environment just for writing abstracts:
```latex
\documentclass{article}

\begin{document}
  \begin{abstract}
  In this paper is shown the minimal example of a Latex document.
  \end{abstract}

  This is the content of the minimal example.
\end{document}
```

By default, Latex will use `Abstract` as the title of your abstract, which may not be desired. To change the behavior, add the following line (replace `Executive Summary` with whatever you need):
```latex
\renewcommand{\abstractname}{Executive Summary}
```

## Images

The easiest way of adding an image is using `\includegraphics` command:
```latex
\includegraphics[height=2cm]{path/to/my-image}
```
EPS, PNG, JPG, and PDF files are supported.

However, you will usually want to use the `figure` environment, which let's you easily add a caption:
```latex
\begin{figure}[ht]
  \centering
  \includegraphics[width=0.5\textwidth]{path/to/my-image.png}
  \caption{An example image}
\end{figure}
```

You can learn more about graphics and positioning in [this article](https://www.learnlatex.org/en/lesson-07).

## Bibliography

There are multiple ways of writing a bibliography in Latex. Here I will show you how to use an embedded method, which will include the bibliography inside the Latex file. Alternatively, you can create a `.bib` file with a specific syntax that will contain bibliographic items in a specific format. To learn more about bibliography management, check this [article](https://en.wikibooks.org/wiki/LaTeX/Bibliography_Management).

The bibliography support is included in Natbib package, which can be included with:
```latex
\usepackage[options]{natbib}
```

Useful options that I always use are:
```latex
\usepackage[numbers,square,sort&compress,comma]{natbib}
```

This will cause the in text citations to be labeled with numbers, sorted, compressed (`[1-3]` instead of `[1,2,3]`), and separated by commas.

A minimal example of a file with bibliography is:
```latex
\documentclass{article}

\begin{document}
  Here we want to cite an imporant paper\cite{doe2023}.

  % This command will tell Latex that we want a list of used literature printed here

  % And here we specify the papers we cited
  \printbibliography
  \begin{thebibliography}{9}
    \bibitem{doe2023} J. Doe. \emph{Phys. Lett. B} \textbf{84} 98 (2023).
  \end{thebibliography}
\end{document}
```

So, you need a `thebibliography` environment with bibliography items, which have the following format:
```latex
\bibitem{key} The citation
```

The `key` can be whatever you want, but I recommend a format `firstAuthorYear` (e.g. `doe2023`) to remember the papers easily. You will use the key, when you want to reference the paper in the text with a `\cite{key}` command. You can also mention several papers separated with comma (`\cite{key1, key2, ...}`).

## A full example of a document


```latex
\documentclass{article}
\usepackage[utf8]{inputenc}
\usepackage[numbers,square,sort&compress,comma]{natbib}

% Meta-data
\title{My Amazing Article}
\author{John Doe}

% Abstract
\begin{abstract}
In this paper is shown an example of a Latex document.
\end{abstract}

% The document content
\begin{document}
  \maketitle

  \section{Introduction}
  Here we introduce our topic\cite{doe2023}.

  \section{Model}
  We used a model with the following Hamiltonian:
  \begin{equation}
    \mathcal{H} = -J \sum_{\langle i, j \rangle} \sigma_i\sigma_j - h \sum_{i = 1}^{N} \sigma_i
  \end{equation}

  \section{Methods}
  \subsection{Monte Carlo simulations}
  Here we explain Metropolis algorithm.

  \subsection{Transfer matrix method}
  Here we explain what is Transfer matrix method.

  \section{Results and discussion}
  Our results go here.

  \section{Conclusion}
  Here we draw conclusions.

  \section*{Acknowledgement}
  We would like to thank to XYZ Grant Agency for financial support.

  \printbibliography
  \begin{thebibliography}{9}
    % You need to sort the entries here manually, otherwise they will appear in the text out of order.
    \bibitem{doe2023} J. Doe. \emph{Phys. Lett. B} \textbf{84} 98 (2023).
  \end{thebibliography}
\end{document}
```

## Conclusion

In this post I've shown you how to use the most basic features of Latex to create a simple document. Even though you will be able to write the most basic texts, this is just a start, and there is a lot to learn. The benefits of Latex may not be obvious at first, but it is a useful tool for writing high quality texts ready for publications, and it will help you get rid of various issues encountered when using text editors such as Microsoft Word.
