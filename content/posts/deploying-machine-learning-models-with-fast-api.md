---
title: "Deploying Machine Learning Models With FastAPI"
date: 2024-08-24T13:57:16+02:00
draft: false
toc: false
images:
tags:
  - "Python"
  - "Machine Learning"
  - "Scikit-Learn"
  - "FastAPI"
---
## Introduction

If you've started with machine learning just recently and created your first model, you might be wondering what to do with it next? Sharing Python scripts is doable, but it might be difficult for non-technical people to setup a Python project. One of the better possibilities is to create a REST API that would make the model accessible via internet.

In this blog post I will show you how to create such REST API with the help of FastAPI web framework. I prefer this framework because it is fast (on par with NodeJS), easy to use, and quick to setup.

## Setup

First, let's create a new directory. You may want to use virtual environments, which are considered to be a good practice, and may help you prevent conflicts of versions of various packages. On Linux you would create and activate a virtual environment with the following commands:

```bash
python -m venv path/to/venv
source path/to/venv
```

If you plan on using the virtual environment only for this project, you can set `path/to/venv` to `./venv`, but the same virtual environment may be used for several projects with the same dependencies.

With the virtual envioronment, we can install the `scikit-learn`, `numpy` and `fastapi[standard]` packages using `pip`:

```bash
pip install numpy scikit-learn "fastapi[standard]"
```

## Model

