FROM alpine AS base
RUN echo "hello world" > /hello.txt

FROM alpine AS final1 
COPY --from=base ./hello.txt /file.txt
CMD ["cat", "/file.txt"]

FROM alpine AS final2 
COPY --from=base ./hello.txt /file2.txt
CMD ["cat", "/file2.txt"]
COPY script.js ./script.js
