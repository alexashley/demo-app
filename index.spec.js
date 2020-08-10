import assert from 'assert';

import moment from 'moment';
import fetch from 'node-fetch';

describe('demo-app', () => {
    const uri = process.env.APP_URI || 'http://localhost:1234';

    describe('/healthz', () => {
        it('should be healthy', async () => {
            const response = await fetch(`${uri}/healthz`);
            assert.strictEqual(response.status, 200);
        });

        it('should indicate status', async () => {
            const response = await fetch(`${uri}/healthz`);
            const statusText = await response.text();

            assert.strictEqual(statusText, 'healthy');
        });
    });

    describe('/message', () => {
        it('should return a certain message', async () => {
            const response = await fetch(`${uri}/message`);
            const payload = await response.json();

            assert.strictEqual(payload.message, 'Automate all the things!');
        });

        it('should return a recent timestamp', async () => {
            const now = moment().unix();

            const response = await fetch(`${uri}/message`);
            const payload = await response.json();
            const diff = payload.timestamp - now;

            assert.ok(diff < 10);
        });
    });
});