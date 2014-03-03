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

// Utility macros (undefined below)

#define PREFIX_ONE(a) 1##a
#define EMPTY_DEFINE(a) (PREFIX_ONE(a) == 1)

// Memory management kind

#if !defined(USING_GC)
#  if defined(__OBJC_GC__)
#     define USING_GC 1
#  else
#    define USING_GC 0
#  endif
#elif EMPTY_DEFINE(USING_GC) 
#   undef USING_GC
#   define USING_GC 1
#endif

#if !defined(USING_ARC)
#  if __has_feature(objc_arc)
#     define USING_ARC 1
#  else
#    define USING_ARC 0
#  endif
#elif EMPTY_DEFINE(USING_ARC)
#   undef USING_ARC
#   define USING_ARC 1
#endif

#if !defined(USING_MRC)
#  if USING_ARC || USING_GC
#     define USING_MRC 0
#  else
#    define USING_MRC 1
#  endif
#elif EMPTY_DEFINE(USING_MRC)
#   undef USING_MRC
#   define USING_MRC 1
#endif

// Remove utility

#undef PREFIX_ONE
#undef EMPTY_DEFINE

// Sanity checks

#if USING_GC
#   if USING_ARC || USING_MRC
#      error "Cannot specify GC and RC memory management"
#   endif
#elif USING_ARC
#   if USING_MRC
#      error "Cannot specify ARC and MRC memory management"
#   endif
#elif !USING_MRC
#   error "Must specify GC, ARC or MRC memory management"
#endif

#if USING_ARC
#   if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_6
#    //  error "ARC requires at least 10.6"
#   endif
#endif

#if !defined(__clang__) || __clang_major__ < 3
#ifndef __bridge
#define __bridge
#endif

#ifndef __bridge_retain
#define __bridge_retain
#endif

#ifndef __bridge_retained
#define __bridge_retained
#endif

#ifndef __autoreleasing
#define __autoreleasing
#endif

#ifndef __strong
#define __strong
#endif

#ifndef __unsafe_unretained
#define __unsafe_unretained
#endif

#ifndef __weak
#define __weak
#endif
#endif

#if __has_feature(objc_arc)
#define SAFE_ARC_PROP_RETAIN strong
#define SAFE_ARC_RETAIN(x) (x)
#define SAFE_ARC_RELEASE(x)
#define SAFE_ARC_AUTORELEASE(x) (x)
#define SAFE_ARC_BLOCK_COPY(x) (x)
#define SAFE_ARC_BLOCK_RELEASE(x)
#define SAFE_ARC_SUPER_DEALLOC()
#define SAFE_ARC_AUTORELEASE_POOL_START() @autoreleasepool {
#define SAFE_ARC_AUTORELEASE_POOL_END() }
#else
#define SAFE_ARC_PROP_RETAIN retain
#define SAFE_ARC_RETAIN(x) ([(x) retain])
#define SAFE_ARC_RELEASE(x) ([(x) release])
#define SAFE_ARC_AUTORELEASE(x) ([(x) autorelease])
#define SAFE_ARC_BLOCK_COPY(x) (Block_copy(x))
#define SAFE_ARC_BLOCK_RELEASE(x) (Block_release(x))
#define SAFE_ARC_SUPER_DEALLOC() ([super dealloc])
#define SAFE_ARC_AUTORELEASE_POOL_START() NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#define SAFE_ARC_AUTORELEASE_POOL_END() [pool release];
#endif


#endif
