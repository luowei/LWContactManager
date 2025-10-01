# LWContactManager

[![CI Status](https://img.shields.io/travis/luowei/LWContactManager.svg?style=flat)](https://travis-ci.org/luowei/LWContactManager)
[![Version](https://img.shields.io/cocoapods/v/LWContactManager.svg?style=flat)](https://cocoapods.org/pods/LWContactManager)
[![License](https://img.shields.io/cocoapods/l/LWContactManager.svg?style=flat)](https://cocoapods.org/pods/LWContactManager)
[![Platform](https://img.shields.io/cocoapods/p/LWContactManager.svg?style=flat)](https://cocoapods.org/pods/LWContactManager)

[English](./README.md) | [中文版](./README_ZH.md)

---

## Table of Contents

- [Description](#description)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
  - [CocoaPods](#cocoapods-recommended)
  - [Carthage](#carthage)
  - [Manual Installation](#manual-installation)
  - [Privacy Configuration](#privacy-configuration)
- [Usage](#usage)
  - [Quick Start](#quick-start)
  - [Basic Setup](#basic-setup)
  - [Requesting Contact Access](#requesting-contact-access)
  - [Loading Contacts](#loading-all-contacts)
  - [Searching Contacts](#searching-contacts)
- [API Documentation](#api-documentation)
- [Advanced Features](#advanced-features)
- [Example Project](#example-project)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

---

## Description

LWContactManager is a comprehensive and powerful iOS contacts management library designed to simplify access to the device's address book. Built on top of the robust APAddressBook framework, it provides an elegant, easy-to-use API for all your contact management needs.

Whether you need to load all contacts, search for specific entries, or handle complex permission scenarios, LWContactManager handles the heavy lifting for you. It features built-in permission management, asynchronous operations, intelligent search capabilities, and localization support including Chinese pinyin sorting. The library is production-ready and optimized for performance with lazy loading and efficient memory management.

### Why Choose LWContactManager?

- **Production-Ready**: Battle-tested and stable, ready for production applications
- **Developer-Friendly**: Clean, intuitive API that reduces boilerplate code
- **Performance-Optimized**: Efficient memory management and asynchronous operations
- **Localization Support**: Native Chinese pinyin sorting for better UX
- **Comprehensive**: Access to all contact fields including names, phones, emails, and addresses
- **Well-Documented**: Extensive documentation with practical examples and best practices

## Features

- **Easy Contact Access**: Simple, intuitive API for accessing device contacts with minimal setup
- **Built-in Permission Handling**: Automatic permission request and status management with detailed error handling
- **Powerful Contact Search**: Search contacts by name with intelligent text matching and regular expression support
- **Async Operations**: Non-blocking contact loading with completion handlers for smooth UI experience
- **Complete Contact Details**: Access comprehensive contact information including names, phones, emails, addresses, and thumbnails
- **Chinese Pinyin Sorting**: Automatic sorting by pinyin initials for Chinese contacts, providing native language support
- **Smart Filtering**: Automatically filters contacts without phone numbers for cleaner results
- **Localization Support**: Language-aware sorting and display with customizable primary language
- **APContact Integration**: Leverages the battle-tested APAddressBook framework for robust contact handling
- **Memory Efficient**: Optimized with lazy loading and efficient contact management to minimize memory footprint
- **Production Ready**: Well-tested, stable API suitable for production applications
- **Flexible Configuration**: Support for custom sorting rules based on language preferences

## Requirements

- iOS 8.0+
- Xcode 8.0+
- Objective-C

## Installation

LWContactManager supports multiple installation methods to fit your project's needs.

### CocoaPods (Recommended)

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate LWContactManager into your Xcode project using CocoaPods, add it to your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target 'YourApp' do
    pod 'LWContactManager'
end
```

Then, run the following command:

```bash
$ pod install
```

After installation, make sure to open the `.xcworkspace` file instead of the `.xcodeproj` file:

```bash
$ open YourApp.xcworkspace
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](https://brew.sh/):

```bash
$ brew update
$ brew install carthage
```

To integrate LWContactManager into your Xcode project using Carthage, specify it in your `Cartfile`:

```ruby
github "luowei/LWContactManager"
```

Run `carthage update` to build the framework and drag the built `LWContactManager.framework` into your Xcode project:

```bash
$ carthage update --platform iOS
```

### Manual Installation

If you prefer not to use dependency managers, you can integrate LWContactManager manually:

1. Download the latest release from the [GitHub repository](https://github.com/luowei/LWContactManager)
2. Add the source files from the `LWContactManager/Classes` folder to your project
3. Make sure to also add the dependency [APAddressBook](https://github.com/Alterplay/APAddressBook) to your project

### Privacy Configuration

Starting with iOS 10, you must provide a usage description in your app's `Info.plist` file:

```xml
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts to help you connect with friends</string>
```

Replace the string value with your own description that explains why your app needs access to contacts. This message will be displayed to users when requesting permission.

## Usage

### Quick Start

Here's a minimal example to get you started:

```objective-c
#import <LWContactManager/LWAddressBookService.h>

// Create service
LWAddressBookService *service = [[LWAddressBookService alloc] init];

// Request permission and load contacts
[service requestAccess:^(BOOL granted, NSError *error) {
    if (granted) {
        [service loadContactsWithSearchText:nil
                               successBlock:^(NSArray<APContact *> *contacts, NSError *err) {
            NSLog(@"Loaded %lu contacts", (unsigned long)contacts.count);
        }];
    }
}];
```

### Basic Setup

First, import the necessary headers in your view controller or service class:

```objective-c
#import <LWContactManager/LWAddressBookService.h>
```

### Creating Address Book Service

#### Standard Initialization

Create a property to hold your address book service instance:

```objective-c
@interface YourViewController ()
@property (nonatomic, strong) LWAddressBookService *addressBookService;
@end

@implementation YourViewController

- (LWAddressBookService *)addressBookService {
    if (!_addressBookService) {
        _addressBookService = [[LWAddressBookService alloc] init];
    }
    return _addressBookService;
}

@end
```

#### Initialization with Language Configuration

For better localization support, especially for Chinese contacts, you can specify a primary language:

```objective-c
- (LWAddressBookService *)addressBookService {
    if (!_addressBookService) {
        // Create service with Chinese language support for pinyin sorting
        _addressBookService = [LWAddressBookService serviceWithPrimaryLanguage:@"zh-Hans"];
    }
    return _addressBookService;
}
```

Supported language codes:
- `@"zh-Hans"` - Simplified Chinese (with pinyin sorting)
- `@"zh-Hant"` - Traditional Chinese
- `@"en"` - English (alphabetical sorting)
- Any other language codes supported by iOS

### Requesting Contact Access

Before accessing contacts, you must request permission from the user:

```objective-c
[self.addressBookService requestAccess:^(BOOL granted, NSError *error) {
    if (granted) {
        NSLog(@"Contact access granted");
        // Proceed to load contacts
        [self loadContacts];
    } else {
        NSLog(@"Contact access denied: %@", error);
        // Show alert to user explaining why access is needed
        [self showAccessDeniedAlert];
    }
}];
```

### Loading All Contacts

Load all contacts from the device's address book:

```objective-c
[self.addressBookService requestAccess:^(BOOL granted, NSError *error) {
    if (granted) {
        [self.addressBookService
            loadContactsWithSearchText:nil
                          successBlock:^(NSArray<APContact *> *contacts, NSError *err) {
                              // Process contacts
                              for (APContact *contact in contacts) {
                                  NSString *fullName = [NSString stringWithFormat:@"%@ %@",
                                                       contact.name.lastName ?: @"",
                                                       contact.name.firstName ?: @""];
                                  NSString *phone = contact.phones.firstObject.number ?: @"No phone";

                                  NSLog(@"Contact: %@, Phone: %@", fullName, phone);
                              }

                              // Update UI
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  self.contacts = contacts;
                                  [self.tableView reloadData];
                              });
                          }];
    }
}];
```

### Searching Contacts

Search for specific contacts by name or phone number:

```objective-c
- (void)searchContactsWithText:(NSString *)searchText {
    __weak typeof(self) weakSelf = self;
    [self.addressBookService requestAccess:^(BOOL granted, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (granted) {
            [strongSelf.addressBookService
                    loadContactsWithSearchText:searchText
                                  successBlock:^(NSArray<APContact *> *contacts, NSError *err) {
                                      // Update UI with filtered contacts
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          strongSelf.contacts = contacts;
                                          [strongSelf.tableView reloadData];
                                      });
                                  }];
        }
    }];
}
```

### Real-time Search Implementation

Here's a complete example implementing a search bar with real-time filtering:

```objective-c
#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // Cancel previous search if still running
    [NSObject cancelPreviousPerformRequestsWithSelector:@selector(performSearch)
                                                 target:self];

    // Delay search to avoid too many requests while typing
    [self performSelector:@selector(performSearch)
               withObject:nil
               afterDelay:0.3];
}

- (void)performSearch {
    NSString *searchText = self.searchBar.text;

    if (searchText.length == 0) {
        // Load all contacts if search is empty
        [self loadAllContacts];
    } else {
        // Search with specific text
        [self searchContactsWithText:searchText];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    [self loadAllContacts];
}
```

### Accessing Contact Details

Retrieve detailed information from contact objects:

```objective-c
- (void)displayContactDetails:(APContact *)contact {
    // Name information
    NSString *firstName = contact.name.firstName ?: @"";
    NSString *lastName = contact.name.lastName ?: @"";
    NSString *middleName = contact.name.middleName ?: @"";
    NSString *nickname = contact.name.nickname ?: @"";

    NSLog(@"Full Name: %@ %@ %@", firstName, middleName, lastName);
    NSLog(@"Nickname: %@", nickname);

    // Phone numbers
    for (APPhone *phone in contact.phones) {
        NSLog(@"Phone (%@): %@", phone.localizedLabel, phone.number);
    }

    // Email addresses
    for (APEmail *email in contact.emails) {
        NSLog(@"Email (%@): %@", email.localizedLabel, email.address);
    }

    // Addresses
    for (APAddress *address in contact.addresses) {
        NSLog(@"Address (%@): %@, %@, %@ %@",
              address.localizedLabel,
              address.street,
              address.city,
              address.state,
              address.zip);
    }

    // Contact thumbnail
    if (contact.thumbnail) {
        UIImage *thumbnailImage = [UIImage imageWithData:contact.thumbnail];
        self.contactImageView.image = thumbnailImage;
    }
}
```

### Displaying Contacts in a Table View

Complete implementation for displaying contacts in a UITableView:

```objective-c
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"
                                                            forIndexPath:indexPath];

    APContact *contact = self.contacts[indexPath.row];

    // Configure cell
    NSString *fullName = [NSString stringWithFormat:@"%@ %@",
                         contact.name.lastName ?: @"",
                         contact.name.firstName ?: @""];
    cell.textLabel.text = fullName;

    // Show phone number as detail
    APPhone *phone = contact.phones.firstObject;
    cell.detailTextLabel.text = phone.number ?: @"No phone";

    // Display thumbnail
    if (contact.thumbnail) {
        cell.imageView.image = [UIImage imageWithData:contact.thumbnail];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"default_avatar"];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    APContact *contact = self.contacts[indexPath.row];
    [self displayContactDetails:contact];
}
```

### Error Handling

Properly handle errors and edge cases:

```objective-c
- (void)loadContactsWithErrorHandling {
    [self.addressBookService requestAccess:^(BOOL granted, NSError *error) {
        if (!granted) {
            // Handle permission denied
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController
                    alertControllerWithTitle:@"Permission Required"
                    message:@"Please enable contact access in Settings to use this feature."
                    preferredStyle:UIAlertControllerStyleAlert];

                [alert addAction:[UIAlertAction actionWithTitle:@"Settings"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:settingsURL
                                                       options:@{}
                                             completionHandler:nil];
                }]];

                [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil]];

                [self presentViewController:alert animated:YES completion:nil];
            });
            return;
        }

        // Load contacts
        [self.addressBookService
            loadContactsWithSearchText:nil
                          successBlock:^(NSArray<APContact *> *contacts, NSError *err) {
                              if (err) {
                                  NSLog(@"Error loading contacts: %@", err);
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self showErrorAlert:err];
                                  });
                                  return;
                              }

                              if (contacts.count == 0) {
                                  NSLog(@"No contacts found");
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [self showNoContactsMessage];
                                  });
                                  return;
                              }

                              // Success
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  self.contacts = contacts;
                                  [self.tableView reloadData];
                              });
                          }];
    }];
}
```

## API Documentation

### LWAddressBookService

The main service class for managing contacts.

```objective-c
@interface LWAddressBookService : NSObject

/**
 * Creates a new address book service instance with specified primary language.
 *
 * @param primaryLanguage The primary language code (e.g., "zh-Hans" for Simplified Chinese,
 *                        "en" for English). This affects sorting behavior:
 *                        - Chinese (starts with "zh"): Contacts sorted by pinyin initials
 *                        - Other languages: Contacts sorted alphabetically
 *
 * @return A new LWAddressBookService instance configured for the specified language
 */
+ (instancetype)serviceWithPrimaryLanguage:(NSString *)primaryLanguage;

/**
 * Requests access to the device's contacts.
 *
 * This method checks the current authorization status and requests permission if needed.
 * If permission has already been granted, the completion block is called immediately.
 * If permission has been denied, an error is returned in the completion block.
 *
 * @param completionBlock Block called when permission request completes
 *                        - granted: YES if access was granted, NO otherwise
 *                        - error: NSError object if access was denied, nil otherwise
 *
 * @discussion This method should be called before any attempt to load contacts.
 *            The completion block is called on the main thread.
 */
- (void)requestAccess:(void (^)(BOOL granted, NSError *error))completionBlock;

/**
 * Loads contacts from the address book with optional search filtering.
 *
 * @param searchText Optional search string to filter contacts. Pass nil or empty string
 *                   to load all contacts. The search matches against:
 *                   - First name
 *                   - Last name
 *                   - Phone numbers
 *                   Search is case-insensitive and supports partial matches.
 *
 * @param successBlock Block called when contacts are loaded
 *                     - contacts: Array of APContact objects (only contacts with phone numbers)
 *                     - error: NSError object if loading failed, nil otherwise
 *
 * @discussion This method automatically filters out contacts without phone numbers.
 *            Contacts are sorted based on the primary language setting.
 *            The success block is called on a background thread.
 *            Make sure to dispatch UI updates to the main thread.
 */
- (void)loadContactsWithSearchText:(NSString *)searchText
                      successBlock:(void (^)(NSArray<APContact *> *contacts, NSError *error))successBlock;

@end
```

#### Method Details

**`+ serviceWithPrimaryLanguage:`**

Creates a service instance with language-specific sorting:
- **Chinese languages** (`zh-Hans`, `zh-Hant`, etc.): Sorts contacts by pinyin initials
- **Other languages**: Sorts contacts alphabetically

Example:
```objective-c
LWAddressBookService *service = [LWAddressBookService serviceWithPrimaryLanguage:@"zh-Hans"];
```

**`- requestAccess:`**

Manages contact permission requests:
- Checks current authorization status
- Requests permission if not determined
- Returns immediately if already authorized or denied
- Thread-safe and can be called multiple times

Example:
```objective-c
[service requestAccess:^(BOOL granted, NSError *error) {
    if (granted) {
        // Permission granted - safe to load contacts
    } else {
        // Permission denied - handle error
        NSLog(@"Error: %@", error.localizedDescription);
    }
}];
```

**`- loadContactsWithSearchText:successBlock:`**

Loads and filters contacts:
- Loads all contact fields: name, phones, emails, addresses, thumbnail
- Filters by search text (case-insensitive, partial match)
- Automatically excludes contacts without phone numbers
- Sorts based on language configuration
- Executes on background thread for performance

Example:
```objective-c
[service loadContactsWithSearchText:@"John"
                       successBlock:^(NSArray<APContact *> *contacts, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update UI with filtered contacts
        self.contacts = contacts;
        [self.tableView reloadData];
    });
}];
```

### APContact

Contact model from the APAddressBook framework representing a person in the address book.

#### Core Properties

```objective-c
@interface APContact : NSObject

@property (nonatomic, readonly) APName *name;              // Name information
@property (nonatomic, readonly) NSArray<APPhone *> *phones;    // Phone numbers
@property (nonatomic, readonly) NSArray<APEmail *> *emails;    // Email addresses
@property (nonatomic, readonly) NSArray<APAddress *> *addresses; // Physical addresses
@property (nonatomic, readonly) NSData *thumbnail;         // Contact photo thumbnail
@property (nonatomic, readonly) UIImage *photo;           // Full-size contact photo
@property (nonatomic, readonly) NSString *note;           // Notes
@property (nonatomic, readonly) NSArray<APSocialProfile *> *socialProfiles; // Social media
@property (nonatomic, readonly) NSArray<APRelatedPerson *> *relatedPersons; // Related contacts
@property (nonatomic, readonly) NSArray<APWebsite *> *websites;  // Websites
@property (nonatomic, readonly) NSDate *birthday;         // Birthday
@property (nonatomic, readonly) NSString *jobTitle;       // Job title
@property (nonatomic, readonly) NSString *department;     // Department
@property (nonatomic, readonly) NSString *company;        // Company/organization

@end
```

### APName

Represents a contact's name components.

```objective-c
@interface APName : NSObject

@property (nonatomic, strong) NSString *firstName;       // Given name
@property (nonatomic, strong) NSString *lastName;        // Family name
@property (nonatomic, strong) NSString *middleName;      // Middle name
@property (nonatomic, strong) NSString *prefix;          // Name prefix (Mr., Mrs., Dr., etc.)
@property (nonatomic, strong) NSString *suffix;          // Name suffix (Jr., Sr., III, etc.)
@property (nonatomic, strong) NSString *nickname;        // Nickname
@property (nonatomic, strong) NSString *firstNamePhonetic;  // Phonetic first name
@property (nonatomic, strong) NSString *lastNamePhonetic;   // Phonetic last name
@property (nonatomic, strong) NSString *middleNamePhonetic; // Phonetic middle name

@end
```

Example usage:
```objective-c
APContact *contact = contacts.firstObject;
NSString *fullName = [NSString stringWithFormat:@"%@ %@ %@",
                     contact.name.firstName ?: @"",
                     contact.name.middleName ?: @"",
                     contact.name.lastName ?: @""];
```

### APPhone

Represents a phone number with its label.

```objective-c
@interface APPhone : NSObject

@property (nonatomic, strong) NSString *number;          // Phone number string
@property (nonatomic, strong) NSString *localizedLabel;  // Localized label (e.g., "mobile", "home", "work")
@property (nonatomic, assign) APPhoneLabel originalLabel; // Original label type

@end
```

Common phone labels:
- `mobile` - Mobile phone
- `home` - Home phone
- `work` - Work phone
- `main` - Main phone
- `iPhone` - iPhone

Example usage:
```objective-c
for (APPhone *phone in contact.phones) {
    NSLog(@"%@: %@", phone.localizedLabel, phone.number);
}
```

### APEmail

Represents an email address with its label.

```objective-c
@interface APEmail : NSObject

@property (nonatomic, strong) NSString *address;         // Email address
@property (nonatomic, strong) NSString *localizedLabel;  // Localized label
@property (nonatomic, assign) APEmailLabel originalLabel; // Original label type

@end
```

Example usage:
```objective-c
APEmail *primaryEmail = contact.emails.firstObject;
if (primaryEmail) {
    NSString *emailLink = [NSString stringWithFormat:@"mailto:%@", primaryEmail.address];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailLink]];
}
```

### APAddress

Represents a physical address.

```objective-c
@interface APAddress : NSObject

@property (nonatomic, strong) NSString *street;          // Street address
@property (nonatomic, strong) NSString *city;            // City
@property (nonatomic, strong) NSString *state;           // State/Province
@property (nonatomic, strong) NSString *zip;             // Postal code
@property (nonatomic, strong) NSString *country;         // Country
@property (nonatomic, strong) NSString *countryCode;     // Country code (e.g., "US")
@property (nonatomic, strong) NSString *localizedLabel;  // Localized label
@property (nonatomic, assign) APAddressLabel originalLabel; // Original label type

@end
```

Example usage:
```objective-c
APAddress *homeAddress = contact.addresses.firstObject;
if (homeAddress) {
    NSString *fullAddress = [NSString stringWithFormat:@"%@, %@, %@ %@",
                            homeAddress.street,
                            homeAddress.city,
                            homeAddress.state,
                            homeAddress.zip];
}
```

### APSocialProfile

Represents a social media profile.

```objective-c
@interface APSocialProfile : NSObject

@property (nonatomic, strong) NSString *service;         // Service name (e.g., "Twitter", "Facebook")
@property (nonatomic, strong) NSString *username;        // Username/handle
@property (nonatomic, strong) NSString *userIdentifier;  // Unique identifier
@property (nonatomic, strong) NSString *url;             // Profile URL

@end
```

### APWebsite

Represents a website URL.

```objective-c
@interface APWebsite : NSObject

@property (nonatomic, strong) NSString *url;             // Website URL
@property (nonatomic, strong) NSString *localizedLabel;  // Localized label

@end
```

### Complete Contact Example

```objective-c
- (void)printAllContactDetails:(APContact *)contact {
    // Name
    NSLog(@"=== Contact Details ===");
    NSLog(@"Name: %@ %@", contact.name.firstName, contact.name.lastName);
    if (contact.name.nickname) {
        NSLog(@"Nickname: %@", contact.name.nickname);
    }

    // Phones
    NSLog(@"\nPhones:");
    for (APPhone *phone in contact.phones) {
        NSLog(@"  %@: %@", phone.localizedLabel, phone.number);
    }

    // Emails
    if (contact.emails.count > 0) {
        NSLog(@"\nEmails:");
        for (APEmail *email in contact.emails) {
            NSLog(@"  %@: %@", email.localizedLabel, email.address);
        }
    }

    // Addresses
    if (contact.addresses.count > 0) {
        NSLog(@"\nAddresses:");
        for (APAddress *address in contact.addresses) {
            NSLog(@"  %@: %@, %@, %@ %@, %@",
                  address.localizedLabel,
                  address.street,
                  address.city,
                  address.state,
                  address.zip,
                  address.country);
        }
    }

    // Company
    if (contact.company) {
        NSLog(@"\nOrganization:");
        NSLog(@"  Company: %@", contact.company);
        if (contact.jobTitle) {
            NSLog(@"  Title: %@", contact.jobTitle);
        }
        if (contact.department) {
            NSLog(@"  Department: %@", contact.department);
        }
    }

    // Birthday
    if (contact.birthday) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        NSLog(@"\nBirthday: %@", [formatter stringFromDate:contact.birthday]);
    }

    // Social Profiles
    if (contact.socialProfiles.count > 0) {
        NSLog(@"\nSocial Profiles:");
        for (APSocialProfile *profile in contact.socialProfiles) {
            NSLog(@"  %@: %@", profile.service, profile.username);
        }
    }

    // Websites
    if (contact.websites.count > 0) {
        NSLog(@"\nWebsites:");
        for (APWebsite *website in contact.websites) {
            NSLog(@"  %@", website.url);
        }
    }

    // Note
    if (contact.note) {
        NSLog(@"\nNote: %@", contact.note);
    }
}
```

## Advanced Features

### Chinese Pinyin Sorting

LWContactManager includes built-in support for Chinese pinyin sorting. When the primary language is set to Chinese (language code starting with "zh"), contacts are automatically sorted by the pinyin initials of their names.

```objective-c
// Create service with Chinese language support
LWAddressBookService *service = [LWAddressBookService serviceWithPrimaryLanguage:@"zh-Hans"];

[service requestAccess:^(BOOL granted, NSError *error) {
    if (granted) {
        [service loadContactsWithSearchText:nil
                               successBlock:^(NSArray<APContact *> *contacts, NSError *err) {
            // Contacts are now sorted by pinyin: A, B, C, D...
            // 张三 (Zhang San) -> Z
            // 李四 (Li Si) -> L
            // 王五 (Wang Wu) -> W
        }];
    }
}];
```

### Smart Contact Filtering

The library automatically filters out contacts without phone numbers, ensuring you only work with contacts that have callable information.

```objective-c
[service loadContactsWithSearchText:nil
                       successBlock:^(NSArray<APContact *> *contacts, NSError *err) {
    // All contacts in this array are guaranteed to have at least one phone number
    for (APContact *contact in contacts) {
        APPhone *phone = contact.phones.firstObject;
        NSLog(@"Can call: %@", phone.number);
    }
}];
```

### Intelligent Search

The search functionality supports fuzzy matching against multiple fields:

```objective-c
// Search by name
[service loadContactsWithSearchText:@"John" successBlock:^(NSArray *contacts, NSError *err) {
    // Matches: John Smith, Johnny Appleseed, etc.
}];

// Search by phone number
[service loadContactsWithSearchText:@"555" successBlock:^(NSArray *contacts, NSError *err) {
    // Matches: contacts with phones containing "555"
}];

// Search works with Chinese characters and pinyin
[service loadContactsWithSearchText:@"张" successBlock:^(NSArray *contacts, NSError *err) {
    // Matches: 张三, 张伟, etc.
}];
```

### Memory Management Best Practices

Keep the service instance alive for the duration of your view controller's lifecycle:

```objective-c
@interface ContactsViewController ()
@property (nonatomic, strong) LWAddressBookService *addressBookService;
@property (nonatomic, strong) NSArray<APContact *> *contacts;
@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize service once
    self.addressBookService = [[LWAddressBookService alloc] init];

    // Load contacts
    [self loadContacts];
}

- (void)loadContacts {
    // Reuse the same service instance
    [self.addressBookService requestAccess:^(BOOL granted, NSError *error) {
        if (granted) {
            [self.addressBookService loadContactsWithSearchText:nil
                                                   successBlock:^(NSArray *contacts, NSError *err) {
                self.contacts = contacts;
                [self.tableView reloadData];
            }];
        }
    }];
}

@end
```

### Thread Safety

The library handles threading for you, but remember to dispatch UI updates to the main thread:

```objective-c
[service loadContactsWithSearchText:nil
                       successBlock:^(NSArray<APContact *> *contacts, NSError *err) {
    // This block is called on a background thread
    // Dispatch UI updates to main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contacts = contacts;
        [self.tableView reloadData];
        [self.activityIndicator stopAnimating];
    });
}];
```

### Performance Optimization

For large contact lists, consider implementing pagination or virtual scrolling:

```objective-c
@interface ContactsViewController ()
@property (nonatomic, strong) NSArray<APContact *> *allContacts;
@property (nonatomic, strong) NSArray<APContact *> *displayedContacts;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger currentPage;
@end

@implementation ContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageSize = 50;
    self.currentPage = 0;
}

- (void)loadContacts {
    [self.addressBookService loadContactsWithSearchText:nil
                                           successBlock:^(NSArray *contacts, NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.allContacts = contacts;
            [self loadNextPage];
        });
    }];
}

- (void)loadNextPage {
    NSInteger start = self.currentPage * self.pageSize;
    NSInteger end = MIN(start + self.pageSize, self.allContacts.count);

    if (start < self.allContacts.count) {
        NSArray *page = [self.allContacts subarrayWithRange:NSMakeRange(start, end - start)];
        self.displayedContacts = [self.displayedContacts arrayByAddingObjectsFromArray:page];
        self.currentPage++;
        [self.tableView reloadData];
    }
}

@end
```

## Example Project

The LWContactManager repository includes a complete example project demonstrating all features of the library.

### Running the Example

1. Clone the repository:
```bash
git clone https://github.com/luowei/LWContactManager.git
cd LWContactManager
```

2. Install dependencies:
```bash
cd Example
pod install
```

3. Open the workspace:
```bash
open LWContactManager.xcworkspace
```

4. Build and run the project in Xcode (Cmd+R)

### What's Included

The example project demonstrates:
- Permission handling and user alerts
- Loading and displaying all contacts
- Real-time search functionality
- Contact detail view with all fields
- Chinese pinyin sorting
- Error handling patterns
- UI integration with UITableView and UICollectionView
- Performance optimization techniques

### Example Project Structure

```
Example/
├── LWContactManager/
│   ├── ViewController.m           # Main contact list
│   ├── ContactDetailViewController.m  # Contact details
│   └── Main.storyboard            # UI layout
├── Podfile                        # Dependencies
└── LWContactManager.xcworkspace   # Workspace file
```

## Best Practices

### 1. Always Request Permission First

```objective-c
// Good
[service requestAccess:^(BOOL granted, NSError *error) {
    if (granted) {
        [self loadContacts];
    }
}];

// Bad - Don't call loadContacts without checking permission
[service loadContactsWithSearchText:nil successBlock:^(NSArray *contacts, NSError *err) {
    // This might fail if permission not granted
}];
```

### 2. Handle Edge Cases

```objective-c
- (void)displayContact:(APContact *)contact {
    // Use nil coalescing to handle missing data
    NSString *firstName = contact.name.firstName ?: @"";
    NSString *lastName = contact.name.lastName ?: @"";

    // Check array count before accessing
    if (contact.phones.count > 0) {
        NSString *phone = contact.phones.firstObject.number;
    }

    // Validate data before using
    if (contact.thumbnail) {
        UIImage *image = [UIImage imageWithData:contact.thumbnail];
    }
}
```

### 3. Provide Clear User Feedback

```objective-c
- (void)loadContactsWithFeedback {
    // Show loading indicator
    [self.activityIndicator startAnimating];

    [self.addressBookService requestAccess:^(BOOL granted, NSError *error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
                [self showPermissionDeniedAlert];
            });
            return;
        }

        [self.addressBookService loadContactsWithSearchText:nil
                                               successBlock:^(NSArray *contacts, NSError *err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];

                if (err) {
                    [self showErrorAlert:err];
                } else if (contacts.count == 0) {
                    [self showNoContactsMessage];
                } else {
                    self.contacts = contacts;
                    [self.tableView reloadData];
                }
            });
        }];
    }];
}
```

### 4. Optimize for Performance

```objective-c
// Cache contacts to avoid repeated loading
@property (nonatomic, strong) NSArray<APContact *> *cachedContacts;
@property (nonatomic, strong) NSDate *lastLoadTime;

- (void)loadContactsIfNeeded {
    NSTimeInterval cacheTimeout = 300; // 5 minutes

    if (self.cachedContacts &&
        [[NSDate date] timeIntervalSinceDate:self.lastLoadTime] < cacheTimeout) {
        // Use cached data
        [self displayContacts:self.cachedContacts];
        return;
    }

    // Load fresh data
    [self loadContacts];
}
```

### 5. Clean Up Resources

```objective-c
@implementation ContactsViewController

- (void)dealloc {
    // Clean up if needed
    self.addressBookService = nil;
    self.contacts = nil;
}

@end
```

## Troubleshooting

### Permission Issues

**Problem**: Contacts permission keeps being denied.

**Solution**: Check your Info.plist includes `NSContactsUsageDescription`:
```xml
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts</string>
```

### No Contacts Returned

**Problem**: `loadContactsWithSearchText:` returns empty array.

**Possible causes**:
1. No contacts in the device's address book
2. All contacts lack phone numbers (library filters these out)
3. Search text too specific

**Solution**:
```objective-c
[service loadContactsWithSearchText:nil successBlock:^(NSArray *contacts, NSError *err) {
    if (contacts.count == 0) {
        NSLog(@"No contacts with phone numbers found");
    }
}];
```

### UI Not Updating

**Problem**: Table view doesn't refresh after loading contacts.

**Solution**: Ensure UI updates happen on main thread:
```objective-c
dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
});
```

### Memory Warnings

**Problem**: App receives memory warnings with large contact lists.

**Solution**: Implement pagination or use `@autoreleasepool`:
```objective-c
@autoreleasepool {
    for (APContact *contact in largeContactArray) {
        // Process contact
    }
}
```

### Chinese Names Not Sorting Correctly

**Problem**: Chinese contacts not sorted by pinyin.

**Solution**: Initialize service with Chinese language:
```objective-c
LWAddressBookService *service =
    [LWAddressBookService serviceWithPrimaryLanguage:@"zh-Hans"];
```

## Migration Guide

### From Direct APAddressBook Usage

If you're currently using APAddressBook directly, migrating to LWContactManager is straightforward:

**Before (APAddressBook):**
```objective-c
APAddressBook *addressBook = [[APAddressBook alloc] init];
[addressBook loadContacts:^(NSArray *contacts, NSError *error) {
    // Handle contacts
}];
```

**After (LWContactManager):**
```objective-c
LWAddressBookService *service = [[LWAddressBookService alloc] init];
[service requestAccess:^(BOOL granted, NSError *error) {
    if (granted) {
        [service loadContactsWithSearchText:nil
                               successBlock:^(NSArray *contacts, NSError *err) {
            // Handle contacts
        }];
    }
}];
```

**Benefits of migration:**
- Automatic permission handling
- Built-in search functionality
- Chinese pinyin sorting
- Cleaner API
- Better error handling

## FAQ

**Q: Does LWContactManager work with iOS 13+?**
A: Yes, while built for iOS 8+, it works perfectly with modern iOS versions including iOS 13 and later.

**Q: Can I access contacts without phone numbers?**
A: Currently, the library filters out contacts without phone numbers. This is by design to focus on callable contacts. You can modify the source if you need all contacts.

**Q: Is the library Swift-compatible?**
A: Yes, LWContactManager is fully compatible with Swift projects through Objective-C bridging.

**Q: How do I customize the sorting order?**
A: Use the `serviceWithPrimaryLanguage:` method with different language codes to change sorting behavior.

**Q: Can I write/modify contacts?**
A: No, LWContactManager is currently read-only. For write operations, you'll need to use the Contacts framework directly.

**Q: Does it support background refresh?**
A: Contact loading happens asynchronously on background threads, but you should handle UI updates on the main thread.

## Dependencies

LWContactManager relies on the following dependency:

- **[APAddressBook](https://github.com/Alterplay/APAddressBook)** - A robust address book framework for iOS
  - Provides low-level contact access
  - Handles iOS version compatibility
  - Manages contact data models

## Contributing

Contributions are welcome! If you'd like to contribute to LWContactManager:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please ensure your code follows the existing style and includes appropriate tests.

## Author

**luowei**
- Email: luowei@wodedata.com
- GitHub: [@luowei](https://github.com/luowei)

## License

LWContactManager is available under the MIT license. See the [LICENSE](LICENSE) file for more information.

### MIT License Summary

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files, to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED.

## Acknowledgments

- Built on top of [APAddressBook](https://github.com/Alterplay/APAddressBook) by Alterplay
- Thanks to all contributors and users of this library
- Inspired by the iOS development community's need for simplified contact management

---

<div align="center">

**LWContactManager** - Making iOS contact management simple and elegant

Made with ❤️ for the iOS development community

[⬆ Back to Top](#lwcontactmanager)

</div>
