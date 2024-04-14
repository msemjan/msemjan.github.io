---
date: "2024-04-13T09:55:35+02:00"
draft: true
title: My Experience With JSNAD
summary: ""
toc: true
tags:
- Javascript
- Node.js
- Programming
- Certification
- JSNAD
---
## What Is OpenJS Node.js Application Developer (JSNAD)?

[JSNAD](https://training.linuxfoundation.org/certification/jsnad/) is a certification offered by [Linux Foundation](https://www.linuxfoundation.org/) that verifies candidate's skill in using [Node.js](https://nodejs.org/en) to build applications of any kind. Unlike many other certifications, this is not a quiz in which you pick a correct answer from a given list of options. It is a practical exam in which you connect to a remote computer and write real code to solve various programming problems. The company I work for bought a voucher for me, so I had an opportunity to take the exam.

In this post I will share what the exam entails, I will give the general information about the certification exam, I will share my experience with JSNAD, as well as provide my recommendations for anyone who would like to obtain this certification. Unfortunately, I am not allowed to disclose any of the questions I got at the exam, since Linux Foundation terms and services[^1] forbid me to do so.

## Specifics of The Exam

As mentioned above, the exam consists of several programming tasks that you need to complete. In total there are 25 questions. To pass, you need a score of at least 68%. The exam-taker has two hours to complete the exam.

At the time of writing of this blog post, the Linux Foundation has listed these key competencies and domains which a candidate for the JSNAD certification must know[^0]:

- **Buffer and Streams** (11%)
  - Node.js Buffer API’s
  - Incremental Processing
  - Transforming Data
  - Connecting Streams
- **Control flow** (12%)
  - Managing asynchronous operations
  - Control flow abstractions
- **Child Processes** (8%)
  - Spawning or Executing child processes
  - Child process configuration
- **Diagnostics** (6%)
  - Debugging Node.js
  - Basic performance analysis
- **Error Handling** (8%)
  - Common patterns
  - Handling errors in various scenarios
- **Node.js CLI** (4%)
  - Node executable command line flags
- **Events** (11%)
  - The event system
  - Building event emitters
  - Consuming event emitters
- **File System** (8%)
  - Input/output
  - Watching
- **JavaScript Prerequisites** (7%)
  - Language fundamentals
  - Scoped to core language features introduced since EcmaScript 1 and still heavily used today
- **Module system** (7%)
  - CommonJS Module System only
- **Process/Operating System** (6%)
  - Controlling the process
  - Getting system data
- **Package.json** (6%)
  - Package configuration
  - Dependency management
- **Unit Testing** (6%)
  - Using assertions
  - Testing synchronous code
  - Testing asynchronous code

This list may change in the future, since the exam targets the latest LTS version of Node.js. As the current Long Term Support version changes the environment will be updated to the latest LTS. See https://github.com/nodejs/Release for information on the Node.js LTS schedule. You will have two hours to complete the exam, which consists of 25 questions from the list.

## The Exam

The exam is proctored. There are several requirements for both [your computer](https://docs.linuxfoundation.org/tc-docs/certification/instructions-openjs#system-requirements-to-take-the-exam) and [the place where yoy will take the exam](https://docs.linuxfoundation.org/tc-docs/certification/faq-openjs#what-are-the-testing-environment-requirements-to-take-the-exam). For example, you are allowed to have only one monitor, and smartphones, headsets, or smartwatches are **not allowed**.

Before you are allowed to take the exam and write your answers, you will go through a check-in process, in which you will take a photo of your ID card and a selfie, then the proctor will verify your identity and inspect your room and your workplace to make sure that they both satisfy all the criteria given by the Linux Foundation.

Then will be connected to a remote virtual machine running Ubuntu with Gnome Desktop environment. The candidate can use anything installed on the workstation (docs, man-pages, etc), and several text editors are provided, including Vim, VS Code, and WebStorm.

You will also have access to [several online resources](https://docs.linuxfoundation.org/tc-docs/certification/certification-resources-allowed#openjs-node.js-application-developer-jsnad-and-openjs-node.js-services-developer-jsnsd), including Node.js documentation, Mozilla Javascript documentation, NPM website, etc. However, even if you have access to these resources, you should prepare appropriately since there will not be much time to search for everything. Moreover, you should be familiar with documentation so you know where to look for the information that you might need. You will have approximately 5 minutes per question and that is not a lot of time.

## My Recommendation of Study Materials and Experience

I have only two websites to recommend:
- [Node.js Certification Study Guide by Hey Node](https://www.nodecertification.com/)
- [Index | Node.js v21.7.3 Documentation](https://nodejs.org/docs/latest/api/)

The Linux Foundation also offers a self-paced course [The Node.js Application Development](https://training.linuxfoundation.org/training/nodejs-application-development-lfw211/), which is allegedly pretty good and should prepare your for the exam, but I can neither confirm, nor deny this information.

I only used the guide by Hey Node to learn the basics. It is good idea to register on this website. It is for free, and you will gain an access to all of their guides. A [temporary 10 Minute Mail](https://10minutemail.com/) can be used to avoid any potential spam. I went through all of the topics on the list by the Linux Foundation and tried the examples, as well as tried to come up with my own. Some of the topics were not as detailed, so I also looked at the Node.js documentation. I highly recommend that you do the same and study each of the modules in more detail. Also take a look at [Globals](https://nodejs.org/docs/latest/api/globals.html), [Path](https://nodejs.org/docs/latest/api/path.html), and [Util](https://nodejs.org/docs/latest/api/util.html) modules.

When I requested a voucher for this exam, I was already professionally working with Node.js for one year and writing production-ready code even though I did not consider (and I still do not) myself to be a Node.js expert. Our tech stack consisted of Node.js, AWS Lambdas, AWS RDS, AWS SNS, and Express. However, I was not using the built-in modules of Node.js standard library on daily basis. But at least I knew how to use promises, handler errors, and had general working knowledge of Javascript, and I was aware of several useful NPM packages, such as Jest and Axios.

I started studying for the exam in December 2024 and spent approximately one to two hours studying. I also took one week off to focus on the preparation. I scheduled the first exam for April 5th of 2024, and I managed to score 65%, which unfortunately was not enough to pass. For reference, you need to score 68% to pass the exam, so I was very close.

The questions I have got were relatively simple. In some questions, you will be provided with some code, and in others you will have to write everything yourself. You can read the questions in the browser, or directly in the text editor of your choice. Using the text editor is of course faster.

Speaking of the text editor, you should pick the one that you are familiar with. If you use something different than what is provided in the exam environment, install one of the editors that will be available and get familiar with it. Also, you should be familiar with shell, Node.js commands and CLI options, and NPM commands, and be able to quickly traverse through the folder structure and execute necessary commands, such as `npm install`. So practice that as well.

Unfortunately I had technical issues during the exam and got disconnected at the end. Moreover, during the exam I had an issue with my keyboard layout and had to use on-screen keyboard, which slowed me down. This happened because I am using a `SK (qwerty)` keyboard, which is fairly good for programming on Linux (unlike the Windows one, which is atrocious). However, ALT key did not work in the PSI Secure Browser, and I needed on-screen keyboard to write several special characters, such as `{`, `}`, `[`, `]`, `<`, and `>`. If you are also using some special keyboard layout, I highly recommend to install `US` keyboard just to be sure and to make the exam easier. I am not sure if this information was never provided in the material by Linux foundation, or if I just missed it, but I find it to be important detail.

The other issue I had was poor internet connection. I did not realize this until it was too late, because my system passed the [PSI Online Proctoring System Check](https://syscheck.bridge.psiexams.com/) without any issues. Unfortunately, I did not manage to fix this by using wired connection either, and I failed my free-retake as well. The second time I manage to get into a loop of passing the check-in process, and then my camera froze, which resulted in a pop-up window that told me something along lines "Your camera stopped working, the PSI Secure Browser will exit in 60 seconds". Even thought the camera started working, after I closed pop-up, the Secure Browser closed. I kept trying to connect, but ultimately I was unsuccessful.

Since I have other important things coming, I will not trying for the third time, despite having received a free retake from the Support team, since I do not have an option to take the exam somewhere with better internet, and  I suspect that trying it at home would result in the same outcome. All the people I have interacted with were polite and helpful, so if you have any issues, do not hesitate to contact them.

Securing stable and fast internet connection is the candidate's responsibility, so if you have slower internet at home, like me, consider taking the exam somewhere else. Ask friends, family, or take the exam at work (though, bring your own computer, because it is not recommended to use the company machine).

Regarding the exam questions, they were relatively easy and I did not have to stress so much as I did before the exam. The questions were only from the list mentioned above. Sometimes you were provided with some code to speed things up, other questions required you to write everything. Even though the questions were simple and you have two hours to complete the exam, it is not that much time. You can read the questions in the web browser, or directly in the text editor, which is faster.

## Conclusion

OpenJS Node.js Application Developer (JSNAD) is a Node.js certification offered by Linux Foundation. The exam content is interesting, and even tough I did not pass the exam, I gained useful knowledge and skills that I can use in both personal projects and work. Unlike many other certifications, JSNAD is obtained by displaying knowledge of Node.js standard library by writing code solving programming problems, not doing a quiz, which gives this certification more weight than some other certificates.

Even though I did not pass the exam and did not obtain the certification, I think I can recommend this certification. I learned a lot of interesting things, which I can use in future projects. Even if you are not interested in taking the exam, studying for JSNAD may be a useful way to learn more about Node.js and its built-in modules.

If I ever move somewhere with a faster and more stable internet connection, I will seriously consider trying to obtain this certification.

## Sources

[^0]: The Linux Foundation. (2024, April 1). _JSNAD Exam | OpenJS Node.js Application Developer Exam_. Linux Foundation - Training. https://training.linuxfoundation.org/certification/jsnad/

[^1]: _Linux Foundation Global Certification and Confidentiality Agreement | T&C DOCS (Candidate Facing Resources)_. (n.d.). https://docs.linuxfoundation.org/tc-docs/certification/lf-cert-agreement
