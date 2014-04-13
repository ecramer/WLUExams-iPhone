//
//  WLUExam.h
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-09.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLUExam : NSObject

@property int examID;
@property NSString *courseCode;
@property NSString *section;
@property NSString *location;
@property NSString *room;
@property float longitude;
@property float latitude;
@property NSDate *date;
@property NSString *department;

@end
