//
// Created by luowei on 2017/4/1.
// Copyright (c) 2017 luowei. All rights reserved.
//

#import "LWAddressBookService.h"
#import "APAddressBook.h"
#import "APContact.h"
#import "pinyin.h"


@implementation LWAddressBookService {
    APAddressBook *_addressBook;
}

+(instancetype)serviceWithPrimaryLanguage:(NSString *)primaryLanguage {
    //NSString *primaryLanguage = [LWKeyboardConfig getUserDefaultValueByKey:Key_PrimaryLanguage];

    LWAddressBookService *addressBookService = [LWAddressBookService new];
    [addressBookService setupAddressBookWithPrimaryLanguage:primaryLanguage];
    return addressBookService;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupAddressBookWithPrimaryLanguage:nil];
    }
    return self;
}

- (void)setupAddressBookWithPrimaryLanguage:(NSString *)primaryLanguage {
    if(!_addressBook){
        _addressBook = [[APAddressBook alloc] init];
    }

    _addressBook.fieldsMask = APContactFieldThumbnail | APContactFieldName | APContactFieldPhonesOnly;

    //排序，判断中英文
    //NSString * primaryLanguage = [[NSLocale preferredLanguages] firstObject];
    if(!primaryLanguage || primaryLanguage.length == 0){
        primaryLanguage = [[NSBundle mainBundle] preferredLocalizations].firstObject;
    }

    if ([primaryLanguage hasPrefix:@"zh"]) {
        NSComparator comparator = ^NSComparisonResult(id obj1, id obj2) {
            if([obj1 isKindOfClass:[NSString class]] || [obj2 isKindOfClass:[NSString class]]){
                return  [obj1 compare:obj2];
            }
            NSString *str1 = obj1,*str2 = obj2;
            if([self isBlankString:str1] || [self isBlankString:str2]){
                return NSOrderedSame;
            }
            NSString *pinyin1 = [[NSString stringWithFormat:@"%c", pinyinFirstLetter([str1 characterAtIndex:0])] uppercaseString];
            NSString *pinyin2 = [[NSString stringWithFormat:@"%c", pinyinFirstLetter([str2 characterAtIndex:0])] uppercaseString];
            return [pinyin1 compare:pinyin2 options:NSLiteralSearch range:NSMakeRange(0, pinyin1.length)];
        };
        _addressBook.sortDescriptors = @[
                [[NSSortDescriptor alloc] initWithKey:@"name.firstName" ascending:YES comparator:comparator],
                [[NSSortDescriptor alloc] initWithKey:@"name.lastName" ascending:YES comparator:comparator],
        ];
    }else{
        _addressBook.sortDescriptors = @[
                [NSSortDescriptor sortDescriptorWithKey:@"name.firstName" ascending:YES],
                [NSSortDescriptor sortDescriptorWithKey:@"name.lastName" ascending:YES],
        ];
    }
}

//请求授权
- (void)requestAccess:(void (^)(BOOL granted, NSError *error))completionBlock{
    if ([APAddressBook access] != APAddressBookAccessGranted) {
        [_addressBook requestAccess:^(BOOL granted, NSError *error) {
            completionBlock(granted,error);
        }];
    }else{
        completionBlock(YES,nil);
    }
}

//获取联系人
- (void)loadContactsWithSearchText:(NSString *)searchText
                      successBlock:(void (^)(NSArray <APContact *> *contacts, NSError *error))successBlock {
    if ([APAddressBook access] == APAddressBookAccessGranted) {
        _addressBook.filterBlock = ^BOOL(APContact *contact) {
            BOOL isLike = YES;
            if(searchText && ![self isBlankString:searchText]){
                //判断 name,phone1,phone2 是否 like
                NSString *lastName = contact.name.lastName;
                NSString *firstName = contact.name.firstName;
                NSString *name = [NSString stringWithFormat:@"%@ %@",lastName ?: @"" ,firstName ?: @""];
                NSString *phone1 = @"";
                if(contact.phones.count > 0){
                    phone1 = ((APPhone *)contact.phones[0]).number;
                }
                NSString *phone2 = @"";
                if(contact.phones.count > 1){
                    phone2 = ((APPhone *)contact.phones[1]).number;
                }

                NSString *regexString = [NSString stringWithFormat:@".*%@.*",searchText];
                NSRange nameRG = [name rangeOfString:regexString options:NSRegularExpressionSearch];
                NSRange phone1RG = [phone1 rangeOfString:regexString options:NSRegularExpressionSearch];
                NSRange phone2RG = [phone2 rangeOfString:regexString options:NSRegularExpressionSearch];
                isLike = nameRG.location != NSNotFound || phone1RG.location != NSNotFound || phone2RG.location != NSNotFound;
            }
            return contact.phones.count > 0 && isLike;
        };
        [_addressBook loadContacts:^(NSArray <APContact *> *contacts, NSError *error) {
            successBlock(contacts, error);
        }];
    }else {
        [_addressBook requestAccess:^(BOOL granted, NSError * _Nullable error) {}];
    }
}

-(BOOL)isBlankString:(NSString *)string {
    if([string length] == 0) { //string is empty or nil
        return YES;
    }
    return ![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
}


@end
