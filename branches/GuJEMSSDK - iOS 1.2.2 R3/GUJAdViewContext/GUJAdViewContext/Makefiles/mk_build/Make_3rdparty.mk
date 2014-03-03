# BSD LICENSE
# Copyright (c) 2012, Mobile Unit of G+J Electronic Media Sales GmbH, Hamburg All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, 
# are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, 
# this list of conditions and the following disclaimer .
# Redistributions in binary form must reproduce the above copyright notice, 
# this list of conditions and the following disclaimer in the documentation 
# and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. 
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# The source code is just allowed for private use, not for commercial use.
#
# GUJ Makefile Set (Build Release) 
# 2012/11 Sven Ewert (sven.ewert@somo.de)
#
#
include $(MAKEFILE_DIR)Make_GlobalVars.mk
include $(MAKEFILE_DIR)Make_XcodeBuild.mk

##############################################################################################################
##################### 				 M O C E A N  S D K 		   	 #####################
##############################################################################################################
_LIB_DIR_MOCEAN_SDK             = $(PROJECT_DIR)/../3rdParty/mOcean/AdMobileSDK/Release/
_LIB_MOCEAN_SDK                 = libAdMobileSDK.a
_LIB_MOCEAN_SDK_SIMULATOR       = libAdMobileSDKSimulator.a

_copy_mOceanSDK_ReleaseiPhoneOS = `cp -a $(_LIB_DIR_MOCEAN_SDK)$(_LIB_MOCEAN_SDK) 		$(_RELEASE_DIR_RELEASE_IPHONEOS) && \
				   cp -a $(_LIB_DIR_MOCEAN_SDK)$(_LIB_MOCEAN_SDK_SIMULATOR) 	$(_RELEASE_DIR_RELEASE_SIMULATOR)`

_copy_mOceanSDK_DebugiPhoneOS 	= `cp -a $(_LIB_DIR_MOCEAN_SDK)$(_LIB_MOCEAN_SDK) 		$(_RELEASE_DIR_DEBUG_IPHONEOS) && \
				   cp -a $(_LIB_DIR_MOCEAN_SDK)$(_LIB_MOCEAN_SDK_SIMULATOR) 	$(_RELEASE_DIR_DEBUG_SIMULATOR)`


##############################################################################################################
##################### 				 X A X S I S  S D K 		   	 #####################
##############################################################################################################
_LIB_DIR_XAXSIS_SDK             = $(PROJECT_DIR)/../3rdParty/Xaxsis/Release/
_LIB_XAXSIS_SDK_armv6           = libAdSDKLib_armv6.a
_LIB_XAXSIS_SDK_armv7           = libAdSDKLib_armv7.a
_LIB_XAXSIS_SDK_SIMULATOR       = libAdSDKLib_i386.a

_LIB_XAXSIS_SDK                 = libXAXSISAdSDK.a
_LIB_XAXSIS_SDK_SIMULATOR_REL   = libXAXSISAdSDKSimulator.a

_LIB_XAXSIS_RESOURCE_BUNDLE     = VideoAdLib.bundle

_createFatXAXSIS_iPhoneosLibrary= `lipo -arch armv6 $(_LIB_DIR_XAXSIS_SDK)$(_LIB_XAXSIS_SDK_armv6) -arch armv7 $(_LIB_DIR_XAXSIS_SDK)$(_LIB_XAXSIS_SDK_armv7) -create -output $(_LIB_DIR_XAXSIS_SDK)$(_LIB_XAXSIS_SDK)`

_copy_XAXSISSDK_ReleaseiPhoneOS = `cp -a $(_LIB_DIR_XAXSIS_SDK)$(_LIB_XAXSIS_SDK) $(_RELEASE_DIR_RELEASE_IPHONEOS) && \
				   cp -a $(_LIB_DIR_XAXSIS_SDK)$(_LIB_XAXSIS_SDK_SIMULATOR) $(_RELEASE_DIR_RELEASE_SIMULATOR)$(_LIB_XAXSIS_SDK_SIMULATOR_REL)`

_copy_XAXSISSDK_DebugiPhoneOS 	= `cp -a $(_LIB_DIR_XAXSIS_SDK)$(_LIB_XAXSIS_SDK) $(_RELEASE_DIR_DEBUG_IPHONEOS) && \
				   cp -a $(_LIB_DIR_XAXSIS_SDK)$(_LIB_XAXSIS_SDK_SIMULATOR) $(_RELEASE_DIR_DEBUG_SIMULATOR)$(_LIB_XAXSIS_SDK_SIMULATOR_REL)`

_copy_XAXSISSDK_Resources   = `rm -Rf $(_RELEASE_DIR_RESOURCES)$(_LIB_XAXSIS_RESOURCE_BUNDLE) && \
				   cp -a $(_LIB_DIR_XAXSIS_SDK)../Resources/$(_LIB_XAXSIS_RESOURCE_BUNDLE) $(_RELEASE_DIR_RESOURCES) && \
				   rm -Rf $(_RELEASE_DIR_RESOURCES)$(_LIB_XAXSIS_RESOURCE_BUNDLE)/.svn`


_clean_XAXSISSDK    = `rm -f $(_LIB_DIR_XAXSIS_SDK)$(_LIB_XAXSIS_SDK)`

prepare_all_extrenal_sdks: prepare_mocean prepare_xaxsi

prepare_xaxsi:
	$(_createReleaseDir)
	$(_clean_XAXSISSDK)
	$(_createFatXAXSIS_iPhoneosLibrary)
	$(_copy_XAXSISSDK_ReleaseiPhoneOS)
	$(_copy_XAXSISSDK_DebugiPhoneOS)
	$(_copy_XAXSISSDK_Resources)
	

prepare_mocean:
	$(_createReleaseDir)	
	$(_copy_mOceanSDK_ReleaseiPhoneOS)
	$(_copy_mOceanSDK_DebugiPhoneOS)

