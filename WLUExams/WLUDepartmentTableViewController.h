//
//  WLUDepartmentTableViewController.h
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-09.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLUDepartmentTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSMutableArray *departments;
@property NSMutableData *receivedData;
@property NSURLConnection *connection;
@property NSMutableArray *filteredDepartments;
@property BOOL isFiltered;
@end
