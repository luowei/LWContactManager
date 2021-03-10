# LWContactManager

[![CI Status](https://img.shields.io/travis/luowei/LWContactManager.svg?style=flat)](https://travis-ci.org/luowei/LWContactManager)
[![Version](https://img.shields.io/cocoapods/v/LWContactManager.svg?style=flat)](https://cocoapods.org/pods/LWContactManager)
[![License](https://img.shields.io/cocoapods/l/LWContactManager.svg?style=flat)](https://cocoapods.org/pods/LWContactManager)
[![Platform](https://img.shields.io/cocoapods/p/LWContactManager.svg?style=flat)](https://cocoapods.org/pods/LWContactManager)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

LWContactManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LWContactManager'
```

**Carthage**
```ruby
github "luowei/LWColorPicker"
```

## Usage

```oc

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

```

## Author

luowei, luowei@wodedata.com

## License

LWContactManager is available under the MIT license. See the LICENSE file for more info.
