//
//  PrettyDatePicker.m
//  AstridiPhone
//
//  Created by Joshua Gross on 6/27/11.
//  Copyright 2011 Todoroo. All rights reserved.
//

#import "PrettyDatePicker.h"

@implementation PrettyDatePicker

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    
    currentDate = [[NSDate date] retain];
    cal = [[NSCalendar currentCalendar] retain];
    compFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    comps = [[cal components:compFlags fromDate:currentDate] retain];
    [comps setHour:23];
    [comps setMinute:59];
    [comps setSecond:59];
    compsToday = [[cal components:compFlags fromDate:[NSDate date]] retain];
    [compsToday setHour:23];
    [compsToday setMinute:59];
    [compsToday setSecond:59];
    
    monthArray = [[NSArray arrayWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec", nil] retain];
    
    [self setDelegate:self];
    [self setDataSource:self];
    [self setShowsSelectionIndicator:YES];

    return self;
}

-(void) dealloc {
    [currentDate release];
    [monthArray release];
    [cal release];
    [compsToday release];
    [comps release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
   
    // Release any cached data, images, etc that aren't in use.
}

-(NSInteger)numberOfDaysInMonth {
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit
                              inUnit:NSMonthCalendarUnit
                             forDate:[cal dateFromComponents:comps]];
    return range.length;
}

#pragma mark - UIPickerViewDelegate
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0 || component == 2) {
        return pickerView.frame.size.width * 0.3;
    }
    return pickerView.frame.size.width * 0.4;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component == 0){
        return 12;
    } else if(component == 1) {
        return [self numberOfDaysInMonth];
    } else {
        return 21;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *title;
    
    if(component == 0) {
        title = [monthArray objectAtIndex:row];
    } else if (component == 1) {
        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormat setDateFormat:@"d (EEE)"];
        NSInteger day = [comps day];
        [comps setDay:row+1];
        NSInteger timeInterval = [[cal dateFromComponents:comps] timeIntervalSinceDate:[cal dateFromComponents:compsToday]];
        
        if (timeInterval == 0) {
            title = @"Today";
        } else if (timeInterval > 0 && timeInterval <= (60*60*24*1)) {
            title = @"Tomorrow";
        } else if (timeInterval >= -(60*60*24*1) && timeInterval < 0) {
            title = @"Yesterday";
        } else if (timeInterval >= (60*60*24*1) && timeInterval <= (60*60*24*5)) {
            title = [dateFormat stringFromDate:[cal dateFromComponents:comps]];
        } else {
            title = [NSString stringWithFormat:@"%d", row+1];
        }
        [comps setDay:day];

    } else {
        title = [NSString stringWithFormat:@"%d", [compsToday year]-2+row];
    }
    return title;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        NSInteger oldMonth = [comps month];
        NSInteger lastRowForPrevMonth = [self numberOfDaysInMonth]-1;
        [comps setMonth:row+1];
        NSInteger lastRowForCurrMonth = [self numberOfDaysInMonth]-1;
        
        // If we are moving away from today's month,
        // move to the last day of the month (if moving to prev month)
        // or first day of the month (if moving to next month)
        BOOL fromThisMonth = (oldMonth == [compsToday month]);
        if (fromThisMonth && [comps month] < [compsToday month] && [comps day] <= 15) {
            [self reloadAllComponents];
            [self selectRow:lastRowForCurrMonth inComponent:1 animated:YES];
        } else if (fromThisMonth && [comps month] > [compsToday month] && [comps day] >= 15) {
            [self reloadAllComponents];
            [self selectRow:0 inComponent:1 animated:YES];
        } else if ([comps day] == lastRowForPrevMonth+1) {
            // select last day of current month (if we change from 30 to 31, 31 to 28 days, etc)
            [self reloadAllComponents];
            [self selectRow:lastRowForCurrMonth inComponent:1 animated:YES];
        }
    } else if (component == 1) {
        [comps setDay:row+1];
    } else {
        [comps setYear:[compsToday year]-2+row];
    }

    currentDate = [[cal dateFromComponents:comps] retain];
    NSLog(@"moved to %@", currentDate);
    
    // Reload pickers so that today/yesterday are updated
    if (component != 1) {
        [self reloadAllComponents];
    }
}




#pragma mark - View lifecycle

- (void)viewDidLoad
{
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) setDate:(NSDate*)date {
    [currentDate release];
    currentDate = [date retain];
    comps = [[cal components:compFlags fromDate:currentDate] retain];
    [comps setHour:23];
    [comps setMinute:59];
    [comps setSecond:59];

    [self reloadAllComponents];
    NSLog(@"Selected %d %d %d %d", [comps month], [comps day], [comps year], [comps year] - [compsToday year]-1);
    [self selectRow:[comps year]-[compsToday year]+2 inComponent:2 animated:YES];
    [self selectRow:[comps month]-1 inComponent:0 animated:YES];
    [self selectRow:[comps day]-1 inComponent:1 animated:YES];
}
-(NSDate*) date {
    return currentDate;
}

@end
