//
//  JasonTimedAction.m
//  Finalsite
//
//  Created by Kevin Spain on 6/17/19.
//  Copyright © 2019 Jasonette. All rights reserved.
//

#import "JasonTimedAction.h"
#import "JasonOptionHelper.h"

@implementation JasonTimedAction

    // $timed.refresh
    -(void)refresh {
        // setup the dateFormat to properly parse the load_time from the server
        NSDateFormatter* dateformat = [[NSDateFormatter alloc]init];
        [dateformat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        // need to include the server timezone so that the NSDate can properly find timeIntervalSinceNow
        [dateformat setTimeZone:[NSTimeZone timeZoneWithName:self.options[@"time_zone"][@"name"]]];

        NSDate* loadTime = [dateformat dateFromString: self.options[@"load_time"]];
        // timeIntervalSinceNow returns a float of seconds since now the current date is
        // so we multiply our minutes by 60 seconds
        float frequency = (60 * [self.options[@"frequency"] floatValue]);
        // loadTime is before now, so timeIntervalSinceNow will be negative and we invert it
        if (-[loadTime timeIntervalSinceNow] > frequency) {
            [[Jason client] reload];
        } else {
            // Properly continue to success actions after this one
            JasonMemory *memory = [JasonMemory client];
            NSDictionary *caller = memory._caller;

            // 1. propagate the memory._register to the next action
            // 2. set the stack with the caller's success action
            if(caller[@"success"]){
                if(self.options) {
                    [[Jason client] call: caller[@"success"] with:@{@"$jason": self.options}];
                } else {
                    [[Jason client] call: caller[@"success"] with:@{@"$jason": @{}}];
                }
            }
            [[Jason client] finish];
        }
    }

@end
