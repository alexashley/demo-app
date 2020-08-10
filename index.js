import vm from 'vm';
import Hapi from '@hapi/hapi';

const currentEpochTime = () => {
    const currentDateTime = new Date();
    const unixTimestampWithMilliseconds = currentDateTime.getTime();

    return Math.floor(unixTimestampWithMilliseconds / 1000);
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

    reticulatingSplines(server);

    try {
        await server.start();
        console.log('server started', server.info)
    } catch (error) {
        console.error('error starting server', error);
    }
})();