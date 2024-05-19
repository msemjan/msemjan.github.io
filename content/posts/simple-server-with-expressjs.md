---
title: "Simple Server With Expressjs"
date: 2024-05-18T11:11:49+02:00
draft: true
toc: false
images:
tags:
  - Express.js
  - Javascript
  - Node.js
  - REST API
  - Server
---
## Introduction

Express.js is a _de facto_ standard for the Node.js back-end development of REST Services and simple servers. It is a simple and fast web framework that allows Javascript developers to write all kinds of applications ranging from simple toy projects to fully-fledged production-ready web services deployed by large companies. Due to its simplicity and flexibility it is suitable for any type of project you may work on. Moreover, it has a thriving ecosystem supported by numerous population of dedicated developers (for example when I search NPM for term `express middleware`, I received [6000 results](https://www.npmjs.com/search?q=express%20middleware)).

In this post I will show the basics of Express.js, including a simple example.

## Installation

Installation of Express.js is very simple and can be accomplished with a single command:

```bash
npm i express
```

Of course, you can install other packages that may help you your application.

## Hello World

A nicely formatted Hello World application can be written just with 11 lines of code. Create an `index.js` file in the root of your project and copy-paste the following code:

```javascript
// Import the Express.js package
const express = require('express');

// Create an Express.js object
const app = express();

// Define the port on which the application will run
const PORT = 3000;

// Create a GET / endpoint that will return the message
app.get('/', (req, res) => {
  res.send('Hello World!');
});

// Start the server on PORT
app.listen(PORT, () => {
  // It is customary to log on which PORT the application runs
  console.log(`Example app listening on port ${PORT}`);
});
```

You can start the application using Node command:

```bash
node index.js
```

You should see `Example app listening on port 3000` in the terminal. Then you can navigate to [http://localhost:3000](http://localhost:3000) and you should see `Hello World!` in your browser window.

## More Complex Example

In real world we would use a database (e.g. PostgreSQL), but this is not in the scope of this blog post. Instead, we will create a simple in-memory database using arrays as storage. I recommend that you create a new project, install Express.js, and create a `src` folder in the root of the project.

Our database will be a class in `db.js` file:
```javascript
const fs = require("node:fs");

// The database is a class. Basically, you can think of it as a table in SQL database. This way the data will not mix if we have different data
class Database {

  // In constructor, we create an array for our data and lastId that we will use for calculating an ID for the new data
  constructor() {
    this.data = [];
    this.lastId = 0;
  }

  // insertOne function takes one object and saves it into internal storage (our array), then increments the lastId
  insertOne = (element) => {
    this.data.push({
      ...element,
      id: lastId,
    });
    this.lastId++;
  };

  // I have also created a bulk insert function, which adds more elements
  insertMultiple = (elements) => {
    // If the argument is not an array, use insertOne function
    if(!Array.isArray(elements)) {
      this.insertOne(elements);
    }

    // Otherwise, insert each element individually
    this.data.push(...elements);
  };

  // Filer out an element with a specific element
  deleteById = (id) => {
    data = data.filter((element) => element.id != id);
  };

  // Just return the data object. Be careful when mutating the data, because this does not return copy, but an actual reference
  selectAll = () => {
    return this.data;
  };

  // Select an element by id by filtering data in the database
  selectById = (id) => {
    const found = data.filter((element) => element.id == id);

    if (found.length == 0) {
      throw new Error("Element not found");
    }

    return found[0];
  };

  // We can update a single record using this function
  updateById = (id, updatedElement) => {
    // We find the index of the element that an user wants to modify
    const index = data.findIndex((element) => element.id == id);

    // If there is no record with a given id, findIndex() will return -1
    if (index < 0) {
      throw new Error("Element not found");
    }

    // We do not want users to modify IDs, so we save it
    const thisId = data[index].id;

    // Here we update the record
    data[index] = {
      ...updatedElement,
      id: thisId,
    }
  }

  // Without this function our database would have no persistence and the data would be lost as soon as the server shuts down. As name suggests, this function saves data into a file in a form of JSON string
  saveToFile = (filename) => {
    fs.writeFile(
      filename,
      JSON.stringify({ data: this.data, lastId: this.lastId }),
      (err) => {
        if (err) {
          console.error(`Failed to save data to '${filename}'`, err);
        } else {
          console.info(`Database data successfully saved to '${filename}'`);
        }
      },
    );
  };

  // Once there is the data was saved, we can load them using loadFromFile
  loadFromFile = (filename) => {
    try {
      const dbData = JSON.parse(require(filename));
      this.data = dbData.data;
      this.lastId = dbData.lastId;
    } catch (err) {
      console.error(
        `Unable to read database data from '${filename}' file.`,
        err,
      );
    }
  };
}

// Export the class, so we can use it in other files
module.exports = {
  Database,
};
```

As you can see, we have implemented a couple of functions for inserting, selecting, modifying, and deleting data. We will use these for our Express.js application.

**Note**: If you already know how to use SQL (or NoSQL) in Node.js, you can rewrite the implementation of this class to use the real database instead.

Now we can start writing the actual server. The beginning of the `index.js` will be the same as before:
```javascript
const express = require('express');
const app = express();
```

We will also need to import the database we wrote and create an instance:
```javascript
const { Database } = require('./db.js');

const db = new Database();
```

Since this is a simple example, I think it is OK to have the database instance as a global variable, but it is not a good practice in general.

We will also use some middleware that comes with Express.js. Middleware functions are functions that have access to the requests object (`req`) and response object (`res`), and they are executed before the request is handled. Middleware functions can perform various tasks, such as:
- Logging requests
- Extracting important data from requests
- Add relevant information into the request object
- Handle errors

You can use more than one middleware function and when the current one ends it's execution, the next on stack will be called (using `next()` callback), otherwise, the request will be left hanging.

Express.js has a couple built-in middleware functions, which we will use:

```javascript
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
```

The first line ensures that URL-encoded payloads are encoded, while the second one parses incoming requests with JSON payloads.

## Practice

To improve your skills, you can do the following exercises:
- Modify the database (`db.js` file) so that every record in the database has `dateCreated` and `dateLastUpdated` fields.
- It is pretty common that database operations are represented using `async` functions. Update the database to use `async` functions and routes to use `await` when calling them.
- Replace the database implementation with a real database of your choice (PostgreSQL, SQLite3, MySQL, MongoDB, Reddis, ...).
- Add validation of user input to ensure that user is sending correct information that the server expects. If you used a SQL database, make sure that your service is not vulnerable to SQL injections by using prepared statements or ORM. Alternatively you could try to sanitize the input, but there is a chance that you might miss something and expose your database to SQL injections (in other words, be careful if you decide to use such a bespoke solution in production).

## Conclusion

In this blog post I demonstrated how to create a simple web server using Express.js. Since it is a _de facto_ industry standard, it is always good to know this framework. Once you master it, you will be able to create back-end services of any kind, and since REST APIs are everywhere these days you may find it valuable.
