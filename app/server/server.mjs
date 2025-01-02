import express from "express";
import cors from "cors";
import session from "express-session";
import { fileURLToPath } from "url";
import path from "path";
import RestUser from "./user/restUser.mjs";
import Configuration from "./config/config.mjs";

var config;

const port = 12345;
const currentModuleURL = import.meta.url;
const currentModulePath = fileURLToPath(currentModuleURL);
const directory = path.dirname(currentModulePath);

const server = express();
const configuration = new Configuration(path.join(directory, "/config/config.json"));
configuration.loadConfiguration()
    .then(getConfig)
    .then(startServer)
    .catch((error) => {
        console.log(error.message);
    });

function getConfig() {
    config = configuration.getConf();
}

function startServer() {
    server.use(
        cors({
            origin: ["http://localhost:5173"],
            methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
            allowedHeaders: ["Content-Type", "Authorization"],
            credentials: true,
        })
    );
    server.use((req, res, next) => {
        res.setHeader("Access-Control-Allow-Origin", "http://localhost:5173");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
        res.setHeader(
            "Access-Control-Allow-Headers",
            "Content-Type, Authorization"
        );
        res.setHeader("Access-Control-Expose-Headers", "Authorization");
        res.setHeader("Access-Control-Allow-Credentials", "true");

        next();
    }
    );

    server.use(express.urlencoded({ extended: true }));
    server.use(express.json());
    server.use(
        session({
            secret: config.sessionSecret,
            saveUninitialized: true,
            cookie: { maxAge: 1000 * 60 * 60 * 3 },
            resave: false,
        })
    );

    restServices();
    serveClient();

    server.listen(port, () => {
        console.log(`Server pokrenut na portu: ${port}`);
    });
}

function restServices() {
    let restUser = new RestUser(config);

    server.post("/api/user/login", restUser.postUserLogin);
}

function serveClient() {}
