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

#import "ListAdViewController.h"
#import "MainTableViewCell.h"


@interface AdViewTableViewCell : MainTableViewCell
@property (strong, nonatomic) IBOutlet UILabel *adTypeLabel;
@property (assign, nonatomic) BOOL loaded;
- (void)loadAd:(NSString*)adSpaceId delegate:(id)delegate;
@end

@implementation AdViewTableViewCell


- (void)loadAd:(NSString*)adSpaceId delegate:(id)delegate
{
    NSLog(@"LOAD");
    //[[self adTypeLabel] removeFromSuperview];
    GUJAdViewContext *ctx = [GUJAdViewContext instanceForAdspaceId:adSpaceId delegate:delegate];
    [self addSubview:[ctx adView]];
    [self setLoaded:YES];
}

@end

@implementation ListAdViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self->nibForCellReuseIdentifier_ = [UINib nibWithNibName:@"AdViewCell_iPhone" bundle:nil];
    [[self adSettingsView] removeFromSuperview];
    [[[self tableViewController] tableView] setDelegate:self];
    [[[self tableViewController] tableView] setDataSource:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( [indexPath row] == 5 || [indexPath row] == 25) {
        return 51.0f;
    } if( [indexPath row] == 12 || [indexPath row] == 33) {
        return 76.0f;
    } else {
        return 40.0f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@_Cell_%i",[self class],[indexPath row]];

    AdViewTableViewCell *cell = nil;
    if( nibForCellReuseIdentifier_ != nil ) {
        [tableView registerNib:nibForCellReuseIdentifier_ forCellReuseIdentifier:cellIdentifier];
    } else {
        [NSException raise:@"Invalid Class or Nib for CellReuseIdentifier." format:@"Class for %@ not found.", cellIdentifier];
    }

    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if( [indexPath row] == 5 || [indexPath row] == 12 || [indexPath row] == 25 || [indexPath row] == 33 ) {
        if( ![cell loaded] ) {
            [[cell adTypeLabel] setText:@"loading Ad"];
            if( [indexPath row] == 12 || [indexPath row] == 33 ) {
                [((AdViewTableViewCell*)cell) loadAd:@"18779" delegate:self];
            } else {
                [((AdViewTableViewCell*)cell) loadAd:@"14833" delegate:self];
            }
        }
    } else {
        [[cell adTypeLabel] setText:@"Empty Cell"];
    }
    return cell;
}

@end
