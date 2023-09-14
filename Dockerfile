# The base linux distribution is Ubuntu if dont use "-alpine"
FROM nimlang/nim:2.0.0-alpine

# This sets the working directory within the Docker container. All subsequent 
# instructions (COPY, RUN, CMD, etc.) will be executed in this directory 
# inside the container.
WORKDIR /app


COPY . /app

# The -y flag tells 'yes' to everything. the -d:release flag complies code the
# way that it doesn't provide debugging information, but it makes the code
# faster. The command installs dependencies specified in nimble file.
RUN nimble install -y -d:release

# Build your Nim application (replace src/flashcards_bot.nim with your actual 
# Nim source file)
RUN nim c -d:release src/flashcards_bot.nim

# Command to run the executable
CMD ["./src/flashcards_bot"]