Creating a good machine learning model is beyond the scope of this blog post. For simplicity we will use synthetic data and Support Vector Machines classifier. I used a simple example for a pipeline (shamelessly stolen) from [scikit-learn documentation](https://scikit-learn.org/stable/modules/generated/sklearn.pipeline.Pipeline.html#pipeline) to generate data, and added a part for saving the model using the [`pickle` library](https://docs.python.org/3/library/pickle.html), which is a part of all standard installation of Python:

```python
import pickle

from sklearn.svm import SVC
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline

# Generate random dataset with four features
X, y = make_classification(random_state=0, n_features=4)

# Split data into training & testing subsets
X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=0)

# Create a pipeline
pipe = Pipeline([("scaler", StandardScaler()), ("svc", SVC())])

# The sklearn pipelines can be used as any other estimators, so we can call fit()
pipe.fit(X_train, y_train)

# Calculate and print score
score = pipe.score(X_test, y_test)
print(f"The model score is {score}")

# Save the model
with open("model.pkl", "wb") as f:
    pickle.dump(pipe, f)
```

> **⚠️ Note**:
> Do not use `pickle` to de-serialize data from untrusted sources. As the documentation states, the module is not secure. An attacker could use it to execute any malicious code during unpickling.

After running the script above, you should find a `model.pkl` file in the root directory of the project. We will use this folder to load the model in the REST API.

> **Note**:
> In case you already have some suitable model, you can try to modify the code in the following sections.

## FastAPI Server - Minimal Example

Creating a minimal example of a server with FastAPI is very simple as can be seen from a snippet below (only 14 lines of code are necessary):

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def greet():
    return { "message": "Hello" }

if __name__ == "__main__":
    # Run app
    from uvicorn import run
    run(app, host='0.0.0.0', port=8000)
```

You can run the example with:

```bash
python server.py
```

This will start the server running at [`http://localhost:8000/`](http://localhost:8000).

Alternatively, it can be further simplified by removing the `if` statement at the end, and then you would run the server with the following `fastapi` command:

```bash
fastapi dev server.py
```

Once the server is running, you can open a browser and navigate to [`http://localhost:8000/`](http://localhost:8000) and you should see `{"message": "Hello"}` in the browser window. Another feature of FastAPI I love is that it automatically generates an interactive documentation provided by [Swagger UI](https://github.com/swagger-api/swagger-ui) that can be accessed in the web browser at [`http://localhost:8000/docs`](http://localhost:8000/docs). All available endpoints will be shown there with examples of arguments, parameters, possible errors, and even `curl` commands for testing.

## Adding An Endpoint For Model Predictions

If we want to serve our model using REST API, we will need a couple of additional features. First we will need to be able to read the model we saved, we will need a new endpoint where users can make requests, then we will need to parse data that were sent by the user, and at the end we will need to be able to return a prediction from our model. Fortunately, it is relatively easy.

First we will add a global variable with a path to our model at the beginning of the file:

```python
MODEL_FILE="model.pkl"
```

And I've also added a logger using the Python's [`logging` library](https://docs.python.org/3/library/logging.html):

```python
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.DEBUG)
```

The logging level can stay `logging.DEBUG` for now, but it is common to set it to `logging.INFO` on a production environment.

We will also need to add a couple of new imports:

```python
import os
from sys import exit
import pickle
import logging
from typing import Union

from numpy import array
from pydantic import BaseModel
from fastapi import FastAPI, Body
```

The data that the user sends using POST request will be of type `DataPoint`, which will be defined like this:

```python
class DataPoint(BaseModel):
    x: list[float]
```

The `pydantic` library will do some validation for us for free (well, there is a runtime cost, but we don't need to write any validation code ourselves). If you are using your own model, the expected input format might be different, and you will need to modify this class. You may also want to add some other fields, that are not related to the machine learning model, but are necessary for the API (such as API keys, or login information).

Now we are ready do add an endpoint for processing the user requests. A code below creates a REST API endpoint, that accepts POST requests, but doesn't do anything except logging that a request occurred:

```python
@app.post("/")
def model(datapoint: DataPoint = Body(None, example={"x": [1.3, 2.7, 3.14, -1.84]})):
    logger.info(f"A new requests on POST /")
```

As you can see, I've also added one argument that is of type `DataPoint` and the specified example will be used in the auto-generated documentation.

This is, however, not very useful, so we will need to implement some business logic. Since the `datapoint` is parsed by FastAPI and validated by `pydantic` (it checks if the received JSON has  a `x` field that is an array of `floats`, and if the JSON does not conform to a specifies schema, `pydantic` will throw a runtime exception 422 Unprocessable Entity error code for the user), we can just check if the array has correct length (it should be of 4, same as the number of features):

```python
@app.post("/")
def model(datapoint: DataPoint = Body(None, example={"x": [1.3, 2.7, 3.14, -1.84]})):
    logger.info(f"A new requests on POST /")
    if len(datapoint.x) != 4:
        logger.error(
            f"User error, the data point must have 4 elements. Got '{datapoint}'"
        )
        return {"error": "The input should have 4 elements!"}
```

If the user sent incorrect data, we will return an error message in a form of a JSON.

Now we will load the model using `pickle` and use it to generate a prediction (we will also add error checking). The POST handler will in the end look like this:

```python
@app.post("/")
def model(datapoint: DataPoint = Body(None, example={"x": [1.3, 2.7, 3.14, -1.84]})):
    logger.info(f"A new requests on POST /")
    if len(datapoint.x) != 4:
        logger.error(
            f"User error, the data point must have 4 elements. Got '{datapoint}'"
        )
        return {"error": "The input should have 4 elements!"}

    try:
        # Open a file with the model
        with open(MODEL_FILE, "rb") as f:
            # Unpickle the model
            clf = pickle.load(f)

            # Make a prediction - Data is reshaped into correct form
            prediction = clfí.predict(array(datapoint.x).reshape([1, -1]))[0]

            # A debug log for testing
            logger.debug(
                f"A prediction was successfully made for x='{datapoint.x}', prediction='{prediction}'"
            )

            # Return the result
            return {"prediction": prediction}

    except FileNotFoundError as e:
        # Just in case someone deleted the model
        logger.error(f"Model not found. Error: {e}")
        return {"error": "Internal server error"}

```

The data also needs to be reshaped and I extracted the first element of the list, which contains the prediction. The result is then returned in a form of a JSON. In our case the value will be either 0 or 1, depending on the input, because we only have two classes (this can be changed during the generation of the synthetic data, by adding a `n_classes` parameter into `make_classification()` function, and setting it to a non-default value; the default is 2).

> **Note**:
> In the example, I am loading the model each time a request is performed. This is advantageous if we want to change the model during the run (e.g. after it was retrained on a new dataset, but the model has still the same number and shape of inputs), but it may not be the best idea if the model is large or does not change very often.
>
> In such a case it would be better to load the model only once, and use it repeatedly. A change of the model would require a reload of the server, but that is not necessary an issue. The classifier object could be either a global variable (some people don't like to use them, but I think it is OK in small applications), or you could utilize FastAPI's [dependency injection](https://fastapi.tiangolo.com/tutorial/dependencies/) feature.

The final change that I've added is an additional check that is performed before running the server:

```python
if __name__ == "__main__":
    # Check if the file with the model does exits, if not, it does not make sense to continue
    if not os.path.exists(MODEL_FILE):
        logger.fatal(f"Model does not exists! Make sure that ${MODEL_FILE} exits")
        exit(1)

    # Run app
    from uvicorn import run

    run(app, host="0.0.0.0", port=8000)
```

It is not strictly necessary, but if you forgot to create a model, you will find out immediately, not after the first request.

## Complete Example

The complete example of the code we wrote can be found below:

```python
import os
from sys import exit
import pickle
import logging
from typing import Union

from numpy import array
from pydantic import BaseModel
from fastapi import FastAPI, Body

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.WARNING)


MODEL_FILE = "model.pkl"


class DataPoint(BaseModel):
    x: list[float]


app = FastAPI()


@app.get("/")
def greet():
    return {"message": "Hello"}


@app.post("/")
def model(datapoint: DataPoint = Body(None, example={"x": [1.3, 2.7, 3.14, -1.84]})):
    logger.info(f"A new requests on POST /")
    if len(datapoint.x) != 4:
        logger.error(
            f"User error, the data point must have 4 elements. Got '{datapoint}'"
        )
        return {"error": "The input should have 4 elements!"}

    try:
        # Load model & return calculated prediction
        with open(MODEL_FILE, "rb") as f:
            clf = pickle.load(f)
            prediction = int(clf.predict(array(datapoint.x).reshape([1, -1]))[0])

            logger.debug(
                f"A prediction was successfully made for x='{datapoint.x}', prediction='{prediction}'"
            )

            return {"prediction": prediction}

    except ValueError as e:
        logger.error(f"Failed to parse body. Error: {e}")
        return {"error": "Invalid datapoint"}

    except FileNotFoundError as e:
        logger.error(f"Model not found. Error: {e}")
        return {"error": "Internal server error"}


if __name__ == "__main__":
    # Check if the file with the model does exits, if not, it does not make sense to continue
    if not os.path.exists(MODEL_FILE):
        logger.fatal(f"Model does not exists! Make sure that ${MODEL_FILE} exits")
        exit(1)

    # Run app
    from uvicorn import run

    run(app, host="0.0.0.0", port=8000)
```

For testing, you can use a `curl` command (or something else, e.g. Postman):

```bash
curl -X 'POST' \
  'http://localhost:8000/' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
    "x": [
      -1, 2, -1.3, 3.14
    ]
  }'
```

As mentioned before, all the commands can be found (and tested!) at `http://localhost:8000/docs`.

## Conclusions

In this post I've shown you how to create a simple REST API server for serving your machine learning project. The same ideas can be used if you have multiple models (just add more endpoints) or if the model uses a different input format (update/replace the `DataPoint` class). Replacing the `scikit-learn` with something else is also possible, e.g. with TensorFlow and Keras, which offer a better way of [saving/loading models](https://www.tensorflow.org/tutorials/keras/save_and_load) than `pickle`, which is insecure and may introduce a vulnerability if the model comes from a untrusted source.

Using REST API will allow your users to consume the API either in some kind of a frontend application, or from other servers or applications that may further process the results. Moreover, FastAPI may be used for endpoints that don't return a result from a machine learning/AI model.

There are also a couple of things that you may want to do (as a practice):
- Definitely use some more useful machine learning model trained on a meaningful dataset
- Update the API so it can do several predictions in a batch, not on a single data point
- Try to improve logging
- The error handling could be improved (there is a page about [error handling](https://fastapi.tiangolo.com/tutorial/handling-errors/#add-custom-headers) in FastAPI documentation)
- Automate retraining of the model on the newest data periodically (maybe with cronjob?), and based on some metrics conditionally replace the used model (I guess that this makes sense only if you are also automatically collecting new data)
- Maybe add database (although, I am not sure what for?)
- Authentication (e.g. using [FastAPI Middleware](https://fastapi.tiangolo.com/tutorial/middleware/))
- Change loading of the model so the file is read only once in the beginning (you may want to look into [dependency injection](https://fastapi.tiangolo.com/tutorial/dependencies/))
- [Dockerize your application](https://www.docker.com/blog/how-to-dockerize-your-python-applications/) (this would be great both for making your application more production-ready, but also improve reproduciblity and security of the API)
- If the API is used in a combination with some frontend to display the data from model, you may want to look into generating [interactive HTML exports with Plotly](https://plotly.com/python/interactive-html-export/) (which also works well with [HTMX](./introducing-ghast-stack.md), and add an endpoint that returns an HTML snippet that contains a chart, which could be simply displayed
- Making your REST API available on your local network using [NGINX as a reverse proxy](./nginx-reverse-proxy-for-apps)
- Try to make a simple app that consumes the API (you can use [`request` library](https://pypi.org/project/requests/) for making HTTP requests in Python)
