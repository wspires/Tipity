//
//  MAComplication.m
//  Tip
//
//  Created by Wade Spires on 7/9/16.
//  Copyright © 2016 Minds Aspire LLC. All rights reserved.
//

#import "MAComplication.h"

#import "ExtensionDelegate.h"

#import "MABill.h"

NSString *ComplicationShortTextData = @"foo";

@implementation MAComplication

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

#pragma mark - CLKComplicationDataSource

// Required.
- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication
                                            withHandler:(void (^)(CLKComplicationTimeTravelDirections directions))handler
{
    handler(CLKComplicationTimeTravelDirectionNone);
}

/*
- (void)getTimelineStartDateForComplication:(CLKComplication *)complication
                                withHandler:(void (^)(NSDate *date))handler
{
    
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication
                              withHandler:(void (^)(NSDate *date))handler
{
    
}

- (void)getNextRequestedUpdateDateWithHandler:(void (^)(NSDate *updateDate))handler
{
    
}
*/

// Required.
- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication
                                   withHandler:(void (^)(CLKComplicationTimelineEntry *))handler
{
    handler(nil);

    // https://developer.apple.com/library/watchos/documentation/General/Conceptual/WatchKitProgrammingGuide/ManagingComplications.html#//apple_ref/doc/uid/TP40014969-CH28-SW1
    
    /*
    // Get the current complication data from the extension delegate.
//    ExtensionDelegate *myDelegate = (ExtensionDelegate*)[[WKExtension sharedExtension] delegate];
//    NSDictionary *data = [myDelegate.myComplicationData objectForKey:ComplicationCurrentEntry];
    
    CLKComplicationTimelineEntry *entry = nil;
    NSDate *now = [NSDate date];
    
    // Create the template and timeline entry.
    if (complication.family == CLKComplicationFamilyModularSmall)
    {
        CLKComplicationTemplateModularSmallSimpleText* textTemplate = [[CLKComplicationTemplateModularSmallSimpleText alloc] init];
        
//        NSString *text = [data objectForKey:ComplicationTextData];
//        NSString *shortText =[data objectForKey:ComplicationShortTextData];
        NSString *text = @"text";
        NSString *shortText = @"short";

        textTemplate.textProvider = [CLKSimpleTextProvider
                                     textProviderWithText:text
                                     shortText:shortText];
        
        // Create the entry.
        entry = [CLKComplicationTimelineEntry entryWithDate:now
                                       complicationTemplate:textTemplate];
    }
    else {
        // ...configure entries for other complication families.
    }
    
    // Pass the timeline entry back to ClockKit.
    handler(entry);
     */
}

/*
- (void)getTimelineEntriesForComplication:(CLKComplication *)complication
                               beforeDate:(NSDate *)date
                                    limit:(NSUInteger)limit
                              withHandler:(void (^)(NSArray<CLKComplicationTimelineEntry *> *entries))handler
{
    
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication
                                afterDate:(NSDate *)date
                                    limit:(NSUInteger)limit
                              withHandler:(void (^)(NSArray<CLKComplicationTimelineEntry *> *entries))handler
{
    
}

- (void)getTimelineAnimationBehaviorForComplication:(CLKComplication *)complication
                                        withHandler:(void (^)(CLKComplicationTimelineAnimationBehavior behavior))handler
{
    
}

- (void)requestedUpdateDidBegin
{
    
}

- (void)requestedUpdateBudgetExhausted
{
    
}
 */

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication
                                        withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler
{
    handler(nil);
}

/*
- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication
                              withHandler:(void (^)(CLKComplicationPrivacyBehavior behavior))handler
{
    
}
*/

@end
