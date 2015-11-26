@interface ModelObject : NSObject <NSCoding>

+ (instancetype)objectWithArchivedValue:(id)value;
- (instancetype)initWithArchivedValue:(id)value;

- (void)updateFromArchivedValue:(id)value;
- (id)archivedValue;

@end
