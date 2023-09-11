import parsetoml

let config = parseFile("config.toml")

let dbHost* = config["dbHost"].getStr
let dbName* = config["dbName"].getStr
let dbUser* = config["dbUser"].getStr
let dbPassword* = config["dbPassword"].getStr
