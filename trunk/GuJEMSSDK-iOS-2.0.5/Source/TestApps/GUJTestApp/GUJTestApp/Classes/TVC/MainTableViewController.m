/*
 * BSD LICENSE
 * Copyright (c) 2012, Mobile Unit of G+J Electronic Media Sales GmbH, Hamburg All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer .
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * The source code is just allowed for private use, not for commercial use.
 *
 */
#import "MainTableViewController.h"

#import "AppDelegate.h"
#import "ViewController.h"

@interface MainTableViewController ()
- (void)_initTableData;
@end

@implementation MainTableViewController
@synthesize tableData;
@synthesize adType;

- (void)_initTableData
{
    NSLog(@"INIT");
    tableData = [NSMutableArray new];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"Custom Single Ad" forKey:@"AD_TYPE"];
    [adType setObject:@"CUST_SINGLE" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"Custom Interstitial Ad" forKey:@"AD_TYPE"];
    [adType setObject:@"CUST_INTER" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    
    if( ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) ) {
        adType = [NSMutableDictionary new];
        [adType setObject:@"Interstitial (16199)" forKey:@"AD_TYPE"];
        [adType setObject:@"STATIC_INTER" forKey:@"AD_CLASS"];
        [tableData addObject:adType];
        
        adType = [NSMutableDictionary new];
        [adType setObject:@"Interstitial No-AutoClose (19807)" forKey:@"AD_TYPE"];
        [adType setObject:@"STATIC_INTER_NC" forKey:@"AD_CLASS"];
        [tableData addObject:adType];
        
        
    } else {
        adType = [NSMutableDictionary new];
        [adType setObject:@"Interstitial (14839)" forKey:@"AD_TYPE"];
        [adType setObject:@"STATIC_INTER" forKey:@"AD_CLASS"];
        [tableData addObject:adType];
        
        adType = [NSMutableDictionary new];
        [adType setObject:@"Interstitial No-AutoClose (19807)" forKey:@"AD_TYPE"];
        [adType setObject:@"STATIC_INTER_NC" forKey:@"AD_CLASS"];
        [tableData addObject:adType];
        
    }
    
    
    

    adType = [NSMutableDictionary new];
    [adType setObject:@"XAXIS (15631)" forKey:@"AD_TYPE"];
    [adType setObject:@"XAXIS" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"Sticky Top/Bottom (14833,18779)" forKey:@"AD_TYPE"];
    [adType setObject:@"STATIC_MULTI_2" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"ListView Ads (14833,18779)" forKey:@"AD_TYPE"];
    [adType setObject:@"LIST_AD_VIEW" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"Rubrikeninterstitial (14839)" forKey:@"AD_TYPE"];
    [adType setObject:@"CATEGORY_INTER" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"ORMMA AllInOne (14835)" forKey:@"AD_TYPE"];
    [adType setObject:@"ORMMA_14835" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"ORMMA Expandable (16511)" forKey:@"AD_TYPE"];
    [adType setObject:@"ORMMA_16511" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"ORMMA Video (15215)" forKey:@"AD_TYPE"];
    [adType setObject:@"ORMMA_VIDEO" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"ORMMA Audio (18783)" forKey:@"AD_TYPE"];
    [adType setObject:@"ORMMA_AUDIO" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"ORMMA Map (18785)" forKey:@"AD_TYPE"];
    [adType setObject:@"ORMMA_MAP" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"ORMMA Calendar (18787)" forKey:@"AD_TYPE"];
    [adType setObject:@"ORMMA_CALENDAR" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"ORMMA Device Tests (18789)" forKey:@"AD_TYPE"];
    [adType setObject:@"ORMMA_TESTS" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
    adType = [NSMutableDictionary new];
    [adType setObject:@"App-Start-Interstitial" forKey:@"AD_TYPE"];
    [adType setObject:@"START_INT" forKey:@"AD_CLASS"];
    [tableData addObject:adType];
    
}

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
    
    [self _initTableData];
    nibForCellReuseIdentifier_ = [UINib nibWithNibName:@"MainTableCell_iPhone" bundle:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"SDK-TESTS";
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_Cell_%i",[self class],[indexPath row]];
    
    MainTableViewCell *cell = nil;
    if( nibForCellReuseIdentifier_ != nil ) {
        [tableView registerNib:nibForCellReuseIdentifier_ forCellReuseIdentifier:cellIdentifier];
    } else {
        [NSException raise:@"Invalid Class or Nib for CellReuseIdentifier." format:@"Class for %@ not found.", cellIdentifier];
    }
    NSDictionary *adData = [tableData objectAtIndex:[indexPath row]];
    //   NSLog(@"D %@",adData);
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
   // cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [[cell adTypeLabel] setText:[adData objectForKey:@"AD_TYPE"]];
    [cell setAdVCClass:[adData objectForKey:@"AD_CLASS"]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
         NSDictionary *adData = [tableData objectAtIndex:[indexPath row]];
    [[((AppDelegate*)[[UIApplication sharedApplication] delegate]) viewController]
    _showAdViewControllerForType:[adData objectForKey:@"AD_CLASS"]];
}

@end
