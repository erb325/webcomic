//
//  ViewController.m
//  WebcomicViewer
//
//  Created by Ember Baker on 9/12/14.
//  Copyright (c) 2014 Ember Baker. All rights reserved.
//
// Write an iOS app that is a basic webcomic viewer for a webcomic of your choice. You should be able to navigate to previous
//and next strips. You should probably use an API feed like the ones available for http://xkcd.com/ but if you want to scrape
// a site, that is ok too.

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableData *responseData;

@end



@implementation ViewController{
    NSString *xURL;

}
@synthesize responseData = _responseData;

int comicNumber;
int MAX = 1400;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getComic];
    
    //swipe gestures for navigation
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}

-(void)getComic{
    //pick a random number to get a comic
    comicNumber =  arc4random_uniform(MAX);
    
    //add that number to the correct spot in the URL
    xURL = [NSString stringWithFormat:@"http://xkcd.com/%d/info.0.json", comicNumber];
    
    //send request and set up for reponse data
    self.responseData = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:xURL]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];

}

-(void)swipeLeft{
    [self getComic];
}

-(void)swipeRight{
    [self getComic];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Recieved Connction YAY!!");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Failed with an error");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Connection did finish loading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    // show all values
    
    NSMutableArray *keyArray = [@[] mutableCopy];
    NSMutableArray *valueArray = [@[] mutableCopy];
    for(id key in res) {
        
        id value = [res objectForKey:key];
       
        NSString *keyAsString = (NSString *)key;
        NSString *valueAsString = (NSString *)value;
        
        NSLog(@"key: %@", keyAsString);
        NSLog(@"value: %@", valueAsString);
        
//add the vaules of keyAsString and Value as string to a mutable array
        [keyArray addObject:keyAsString];
        [valueArray addObject:valueAsString];
    }
    int k;  //subscript
    
    for (int i=0; i<=keyArray.count -1; i++) {
        if ([keyArray[i]  isEqual: @"img"]) {       //find where in the array 'img' is and give me the url ect...
            k=i;
            NSLog(@"k equals %d", k);
            NSLog(@"when k equals %d then value is %@", k, valueArray[k]);
            
            UIView *mainView = [[UIView alloc]initWithFrame:CGRectMake(0,30,320,400)];
            UIImage *comic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:valueArray[k]]]];
            UIImageView *comicView = [[UIImageView alloc] initWithImage:comic];
            comicView.frame = mainView.bounds;
            [mainView addSubview:comicView];
            [self.view addSubview:mainView];
        }
    }

    NSArray *results = [res objectForKey:@"results"];

    
    for (NSDictionary *result in results) {
        NSString *img = [result objectForKey:@"img"];
        NSLog(@"img: %@", img);
    }
    
}


@end
