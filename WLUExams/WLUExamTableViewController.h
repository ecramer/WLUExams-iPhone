//
//  WLUExamTableViewController.h
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-09.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLUExamTableViewController : UITableViewController

@property NSMutableArray *exams;
@property NSMutableData *receivedData;
@property NSURLConnection *connection;
@property (strong, nonatomic) NSMutableArray *filteredExams;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property BOOL isFiltered;
@end
