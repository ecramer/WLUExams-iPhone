//
//  WLUDepartmentTableViewController.m
//  WLUExams
//
//  Created by Erin Cramer on 2014-04-09.
//  Copyright (c) 2014 Erin Cramer. All rights reserved.
//

#import "WLUDepartmentTableViewController.h"
#import "WLUDepartment.h"
#import "WLUExamByDepartmentTableViewController.h"


@implementation WLUDepartmentTableViewController

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
    self.departments = [[NSMutableArray alloc] init];
    [self getDepartments];
    self.searchBar.delegate = (id)self;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
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
        self.filteredDepartments = [[NSMutableArray alloc] init];
        
        for (WLUDepartment *dept in self.departments)
        {
            NSRange nameRange = [dept.name rangeOfString:text options:NSCaseInsensitiveSearch];
            
            if(nameRange.location != NSNotFound)
            {
                
                [self.filteredDepartments addObject:dept];
                
            }
        }
    }
    
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowCount;
    
    if(self.isFiltered) {
        
        rowCount = self.filteredDepartments.count;
        
    } else {
        
        rowCount = self.departments.count;
    }
    return rowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DepartmentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    WLUDepartment *department;
    
    if(self.isFiltered)
        department = [self.filteredDepartments objectAtIndex:indexPath.row];
    else
        department = [self.departments objectAtIndex:indexPath.row];
    
    NSString *departmentName = [NSString stringWithFormat: @"%@", [department name]];
    cell.textLabel.text = departmentName;
    
    return cell;

}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showDepartmentExams"]){
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        WLUDepartment *department;
        if (self.isFiltered){
            
            department = self.filteredDepartments[indexPath.row];
            
        } else {
            
            department = self.departments[indexPath.row];
            
        }
        
        [[segue destinationViewController] setDepartment:department];
        
    }
}

- (void) getDepartments {
    
    NSString *link = @"http://hopper.wlu.ca/~cram8680/php/Departments/list.php";
    
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
            
            WLUDepartment *department = [[WLUDepartment alloc]init];
            
            department.departmentID = [[jsonDictionary objectForKey:@"ID"]intValue];
            department.name = [jsonDictionary objectForKey:@"name"];
            
            [self.departments addObject:department];
            
        }
        
        [self.tableView reloadData];
        
        
    }
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.searchBar resignFirstResponder];
    
}


@end
