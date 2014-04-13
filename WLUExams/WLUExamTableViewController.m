//
//  WLUExamTableViewController.m
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-09.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import "WLUExamTableViewController.h"
#import "WLUExam.h"
#import "WLUDetailViewController.h"

@implementation WLUExamTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.exams = [[NSMutableArray alloc] init];
    [self getExams];
    self.searchBar.delegate = (id)self;
    
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        self.isFiltered = FALSE;
        [searchBar performSelector: @selector(resignFirstResponder)
                        withObject: nil
                        afterDelay: 0.1];
    }
    else
    {
        self.isFiltered = true;
        self.filteredExams = [[NSMutableArray alloc] init];
        
        for (WLUExam *exam in self.exams)
        {
            NSRange nameRange = [exam.courseCode rangeOfString:text options:NSCaseInsensitiveSearch];
            
            if(nameRange.location != NSNotFound)
            {
                
                [self.filteredExams addObject:exam];
                
            }
        }
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowCount;
    
    if(self.isFiltered) {
        
        rowCount = self.filteredExams.count;
    
    } else {
        
        rowCount = self.exams.count;
    }
    return rowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"ExamCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    WLUExam *exam;
    
    if(self.isFiltered)
        exam = [self.filteredExams objectAtIndex:indexPath.row];
    else
        exam = [self.exams objectAtIndex:indexPath.row];
    
    NSString *courseString = [NSString stringWithFormat: @"%@ %@", [exam courseCode], [exam section]];
    cell.textLabel.text = courseString;
    return cell;
    
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showExamDetail"]){
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WLUExam *exam;
        if (self.isFiltered){
            
            exam = self.filteredExams[indexPath.row];
            
        } else {
            
            exam = self.exams[indexPath.row];
            
        }
        
        [[segue destinationViewController] setExam:exam];
        
    }
    
}

- (void)getExams {
    
    NSString *link = @"http://hopper.wlu.ca/~cram8680/php/Exams/list.php";
    
    _receivedData = [NSMutableData dataWithCapacity: 0];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    
                                    requestWithURL:[NSURL URLWithString:link]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod:@"POST"];
    
    
    _connection=[[NSURLConnection alloc]
                 initWithRequest:request delegate:self];
    
}

- (void)connection:(NSURLConnection
                    *)connection didReceiveResponse:
(NSURLResponse *)response {
    
    [_receivedData setLength:0];
    
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    
    [_receivedData appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error{
    
    _connection = nil; // release the connection
    _receivedData = nil;
    
    
}

- (void)connectionDidFinishLoading:
(NSURLConnection *)connection
{
    [self parseJSON];
    _connection = nil;
    _receivedData = nil;
    
}

- (void) parseJSON {
    
    
    NSError *jsonError = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:_receivedData options:kNilOptions error:&jsonError];
    
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        
        NSArray *jsonArray = (NSArray *)jsonObject;
        for(NSDictionary *jsonDictionary in jsonArray) {
            
            WLUExam *exam = [[WLUExam alloc]init];
            
            exam.examID = [[jsonDictionary objectForKey:@"ID"]intValue];
            exam.courseCode = [jsonDictionary objectForKey:@"courseID"];
            exam.section = [jsonDictionary objectForKey:@"section"];
            exam.location = [jsonDictionary objectForKey:@"location"];
            exam.room = [jsonDictionary objectForKey:@"room"];
            exam.department = [jsonDictionary objectForKey:@"depName"];
            NSString *strDate = [jsonDictionary objectForKey:@"date"];
            NSString *strTime = [jsonDictionary objectForKey:@"time"];
            
            NSString *strDateTime = [[NSString alloc] initWithFormat:@"%@ %@", strDate, strTime];
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
            
            exam.date = [formatter dateFromString:strDateTime];
            
            if (![exam.location isEqualToString:@"Online"]){
                
                exam.latitude = [[jsonDictionary objectForKey:@"lat"]floatValue];
                exam.longitude = [[jsonDictionary objectForKey:@"long"]floatValue];
                
            }
            
            [self.exams addObject:exam];
            
        }
        
        [self.tableView reloadData];
        
        
    }
    
}



-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.searchBar resignFirstResponder];
    
}



@end
