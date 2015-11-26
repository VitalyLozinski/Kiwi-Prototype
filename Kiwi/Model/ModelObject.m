#import "ModelObject.h"

@implementation ModelObject

+ (instancetype)objectWithArchivedValue:(id)value
{
	return [[self alloc] initWithArchivedValue:value];
}

- (instancetype)initWithArchivedValue:(id)value
{
	if (self = [self init]) {
		[self updateFromArchivedValue:value];
	}
	return self;
}

#pragma mark - NSCoding interface

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	return [self initWithArchivedValue:[aDecoder decodeObject]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:[self archivedValue]];
}

#pragma mark - public interface

- (void)updateFromArchivedValue:(id)value {
}

- (id)archivedValue {
	return @{};
}

@end
