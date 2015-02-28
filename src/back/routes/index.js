var express = require('express');
var router = express.Router();

router.get('/', function(req, res) {
    res.status(200)
        .set('Content-Type', 'text/plain')
        .send('ok');
});

module.exports = router;
