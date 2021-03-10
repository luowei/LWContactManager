//
//  LWViewController.m
//  LWContactManager
//
//  Created by luowei on 12/11/2019.
//  Copyright (c) 2019 luowei. All rights reserved.
//

#import <LWContactManager/LWAddressBookService.h>
#import <APAddressBook/APContact.h>
#import "LWViewController.h"

@interface LWViewController (){
    LWAddressBookService *_addressBookService;
}

@end

@implementation LWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //加载联系人
    [self reloadSearchAddressBook];
}


-(LWAddressBookService *)addressBookService{
    if(!_addressBookService){
        _addressBookService = [[LWAddressBookService alloc] init];
    }
    return _addressBookService;
}

//重新搜索联系人列表
- (void)reloadSearchAddressBook {
    __weak typeof(self) weakSelf = self;
    [self.addressBookService requestAccess:^(BOOL granted, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (granted) {
            NSString *searchText = [strongSelf searchText];
            [strongSelf.addressBookService
                    loadContactsWithSearchText:searchText
                                  successBlock:^(NSArray<APContact *> *contacts, NSError *err) {
                                        for(APContact *contact in contacts){
                                            NSLog(@"==== name:%@ %@ phone:%@",contact.name.lastName,contact.name.firstName,contact.phones.firstObject.number);
                                        }
                                      //todo:设置联系人
                                  }];
        }
    }];
}

- (NSString *)searchText {
    return @"李";
}

@end
