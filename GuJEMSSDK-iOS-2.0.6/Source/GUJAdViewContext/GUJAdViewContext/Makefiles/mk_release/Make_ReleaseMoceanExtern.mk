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
# GUJ Makefile Set (Build Bundle) 
# Sven Ewert (sven.ewert@gomindo.de)
#
#
include $(MAKEFILE_DIR)Make_ReleaseGlobalVars.mk
include $(MAKEFILE_DIR)Make_ReleaseFunctions.mk

_TARGET_NAME                = GUJMOCEANSDK
_TARGET_DIR                 = $(_BUNDLE_DIR)$(_TARGET_NAME)/

ifdef EXT_LIB_DIR
EXTLIBDIR                   = $(EXT_LIB_DIR)
else
EXTLIBDIR                   = $(_TARGET_DIR)
endif

ifdef RELEASE
_BUILD_DIR                  = $(_TARGET_DIR)Build/$(_DIR_RELEASE)
else
_BUILD_DIR                  = $(_TARGET_DIR)Build/$(_DIR_DEBUG)
endif
_LIB_SDK_NAME               = libAdMobileSDK
_LIB_SDK_NAME_SIM           = libAdMobileSDKSimulator
_SOURCE_LIB_SDK             = $(_LIB_SDK_NAME).a
_SOURCE_LIB_SDK_SIM 		= $(_LIB_SDK_NAME_SIM).a

_ARMV7S_AR_DIR               = $(_BUILD_DIR_IPHONEOS_ARMV7S)$(_AR_DIR)
_ARMV7S_LIB_SDK              = $(_LIB_SDK_NAME)_armv7s.a
_ARMV7S_LIB_SDK_DIR          = $(_BUILD_DIR_IPHONEOS_ARMV7S)$(_ARMV7S_LIB_SDK)
_ARMV7S_LIB_MERGED           = $(_TARGET_NAME)_armv7s_merged.a
_ARMV7S_LIB_MERGED_DIR		= $(_BUILD_DIR_IPHONEOS_ARMV7S)$(_ARMV7S_LIB_MERGED)

_ARMV7_AR_DIR               = $(_BUILD_DIR_IPHONEOS_ARMV7)$(_AR_DIR)
_ARMV7_LIB_SDK              = $(_LIB_SDK_NAME)_armv7.a
_ARMV7_LIB_SDK_DIR          = $(_BUILD_DIR_IPHONEOS_ARMV7)$(_ARMV7_LIB_SDK)
_ARMV7_LIB_MERGED           = $(_TARGET_NAME)_armv7_merged.a
_ARMV7_LIB_MERGED_DIR		= $(_BUILD_DIR_IPHONEOS_ARMV7)$(_ARMV7_LIB_MERGED)

_ARM64_AR_DIR               = $(_BUILD_DIR_IPHONEOS_ARM64)$(_AR_DIR)
_ARM64_LIB_SDK              = $(_LIB_SDK_NAME)_arm64.a
_ARM64_LIB_SDK_DIR          = $(_BUILD_DIR_IPHONEOS_ARM64)$(_ARM64_LIB_SDK)
_ARM64_LIB_MERGED           = $(_TARGET_NAME)_arm64_merged.a
_ARM64_LIB_MERGED_DIR		= $(_BUILD_DIR_IPHONEOS_ARM64)$(_ARM64_LIB_MERGED)

_i386_AR_DIR                = $(_BUILD_IPHONESIMULATOR_i386)$(_AR_DIR)
_i386_LIB_SDK               = $(_LIB_SDK_NAME)_i386.a
_i386_LIB_SDK_DIR           = $(_BUILD_IPHONESIMULATOR_i386)$(_i386_LIB_SDK)

_i386_LIB_MERGED            = $(_TARGET_NAME)_i386_merged.a
_i386_LIB_MERGED_DIR		= $(_BUILD_IPHONESIMULATOR_i386)$(_i386_LIB_MERGED)

_x86_64_AR_DIR              = $(_BUILD_IPHONESIMULATOR_x8664)$(_AR_DIR)
_x86_64_LIB_SDK             = $(_LIB_SDK_NAME)_x8664.a
_x86_64_LIB_SDK_DIR         = $(_BUILD_IPHONESIMULATOR_x8664)$(_x86_64_LIB_SDK)

_x86_64_LIB_MERGED            = $(_TARGET_NAME)_x8664_merged.a
_x86_64_LIB_MERGED_DIR		= $(_BUILD_IPHONESIMULATOR_x8664)$(_x86_64_LIB_MERGED)


ifdef RELEASE
_SRC_LIB_LOC_IPHONEOS		= $(BINARY_DIR)$(_DIR_RELEASE_IPHONEOS)
_SRC_LIB_LOC_IPHONSIMULATOR	= $(BINARY_DIR)$(_DIR_RELEASE_IPHONESIMULATOR)

