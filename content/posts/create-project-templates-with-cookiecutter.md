---
title: "Create Project Templates With Cookiecutter"
date: 2024-05-05T16:01:14+02:00
draft: false 
toc: false
images:
tags:
  - Cookiecutter
  - Projects
  - Templates
  - Python
---
## What Is Cookiecutter And Why You Should Use It?

[Cookiecutter](https://cookiecutter.readthedocs.io/en/stable/index.html) is a cross-platform CLI application that creates projects from project templates. It is ideal for people who tend to create the same project structure repeatedly and want to save some time. Cookiecutter is not dedicated to a specific programming language (or programming projects in general) and can create a given project structure for any programming, machine learning or any other text-based project.

Cookiecutter also allows you to use one of the templates created by community (just [search for Cookiecutter on Github](https://github.com/search?q=cookiecutter&type=repositories) and pick one you like). In this post I will show how to get started (both with using existing templates and writing your own).


## Installation

Using `pipx` is recommended, but you can also install it with `pip`:
```bash
pipx install cookiecutter
# or
python -m pip install --user cookiecutter
```

When you are done with installation, you can verify that it works using `cookiecutter --version` command.

## Using An Existing Template

In order to generate a new project, you can use a template that is on your disk, but it works with Git too!

To generating code with a local folder use the following command (you may need to clone some template if you want to follow along, but we will create a new one later):
```bash
cookiecutter path/to/cookiecutter/template
```

The application will prompt you for any inputs that the template requires. Cookiecutter will generate the project based on the values you've entered or use the defaults. You may modify the default values by modifying the template's `cookiecutter.json`, if necessary.

If you want to use a Git repository instead of a local folder, use an URL instead of path to folder:
```bash
cookiecutter https://github.com/john-doe/example-template.git
```

And if you want a specific branch, you can add `--checkout <branch>`, e.g. for `develop` branch:
```bash
cookiecutter https://github.com/john-doe/example-template.git --checkout develop
```

In addition to local files and Git repositories, you can also use templates in ZIP files, templates on private servers, and even Mercurial repositories.

## Writing Your First Project Template

We will create a folder structure that looks something like this:
```
.
├── cookiecutter.json
├── {{ cookiecutter.project_slug }}
│   ├── Dockerfile
│   ├── LICENSE
│   ├── Makefile
│   ├── README.md
│   ├── src
│   │   └── ...
│   └────── ...
├── LICENSE
└── README.md
```

The first strange thing you will probably notice is this strange file called `{{ cookiecutter.project_slug }}`. Cookiecutter uses [Jinja2 templating engine](https://jinja.palletsprojects.com/), which is also used in other projects (such as Ansible, SaltStack, and Flask). Basically, Jinja2 will try to substitute everything that is between two curly braces with values of the corresponding variables. The values in the object `cookiecutter` are specified in the `cookiecutter.json`.

When creating a Cookiecutter template, you can add new fields to `cookiecutter.json` (as long as it is a valid JSON, it's fine) and then use the variables inside the template. Usually there is a `project_slug` that will then be rendered as a root folder of the generated project. You can also call Python functions to create new fields. Example `cookiecutter.json`:

```json
{
  "email": "john.doe@example.com",
  "project_name": "My Amazing Project",
  "project_slug": "{{ cookiecutter.project_name.lower().replace(' ', '-') }}",
  "short_description": "This is my amazing project"
}
```

As you can see, we are transforming the `project_name` to create the default value of the `project_slug` (we are transforming the text to lower case and replacing any spaces with dashes). The values inside `cookiecutter.json` then can be used in any file inside the `{{ cookiecutter.project_slug }}` folder (including in the file names, though you may run into issues with some special characters). Several variable types are supported by Jinja2 (and therefore by Cookiecutter): numbers, strings, dictionaries, arrays (the arrays are used for options from which a user can select).

These values then can be used in files we add into our template. For example we can create a `README.md` file with the following content:

```markdown
# {{ cookiecutter.project_name }}

{{ cookiecutter.short_description }}

## Report issues

If you find any issue, don't hesitate and send me an email at {{ coookiecutter.email }}.

## Contributing

We are open to contributions!
```

In my practice project I've added a couple more files, including a couple files for a simple server into `{{ cookiecutter.project_slug }}/src/`. In the `main.go`:
```go
package main

import (
	"net/http"
)

func main() {
	http.HandleFunc("/index", IndexHandler)
	http.ListenAndServe(":8080", nil)
}
```

In the `handler.go`:
```go
package main

import (
	"fmt"
	"log"
	"net/http"
)

func IndexHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("/index endpoint was hit")
	fmt.Fprintf(w, fmt.Sprintf("Hello %s", "{{ cookiecutter.author }}"))
}
```

And a relevant test in `handler_test.go`:
```go
package main

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestIndexHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/index", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(IndexHandler)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	expected := fmt.Sprintf("Hello %s", "{{ cookiecutter.author }}")
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expected)
	}
}
```

Arguably, such code would not be very useful in a template, but you could replace `IndexHandler` with a more useful health check that would work similarly, and it is enough for demonstration purposes. Of course, you can and probably should write something more useful. As said before, we can use Cookiecutter variables inside the code. Once we generate the project, `{{ cookiecutter.author }}` will be replaced with an actual value. This may be useful if you want to create functions or variables that have some prefix, e.g.:

```go
func {{ cookiecutter.endpoint }}Handler(w http.ResponseWriter, r *http.Request) {
  // implementation that uses cookiecutter.endpoint
}
```

If we specified `cookiecutter.endpoint` as `Post`, Cookiecutter would generate `PostHandler()` function. One of the CLI options, that Cookiecutter has, is `--skip-if-file-exists`, so you probably (I haven't tested it) could run Cookiecutter repeatedly with the same `project_slug`, but different `endpoint` to generate code for several different objects that the API can return, and than tweak the implementations and add correct business logic. Since you can call Python functions, you can capitalize or transform to lower/upper case based on your needs.


Another feature is that the variables in the `cookiecutter.json` can be defined as private by prepending an underscore to the variable. The user will not be required to fill the values of private variables. Furthermore the user does not need to see these variables and they will not be rendered. If we user should see the value for some reason, we can prepend a double underscore to show the value. Non-render private variables can be useful for defining constants, or when you want to enforce any naming conventions, e.g. to use the same name for both the project and the package name.

Text can be rendered conditionally using the `if` statement:
```markdown
{%- if cookiecutter.should_print -%}
This will be printed if should_print is true.
{%- else -%}
This will be printed if should_print is false.
{% endif %}
```

The variable `should_print` can be a boolean in the `cookiecutter.json` or a result of some condition. We can also write the condition inside the Jinja2 template.

Once you create all the variables and files that you would like in your template, you can generate a new project using `cookiecutter path/to/your/template`.

## Conclusion

In this blog post I've introduced the basics of Cookiecutter. An example Cookiecutter project, that was based on this post, can be found [on my Github](https://github.com/msemjan/cookiecutter-example) (it is a simple Go Hello World project). Many other examples can be found on Github and used as an inspiration for your new templates. I think that Cookiecutter is an interesting and useful tool that will simplify the start of new projects (especially the ones that require more setup and a lot of boilerplate code). There are some advanced features which were not covered by this article (e.g. hooks, user config, calling Cookiecutter functions from Python, injecting extra context, or template extensions), which allow the template creators to build more complex templates. However, the basics described above are more than enough to get started and write templates for majority of projects.
