//
//  MoviesViewController.m
//  Flix
//
//  Created by samason1 on 6/26/19.
//  Copyright © 2019 samason1. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h" //added import to get posters from cocopods and network
@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate> //STEP 2 - configure view controller to implement both interfaces

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//creates private instance variable, automatically creates getter and setter methods
//(nonatomic, strong) specify how the complier should generate the getter and setter methods
@property (nonatomic, strong) NSArray *movies;
//STEP 1 - created an outlet for table view to refer to view controller

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //STEP 3 - make view controller data source and delegate
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    
    [self fetchMovies];
    
    //UIRefreshControl designed to work with scroll view
    self.refreshControl = [[UIRefreshControl alloc] init];
    

    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView insertSubview:self.refreshControl atIndex:0];
  
    // [self.tableView addSubview:self.refreshControl];
   
}

- (void)fetchMovies {
    //API networking code/call
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //lines inside block called once network call is finished
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            //displays data from API being pulled into app in command line
            NSLog(@"%@", dataDictionary);
            
            // TODO: Get the array of movies
            self.movies = dataDictionary[@"results"];
            //iterating through array using for loop
            for (NSDictionary *movie in self.movies) {
                NSLog(@"%@", movie[@"title"]);
            }
            
            [self.tableView reloadData];
            // TODO: Store the movies in a property to use elsewhere
            // TODO: Reload your table view data
        }
        
        [self.refreshControl endRefreshing];
    }];
    [task resume];
}



- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    //Dispose of any resourcea that can be recreated
}

//STEP 4 - implement 2 data source methods
//Method that tells you how many rows you have
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.movies.count;
}

//Method to create and configure a cell based on different index paths
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movie = self.movies[indexPath.row];
    
    cell.titleLabel.text = movie[@"title"];
    cell.summaryLabel.text = movie[@"overview"];
    
    //adds image to UIImageView from API
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    cell.posterView.image=nil;
    [cell.posterView setImageWithURL:posterURL];
//cell.textLabel.text=movie[@"title"];
    
    //cell.textLabel.text = [NSString stringWithFormat:@"row: %d, section %d", indexPath.row, indexPath.section];
    
    return cell;
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    DetailsViewController *detailViewController = [segue destinationViewController];
    
    detailViewController.movie = movie;
    
   // NSLog(@"Tapping on a movie!");
    
}


@end
