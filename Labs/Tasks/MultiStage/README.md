![DockerLabs Banner](../../assets/images/docker-logos.png)

---

# In-Class Exercise - Multi-Stage Dockerfile
    
- Create a `multi-stage` docker file that will build 2 images
- The first image will be based on `alpine` and will create a file named `alpine.txt` with the content: `This is alpine image`
- The second image will be based on `node` and will create a file named `node.txt` with the content: `This is node image`
- The final image should be based on `alpine` and should copy the files which you created from the previous stages and display their content when the container will run.
- Hint: Use the `COPY --from=` command to copy files from previous stages

<details markdown="1">
<summary>Solution</summary>

### Dockerfile Solution

Create a file named `Dockerfile-exercise`:

```dockerfile
# First stage: Alpine image
FROM  alpine AS alpine-stage
RUN   echo "This is alpine image" > alpine.txt

# Second stage: Node image
FROM  node AS node-stage
RUN   echo "This is node image" > node.txt

# Final stage: Alpine with files from previous stages
FROM  alpine
COPY  --from=alpine-stage alpine.txt  .
COPY  --from=node-stage node.txt      .

# Run the command to display contents
CMD   cat alpine.txt && cat node.txt
```

### Build and Test

Build the image:

```bash
docker build -f Dockerfile-exercise -t exercise-solution .
```

Run the container:

```bash
docker run exercise-solution
```

Expected output:

```text
This is alpine image
This is node image
```

### Explanation

1. **First Stage (alpine-stage)**: Based on `alpine`, creates `alpine.txt` with the required content
2. **Second Stage (node-stage)**: Based on `node`, creates `node.txt` with the required content
3. **Final Stage**: Based on `alpine` (lightweight), copies both files from previous stages using `COPY --from=<stage-name>` and displays their content when run

</details>
