# LWContactManager

[![CI Status](https://img.shields.io/travis/luowei/LWContactManager.svg?style=flat)](https://travis-ci.org/luowei/LWContactManager)
[![Version](https://img.shields.io/cocoapods/v/LWContactManager.svg?style=flat)](https://cocoapods.org/pods/LWContactManager)
[![License](https://img.shields.io/cocoapods/l/LWContactManager.svg?style=flat)](https://cocoapods.org/pods/LWContactManager)
[![Platform](https://img.shields.io/cocoapods/p/LWContactManager.svg?style=flat)](https://cocoapods.org/pods/LWContactManager)

[English Document](README.md)

## 项目描述

LWContactManager 是一个全面的 iOS 通讯录管理库，提供对设备通讯录的便捷访问。它简化了通讯录操作，包括读取、搜索和管理联系人，并内置了权限处理。基于 APAddressBook 构建，为通讯录管理提供了简洁直观的 API。

## 功能特性

- **便捷的联系人访问**：提供简单的 API 用于访问设备联系人
- **权限处理**：内置权限请求和处理机制
- **联系人搜索**：支持按姓名进行文本匹配搜索
- **异步操作**：使用完成回调进行非阻塞联系人加载
- **完整的联系人详情**：访问完整的联系人信息（姓名、电话、邮箱等）
- **APContact 集成**：利用 APAddressBook 实现强大的联系人处理
- **高效内存管理**：延迟加载和高效的联系人管理
- **中文拼音排序**：支持中文联系人按拼音首字母排序

## 系统要求

- iOS 8.0+
- Xcode 8.0+
- Objective-C

## 安装方式

### CocoaPods

LWContactManager 可通过 [CocoaPods](https://cocoapods.org) 安装。只需在 Podfile 中添加以下行：

```ruby
pod 'LWContactManager'
```

然后运行：
```bash
pod install
```

### Carthage

在 Cartfile 中添加以下行：

```ruby
github "luowei/LWContactManager"
```

然后运行：
```bash
carthage update --platform iOS
```

## 使用方法

### 基础配置

导入头文件：

```objective-c
#import <LWContactManager/LWAddressBookService.h>
```

### 创建通讯录服务

```objective-c
@property (nonatomic, strong) LWAddressBookService *addressBookService;

- (LWAddressBookService *)addressBookService {
    if (!_addressBookService) {
        _addressBookService = [[LWAddressBookService alloc] init];
    }
    return _addressBookService;
}
```

### 创建带语言配置的通讯录服务

```objective-c
// 使用指定的主要语言创建服务（用于排序规则）
LWAddressBookService *addressBookService =
    [LWAddressBookService serviceWithPrimaryLanguage:@"zh-Hans"];
```

### 请求联系人访问权限

```objective-c
[self.addressBookService requestAccess:^(BOOL granted, NSError *error) {
    if (granted) {
        NSLog(@"联系人访问权限已授予");
        // 加载联系人
    } else {
        NSLog(@"联系人访问权限被拒绝: %@", error);
    }
}];
```

### 加载所有联系人

```objective-c
[self.addressBookService requestAccess:^(BOOL granted, NSError *error) {
    if (granted) {
        [self.addressBookService
            loadContactsWithSearchText:nil
                          successBlock:^(NSArray<APContact *> *contacts, NSError *err) {
                              // 遍历所有联系人
                              for (APContact *contact in contacts) {
                                  NSLog(@"姓名: %@ %@, 电话: %@",
                                        contact.name.lastName,
                                        contact.name.firstName,
                                        contact.phones.firstObject.number);
                              }
                          }];
    }
}];
```

### 搜索联系人

```objective-c
- (void)reloadSearchAddressBook {
    __weak typeof(self) weakSelf = self;
    [self.addressBookService requestAccess:^(BOOL granted, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (granted) {
            NSString *searchText = [strongSelf searchText];
            [strongSelf.addressBookService
                    loadContactsWithSearchText:searchText
                                  successBlock:^(NSArray<APContact *> *contacts, NSError *err) {
                                      // 更新联系人列表
                                      [strongSelf setContacts:contacts];
                                      [strongSelf reloadData];
                                      [strongSelf.collectionViewLayout invalidateLayout];
                                  }];
        }
    }];
}

- (NSString *)searchText {
    return @"张三"; // 搜索包含"张三"的联系人
}
```

## API 文档

### LWAddressBookService

```objective-c
@interface LWAddressBookService : NSObject

// 使用指定的主要语言创建服务实例
+ (instancetype)serviceWithPrimaryLanguage:(NSString *)primaryLanguage;

// 请求访问联系人权限
- (void)requestAccess:(void (^)(BOOL granted, NSError *error))completionBlock;

// 加载联系人，支持可选的搜索文本
- (void)loadContactsWithSearchText:(NSString *)searchText
                      successBlock:(void (^)(NSArray<APContact *> *contacts, NSError *error))successBlock;

@end
```

#### 主要方法说明

**serviceWithPrimaryLanguage:**
- 参数：`primaryLanguage` - 主要语言代码（如 "zh-Hans" 表示简体中文，"en" 表示英文）
- 返回：配置好的 LWAddressBookService 实例
- 说明：根据语言设置不同的排序规则。中文环境下会按拼音首字母排序，英文环境下按字母顺序排序

**requestAccess:**
- 参数：`completionBlock` - 权限请求完成回调，包含授权结果和可能的错误
- 说明：请求访问设备通讯录的权限。如果已授权，会直接调用回调；否则会向用户请求权限

**loadContactsWithSearchText:successBlock:**
- 参数：
  - `searchText` - 搜索关键词（可选）。传 nil 或空字符串加载所有联系人
  - `successBlock` - 成功加载后的回调，返回联系人数组和可能的错误
- 说明：加载并返回联系人列表。搜索功能支持姓名和电话号码匹配

### APContact

来自 APAddressBook 的联系人模型：

- `name`：APName 对象，包含 firstName（名）、lastName（姓）等
- `phones`：APPhone 对象数组，包含所有电话号码
- `emails`：APEmail 对象数组，包含所有邮箱地址
- `addresses`：APAddress 对象数组，包含所有地址信息
- 以及更多联系人字段

#### 常用属性说明

```objective-c
// 姓名信息
contact.name.firstName    // 名
contact.name.lastName     // 姓
contact.name.middleName   // 中间名
contact.name.nickname     // 昵称

// 电话信息
APPhone *phone = contact.phones.firstObject;
phone.number             // 电话号码
phone.localizedLabel     // 电话类型标签（如"手机"、"工作"等）

// 邮箱信息
APEmail *email = contact.emails.firstObject;
email.address            // 邮箱地址
email.localizedLabel     // 邮箱类型标签

// 缩略图
contact.thumbnail        // 联系人头像缩略图
```

## 特色功能

### 中文拼音排序

LWContactManager 内置了中文拼音排序支持。当检测到主要语言为中文时（语言代码以 "zh" 开头），联系人会自动按照姓名的拼音首字母进行排序，提供更符合中文用户习惯的排序体验。

### 智能搜索

搜索功能支持：
- 姓名匹配（包括姓和名）
- 电话号码匹配（支持多个电话号码）
- 正则表达式模糊匹配
- 自动过滤没有电话号码的联系人

### 高效加载

- 只加载必要的字段（缩略图、姓名、电话）
- 使用 APAddressBook 的异步加载机制
- 支持自定义过滤条件

## 示例项目

要运行示例项目，请克隆仓库并首先在 Example 目录中运行 `pod install`：

```bash
git clone https://github.com/luowei/LWContactManager.git
cd LWContactManager/Example
pod install
open LWContactManager.xcworkspace
```

## 依赖库

- [APAddressBook](https://github.com/Alterplay/APAddressBook)：通讯录框架

## 注意事项

### 隐私权限配置

从 iOS 10 开始，您需要在应用的 Info.plist 文件中添加通讯录访问权限说明：

```xml
<key>NSContactsUsageDescription</key>
<string>需要访问您的通讯录以便选择联系人</string>
```

### 权限检查

使用联系人功能前，务必先调用 `requestAccess:` 方法请求权限。未授权状态下调用 `loadContactsWithSearchText:successBlock:` 会自动触发权限请求。

### 内存管理

建议将 LWAddressBookService 实例作为属性保存，避免重复创建。服务实例会在内部管理 APAddressBook 对象的生命周期。

## 作者

luowei, luowei@wodedata.com

## 开源协议

LWContactManager 基于 MIT 协议开源。详见 LICENSE 文件。
