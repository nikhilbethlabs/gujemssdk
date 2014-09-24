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
#ifndef GEAdBaseSDK_GUJMacros_h
#define GEAdBaseSDK_GUJMacros_h

// Quick Access to NSNumber 
#define NSNUMBER_WITH_BOOL(b)         ([NSNumber numberWithBool:b])
#define NSNUMBER_WITH_INT(i)          ([NSNumber numberWithInt:i])
#define NSNUMBER_WITH_LONG(l)         ([NSNumber numberWithLong:l])
#define NSNUMBER_WITH_LONG_LONG(ll)   ([NSNumber numberWithLongLong:ll])
#define NSNUMBER_WITH_FLOAT(f)        ([NSNumber numberWithFloat:f])
#define NSNUMBER_WITH_DOUBLE(d)       ([NSNumber numberWithDouble:d])


// If iOS > 3.1.3 UI_USER_INTERFACE_IDIOM is supported
#if (UI_USER_INTERFACE_IDIOM == 1 )
    #define IS_IPHONE() ( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) != NO ) 
    #define IS_IPAD()   ( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) != YES )
#else
    #define IS_IPHONE() YES // set iPhone as default. skip iPad 1 with 3.1.3 
    #define IS_IPAD() NO
#endif



#endif