_LIB_IPHONEOS               = $(_TARGET_DIR_RELEASE)$(_DIR_RELEASE_IPHONEOS)lib$(_TARGET_NAME).a
_LIB_IPHONESIMULATOR		= $(_TARGET_DIR_RELEASE)$(_DIR_RELEASE_IPHONESIMULATOR)lib$(_TARGET_NAME)Simulator.a
_LIB_UNIVERSAL              = $(_TARGET_DIR_RELEASE)$(_DIR_RELEASE_UNIVERSAL)lib$(_TARGET_NAME)Universal.a

_EXT_LIB_IPHONEOS           = $(EXTLIBDIR)$(_DIR_RELEASE)$(_DIR_RELEASE_IPHONEOS)$(_SOURCE_LIB_SDK)
_EXT_LIB_IPHONESIMULATOR	= $(EXTLIBDIR)$(_DIR_RELEASE)$(_DIR_RELEASE_IPHONESIMULATOR)$(_SOURCE_LIB_SDK_SIM)
_EXT_LIB_UNIVERSAL          = $(EXTLIBDIR)$(_DIR_RELEASE)$(_DIR_RELEASE_UNIVERSAL)$(_LIB_SDK_NAME)Universal.a

else
_SRC_LIB_LOC_IPHONEOS		= $(BINARY_DIR)$(_DIR_DEBUG_IPHONEOS)
_SRC_LIB_LOC_IPHONSIMULATOR	= $(BINARY_DIR)$(_DIR_DEBUG_IPHONESIMULATOR)

_LIB_IPHONEOS               = $(_TARGET_DIR_DEBUG)$(_DIR_DEBUG_IPHONEOS)lib$(_TARGET_NAME).a
_LIB_IPHONESIMULATOR		= $(_TARGET_DIR_DEBUG)$(_DIR_DEBUG_IPHONESIMULATOR)lib$(_TARGET_NAME)Simulator.a
_LIB_UNIVERSAL              = $(_TARGET_DIR_DEBUG)$(_DIR_DEBUG_UNIVERSAL)lib$(_TARGET_NAME)Universal.a

_EXT_LIB_IPHONEOS           = $(EXTLIBDIR)$(_DIR_DEBUG)$(_DIR_DEBUG_IPHONEOS)$(_SOURCE_LIB_SDK)
_EXT_LIB_IPHONESIMULATOR	= $(EXTLIBDIR)$(_DIR_DEBUG)$(_DIR_DEBUG_IPHONESIMULATOR)$(_SOURCE_LIB_SDK_SIM)
_EXT_LIB_UNIVERSAL          = $(EXTLIBDIR)$(_DIR_DEBUG)$(_DIR_DEBUG_UNIVERSAL)$(_LIB_SDK_NAME)Universal.a

endif

_prepareExtThinLibraries	= `xcrun -sdk iphoneos lipo -thin arm64 $(_SRC_LIB_LOC_IPHONEOS)$(_SOURCE_LIB_SDK) -output $(_ARM64_LIB_SDK) && lipo -thin armv7s $(_SRC_LIB_LOC_IPHONEOS)$(_SOURCE_LIB_SDK)  -output $(_ARMV7S_LIB_SDK_DIR) && xcrun -sdk iphoneos lipo -thin armv7 $(_SRC_LIB_LOC_IPHONEOS)$(_SOURCE_LIB_SDK)  -output $(_ARMV7_LIB_SDK_DIR) && cp -a $(_SRC_LIB_LOC_IPHONSIMULATOR)$(_SOURCE_LIB_SDK_SIM) $(_i386_LIB_SDK_DIR)`

_copyExtI386Library		= `cp -a $(_i386_LIB_SDK_DIR)  $(_EXT_LIB_IPHONESIMULATOR)`
_createExtIPhoneOSLibrary	= `xcrun -sdk iphoneos lipo -arch arm64 $(_ARM64_LIB_SDK) -arch armv7s $(_ARMV7S_LIB_SDK_DIR) -arch armv7 $(_ARMV7_LIB_SDK_DIR) -create -output $(_EXT_LIB_IPHONEOS)`
_createExtUniversalLibrary	= `xcrun -sdk iphoneos lipo -arch arm64 $(_ARM64_LIB_SDK) -arch armv7s $(_ARMV7S_LIB_SDK_DIR) -arch armv7 $(_ARMV7_LIB_SDK_DIR) -arch i386 $(_i386_LIB_SDK_DIR) -create -output $(_EXT_LIB_UNIVERSAL)`

copy_mocean_sdk_extern:
	$(_prepareExtThinLibraries)
	$(_createExtIPhoneOSLibrary)
	$(_createFatiPhoneSimulatorLibrary)
	$(_createExtUniversalLibrary)

extract_mocean_sdk_extern:
	$(_createBuildDirectories)
	$(_extractArmV6)
	$(_extractArmV7)
	$(_extractArm64)       
	$(_extracti386)
	$(_extractx8664)    

