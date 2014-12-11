//
//  P3SKBValueTransformer.m
//  TSTripleSec
//
//  Created by Gabriel on 10/8/14.
//  Copyright (c) 2014 Gabriel Handford. All rights reserved.
//

#import "P3SKBValueTransformer.h"
#import "P3SKB.h"

@implementation P3SKBValueTransformer

+ (Class)transformedValueClass {
  return [P3SKB class];
}

+ (BOOL)allowsReverseTransformation {
  return YES;
}

- (id)transformedValue:(id)value {
  if (!value) return nil;
  NSData *data = [[NSData alloc] initWithBase64EncodedData:value options:0];
  return [P3SKB P3SKBFromData:data error:nil];
}

- (id)reverseTransformedValue:(id)value {
  if (!value) return nil;
  return [[value data] base64EncodedStringWithOptions:0];
}

@end
