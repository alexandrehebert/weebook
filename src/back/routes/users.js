var express = require('express');
var router = express.Router();

router.get('/users', function(req, res) {
  res.send({
      user: 'blah'
  });
});

module.exports = router;
