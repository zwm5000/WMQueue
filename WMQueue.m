//
//  WMQueue.m
//
//  Created by zengwm on 15/1/26.
//

#import "WMQueue.h"

@interface WMQueue ()

@property (nonatomic,strong) NSMutableArray *queueArray;
@property (nonatomic,strong) dispatch_queue_t queue;

@end

@implementation WMQueue

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _queueArray = [NSMutableArray array];
        _queue = dispatch_queue_create("com.imv.Queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)insertObject:(id)object
{
    if (nil == object) {
        NSAssert(object != nil, @"You can't push nil object to deque");
        return;
    }
    dispatch_barrier_async(self.queue, ^{
        [self.queueArray addObject:object];
    });
    
}

- (id)removeFirstObject
{
    __block id object = nil;
    dispatch_barrier_async(self.queue, ^{
        object = [self.queueArray objectAtIndex:0];
        [self.queueArray removeObject:object];
    });
    return object;
}

- (id)peek
{
    __block id object = nil;
    dispatch_sync(self.queue, ^{
        if (self.queueArray.count > 0) {
            object = [self.queueArray objectAtIndex:0];
        }
    });
    return object;
}

- (BOOL)isEmpty
{
    __block BOOL empty = NO;
    dispatch_sync(self.queue, ^{
        empty = (self.queueArray.count == 0);
    });
    return empty;
}

- (void)clear
{
    dispatch_barrier_async(self.queue, ^{
        [self.queueArray removeAllObjects];
    });
}

- (NSArray *)allObjectsFromQueue
{
    NSMutableArray *buffer = [@[] mutableCopy];
    dispatch_sync(self.queue, ^{
        for (id object in self.queueArray) {
            [buffer addObject:object];
        }
    });
    return [buffer copy];
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.queueArray forKey:@"queueArray"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [self init]) {
        if ([[self class] supportsSecureCoding]) {
            _queueArray = [aDecoder decodeObjectOfClass:[NSMutableArray class] forKey:@"queueArray"];
        } else {
            _queueArray = [aDecoder decodeObjectForKey:@"queueArray"];
        }
    }
    return self;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    WMQueue *queue = [[[self class] alloc] init];
    queue->_queueArray = _queueArray;
    return queue;
}

@end
