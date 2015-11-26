#import "Event.h"

#import "PLSCalendarDate.h"

#import "ServerRequestQueue.h"
#import "Conventions.h"

NSString * const EventDidUpdateNotification = @"EventDidUpdateNotification";
NSString * const EventBookDidFailNotification = @"EventBookDidFailNotification";
NSString * const EventBookDidFinishNotification = @"EventBookDidFinishNotification";
NSString * const EventCancelDidFailNotification = @"EventCancelDidFailNotification";
NSString * const EventCancelDidFinishNotification = @"EventCancelDidFinishNotification";
NSString * const EventRatingSaveDidFailNotification = @"EventRatingSaveDidFailNotification";
NSString * const EventRatingSaveDidFinishNotification = @"EventRatingSaveDidFinishNotification";

@implementation EventTypeObject

-(id)initWith:(EventType)type
{
    self = [super init];
    if (self)
    {
        _type = type;
    }
    return self;
}

@end

@implementation Event {
    NSString *_detailsId;
}

- (BOOL)valid
{
    return _eventname && _eventname.length > 0;
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", _name, _lastname];
}

- (NSString *)shortName
{
    if (_lastname.length == 0)
        return _name;
    return [NSString stringWithFormat:@"%@ %@.", _name, [_lastname substringToIndex:1]];
}

-(NSString*)ratedPref
{
    return [NSString stringWithFormat:@"event_%@_rated", _detailsId];
}

-(BOOL)rated
{
    if (_myRating > 0)
        return YES;
    
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    return ([prefs integerForKey:[self ratedPref]] != 0);
}

-(void)setRated:(BOOL)r
{
    NSString * pref = [self ratedPref];
    Trace(@"Saving event %@ as rated to %@", self.eventname, pref);
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:(r ? 1 : 0) forKey:pref];
    [prefs synchronize];
}

#pragma mark - server request/responses

static NSDateFormatter *eventDateFormatter;

@synthesize description = _description;

- (void)updateFromArchivedValue:(id)value
{
    if ([value isKindOfClass:[NSDictionary class]])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            eventDateFormatter = [NSDateFormatter new];
            eventDateFormatter.dateFormat = ModelDateTimeFormat;
            eventDateFormatter.timeZone = [NSTimeZone timeZoneWithName:ModelTimeZone];
        });
        
        _detailsId = [value objectForKey:@"eventdetail_id"];
        _photoUrlStr = value[@"photo"];
        if (!_photoUrlStr || [_photoUrlStr isKindOfClass:[NSNull class]])
            _photoUrlStr = @"";
        
        _eventname = [value objectForKey:@"eventname"];
        if (!_eventname || [_eventname isKindOfClass:[NSNull class]])
            _eventname = @"";
        
        _description = [value objectForKey:@"description"];
        if (!_description || [_description isKindOfClass:[NSNull class]])
            _description = @"";
        
        _type = (EventType)[[value objectForKey:@"id_eventtype"] intValue];
        _myRating = (EventType)[[value objectForKey:@"my_rating"] intValue];
        _votesCount = (EventType)[[value objectForKey:@"count_rating"] intValue];
        
        float latitude = [[value objectForKey:@"latitude"] floatValue];
        float longitude = [[value objectForKey:@"longitude"] floatValue];
        _location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        _address = [value objectForKey:@"location"];
        if (!_address || [_address isKindOfClass:[NSNull class]])
            _address = @"";
        
        NSString *startStr = value[@"start"];
        _start = [[eventDateFormatter dateFromString:startStr] calendarDateCopy];
        
        _showRating = ([[value objectForKey:@"show_rating"] integerValue] != 0);

        _rating = [[value objectForKey:@"avg_rating"] floatValue];
        _price = [[value objectForKey:@"price"] floatValue];
        _freeSeats = [[value objectForKey:@"freeseats"] intValue];
        _totalSeats = [[value objectForKey:@"seats"] intValue];
        
        _name = [value objectForKey:@"name"];
        if (!_name || [_name isKindOfClass:[NSNull class]])
            _name = @"";

        _lastname = [value objectForKey:@"lastname"];
        if (!_lastname || [_lastname isKindOfClass:[NSNull class]])
            _lastname = @"";

        _profileTitle = [value objectForKey:@"profile_title"];
        if (!_profileTitle || [_profileTitle isKindOfClass:[NSNull class]])
            _profileTitle = @"";

        _profile = [value objectForKey:@"profile"];
        if (!_profile || [_profile isKindOfClass:[NSNull class]])
            _profile = @"";

        _passImage = -1;
        _passColor = -1;
        _finished = NO;
        _booked = NO;
        _canceled = NO;
        
        id bookingStatus = [value objectForKey:@"booking_status"];
        id booked = [value objectForKey:@"booked"];
        
        if (bookingStatus &&
            [bookingStatus isKindOfClass:[NSString class]])
        {
            if ([(NSString*)bookingStatus isEqualToString:@"finished"])
            {
                _booked = YES;
                _finished = YES;
            }
            else if ([(NSString*)bookingStatus isEqualToString:@"canceled"])
            {
                _booked = NO;
                _canceled = YES;
            }
        }
        else
        {
            if ([booked integerValue])
            {
                _booked = YES;
                _passImage = [[value objectForKey:@"ornament"] integerValue];
                _passColor = [[value objectForKey:@"icon_color"] integerValue];
            }
        }
    }
}

