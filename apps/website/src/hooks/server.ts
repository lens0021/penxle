import { sequence } from '@sveltejs/kit/hooks';
import { building } from '$app/environment';
import { setupGlobals } from './common';
import { logging, maintenance } from './handles';

export { handleError } from './common';

setupGlobals();

export const handle = sequence(logging, maintenance);

if (!building) {
  await import('$lib/server/graphql/handler');
  await import('$lib/server/rest/handler');
  await import('$lib/server/jobs');
}
