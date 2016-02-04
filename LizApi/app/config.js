var config = {};

config.server = {};
config.server.port = 8080;
config.server.baseurl = {
	dev: 'http://localhost:'+config.server.port,
	prod: 'http://87.106.80.36:'+config.server.port
};

config.db = {};
config.db.url = 'mongodb://localhost/liz';

module.exports = config;