- (void)updateFor:(NSString*)detailId
{
    _detailsId = detailId;
    [self update];
}

- (void)update
{
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:ServerLinkEventDetails withBodyDict:@{@"id": _detailsId} completionHandler: ^(id result, NSError *error) {
        NSDictionary *userInfo = nil;
        if (error) {
            userInfo = @{@"error": error};
        } else {
            [self updateFromArchivedValue:result];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:EventDidUpdateNotification object:self userInfo:userInfo];
    }];
}

- (void)book:(NSDictionary *)paymentInfo
{
    ServerLink serverLink = ServerLinkCardUseCard;
    [paymentInfo setValue:_detailsId forKey:@"eventdetail_id"];
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:serverLink withBodyDict:paymentInfo completionHandler: ^(id result, NSError *error)
    {
        if (error)
        {
            NSDictionary *userInfo = @{@"error" : error };
            [[NSNotificationCenter defaultCenter] postNotificationName:EventBookDidFailNotification object:self userInfo:userInfo];
        }
        else
        {
            _booked = YES;
            NSDictionary *userInfo = @{};
            [[NSNotificationCenter defaultCenter] postNotificationName:EventBookDidFinishNotification object:self userInfo:userInfo];
        }
    }];
}

-(void)cancel
{
    ServerLink serverLink = ServerLinkEventCancel;
    NSDictionary * args = @{ @"eventdetail_id" : _detailsId };
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:serverLink withBodyDict:args completionHandler: ^(id result, NSError *error)
     {
         if (error)
         {
             NSDictionary *userInfo = @{@"error" : error };
             [[NSNotificationCenter defaultCenter] postNotificationName:EventCancelDidFailNotification object:self userInfo:userInfo];
         }
         else
         {
             _booked = NO;
             NSDictionary *userInfo = @{};
             [[NSNotificationCenter defaultCenter] postNotificationName:EventCancelDidFinishNotification object:self userInfo:userInfo];
         }
     }];
}

- (void)rate:(NSInteger)stars
{
    [self rate:stars comment:@""];
}

- (void)rate:(NSInteger)stars comment:(NSString*)text
{
    ServerLink serverLink = ServerLinkEventSaveRating;
    NSDictionary * args;
    if (text.length > 0)
    {
        args = @{ @"eventdetail_id" : _detailsId,
                  @"rating" : [NSString stringWithFormat:@"%li", (long)stars],
                  @"comment" : text };
    }
    else
    {
        args = @{ @"eventdetail_id" : _detailsId,
                  @"rating" : [NSString stringWithFormat:@"%li", (long)stars] };
    }
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:serverLink withBodyDict:args completionHandler: ^(id result, NSError *error)
     {
         if (error)
         {
             NSDictionary *userInfo = @{@"error" : error };
             [[NSNotificationCenter defaultCenter] postNotificationName:EventRatingSaveDidFailNotification object:self userInfo:userInfo];
         }
         else
         {
             NSDictionary *userInfo = @{};
             [[NSNotificationCenter defaultCenter] postNotificationName:EventRatingSaveDidFinishNotification object:self userInfo:userInfo];
         }
     }];
}

-(NSString*)startString
{
    static NSDateFormatter *sDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sDateFormatter = [NSDateFormatter new];
        sDateFormatter.dateFormat = ViewDateTimeFormat;
    });

    return [sDateFormatter stringFromDate:self.start];
}

@end
