var winston = require('winston');
winston.add(winston.transports.File, { filename: '/var/log/requests.log', level: 'info'});
exports.logger = function(req,res,next) {
	winston.info('HTTP Request', {timestamp: new Date(), method: req.method, url: req.url});
        next();
}



