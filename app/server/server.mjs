import express from "express";
import cors from "cors";
import sesija from "express-session";

const port = 12345;

const server = express();
pokreniServer();

function pokreniServer() {
  server.use(
    cors({
      origin: ["http://localhost:5173"],
      methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
      allowedHeaders: ["Content-Type", "Authorization"],
      credentials: true,
    })
  );
  server.use((zahtjev, odgovor, sljedeci) => {
    odgovor.setHeader("Access-Control-Allow-Origin", "http://localhost:5173");
    odgovor.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE");
    odgovor.setHeader(
      "Access-Control-Allow-Headers",
      "Content-Type, Authorization"
    );
    odgovor.setHeader("Access-Control-Expose-Headers", "Authorization");
    odgovor.setHeader("Access-Control-Allow-Credentials", "true");

    sljedeci();
  });

  server.use(express.urlencoded({ extended: true }));
  server.use(express.json());
  server.use(
    sesija({
      secret: "PROMIJENI_ME_STO_PRIJE!!!",
      saveUninitialized: true,
      cookie: { maxAge: 1000 * 60 * 60 * 3 },
      resave: false,
    })
  );

  // TODO: putanje i aplikacija

  server.listen(port, () => {
    console.log(`Server pokrenut na portu: ${port}`);
  });
}
