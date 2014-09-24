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
#ifndef GUJAdViewContext_GUJAdViewContextLocalTypeDefinition_h
#define GUJAdViewContext_GUJAdViewContextLocalTypeDefinition_h

static inline void GUJADViewContextSDKDependencyCheck()
{
#ifdef GUJXAXISSDK_GUJXAXISSDKVersion_h
    if( !LIB_GUJ_XAXIS_SDK_VERSION_CHECK(kGUJ_REQIURED_VERSION_MAJ_XAXIS_SDK,kGUJ_REQIURED_VERSION_MIN_XAXIS_SDK) ) {
        [[NSException exceptionWithName:kGUJ_EXCEPTION_LIBRARY_DEPENDENCY_FAILURE 
                                 reason:[NSString stringWithFormat:kGUJ_EXCEPTION_REASON_VERSION_MISMATCH, 
                                         kGUJ_LIBRARY_PRODUCT_NAME_XAXSIS_SDK,
                                         kGUJ_REQIURED_VERSION_MAJ_XAXIS_SDK,kGUJ_REQIURED_VERSION_MIN_XAXIS_SDK,
                                         LIB_GUJ_XAXIS_SDK_MAJOR_VERSION,LIB_GUJ_XAXIS_SDK_MINOR_VERSION]
                               userInfo:nil] raise];    
    }
#else
    [[NSException exceptionWithName:kGUJ_EXCEPTION_LIBRARY_DEPENDENCY_FAILURE 
                             reason:[NSString stringWithFormat:kGUJ_EXCEPTION_REASON_VERSION_NOT_FOUND,kGUJ_LIBRARY_PRODUCT_NAME_XAXSIS_SDK]
                           userInfo:nil] raise];   
#endif    
    
#ifdef GUJmOceanSDK_GUJmOceanSDKVersion_h
    if( !LIB_GUJ_MOCEAN_SDK_VERSION_CHECK(kGUJ_REQIURED_VERSION_MAJ_MOCEAN_SDK,kGUJ_REQIURED_VERSION_MIN_MOCEAN_SDK) ) {
        [[NSException exceptionWithName:kGUJ_EXCEPTION_LIBRARY_DEPENDENCY_FAILURE 
                                 reason:[NSString stringWithFormat:kGUJ_EXCEPTION_REASON_VERSION_MISMATCH, 
                                         kGUJ_LIBRARY_PRODUCT_NAME_MOCEAN_SDK,
                                         kGUJ_REQIURED_VERSION_MAJ_XAXIS_SDK,kGUJ_REQIURED_VERSION_MIN_XAXIS_SDK,
                                         LIB_GUJ_XAXIS_SDK_MAJOR_VERSION,LIB_GUJ_XAXIS_SDK_MINOR_VERSION]
                               userInfo:nil] raise];        
    }
#else    
    [[NSException exceptionWithName:kGUJ_EXCEPTION_LIBRARY_DEPENDENCY_FAILURE 
                             reason:[NSString stringWithFormat:kGUJ_EXCEPTION_REASON_VERSION_NOT_FOUND,kGUJ_LIBRARY_PRODUCT_NAME_MOCEAN_SDK]
                           userInfo:nil] raise]; 
#endif
    
#ifdef GUJORMMASDK_GUJORMMASDKVersion_h
    if( !LIB_GUJ_ORMMA_SDK_VERSION_CHECK(kGUJ_REQIURED_VERSION_MAJ_ORMMA_SDK,kGUJ_REQIURED_VERSION_MIN_ORMMA_SDK) ) {
        [[NSException exceptionWithName:kGUJ_EXCEPTION_LIBRARY_DEPENDENCY_FAILURE 
                                 reason:[NSString stringWithFormat:kGUJ_EXCEPTION_REASON_VERSION_MISMATCH,  
                                         kGUJ_LIBRARY_PRODUCT_NAME_ORMMA_SDK,
                                         kGUJ_REQIURED_VERSION_MAJ_XAXIS_SDK,kGUJ_REQIURED_VERSION_MIN_XAXIS_SDK,
                                         LIB_GUJ_XAXIS_SDK_MAJOR_VERSION,LIB_GUJ_XAXIS_SDK_MINOR_VERSION]
                               userInfo:nil] raise];    
    }
#else    
    [[NSException exceptionWithName:kGUJ_EXCEPTION_LIBRARY_DEPENDENCY_FAILURE 
                             reason:[NSString stringWithFormat:kGUJ_EXCEPTION_REASON_VERSION_NOT_FOUND,kGUJ_LIBRARY_PRODUCT_NAME_ORMMA_SDK]
                           userInfo:nil] raise]; 
#endif    
    
#ifdef GUJBaseSDK_GUJBaseSDKVersion_h
    if( !LIB_GUJ_BASE_SDK_VERSION_CHECK(kGUJ_REQIURED_VERSION_MAJ_BASE_SDK,kGUJ_REQIURED_VERSION_MIN_BASE_SDK) ) {
        [[NSException exceptionWithName:kGUJ_EXCEPTION_LIBRARY_DEPENDENCY_FAILURE 
                                 reason:[NSString stringWithFormat:kGUJ_EXCEPTION_REASON_VERSION_MISMATCH,  
                                         kGUJ_LIBRARY_PRODUCT_NAME_BASE_SDK,
                                         kGUJ_REQIURED_VERSION_MAJ_XAXIS_SDK,kGUJ_REQIURED_VERSION_MIN_XAXIS_SDK,
                                         LIB_GUJ_XAXIS_SDK_MAJOR_VERSION,LIB_GUJ_XAXIS_SDK_MINOR_VERSION]
                               userInfo:nil] raise];    
    }
#else    
    [[NSException exceptionWithName:kGUJ_EXCEPTION_LIBRARY_DEPENDENCY_FAILURE 
                             reason:[NSString stringWithFormat:kGUJ_EXCEPTION_REASON_VERSION_NOT_FOUND,kGUJ_LIBRARY_PRODUCT_NAME_BASE_SDK]
                           userInfo:nil] raise];  
#endif
}

#endif
