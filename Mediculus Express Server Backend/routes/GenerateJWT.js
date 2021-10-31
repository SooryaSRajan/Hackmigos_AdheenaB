const Express = require("express");
const router = Express.Router();
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

require('dotenv').config();

router.post("/", async (req, res) => {


    if (req.body.password == null){
        res.status(401).send('Please attach password')
        return;
    } 

    const validateKey = await bcrypt.compare(
        req.body.password,
        process.env.BCRYPT_KEY
    );


    var response;
    if (validateKey) {
        const token = jwt.sign(
            { _id: process.env.JWT_ID, },
            process.env.JWT_SECRET_KEY
        );

        response = {
            success: true,
            jwt: token
        }
        res.send(response)
        return;
    }

    else {
        response = {
            success: false,
            message: 'Invalid credential to generate jwt'
        }
        res.status(401).send(response)
    }

});

module.exports = router;
