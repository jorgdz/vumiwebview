import { registerPlugin } from '@capacitor/core';

import type { VideoWebviewPlugin } from './definitions';

const VideoWebview = registerPlugin<VideoWebviewPlugin>('VideoWebview', {
  web: () => import('./web').then(m => new m.VideoWebviewWeb()),
});

export * from './definitions';
export { VideoWebview };
