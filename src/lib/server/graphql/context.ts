import { track } from '../analytics';
import { prismaClient } from '../database';
import type { TransactionClient } from '../database';
import type { RequestEvent } from '@sveltejs/kit';
import type { YogaInitialContext } from 'graphql-yoga';

type DefaultContext = {
  db: TransactionClient;
  track: (eventName: string, properties?: Record<string, unknown>) => void;
};

export type AuthContext = {
  session: {
    id: string;
    userId: string;
    profileId: string;
  };
};

type ExtendedContext = App.Locals & DefaultContext & Partial<AuthContext>;
type InitialContext = YogaInitialContext & RequestEvent;
export type Context = InitialContext & ExtendedContext;

export const extendContext = async (
  context: InitialContext
): Promise<ExtendedContext> => {
  const db = await prismaClient.$begin({ isolation: 'RepeatableRead' });

  const ctx: ExtendedContext = {
    ...context.locals,
    db,
    track: (eventName, properties) => {
      track(context, eventName, { ...properties });
    },
  };

  const sessionId = context.cookies.get('penxle-sid');
  if (sessionId) {
    const session = await db.session.findUnique({
      select: { userId: true, profileId: true },
      where: { id: sessionId },
    });

    if (session) {
      ctx.session = {
        id: sessionId,
        userId: session.userId,
        profileId: session.profileId,
      };

      ctx.track = (eventName, properties) => {
        track(context, eventName, {
          $user_id: session.userId,
          ...properties,
        });
      };
    }
  }

  return ctx;
};
