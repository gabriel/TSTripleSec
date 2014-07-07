//
//  P3SKBTest.m
//

#import <GHUnit/GHUnit.h>

#import "P3SKB.h"
#import <NAChloride/NAChloride.h>
#import <MPMessagePack/MPMessagePack.h>

@interface P3SKBTest : GHTestCase
@end

@implementation P3SKBTest

- (void)test {
  NSData *key = [@"deadbeef" na_dataFromHexString];
  P3SKB *privateKey = [P3SKB P3SKBWithKey:key password:@"toomanysecrets" error:nil];
  GHAssertNotNil(privateKey, nil);
  
  NSDictionary *dict = [MPMessagePackReader readData:[privateKey data]];
  
  GHTestLog(@"P3SKB: %@", dict);
}

@end