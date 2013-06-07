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
##################### 				M O C E A N   S D K			 #####################
##############################################################################################################

_SOURCE_DIR_SDK			= $(PROJECT_DIR)/../GUJmOceanSDK/
_PRJ_SDK                = "$(_SOURCE_DIR_SDK)GUJmOceanSDK.xcodeproj"
_TRGT_SDK_SIMULATOR		= GUJmOceanSDKSimulator
_TRGT_SDK_IPHONEOS		= GUJmOceanSDK

release_mocean_sdk:
	$(_createReleaseDir)
	$(_cleanBuildDir_SDK)
	$(_clean_SDK_ReleaseiPhoneOS)
	$(_build_SDK_ReleaseiPhoneOS)
	$(_clean_SDK_ReleaseSimulator)
	$(_build_SDK_ReleaseSimulator)
	$(_copy_SDK_ReleaseiPhoneOS)

debug_mocean_sdk:
	$(_createReleaseDir)
	$(_cleanBuildDir_SDK)
	$(_clean_SDK_DebugiPhoneOS)
	$(_build_SDK_DebugiPhoneOS)
	$(_clean_SDK_DebugSimulator)
	$(_build_SDK_DebugSimulator)
	$(_copy_SDK_DebugiPhoneOS)

build_mocean_sdk: clean release_mocean_sdk debug_mocean_sdk