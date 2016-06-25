//
//  MSG.h
//  SQLiteTest
//
//  Created by 谭钧豪 on 16/6/22.
//  Copyright © 2016年 谭钧豪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSG : NSObject

@property NSString *sender,*reciver,*content;
@property NSInteger msgID;

-(id)initWithID:(NSInteger)msgid
        Content:(NSString*)msgContent
         Sender:(NSString*)msgSender
        Reciver:(NSString*)msgReciver;

@end
