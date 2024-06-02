---
title: "Docker Compose Watch"
date: 2024-06-02T15:44:08+02:00
summary: "In version 2.22.0 Docker Compose introduced Compose Watch feature, which allows Docker Compose users to automatically update and preview services running as soon as the work is saved."
draft: false
toc: false
images:
tags:
  - Docker
  - Docker Compose
  - DevOps
  - Containerization
---
## Introduction

The [Docker Compose](https://docs.docker.com/compose/) allows you to easily spin up several Docker containers in a reliable and reproducible way. It is useful for every developer who is using Docker containers, especially if more than one is used (e.g. one for database, one for caching with Redis, and one for your applications). By using Docker compose, you can avoid running multiple Docker run commands for each service.

In the Docker Compose version 2.22.0 was introduced a new feature: the Compose Watch[^1], which allows you to automatically update and preview your running the Compose services after you have edited and saved your code changes. This enables a hands-off development workflow once the Compose is running. The services will automatically restart as you save your changes. It is similar to [Nodemon](https://www.npmjs.com/package/nodemon) for Node.js, [Air](https://github.com/cosmtrek/air) for Go, [Reloadium](https://github.com/reloadware/reloadium) for Python, and other similar tools that simplify and streamline development by providing hot reloading functionality.

## Example

Let's consider a minimal Node.js application with the following project structure:

```
my-nodejs-app/
├── web/
│   ├── App.jsx
│   └── index.js
├── Dockerfile
├── compose.yaml
└── package.json
```

In the `Dockerfile` we will have:

```Dockerfile
# Run as a non-privileged user
FROM node:18-alpine
RUN useradd -ms /bin/sh -u 1001 app
USER app

# Install dependencies
WORKDIR /app
COPY package.json package.lock .
RUN npm install

# Copy source files into application directory
COPY --chown=app:app . /app
```

The `compose.yaml` file will contain the following:

```yaml
services:
  web:
    build: .
    command: npm start
    develop:
      watch:                   # This part is necessary for each service you want to automatically sync in watch mode
        - action: sync         # Sync action ensures that changes in local files are automatically synced with the container
          path: ./web
          target: /src/web
          ignore:
            - node_modules/
        - action: rebuild      # Rebuild action automatically builds a new image if there are any changes to package.json,
	                           # this is also ideal options for compiled languages
          path: package.json
```

To use the watch feature, run the Docker Compose with `--watch` flag:

```bash
docker compose up --watch
```

Then a container for the `web` service will be launched using an image built with the `Dockerfile` in the project's root folder. The `web` service will run `npm start` as a command, which than launches the development version of the application with Hot Module Reload enabled in the bundler (Webpack, Vite, Turbopack, ...).

The services that will be watched are specified in the `watch` section in YAML. There are rules that control automatic service updates based on local file changes. Each rule requires a `path` and an `action` that will be performed when a change is detected. Some `action`s may provide or require other fields. Besides the options shown in the example above, there is also "sync + restart" option that will sync changes with the service containers and then restart it. It is ideal for configuration changes that don't require rebuild of the container, but need a service container restart to take effect, e.g. for database configurations or your `nginx.conf` file.

The watch mode uses common executables that must be be present in the image containers, and you should ensure that they are installed:
- `stat`
- `mkdir`
- `rmdir`

The watch mode also requires that the container's `USER` has write permissions and can update files. It is common to create a new user before running `COPY` instruction in Docker. To ensure that the user can modify files, use `COPY --chown` flag, e.g. in the example above we used:

```dockerfile
RUN useradd -ms /bin/sh -u 1001 app
USER app

# (Omitted parts)

COPY --chown=app:app . /app
```

Specific paths and rules will vary from project to project, but the main idea stays the same. Moreover, you don't need to watch all services, only those you will edit and will need a restart, e.g. only front-end you are working on.

If any changes are saved, the Docker Compose in the watch mode will trigger a sync and update corresponding files in the `/src/web` folder inside the container. Once copied, the bundler will update the running application without a need for a restart.

**Note**: While source files can be updated on-fly, the dependencies can not. Whenever you install or remove a package, or update the `package.json`, the Compose needs to rebuild the image and recreate the `web` service container.

This approach can be used for many languages and frameworks, e.g. Python with Flask framework. The source files can be easily synced while a change to `requirements.txt` triggers a rebuild. In case of compiled languages, the entire container will have to be rebuilt.

## Path Rules

The Compose Watch follows a couple of path rules:
- All paths are relative to the project root directory
- Directories are watched recursively
- Glob patterns are not supported
- Rules from `.dockerignore` and `ignore` option apply
- IDE files are automatically ignored
- `.git` folder is ignored automatically

## What Is The Difference Between Compose Watch And Bind Mounts

The Compose Watch does not replace the existing support for sharing a host directory inside service containers, but it exists as a complement suited for development inside containers.

Moreover, the watch mode allows for increased granularity than bind mounts. The rules in the `watch` section let you watch or ignore specific files or directories within the watched tree. This is useful if you have many small files that would cause high I/O load (e.g. `node_modules/` in Javascript projects) or if the compiled artifacts can not be shared across different architectures, because they are platform dependent (e.g. Node packages can contain native code).

## Conclusion

The Docker Compose with the new watch mode adds a new functionality to a tried and tested tool. It is amazing for people who want/need to do their development in Docker containers. Despite the fact that such development was possible before with bound mounts, or simply by using `docker-compose down && docker-compose up` after each meaningful change, now it is easier than ever.

Moreover, the watch mode provides an option to exclude files and folders that will be synced with improved granularity, and is general improvement to containerized development. If you use the Docker Compose, consider using the watch mode, since it is very useful and simplifies any workflow.

## Sources 📚️

[^1]: _“Use compose watch.”_ (2024, May 20). Docker Documentation. https://docs.docker.com/compose/file-watch
