//
//  TestVC.m
//  HotspotProject
//
//  Created by Genrih Korenujenko on 27.09.17.
//  Copyright © 2017 Koreniuzhenko Henrikh. All rights reserved.
//

#import "TestVC.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface TestVC () <NSStreamDelegate, EAWiFiUnconfiguredAccessoryBrowserDelegate>
{
    EASession *session;
    NSInteger byteIndex;
    NSMutableData *data;
    
    EAWiFiUnconfiguredAccessoryBrowser *browser;
}
@end

@implementation TestVC

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self openSessionForProtocol:@"tcp"];
    
    browser = [[EAWiFiUnconfiguredAccessoryBrowser alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    [browser startSearchingForUnconfiguredAccessoriesMatchingPredicate:nil];
}

- (EASession *)openSessionForProtocol:(NSString *)protocolString
{
    id values = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];
    
    NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager]
                            connectedAccessories];
    NSLog(@"%@", accessories);
    EAAccessory *accessory = nil;
    session = nil;
    
    for (EAAccessory *obj in accessories)
    {
        if ([[obj protocolStrings] containsObject:protocolString])
        {
            accessory = obj;
            break;
        }
    }
    
    [[EAAccessoryManager sharedAccessoryManager] showBluetoothAccessoryPickerWithNameFilter:nil completion:^(NSError * _Nullable error) {
        NSArray *accessories2 = [[EAAccessoryManager sharedAccessoryManager]
                                connectedAccessories];
        
        NSLog(@"%@", accessories2);
    }];
    
    if (accessory)
    {
        session = [[EASession alloc] initWithAccessory:accessory
                                           forProtocol:protocolString];
        if (session)
        {
            [[session inputStream] setDelegate:self];
            [[session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                             forMode:NSDefaultRunLoopMode];
            [[session inputStream] open];
            [[session outputStream] setDelegate:self];
            [[session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                              forMode:NSDefaultRunLoopMode];
            [[session outputStream] open];
        }
    }
    
    return session;
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode)
    {
        case  NSStreamEventEndEncountered:
        {
            // If all data hasn't been read, fall through to the "has bytes" event
            NSData *newData = [stream propertyForKey: NSStreamDataWrittenToMemoryStreamKey];
            
            if (!newData)
            {
                NSLog(@"No data written to memory!");
            }
            else
            {
                //                [self processData:newData];
            }
        }
            break;
        case NSStreamEventHasBytesAvailable:
        {
            if (stream == session.outputStream)
            {
                // We need a semicolon here before we can declare local variables
                uint8_t *readBytes = (uint8_t *)[data mutableBytes];
                readBytes += byteIndex; // instance variable to move pointer
                NSInteger data_len = [data length];
                NSInteger len = ((data_len - byteIndex >= 1024) ? 1024 : (data_len-byteIndex));
                uint8_t buf[len];
                (void)memcpy(buf, readBytes, len);
                len = [session.outputStream write:(const uint8_t *)buf maxLength:len];
                byteIndex += len;
            }
            else
            {
                uint8_t     b;
                NSInteger   bytesRead;
                bytesRead = [session.inputStream read:&b maxLength:sizeof(uint8_t)];
                NSLog(@"%tu", bytesRead);
            }
        }
            break;
        case NSStreamEventErrorOccurred:
            // some other error
            break;
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
    }
}

- (void)accessoryBrowser:(nonnull EAWiFiUnconfiguredAccessoryBrowser *)browser didFindUnconfiguredAccessories:(nonnull NSSet<EAWiFiUnconfiguredAccessory *> *)accessories
{
    
}

- (void)accessoryBrowser:(nonnull EAWiFiUnconfiguredAccessoryBrowser *)browser didFinishConfiguringAccessory:(nonnull EAWiFiUnconfiguredAccessory *)accessory withStatus:(EAWiFiUnconfiguredAccessoryConfigurationStatus)status
{
    
}

- (void)accessoryBrowser:(nonnull EAWiFiUnconfiguredAccessoryBrowser *)browser didRemoveUnconfiguredAccessories:(nonnull NSSet<EAWiFiUnconfiguredAccessory *> *)accessories
{
    
}

- (void)accessoryBrowser:(nonnull EAWiFiUnconfiguredAccessoryBrowser *)browser didUpdateState:(EAWiFiUnconfiguredAccessoryBrowserState)state
{
    
}

@end
