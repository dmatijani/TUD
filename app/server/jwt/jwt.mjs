import jwt from "jsonwebtoken";

class JWT {
    constructor(jwtConfig) {
        this.jwtConfig = jwtConfig;
    }

    generateToken(data) {
        return jwt.sign(data, this.jwtConfig.jwtKey, {
            expiresIn: `${this.jwtConfig.jwtDuration}s`
        });
    }

    validateToken(req) {
        if (!req.headers.authorization) {
            return false;
        }

        let token = req.headers.authorization.split(" ")[1];
        if (!token) {
            return false;
        }

        let id = req.session.userId;
        if (!id) {
            return false;
        }
        let username = req.session.username;
        if (!username) {
            return false;
        }

        let decodedToken = decodeToken(token);

        if (decodedToken.userId != id || decodedToken.username != username) {
            return false;
        }

        try {
            jwt.verify(token, this.jwtConfig.jwtKey);
            return true;
        } catch (e) {
            return false;
        }
    }
}

function decodeToken(token) {
    let parts = token.split(".");
    let decoded = decodeBase64(parts[1]);
    let body = JSON.parse(decoded);
    return body;
}

function decodeBase64(data) {
    try {
        let buff = Buffer.from(data, "base64");
        let str = buff.toString("utf-8");
        return str;
    } catch (error) {
        return "{}";
    }
}


export default JWT;