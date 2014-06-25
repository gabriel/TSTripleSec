TripleSec
===========

Objective-C implementation for [TripleSec](https://keybase.io/triplesec)

# Install

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects.

## Podfile

```ruby
platform :ios, "7.0"
pod "TripleSec"
```

# TripleSec

```objc
#import <TSTripleSec/TSTripleSec.h>

NSError *error = nil;
NSData *message = [@"this is a secret message" dataUsingEncoding:NSUTF8StringEncoding];
NSData *key = [@"toomanysecrets" dataUsingEncoding:NSUTF8StringEncoding];

TSTripleSec *tripleSec = [[TSTripleSec alloc] init];
NSData *encrypted = [tripleSec encrypt:message key:key error:&error];

NSData *decrypted = [tripleSec decrypt:encrypted key:key error:&error];
```
