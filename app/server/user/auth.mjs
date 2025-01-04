import JWT from "../jwt/jwt.mjs";

class Auth {
    constructor(jwtConfig) {
        this.jwtConfig = jwtConfig;
    }

    checkSession = (req) => {
        if (req.session == undefined || req.session == null) {
            return false;
        }

        let id = req.session.user_id;

        if (id == null || id == undefined) {
            return false
        }

        return true;
    }

    checkAuth = async (req) => {
        if (!this.checkSession(req)) {
            throw new Error("Neispravna sesija.");
        }

        let jwt = new JWT(this.jwtConfig);
        let tokenValid = jwt.validateToken(req);
        if (!tokenValid) {
            throw new Error("Token nije validan.");
        }

        return req.session.id;
    }
}

export default Auth;