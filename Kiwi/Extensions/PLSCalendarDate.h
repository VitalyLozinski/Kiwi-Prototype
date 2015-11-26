//
//  PLSCalendarDate.h
//
//  Created by Aurélien Scelles, Georgiy Kassabli on 31/08/12.
//  Copyright (c) 2012 Playsoft. All rights reserved.
//

// used only for setting last day of the month, don't compare result to it
#define PLSLastMonthDay NSIntegerMax

#define NSCalendarUnitFullPrecision (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond)

@interface PLSCalendarDate : NSDate

- (instancetype)initWithDate:(NSDate *)date;

// Uses [NSCalendar currentCalendar] by default
+ (void)setActiveCalendar:(NSCalendar *)activeCalendar;

// All properties are NOT thread safe.
@property (nonatomic) NSInteger weekDay;
@property (nonatomic) NSInteger weekOfMonth;
@property (nonatomic) NSInteger weekOfYear;
@property (nonatomic) NSInteger day;
@property (nonatomic) NSInteger month;
@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger seconds;
@property (nonatomic) NSInteger minutes;
@property (nonatomic) NSInteger hours;

// convenience properties
@property (nonatomic) NSInteger time;
// latter can be used for comparison and calculations of units between dates
// for instance calendarDate1.monthsSinceReferenceDate == calendarDate2.monthsSinceReferenceDate
// means that dates in in the same month
@property (nonatomic) NSInteger monthsSinceReferenceDate;
@property (nonatomic) NSInteger weeksSinceReferenceDate;
@property (nonatomic) NSInteger daysSinceReferenceDate;
@property (nonatomic) CGFloat hoursSinceReferenceDate;
@property (nonatomic) CGFloat minutesSinceReferenceDate;
@property (nonatomic) CGFloat secondsSinceReferenceDate;

@end

@interface NSDate (PLSCalendarDateExtension)

- (PLSCalendarDate *)calendarDateCopy;

@end
