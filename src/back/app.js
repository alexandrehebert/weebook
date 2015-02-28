var express = require('express');
var path = require('path');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var errorHandler = require('errorhandler');
var methodOverride = require('method-override');

var port = process.argv[2] || 8080;
var routes = require('./routes/index');
var users = require('./routes/users');

var api = module.exports.api = express();
var app = module.exports.app = express();

console.log('env:', api.get('env'));
console.log('dir:', __dirname);

{
    api.use(logger('dev'));
    api.use(bodyParser.json());
    api.use(cookieParser());
    api.use(methodOverride('_method'))

    if (api.get('env') === 'development') {
        api.use(errorHandler());
    }
}

{
    app.use(express.static(path.join(__dirname, '../../build/web/')));
}

api.use(routes);
api.use(users);

// catch 404 and forward to error handler
api.use(function (req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

// error handlers
api.use(function (err, req, res) {
    res.status(err.status || 500);
    res.render('error', {
        message: err.message,
        error: api.get('env') === 'development' ? err : {}
    });
});

api.listen(port);
app.listen(port + 1);
// module.exports = api;