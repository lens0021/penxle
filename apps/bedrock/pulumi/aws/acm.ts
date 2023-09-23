import * as aws from '@pulumi/aws';
import { usEast1 } from '$aws/providers';

const createCertificate = (domain: string) => {
  const certificate = new aws.acm.Certificate(domain, {
    domainName: domain,
    subjectAlternativeNames: [`*.${domain}`],
    validationMethod: 'DNS',
  });

  new aws.acm.CertificateValidation(domain, {
    certificateArn: certificate.arn,
  });

  return certificate;
};

const createCloudFrontCertificate = (domain: string) => {
  const certificate = new aws.acm.Certificate(
    `cloudfront/${domain}`,
    {
      domainName: domain,
      subjectAlternativeNames: [`*.${domain}`],
      validationMethod: 'DNS',
    },
    { provider: usEast1 },
  );

  new aws.acm.CertificateValidation(`cloudfront/${domain}`, { certificateArn: certificate.arn }, { provider: usEast1 });

  return certificate;
};

export const certificates = {
  penxle_com: createCertificate('penxle.com'),
  penxle_io: createCertificate('penxle.io'),
  pnxl_cc: createCertificate('pnxl.cc'),
  pnxl_co: createCertificate('pnxl.co'),
  pnxl_net: createCertificate('pnxl.net'),
  pnxl_site: createCertificate('pnxl.site'),
};

export const cloudFrontCertificates = {
  penxle_com: createCloudFrontCertificate('penxle.com'),
  penxle_io: createCloudFrontCertificate('penxle.io'),
  pnxl_cc: createCloudFrontCertificate('pnxl.cc'),
  pnxl_co: createCloudFrontCertificate('pnxl.co'),
  pnxl_net: createCloudFrontCertificate('pnxl.net'),
  pnxl_site: createCloudFrontCertificate('pnxl.site'),
};

export const outputs = {
  AWS_ACM_PENXLE_COM_CERTIFICATE_ARN: certificates.penxle_com.arn,
  AWS_ACM_PENXLE_IO_CERTIFICATE_ARN: certificates.penxle_io.arn,
  AWS_ACM_PNXL_CC_CERTIFICATE_ARN: certificates.pnxl_cc.arn,
  AWS_ACM_PNXL_CO_CERTIFICATE_ARN: certificates.pnxl_co.arn,
  AWS_ACM_PNXL_NET_CERTIFICATE_ARN: certificates.pnxl_net.arn,
  AWS_ACM_PNXL_SITE_CERTIFICATE_ARN: certificates.pnxl_site.arn,

  AWS_ACM_CLOUDFRONT_PENXLE_COM_CERTIFICATE_ARN: cloudFrontCertificates.penxle_com.arn,
  AWS_ACM_CLOUDFRONT_PENXLE_IO_CERTIFICATE_ARN: cloudFrontCertificates.penxle_io.arn,
  AWS_ACM_CLOUDFRONT_PNXL_CC_CERTIFICATE_ARN: cloudFrontCertificates.pnxl_cc.arn,
  AWS_ACM_CLOUDFRONT_PNXL_CO_CERTIFICATE_ARN: cloudFrontCertificates.pnxl_co.arn,
  AWS_ACM_CLOUDFRONT_PNXL_NET_CERTIFICATE_ARN: cloudFrontCertificates.pnxl_net.arn,
  AWS_ACM_CLOUDFRONT_PNXL_SITE_CERTIFICATE_ARN: cloudFrontCertificates.pnxl_site.arn,
};
