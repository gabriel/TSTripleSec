TripleSec
===========

Objective-C implementation for [TripleSec](https://keybase.io/triplesec). 

TripleSec is a triple-paranoid symmetric encryption so that a failure in one or two ciphers won't comprimise the data.

See [gabriel/NAChloride](https://github.com/gabriel/NAChloride) for more details on crypto implementations used here.

# Install

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects.

## Podfile

```ruby
platform :ios, "7.0"
pod "TSTripleSec"
```

# TSTripleSec

```objc
#import <TSTripleSec/TSTripleSec.h>

NSError *error = nil;
NSData *message = [@"this is a secret message" dataUsingEncoding:NSUTF8StringEncoding];
NSData *key = [@"toomanysecrets" dataUsingEncoding:NSUTF8StringEncoding];

TSTripleSec *tripleSec = [[TSTripleSec alloc] init];
NSData *encrypted = [tripleSec encrypt:message key:key error:&error];

NSData *decrypted = [tripleSec decrypt:encrypted key:key error:&error];
```

# P3SKB

[P3SKB](https://keybase.io/docs/api/1.0/p3skb_format) is a new format for storing encrypted keys thats better than PGP's method.

```objc
NSData *privateKeyData = ...;
P3SKB *privateKey = [P3SKB P3SKBWithKey:privateKeyData password:@"toomanysecrets" error:&error];
```
