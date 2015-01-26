//
//  WMQueue.h
//
//  Created by zengwm on 15/1/26.
//

#import <Foundation/Foundation.h>

@interface WMQueue : NSObject<NSSecureCoding,NSCopying>

- (void)insertObject:(id)object;
- (id)removeFirstObject;
- (id)peek;
- (BOOL)isEmpty;
- (void)clear;
- (NSArray *)allObjectsFromQueue;

@end
