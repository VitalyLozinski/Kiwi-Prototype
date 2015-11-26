//
//  PLSCalendarDate.m
//
//  Created by Aurélien Scelles, Georgiy Kassabli on 31/08/12.
//  Copyright (c) 2012 Playsoft. All rights reserved.
//

#import "PLSCalendarDate.h"

@implementation NSDate (PLSCalendarDateExtension)

- (PLSCalendarDate *)calendarDateCopy
{
    return [PLSCalendarDate dateWithTimeIntervalSinceReferenceDate:self.timeIntervalSinceReferenceDate];
}

@end

@implementation PLSCalendarDate {
    NSDate *_date;
}

#pragma mark - class setup

static NSCalendar *sActiveCalendar;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sActiveCalendar = [NSCalendar currentCalendar];
    });
}

+ (void)setActiveCalendar:(NSCalendar *)activeCalendar
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sActiveCalendar = activeCalendar;        
    });
}

#pragma mark - lifecycle methods

- (instancetype)initWithDate:(NSDate *)date
{
    self = [self initWithTimeIntervalSinceReferenceDate:date.timeIntervalSinceReferenceDate];
    return self;
}

#pragma mark - primitives override

- (instancetype)initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)ti
{
    if (self = [super init]) {
        _date = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:ti];
    }
    return self;
}

- (NSTimeInterval)timeIntervalSinceReferenceDate
{
    return [_date timeIntervalSinceReferenceDate];
}

- (id)copyWithZone:(NSZone *)zone
{
    PLSCalendarDate *result = [PLSCalendarDate new];
    result->_date = [_date copy];
    return result;
}

#pragma mark - public interface

- (NSInteger)weekDay
{
    return [sActiveCalendar components:NSCalendarUnitWeekday fromDate:_date].weekday;
}

- (void)setWeekDay:(NSInteger)weekDay
{
    NSDateComponents *dateComponents = [sActiveCalendar components:(NSCalendarUnitFullPrecision ^ NSCalendarUnitDay) | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth fromDate:_date];
    dateComponents.weekday = weekDay;
    _date = [sActiveCalendar dateFromComponents:dateComponents];
}

- (NSInteger)weekOfMonth
{
    return [sActiveCalendar components:NSCalendarUnitWeekOfMonth fromDate:_date].weekOfMonth;
}

- (void)setWeekOfMonth:(NSInteger)weekOfMonth
{
    NSDateComponents *dateComponents = [sActiveCalendar components:(NSCalendarUnitFullPrecision ^ NSCalendarUnitDay) | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth fromDate:_date];
    dateComponents.weekOfMonth = weekOfMonth;
    _date = [sActiveCalendar dateFromComponents:dateComponents];
}

- (NSInteger)weekOfYear
{
    return [sActiveCalendar components:NSCalendarUnitWeekOfYear fromDate:_date].weekOfYear;
}

- (void)setWeekOfYear:(NSInteger)weekOfYear
{
    NSDateComponents *dateComponents = [sActiveCalendar components:(NSCalendarUnitFullPrecision ^ NSCalendarUnitDay ^ NSCalendarUnitMonth) | NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:_date];
    dateComponents.weekOfYear = weekOfYear;
    _date = [sActiveCalendar dateFromComponents:dateComponents];
}

- (NSInteger)day
{
    return [sActiveCalendar components:NSCalendarUnitDay fromDate:_date].day;
}

- (void)setDay:(NSInteger)day
{
    NSDateComponents *dateComponents = [sActiveCalendar components:NSCalendarUnitFullPrecision fromDate:_date];
    if (day == PLSLastMonthDay) {
        dateComponents.month += 1;
        dateComponents.day = 0;
    } else {
        dateComponents.day = day;
    }
    _date = [sActiveCalendar dateFromComponents:dateComponents];
}

- (NSInteger)month
{
    return [sActiveCalendar components:NSCalendarUnitMonth fromDate:_date].month;
}

- (void)setMonth:(NSInteger)month
{
    NSDateComponents *dateComponents = [sActiveCalendar components:NSCalendarUnitFullPrecision fromDate:_date];
    dateComponents.month = month;
    _date = [sActiveCalendar dateFromComponents:dateComponents];
    // We need to correct date if month we used previously has more days then new
    while ((self.month % 12) != (month % 12)) {
        self.day -= 1;
    }
}

- (NSInteger)year
{
    return [sActiveCalendar components:NSCalendarUnitYear fromDate:_date].year;
}

- (void)setYear:(NSInteger)year
{
    NSDateComponents *dateComponents = [sActiveCalendar components:NSCalendarUnitFullPrecision fromDate:_date];
    dateComponents.year = year;
    _date = [sActiveCalendar dateFromComponents:dateComponents];
}

- (NSInteger)seconds
{
    return [sActiveCalendar components:NSCalendarUnitSecond fromDate:_date].second;
}

- (void)setSeconds:(NSInteger)seconds
{
    NSDateComponents *dateComponents = [sActiveCalendar components:NSCalendarUnitFullPrecision fromDate:_date];
    dateComponents.second = seconds;
    _date = [sActiveCalendar dateFromComponents:dateComponents];
}

- (NSInteger)minutes
{
    return [sActiveCalendar components:NSCalendarUnitMinute fromDate:_date].second;
}

- (void)setMinutes:(NSInteger)minutes
{
    NSDateComponents *dateComponents = [sActiveCalendar components:NSCalendarUnitFullPrecision fromDate:_date];
    dateComponents.minute = minutes;
    _date = [sActiveCalendar dateFromComponents:dateComponents];
}

- (NSInteger)hours
{
    return [sActiveCalendar components:NSCalendarUnitHour fromDate:_date].second;
}

- (void)setHours:(NSInteger)hours
{
    NSDateComponents *dateComponents = [sActiveCalendar components:NSCalendarUnitFullPrecision fromDate:_date];
    dateComponents.hour = hours;
    _date = [sActiveCalendar dateFromComponents:dateComponents];
}

- (NSInteger)time
{
    NSDateComponents *timeComponents = [sActiveCalendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:_date];
    return [sActiveCalendar dateFromComponents:timeComponents].timeIntervalSinceReferenceDate;
}

- (void)setTime:(NSInteger)time
{
    NSDateComponents *dateComponents = [sActiveCalendar components:NSCalendarUnitFullPrecision fromDate:_date];
    dateComponents.hour = 0;
    dateComponents.minute = 0;
    dateComponents.second = time;
    _date = [sActiveCalendar dateFromComponents:dateComponents];
}

- (NSInteger)monthsSinceReferenceDate
{
    return self.month + self.year * 12;
}

- (NSInteger)weeksSinceReferenceDate
{
    return self.daysSinceReferenceDate / 7;
}

- (NSInteger)daysSinceReferenceDate
{
    return self.hoursSinceReferenceDate / 24;
}

- (CGFloat)hoursSinceReferenceDate
{
    return self.minutesSinceReferenceDate / 60;
}

- (CGFloat)minutesSinceReferenceDate
{
    return self.secondsSinceReferenceDate / 60;
}

- (CGFloat)secondsSinceReferenceDate
{
    return self.timeIntervalSinceReferenceDate;
}

#pragma mark - NSCoding

- (Class)classForCoder
{
    return [self class];
}

@end
