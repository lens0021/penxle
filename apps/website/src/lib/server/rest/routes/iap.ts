import { status } from 'itty-router';
import { createRouter } from '../router';

export const iap = createRouter();

iap.post('/iap/google', async (_, context) => {
  const payload = await context.event.request.json();
  console.log(payload);

  return status(200);
});

iap.post('/iap/apple', async (_, context) => {
  const payload = await context.event.request.json();
  console.log(payload);

  return status(200);
});
