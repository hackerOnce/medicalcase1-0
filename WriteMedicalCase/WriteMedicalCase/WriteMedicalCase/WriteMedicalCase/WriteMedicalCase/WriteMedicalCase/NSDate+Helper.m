//
//  NSDate+Helper.m
//  MedicalCase
//
//  Created by ihefe-JF on 15/4/16.
//  Copyright (c) 2015年 ihefe. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

///得到当前系统时间
-(NSDate*)getSystemCurrentTime
{
    NSDate *newDate = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSTimeInterval interval = [zone secondsFromGMTForDate:newDate];
    NSDate *localDate = [newDate dateByAddingTimeInterval:interval];

    return localDate;
}
-(NSString*)getYearAndMonthWithDateStr:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    
    NSString *dateStr = [formatter stringFromDate:date];
    
    NSLog(@"date : %@",dateStr);
    
    return dateStr;
}
-(NSString*)getDayWithDateStr:(NSDate*)date
{
    NSString *dayStr ;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    
    dayStr = [formatter stringFromDate:date];
    return dayStr;
}
-(NSString*)getMonthWithDateStr:(NSDate*)date
{
    NSString *monthStr ;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE"];
    //[formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    monthStr = [formatter stringFromDate:date];
    return monthStr;
}

-(NSString*)YearAndMonthWithDate:(NSDate*)transformDate
{
    NSString *YearAndMonthSTring;
    
    
    
    return YearAndMonthSTring;
}
@end
