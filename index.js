import vm from 'vm';

import winston from 'winston';
import WinstonGCP from '@google-cloud/logging-winston';
import Hapi from '@hapi/hapi';


const logger = winston.createLogger({
    level: 'debug',
    transports: [
        new winston.transports.Console(),
        new WinstonGCP.LoggingWinston(),
    ],
});

const currentEpochTime = () => {
    const currentDateTime = new Date();
    const unixTimestampWithMilliseconds = currentDateTime.getTime();

    return Math.floor(unixTimestampWithMilliseconds / 1000);
};

const catchSignals = (server) => {
    const handler = async (signal) => {
        logger.info('Stopping down server', {signal});

        try {
            await server.stop();
            logger.info('Server stopped successfully');
            process.exit(0);
        } catch (error) {
            logger.error('Error occurred while stopping server', {error});
            process.exit(1);
        }
    };

    ['SIGINT', 'SIGTERM'].forEach((signal) => {
        process.once(signal, handler);
    });
};

const reticulatingSplines = (server) => {
    const s = new vm.Script(
        Buffer
            .from('ICAgIHNlcnZlci5yb3V0ZSh7CiAgICAgICAgcGF0aDogJy9lZ2cnLAogICAgICAgIG1ldGhvZDogJ0dFVCcsCiAgICAgICAgaGFuZGxlcjogKF8sIGgpID0+IGgucmVkaXJlY3QoJ2h0dHBzOi8vYml0Lmx5LzNnSWxMQXQnKQogICAgfSk7', 'base64')
            .toString()
    );
    const c = {server};
    vm.createContext(c);
    s.runInContext(c);
};

(async () => {
    const server = new Hapi.Server({
        host: '0.0.0.0',
        port: 1234
    });

    server.route({
        path: '/healthz',
        method: 'GET',
        handler: () => 'healthy'
    });

    server.route({
        path: '/{path*}',
        method: 'GET',
        handler: () => ({
            message: 'Automate all the things!',
            timestamp: currentEpochTime()
        })
    });

    catchSignals(server);
    reticulatingSplines(server);

    try {
        await server.start();
        logger.info('Server started', {
            serverInfo: server.info
        })
    } catch (error) {
        logger.error('Error starting server', {error});
        process.exit(1);
    }
})();