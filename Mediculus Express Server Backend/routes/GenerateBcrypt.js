const Express = require("express");
const router = Express.Router();

const bcrypt = require("bcrypt");

router.post("/", async (req, res) => {
    

    console.log(req.body)
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(req.body.password, salt);
    res.send(hashedPassword)
});

module.exports = router;