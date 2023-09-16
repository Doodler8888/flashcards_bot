FROM nimlang/nim:2.0.0-alpine

RUN apk add --no-cache postgresql-libs

ENV DBHOST="localhost"
ENV DBNAME="flashcards_bot"
ENV DBUSER="wurfkreuz"
ENV DBPASSWORD=

WORKDIR /app

COPY . /app

RUN nimble install -y -d:release

RUN nim c -d:release -d:ssl -d:nimDebugDlOpen src/flashcards_bot.nim

# Command to run the executable
CMD ["./src/flashcards_bot"]


# This sets the working directory within the Docker container. All subsequent 
# instructions (COPY, RUN, CMD, etc.) will be executed in this directory 
# inside the container.

# The -y flag tells 'yes' to everything. the -d:release flag complies code the
# way that it doesn't provide debugging information, but it makes the code
# faster. The command installs dependencies specified in nimble file.

# Build your Nim application (replace src/flashcards_bot.nim with your actual 
# Nim source file)

