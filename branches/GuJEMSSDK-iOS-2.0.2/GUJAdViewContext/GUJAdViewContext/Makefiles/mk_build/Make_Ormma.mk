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
# Sven Ewert (sven.ewert@gomindo.de)
#
#
include $(MAKEFILE_DIR)Make_GlobalVars.mk
include $(MAKEFILE_DIR)Make_XcodeBuild.mk

##############################################################################################################
##################### O R M M A   S D K							 #####################
##############################################################################################################
# Base SDK
_SOURCE_DIR_SDK			= $(PROJECT_DIR)/../GUJORMMASDK/
_PRJ_SDK                = "$(_SOURCE_DIR_SDK)GUJORMMASDK.xcodeproj"
_TRGT_SDK_SIMULATOR		= GUJORMMASDKSimulator
_TRGT_SDK_IPHONEOS		= GUJORMMASDK


##############################################################################################################
##################### O R M M A   R E S O U R C E S					 #####################
##############################################################################################################
_SOURCE_DIR_ORMMA_RESOURCE	= $(PROJECT_DIR)/../ORMMAResourceBundle/
_PRJ_ORMMA_RESOURCE		= "$(_SOURCE_DIR_ORMMA_RESOURCE)ORMMAResourceBundle.xcodeproj"
_TRGT_ORMMA_RESOURCE		= ORMMAResourceBundle

_cleanBuildDir_ORMMA_RESOURCE	= `rm -rf $(_SOURCE_DIR_ORMMA_RESOURCE)build/*`
_clean_ORMMA_ResourceBundle	= xcodebuild -project $(_PRJ_ORMMA_RESOURCE) -target $(_TRGT_ORMMA_RESOURCE) -configuration $(_CONFIG_RELEASE) -arch $(_ARCH_IPHONE_OS) clean
_build_ORMMA_ResourceBundle	= xcodebuild -project $(_PRJ_ORMMA_RESOURCE) -target $(_TRGT_ORMMA_RESOURCE) -configuration $(_CONFIG_RELEASE) -arch $(_ARCH_IPHONE_OS) $(__NO_DEBUG) build

_copy_ORMMA_ResourceBundle	= `cp -a $(_SOURCE_DIR_ORMMA_RESOURCE)$(_BUILD_DIR)$(_RELEASE_DIR_IPHONEOS)*.bundle  $(_RELEASE_DIR_RESOURCES)`

_copy_ormma_release_makefile	= `cp -a ormmasdk.mk $(_RELEASE_DIR)/Makefile`


release_ormma_resources:
	$(_createReleaseDir)
	$(_clean_ORMMA_ResourceBundle)
	$(_cleanBuildDir_ORMMA_RESOURCE)
	$(_build_ORMMA_ResourceBundle)
	$(_copy_ORMMA_ResourceBundle)

release_ormma_sdk:
	$(_createReleaseDir)
	$(_cleanBuildDir_SDK)
	$(_clean_SDK_ReleaseiPhoneOS)
	$(_build_SDK_ReleaseiPhoneOS)
	$(_clean_SDK_ReleaseSimulator)
	$(_build_SDK_ReleaseSimulator)
	$(_copy_SDK_ReleaseiPhoneOS)

debug_ormma_sdk:
	$(_createReleaseDir)
	$(_cleanBuildDir_SDK)
	$(_clean_SDK_DebugiPhoneOS)
	$(_build_SDK_DebugiPhoneOS)
	$(_clean_SDK_DebugSimulator)
	$(_build_SDK_DebugSimulator)
	$(_copy_SDK_DebugiPhoneOS)

build_ormma_sdk: clean release_ormma_sdk debug_ormma_sdk

build_ormma_resources: clean release_ormma_resources

prepare_ormma_release:
	$(_copy_ormma_release_makefile)

