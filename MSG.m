//
//  MSG.m
//  SQLiteTest
//
//  Created by 谭钧豪 on 16/6/22.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

#import "MSG.h"

@implementation MSG

@synthesize sender,reciver,content,msgID;

-(id)initWithID:(NSInteger)msgid
        Content:(NSString*)msgContent
         Sender:(NSString*)msgSender
        Reciver:(NSString*)msgReciver
{
    if (self = [super init]){
        msgID = msgid;
        content = msgContent;
        sender = msgSender;
        reciver = msgReciver;
    }
    return self;
}

@end
