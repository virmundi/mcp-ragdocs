import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { ApiClient } from '../api-client.js';
import { McpToolResponse } from '../types.js';

export abstract class BaseHandler {
  protected server: Server;
  protected apiClient: ApiClient;

  constructor(server: Server, apiClient: ApiClient) {
    this.server = server;
    this.apiClient = apiClient;
  }

  protected abstract handle(args: any, callContext?: { progressToken?: string | number, requestId: string | number }): Promise<McpToolResponse>;

  protected sendProgress(
    progressToken: string | number | undefined,
    percentageComplete = 0
  ): void {
    if (progressToken === undefined) return;

    void this.server.notification({
      method: 'notifications/progress',
      params: {
        progressToken,
        progress: percentageComplete,
        total: 100,
      },
    }).catch(error => {
      console.error('Failed to send progress notification:', error);
    });
  }
}
