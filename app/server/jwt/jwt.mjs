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
        if (req.headers.authorization == null) {
            return false;
        }

        let token = req.headers.authorization.split(" ")[1];

        // TODO: provjera username iz sesije

        try {
            jwt.verify(token, this.jwtConfig.jwtKey);
            return true;
        } catch (e) {
            return false;
        }
    }
}

export default JWT;