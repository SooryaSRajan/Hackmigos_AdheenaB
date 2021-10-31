const jwt = require("jsonwebtoken");

module.exports = function (req, res, next) {
    const token = req.header("jwt-token");

    if (!token) {
        return res
            .status(401)
            .send("Please attach token to header");
    }

    try {
        const verifiedToken = jwt.verify(token, process.env.JWT_SECRET_KEY);

        if (verifiedToken._id == process.env.JWT_ID) {
            next();
        }
        else {
            res.status(401).send("Invalid JWT id");
        }

    } catch (error) {
        res.status(401).send("Invalid Token");
    }
};