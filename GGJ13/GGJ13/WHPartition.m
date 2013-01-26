//
//  Partition.m
//  GGJ13
//
//  Created by noliv on 25/01/13.
//
//

#import "WHPartition.h"

@implementation WHPartition
{
    int _currentItem;
}

-(float)nextItemTimestamp
{
    float result = 0.0;
    if (_currentItem < [self.array count])
    {
        NSArray *a = [self.array objectAtIndex:_currentItem];
        NSNumber *nb = [a objectAtIndex:0];
        result = [nb floatValue];
    }
    return result;
}

-(int)itemLane
{
    int result = -1;
    if (_currentItem < [self.array count]) {
        NSArray *a = [self.array objectAtIndex:_currentItem];
        NSNumber *nb = [a objectAtIndex:1];
        result = [nb intValue];
    }
    return result;
}

-(void)goToNextItem
{
    _currentItem++;
}

#pragma mark NSCoding

- (id)initWithArray: (NSMutableArray *)array
{
    self = [super init];
    if (self) {
        self.array = array;
        _currentItem = 0;
    }
    return self;
}

#define kArrayKey @"Array"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.array forKey:kArrayKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSMutableArray *array = [decoder decodeObjectForKey:kArrayKey];
    return [self initWithArray:array];
}


-(void)loadData {
    NSString *dataPath = [WHPartition getPrivateDocsDir];
    // dataPath = [dataPath stringByAppendingPathComponent:@"testLecture"];
    
    dataPath = [[NSBundle mainBundle] pathForResource:@"testPart" ofType:@"plist"];
    
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:dataPath];
    
    if (codedData == nil) { /* gérer cette erreur */ };
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    self.array = [unarchiver decodeObjectForKey:kArrayKey];
    [unarchiver finishDecoding];
}


-(void)saveData {
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.array forKey:kArrayKey];
    [archiver finishEncoding];
    NSString *path = [WHPartition getPrivateDocsDir];
    path = [path stringByAppendingPathComponent:@"tarabiscotte"];
    [data writeToFile:path atomically:YES];
    
}


+ (NSString *)getPrivateDocsDir {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    return documentsDirectory;
    
}
@end
