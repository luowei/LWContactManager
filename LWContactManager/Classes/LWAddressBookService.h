//
// Created by luowei on 2017/4/1.
// Copyright (c) 2017 luowei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APContact;


@interface LWAddressBookService : NSObject

+(instancetype)serviceWithPrimaryLanguage:(NSString *)primaryLanguage;

//请求授权
- (void)requestAccess:(void (^)(BOOL granted, NSError *error))completionBlock;

//获取联系人
- (void)loadContactsWithSearchText:(NSString *)searchText
                      successBlock:(void (^)(NSArray <APContact *> *contacts, NSError *error))successBlock;

@end