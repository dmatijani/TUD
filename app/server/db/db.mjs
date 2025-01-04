import pkg from 'pg';
const { Client } = pkg;

class DB {
    constructor(dbConfig) {
        this.dbConfig = dbConfig;
        this.client = null;
    }

    async connect() {
        if (this.client) {
            console.warn("Veza s bazom već postoji.");
            return;
        }

        this.client = new Client(this.dbConfig);

        try {
            await this.client.connect();
        } catch (err) {
            console.error("Greška pri spajanju na bazu: ", err);
            throw err;
        }
    }

    async execute(sql, parametri = []) {
        if (!this.client) {
            throw new Error("Ne postoji baza s konekcijom. Pozovi 'connect' prije izvršavanja.");
        }

        try {
            const result = await this.client.query(sql, parametri);
            return result.rows;
        } catch (err) {
            throw err;
        }
    }

    async close() {
        if (!this.client) {
            console.warn("Veza s bazom već je zatvorena ili nije uspostavljena.");
            return;
        }

        try {
            await this.client.end();
        } catch (err) {
            console.error("Greška pri zatvaranju veze s bazom:", err);
            throw err;
        } finally {
            this.client = null;
        }
    }
}

export default DB;