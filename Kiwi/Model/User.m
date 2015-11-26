#import "User.h"

#import "ServerRequestQueue.h"

#import "NSString+Utilities.h"
#import "UIImage+Http.h"

#import "Payments.h"

NSString * const UserDidUpdateNotification = @"UserDidUpdateNotification";
NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";
NSString * const UserDidSavePassNotification = @"UserDidSavePassNotification";
NSString * const UserDidSaveDetailsNotification = @"UserDidSaveDetailsNotification";
NSString * const UserDidSavePictureNotification = @"UserDidSavePictureNotification";

#define SALT_HASH @"DarthVader"

@implementation User
{
	BOOL _updating;
}

+ (instancetype)currentUser
{
	static User *sCurrentUser = nil;
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
	    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUser"];
	    if (userData)
        {
	        sCurrentUser = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
		}
	    else
        {
	        sCurrentUser = [User new];
		}
	});
	return sCurrentUser;
}

+ (void)archive
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[self currentUser]] forKey:@"currentUser"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (instancetype)init
{
    if (self = [super init]) {
        _paymentInfo = [Payments new];
    }
    return self;
}

#pragma mark - login methods

- (void)loginWithEmail:(NSString *)email password:(NSString *)pass
{
#ifdef DEBUG
    if (email.length == 0 && pass.length == 0)
    {
        email = @"1";
        pass = @"1";
    }
#endif
    [self requestTokenWithEmail:email password:pass login:YES];
}

- (void)registerWithEmail:(NSString *)email password:(NSString *)pass
{
    [self requestTokenWithEmail:email password:pass login:NO];
}

- (void)loginWithFbToken:(NSString *)oauthToken
{
    NSMutableDictionary *tokenDict = [NSMutableDictionary new];
    tokenDict[@"access_token"] = oauthToken;
    tokenDict[@"log_type"] = @"fb";
    [self requestTokenWithDict:tokenDict login:YES];
}

- (void)loginWithTwiUsername:(NSString *)username
{
    NSMutableDictionary *tokenDict = [NSMutableDictionary new];
    tokenDict[@"service_id"] = username;
    tokenDict[@"log_type"] = @"tw";
    [self requestTokenWithDict:tokenDict login:YES];
}

- (void)requestTokenWithEmail:(NSString *)email password:(NSString *)password login:(BOOL)login
{
    NSString *computedHash = [[NSString stringWithFormat:@"%@%@", password, SALT_HASH] SHAHash];
    NSMutableDictionary *tokenDict = [NSMutableDictionary new];
    NSString *typeKey = login ? @"log_type" : @"reg_type";
    tokenDict[typeKey] = @"mail";
    tokenDict[@"pass_hash"] = computedHash;
    tokenDict[@"email"] = email;
    [self requestTokenWithDict:tokenDict login:login];
}

- (void)requestTokenWithDict:(NSMutableDictionary *)dict login:(BOOL)login
{
    dict[@"device_UUID"] = [[UIDevice currentDevice].identifierForVendor UUIDString];
    ServerLink requestLink = login ? ServerLinkLogin : ServerLinkRegister;
    
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:requestLink withBodyDict:dict completionHandler: ^(id result, NSError *error)
    {
        NSDictionary * userInfo = nil;
        if (error)
        {
            userInfo = @{ @"error" : error };
            _loggedIn = NO;
        }
        else
        {
            _loggedIn = YES;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:self userInfo:userInfo];
        [self update];
    }];
}

- (void)logout
{
    _loggedIn = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:self userInfo:nil];
}

#pragma mark - public methods

- (void)update
{
	if (_updating)
    {
        return;
    }
    
    _updating = YES;
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:ServerLinkGetProfile withBodyDict:@{} completionHandler: ^(id result, NSError *error)
    {
        NSDictionary *userInfo = nil;
        if (!error)
        {
            [self updateFromArchivedValue:result];
        }
        else
        {
            userInfo = @{ @"error": error };
        }
        _updating = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidUpdateNotification object:self userInfo:userInfo];
    }];
}

- (void)uploadPhoto:(UIImage *)photo
{
    if (!_pictureIsUploading) {
        _pictureIsUploading = YES;
        [[ServerRequestQueue defaultQueue] addServerRequestForLink:ServerLinkUploadProfilePicture withBodyDict:@{@"photo_type":@"jpg", @"photo":[photo base64EncodedJpegWithQuality:0.1]} completionHandler:^(id result, NSError *error) {
            _pictureIsUploading = NO;
            NSDictionary *userInfo = nil;
            if (error) {
                userInfo = @{@"error": error};
            } else {
                [self update];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:UserDidSavePictureNotification object:self userInfo:userInfo];
        }];
    }
}

- (void)setEmail:(NSString *)email name:(NSString *)name lastName:(NSString *)lastName password:(NSString *)oldPass
{
    NSMutableDictionary *bodyDict = [NSMutableDictionary new];
    if (name) {
        bodyDict[@"name"] = name;
        _userName = name;
    }
    if (lastName) {
        bodyDict[@"lastname"] = lastName;
        _lastName = lastName;
    }
    if (email) {
        bodyDict[@"email"] = email;
        _email = email;
    }
    bodyDict[@"passhash"] = [[NSString stringWithFormat:@"%@%@", oldPass, SALT_HASH] SHAHash];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidUpdateNotification object:self userInfo:nil];
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:ServerLinkSaveProfile withBodyDict:bodyDict completionHandler: ^(id result, NSError *error) {
        NSDictionary *ntfInfo = nil;
        if (error) {
            ntfInfo = @{@"error": error};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidSaveDetailsNotification object:self userInfo:ntfInfo];
    }];
}

- (void)changePassword:(NSString *)oldPass newPassword:(NSString *)newPass
{
    NSString *oldPassHash = [[NSString stringWithFormat:@"%@%@", oldPass, SALT_HASH] SHAHash];
    NSString *newPassHash = [[NSString stringWithFormat:@"%@%@", newPass, SALT_HASH] SHAHash];
    [[ServerRequestQueue defaultQueue] addServerRequestForLink:ServerLinkChangePassword withBodyDict:@{@"oldpass": oldPassHash, @"newpass":newPassHash} completionHandler: ^(id result, NSError *error) {
        NSDictionary *ntfInfo = nil;
        if (error) {
            ntfInfo = @{@"error": error};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidSavePassNotification object:self userInfo:ntfInfo];
    }];
}

- (NSString *)fullName
{
    return [[NSString stringWithFormat:@"%@ %@", _userName, _lastName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark - (de)serialization

- (void)updateFromArchivedValue:(id)value
{
    [super updateFromArchivedValue:value];
    if ([value isKindOfClass:[NSDictionary class]]) {
        _email = value[@"email"];
        _userName = value[@"name"];
        _lastName = value[@"lastname"];
        _userPicUrl = value[@"photo"];
        if (![_userPicUrl isKindOfClass:[NSString class]]) {
            _userPicUrl = nil;
        }
    }
}

@end
