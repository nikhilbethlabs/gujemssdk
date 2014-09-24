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

#import "ViewController.h"
#import "GUJAdViewContext.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize rootTableView;

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
[UIApplication sharedApplication].statusBarHidden = YES;
    
    [self setTitle:@"ORMMA-SDK"];
    if( ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) ) {
        self.view.frame = CGRectMake(0, 0, 768, 1024);
    }
}

- (void)_showAdViewControllerForType:(NSString*)type
{
    NSString *devString = @"iPhone";
    if( ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) ) {
        devString = @"iPad";
    }
    TestAdViewController *vc = nil;
    if( [type isEqualToString:@"XAXIS"] ) {
        vc = [[XAXSISAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"InterReloadableAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"XAXIS Ad"];
    } else if( [type isEqualToString:@"CUST_SINGLE"] ) {
        vc = [[CustomSingleAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"SingleAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"Custom Ad"];
    } else if( [type isEqualToString:@"CUST_INTER"] ) {
        vc = [[CustomInterstitalAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"SingleAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"Custom Interstitial"];
    } else if( [type isEqualToString:@"STATIC_INTER"] ) {
        vc = [[StaticInterstitialViewController alloc] initWithNibName:[NSString stringWithFormat:@"InterReloadableAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"Interstitial"];
        if( ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) ) {
            [((StaticInterstitialViewController*)vc) setStaticAdSpaceId:@"16197"];
        } else {
            [((StaticInterstitialViewController*)vc) setStaticAdSpaceId:@"14839"];
        }
    } else if( [type isEqualToString:@"STATIC_INTER_NC"] ) {
        vc = [[StaticInterstitialViewController alloc] initWithNibName:[NSString stringWithFormat:@"InterReloadableAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"Interstitial (NoAutoClose)"];
        if( ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) ) {
            [((StaticInterstitialViewController*)vc) setStaticAdSpaceId:@"19807"];
        } else {
            [((StaticInterstitialViewController*)vc) setStaticAdSpaceId:@"19807"];
        }
    } else if( [type isEqualToString:@"STATIC_MULTI_2"] ) {
        vc = [[MultiAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"MultiAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"Sticky Top/Bottom"];
    } else if( [type isEqualToString:@"ORMMA_14835"] ) {
        vc = [[StaticORMMAAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"InterReloadableAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"ORMMA Ad"];
        [((StaticORMMAAdViewController*)vc) setStaticAdSpaceId:@"14835"];
    } else if( [type isEqualToString:@"ORMMA_16511"] ) {
        vc = [[ExpandableViewController alloc] initWithNibName:[NSString stringWithFormat:@"SingleAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"ORMMA Expandable Ad"];
        [((ExpandableViewController*)vc) setStaticAdSpaceId:@"16511"];
    } else if( [type isEqualToString:@"ORMMA_VIDEO"] ) {
        vc = [[StaticORMMAAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"InterReloadableAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"ORMMA Video Ad"];
        [((StaticORMMAAdViewController*)vc) setStaticAdSpaceId:@"15215"];
    } else if( [type isEqualToString:@"ORMMA_AUDIO"] ) {
        vc = [[StaticORMMAAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"InterReloadableAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"ORMMA Audio Ad"];
        [((StaticORMMAAdViewController*)vc) setStaticAdSpaceId:@"18783"];
    } else if( [type isEqualToString:@"ORMMA_MAP"] ) {
        vc = [[StaticORMMAAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"InterReloadableAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"ORMMA Map Ad"];
        [((StaticORMMAAdViewController*)vc) setStaticAdSpaceId:@"18785"];
    } else if( [type isEqualToString:@"ORMMA_CALENDAR"] ) {
        vc = [[StaticORMMAAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"InterReloadableAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"ORMMA Calendar Ad"];
        [((StaticORMMAAdViewController*)vc) setStaticAdSpaceId:@"18787"];
    } else if( [type isEqualToString:@"ORMMA_TESTS"] ) {
        vc = [[StaticORMMAAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"InterReloadableAdViewController_%@",devString] bundle:nil];
        [vc setTitle:@"ORMMA Device Tests Ad"];
        [((StaticORMMAAdViewController*)vc) setStaticAdSpaceId:@"18789"];
    } else if( [type isEqualToString:@"CATEGORY_INTER"] ) {
        vc = [[CategoryInterstitialViewController alloc] initWithNibName:[NSString stringWithFormat:@"CategoryInterstitial_%@",devString] bundle:nil];
        [vc setTitle:@"Rubrikeninterstitial"];
    } else if( [type isEqualToString:@"LIST_AD_VIEW"] ) {
        vc = [[ListAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"ListAdViewController_iPhone",devString] bundle:nil];
        [vc setTitle:@"ListView Ads"];
    } else if( [type isEqualToString:@"START_INT"] ) {
        vc = [[AppStartInterstitialViewController alloc] initWithNibName:[NSString stringWithFormat:@"AppStartInterstitial_%@",devString] bundle:nil];
        [vc setTitle:@"App-Start Interstitial"];
    }
    
    else {
        vc = [[CustomInterstitalAdViewController alloc] initWithNibName:[NSString stringWithFormat:@"SingleAdViewController_%@",devString] bundle:nil];
    }
    if( ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) ) {
        vc.view.frame = CGRectMake(0, 0, 768, 1024);
    }
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

@end
