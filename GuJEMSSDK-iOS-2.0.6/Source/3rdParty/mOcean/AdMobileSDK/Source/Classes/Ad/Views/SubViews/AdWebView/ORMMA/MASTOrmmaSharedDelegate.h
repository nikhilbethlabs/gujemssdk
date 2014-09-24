//
//  MASTOrmmaSharedDelegate.h
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <EventKit/EventKit.h>

#import "OrmmaProtocols.h"

@interface MASTOrmmaSharedDelegate : NSObject <OrmmaDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

+ (id)sharedInstance;

@end