import { Injectable } from '@nestjs/common';
import type { Request } from 'express';

export type VisitInfo = {
  timestamp: string;
  ip: string | null;
};

@Injectable()
export class AppService {
  getHello(req: Request): VisitInfo {
    const timestamp = new Date().toISOString();
    const ip = this.getClientIp(req);
    return { timestamp, ip };
  }

  private getClientIp(req: Request): string | null {
    const xff = req.headers['x-forwarded-for'];

    if (typeof xff === 'string' && xff.length > 0) {
      return xff.split(',')[0].trim();
    }
    if (Array.isArray(xff) && xff.length > 0 && typeof xff[0] === 'string') {
      return xff[0].trim();
    }

    if (req.ip && req.ip.length > 0) {
      return req.ip;
    }

    return req.socket?.remoteAddress ?? null;
  }
}
