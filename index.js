import Hapi from '@hapi/hapi';

const currentEpochTime = () => {
    const currentDateTime = new Date();
    const unixTimestampWithMilliseconds = currentDateTime.getTime();

    return Math.floor(unixTimestampWithMilliseconds / 1000);
};

(async () => {
    const server = new Hapi.Server({
        host: '0.0.0.0',
        port: 1234
    });

    server.route({
        path: '/healthz',
        handler: () => 'healthy',
        method: 'GET'
    });

    server.route({
        path: '/{path*}',
        method: 'GET',
        handler: () => ({
            message: 'Automate all the things!',
            timestamp: currentEpochTime()
        })
    });

    try {
        await server.start();
        console.log('server started', server.info)
    } catch (error) {
        console.error('error starting server', error);
    }
})();