//
//  PrettyDatePicker.h
//  AstridiPhone
//
//  Created by Joshua Gross on 6/27/11.
//  Copyright 2011 Todoroo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/NSDate.h>

@interface PrettyDatePicker : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource> {
    NSDate *currentDate;
    NSInteger compFlags;
    NSCalendar *cal;// = [NSCalendar currentCalendar];
    NSDateComponents* comps;// = [cal components:compFlags fromDate:currentDate];
    NSDateComponents* compsToday;// = [cal components:compFlags fromDate:[NSDate date]];

    NSArray *monthArray;
}

-(void) setDate:(NSDate*)date;
-(NSDate*) date;

@end
