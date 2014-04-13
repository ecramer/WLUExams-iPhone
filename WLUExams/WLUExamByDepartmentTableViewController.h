//
//  WLUExamByDepartmentTableViewController.h
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-11.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WLUDepartment;
@interface WLUExamByDepartmentTableViewController : UITableViewController

@property NSMutableData *receivedData;
@property NSURLConnection *connection;
@property WLUDepartment* department;
@property NSMutableArray *exams;
@property NSMutableArray *filteredExams;
@property BOOL isFiltered;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
