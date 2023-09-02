import { bedrockRef } from '@penxle/pulumi';
import * as aws from '@pulumi/aws';
import * as pulumi from '@pulumi/pulumi';

const pkg = aws.s3.getObjectOutput({
  bucket: bedrockRef('AWS_S3_BUCKET_ARTIFACTS_BUCKET'),
  key: 'lambda/prod--literoom.zip',
});

const role = new aws.iam.Role('literoom-optimize@lambda', {
  name: 'literoom-optimize@lambda',
  assumeRolePolicy: aws.iam.assumeRolePolicyForPrincipal({
    Service: 'lambda.amazonaws.com',
  }),
  managedPolicyArns: [aws.iam.ManagedPolicies.AWSLambdaBasicExecutionRole],
});

new aws.iam.RolePolicy('literoom-optimize@lambda', {
  name: 'literoom-optimize@lambda',
  role: role.name,

  policy: {
    Version: '2012-10-17',
    Statement: [
      {
        Effect: 'Allow',
        Action: ['s3:GetObject', 's3:PutObject', 's3:DeleteObject'],
        Resource: [pulumi.concat(bedrockRef('AWS_S3_BUCKET_DATA_ARN'), '/*')],
      },
    ],
  },
});

new aws.lambda.Function(`literoom-optimize`, {
  name: 'literoom-optimize',
  role: role.arn,

  runtime: 'nodejs18.x',
  architectures: ['arm64'],

  memorySize: 10_240,
  timeout: 900,

  s3Bucket: pkg.bucket,
  s3Key: pkg.key,
  handler: 'optimize.handler',

  sourceCodeHash: pkg.metadata.Hash,
});
