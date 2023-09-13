# The base linux distribution is Ubuntu if dont use "-alpine"
FROM nimlang/nim:latest-alpine

# This sets the working directory within the Docker container. All subsequent 
# instructions (COPY, RUN, CMD, etc.) will be executed in this directory 
# inside the container.
WORKDIR /app


COPY . /app


RUN nimble install -y -d:release flashcards
