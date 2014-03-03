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

/*!
 * The GUJNotificationObserver is an instance between the NSNotificationCenter
 * and objects that subscribe to notifications that known by the GUJNotificationObserver.
 *
 * For notification forwarding, first register the GUJNotificationObserver with
 * the NSNotificationCenter.
 *
 * If an object registers for notifications with the GUJNotificationObserver
 * all notifications will piped to it directly when the GUJNotificationObserver
 * received a valid notification message that fits.
 *
 * If a object unsubscribes the GUJNotificationObserver will stop sending notifications
 * to this object.
 *
 * On the fitst view, it seems the GUJNotificationObserver is just a replacement for
 * the NSNotificationCenter, but its not.
 *
 * The GUJNotificationObserver starts where the NotificationCenter stops and givs the
 * developer more control over which notification will, can and should be sent to
 * different sub observers.
 *
 */

#import "GUJObserver.h"

@interface GUJNotificationObserver : GUJObserver {
@private
    __strong NSMutableDictionary *registeredNotificationReceivers_;
    __strong NSMutableDictionary *registeredNotificationSenders_;
    __strong NSMutableDictionary *handledNotifications_;
}

/*!
 * Unregisters and fress the current instance.
 */
- (void)freeInstance;

/*!
 * Register a class to receive notifications.
 * The class will not added to the NSNotificaion center.
 @param receiver the object that should receive notifications
 @param notificationName the name of the notification that will be forwarded.
 @param selector the method of the receiver class that will be invoked when a notification is forwarded.
 */
+ (void)addObserverForNotification:(NSString *)notifcationName receiver:(id)receiver selector:(SEL)selector;
+ (void)addObserverForNotification:(NSString *)notifcationName sender:(id)sender receiver:(id)receiver selector:(SEL)selector;
+ (void)removeObserverForNotification:(NSString *)notifcationName sender:(id)sender receiver:(id)receiver;
+ (void)removeObserverForNotification:(NSString *)notifcationName receiver:(id)receiver;
+ (void)removeObserverForAllNotifications:(id)receiver;


@end
