import * as Sentry from '@sentry/sveltekit';
import { match } from 'ts-pattern';
import { z } from 'zod';

enum AppErrorKind {
  UnknownError = 'UnknownError',
  IntentionalError = 'IntentionalError',
  PermissionDeniedError = 'PermissionDeniedError',
  NotFoundError = 'NotFoundError',
  FormValidationError = 'FormValidationError',
}

type AppErrorExtra = {
  [key: string]: unknown;
  code?: number;
  internal?: boolean;
};

type AppErrorConstructorParams = {
  kind: AppErrorKind;
  message: string;
  extra?: AppErrorExtra;
};

export type PortableAppError = z.infer<typeof PortableAppErrorSchema>;
const PortableAppErrorSchema = z.object({
  message: z.string(),
  extensions: z.object({
    __app: z.object({
      kind: z.nativeEnum(AppErrorKind),
      extra: z.record(z.unknown()),
    }),
  }),
});

export abstract class AppError extends Error {
  public override readonly name: AppErrorKind;
  public extra: AppErrorExtra;

  constructor({ kind, message, extra = {} }: AppErrorConstructorParams) {
    super(message);

    this.name = kind;
    this.extra = extra;
  }

  public serialize(): PortableAppError {
    return {
      message: this.message,
      extensions: {
        __app: {
          kind: this.name,
          extra: this.extra,
        },
      },
    };
  }

  static deserialize(error: unknown): AppError {
    const r = PortableAppErrorSchema.safeParse(error);

    if (r.success) {
      const {
        message,
        extensions: {
          __app: { kind, extra },
        },
      } = r.data;

      return match(kind)
        .with(AppErrorKind.UnknownError, () => new UnknownError(extra.cause, extra.id as string))
        .with(AppErrorKind.IntentionalError, () => new IntentionalError(message))
        .with(AppErrorKind.PermissionDeniedError, () => new PermissionDeniedError())
        .with(AppErrorKind.NotFoundError, () => new NotFoundError())
        .with(AppErrorKind.FormValidationError, () => new FormValidationError(extra.field as string, message))
        .exhaustive();
    } else {
      return new UnknownError(error);
    }
  }
}

type ErrorLike = z.infer<typeof ErrorLikeSchema>;
const ErrorLikeSchema = z.object({
  name: z.string(),
  message: z.string(),
  stack: z.string().optional(),
});

export class UnknownError extends AppError {
  public override readonly cause: ErrorLike;
  public readonly id: string;

  constructor(cause: unknown, id?: string) {
    const r = ErrorLikeSchema.safeParse(cause);
    const c = r.success ? r.data : new Error(String(cause));

    if (!id) {
      id = Sentry.captureException(cause);
    }

    super({
      kind: AppErrorKind.UnknownError,
      message: `${c.name}: ${c.message}`,
      extra: { id, cause: c },
    });

    this.id = id;
    this.cause = c;
  }
}

export class IntentionalError extends AppError {
  constructor(message: string) {
    super({
      kind: AppErrorKind.IntentionalError,
      message,
    });
  }
}

export class PermissionDeniedError extends AppError {
  constructor() {
    super({
      kind: AppErrorKind.PermissionDeniedError,
      message: '권한이 없어요',
      extra: { code: 403 },
    });
  }
}

export class NotFoundError extends AppError {
  constructor() {
    super({
      kind: AppErrorKind.NotFoundError,
      message: '페이지를 찾을 수 없어요',
      extra: { code: 404 },
    });
  }
}

export class FormValidationError extends AppError {
  public readonly field: string;

  constructor(field: string, message: string) {
    super({
      kind: AppErrorKind.FormValidationError,
      message,
      extra: { field, internal: true },
    });

    this.field = field;
  }
}
