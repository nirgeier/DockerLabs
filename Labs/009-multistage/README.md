# Docker Multistage Build

- `Docker multistage builds` allow you to use multiple `FROM` statements in your Dockerfile.
- `Docker multistage builds` is used for copying artifacts from one stage to another. 
- `Docker multistage builds` helps create smaller, more secure images by separating build dependencies from the final runtime image.

---

## Why Use Multistage Builds?

- **Reduce image size:**
  - Use a minimal base image for the final stage.
  - Only copy necessary files to the final image.
- **Improve security:**
  - Exclude build tools and secrets from the runtime image.
  - Limit the attack surface by using a smaller image.
  - Use a non-root user in the final image.
- **Simplify CI/CD pipelines:**
  - Combine build, test, and deploy stages in a single Dockerfile.
  - Use different base images for different stages (e.g., `golang`, `node`, `python`).
- **Easier debugging:**
  - Each stage can be built and tested independently.
  - Use named stages for better readability and maintainability.
- **Faster builds:**
  - Leverage Docker's caching mechanism to speed up builds.
  - Only rebuild stages that have changed.
- **Cleaner Dockerfiles:**
  - Separate concerns by using multiple stages.
  - Avoid cluttering the final image with unnecessary files.
- **Better caching:**
  - Docker caches each stage, so only changed stages need to be rebuilt.
- **Easier to manage dependencies:**
  - Install build dependencies in one stage and runtime dependencies in another.
  - Use different base images for different stages (e.g., `golang`, `node`, `python`).
  - This allows you to use the best image for each stage without bloating the final image.
- **Simplify Dockerfiles:** 
  - No need for manual cleanup of build dependencies.
  - Easier to read and maintain.
  - Use comments to explain each stage's purpose.
  - Use meaningful names for stages to clarify their roles.
- **Better caching:**
  - Docker caches each stage, so only changed stages need to be rebuilt.

---

## Basic Example

Suppose you have a simple Go application:

**Dockerfile:**
```dockerfile
# Build stage
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

# Final stage
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/myapp ./
CMD ["./myapp"]
```

**How it works:**
- The first stage (`builder`) compiles the Go app.
- The second stage copies only the compiled binary into a minimal Alpine image.

---

## Node.js Example

```dockerfile
# Build stage
FROM node:20 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM node:20-slim
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
RUN npm install --only=production
CMD ["node", "dist/index.js"]
```

---

## Advanced Multistage Build Examples

### 1. Multi-Artifact Build (Frontend + Backend)

```dockerfile
# Build frontend
FROM node:20 AS frontend-build
WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ .
RUN npm run build

# Build backend
FROM golang:1.21 AS backend-build
WORKDIR /backend
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ .
RUN go build -o app

# Final image
FROM alpine:latest
WORKDIR /app
COPY --from=backend-build /backend/app ./
COPY --from=frontend-build /frontend/dist ./public
CMD ["./app"]
```

---

### 2. Test, Lint, and Build Stages

```dockerfile
# Install dependencies and run tests
FROM node:20 AS test
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm test

# Lint stage
FROM test AS lint
RUN npm run lint

# Build stage
FROM test AS build
RUN npm run build

# Production image
FROM node:20-slim
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/package*.json ./
RUN npm ci --only=production
CMD ["node", "dist/index.js"]
```

---

### 3. Using a Custom Build Tool (e.g., Maven for Java)

```dockerfile
# Build with Maven
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Final image with JRE only
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/app.jar ./app.jar
CMD ["java", "-jar", "app.jar"]
```

---

- These advanced examples show how to:

  - Build and combine multiple artifacts (frontend + backend)
  - Add test and lint stages for better CI/CD
  - Use language-specific build tools and copy only the final artifact

---

## Tips

- Name your stages for clarity: `FROM node:20 AS build`.
- Use `.dockerignore` to exclude unnecessary files from the build context.
- You can have as many stages as needed.

---

## References
- [Docker Docs: Multistage Builds](https://docs.docker.com/build/building/multi-stage/)

---


