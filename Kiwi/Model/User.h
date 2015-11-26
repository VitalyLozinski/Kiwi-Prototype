#import "ModelObject.h"

extern NSString * const UserDidUpdateNotification;
extern NSString * const UserDidLoginNotification;
extern NSString * const UserDidLogoutNotification;
extern NSString * const UserDidSaveDetailsNotification;
extern NSString * const UserDidSavePassNotification;
extern NSString * const UserDidSavePictureNotification;

@class Payments;

@interface User : ModelObject

@property (nonatomic, readonly) NSInteger userId;
@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) BOOL loggedIn;
@property (nonatomic, readonly) NSString *userPicUrl;
@property (nonatomic, readonly) BOOL pictureIsUploading;

@property (nonatomic, readonly) Payments *paymentInfo;

+ (instancetype)currentUser;
+ (void)archive;

- (void)loginWithEmail:(NSString *)email password:(NSString *)pass;
- (void)registerWithEmail:(NSString *)email password:(NSString *)pass;
- (void)loginWithFbToken:(NSString *)oauthToken;
- (void)loginWithTwiUsername:(NSString *)username;

- (void)logout;

- (void)setEmail:(NSString *)email name:(NSString *)name lastName:(NSString *)lastName password:(NSString *)oldPass;
- (void)changePassword:(NSString *)oldPass newPassword:(NSString *)newPass;

- (void)update;
- (void)uploadPhoto:(UIImage *)photo;

@end
