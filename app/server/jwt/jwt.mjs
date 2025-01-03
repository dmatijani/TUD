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
        if (req.headers.authorization == null || req.headers.authorization == undefined) {
            return false;
        }

        let token = req.headers.authorization.split(" ")[1];
        if (token == "" || token == undefined || token == null) {
            return false;
        }

        let id = req.session.user_id;
        if (id == null || id == undefined) {
            return false;
        }
        let username = req.session.username;
        if (username == "" || username == null || username == undefined) {
            return false;
        }

        let decodedToken = decodeToken(token);
        console.log(decodedToken);

        if (decodedToken.user_id != id || decodedToken.username != username) {
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