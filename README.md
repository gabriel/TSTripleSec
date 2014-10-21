TSTripleSec
===========

Objective-C implementation for [TripleSec](https://keybase.io/triplesec). 

TripleSec is a triple-paranoid symmetric encryption so that a failure in one or two ciphers won't comprimise the data.

See [gabriel/NAChloride](https://github.com/gabriel/NAChloride) for more details on crypto implementations used here.

TSTripleSec uses [gabriel/GRUnit](https://github.com/gabriel/GRUnit) for unit testing.

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

[P3SKB](https://keybase.io/docs/api/1.0/p3skb_format) is a format for storing encrypted keys.

```objc
NSData *privateKey = ...;
NSData *publicKey = ...;
P3SKB *key = [P3SKB P3SKBWithPrivateKey:privateKey password:@"toomanysecrets" publicKey:publicKey error:&error];

// Create from serialized data
P3SKB *key = [P3SKB P3SKBFromData:keyData error:&error];
```
