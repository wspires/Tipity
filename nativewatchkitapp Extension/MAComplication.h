//
//  MAComplication.h
//  Tip
//
//  Created by Wade Spires on 7/9/16.
//  Copyright © 2016 Minds Aspire LLC. All rights reserved.
//

#import <WatchKit/WatchKit.h>

@import ClockKit;

@interface MAComplication : NSObject <CLKComplicationDataSource>

- (id)init;

@end
