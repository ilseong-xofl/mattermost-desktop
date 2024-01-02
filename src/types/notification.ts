// Copyright (c) 2016-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import {NotificationConstructorOptions} from 'electron/common';

export type MentionOptions = NotificationConstructorOptions & {
    soundName: string;
}

export type SenderData = {
    imgUrl: string;
    userId: string;
    name: string;
    message: string;
    baseUrl: string;
}
