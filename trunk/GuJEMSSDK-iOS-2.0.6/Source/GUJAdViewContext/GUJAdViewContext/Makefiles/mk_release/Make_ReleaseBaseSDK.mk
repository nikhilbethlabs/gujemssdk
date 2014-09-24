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

_TARGET_DIR                 = ORMMA_SDK/
_LIB_SDK_NAME               = libGUJBaseSDK
_LIB_SDK_NAME_SIM           = libGUJBaseSDKSimulator

_SOURCE_LIB_SDK             = $(_LIB_SDK_NAME).a
_SOURCE_LIB_SDK_SIM 		= $(_LIB_SDK_NAME_SIM).a

_ARMV7S_AR_DIR               = $(_BUILD_DIR_IPHONEOS_ARMV7S)$(_AR_DIR)
_ARMV7S_LIB_SDK              = $(_LIB_SDK_NAME)_armv7s.a
_ARMV7S_LIB_SDK_DIR          = $(_BUILD_DIR_IPHONEOS_ARMV7S)$(_ARMV7S_LIB_SDK)

_ARMV7_AR_DIR               = $(_BUILD_DIR_IPHONEOS_ARMV7)$(_AR_DIR)
_ARMV7_LIB_SDK              = $(_LIB_SDK_NAME)_armv7.a
_ARMV7_LIB_SDK_DIR          = $(_BUILD_DIR_IPHONEOS_ARMV7)$(_ARMV7_LIB_SDK)

_ARM64_AR_DIR               = $(_BUILD_DIR_IPHONEOS_ARM64)$(_AR_DIR)
_ARM64_LIB_SDK              = $(_LIB_SDK_NAME)_arm64.a
_ARM64_LIB_SDK_DIR          = $(_BUILD_DIR_IPHONEOS_ARM64)$(_ARM64_LIB_SDK)

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
else
_SRC_LIB_LOC_IPHONEOS		= $(BINARY_DIR)$(_DIR_DEBUG_IPHONEOS)
_SRC_LIB_LOC_IPHONSIMULATOR	= $(BINARY_DIR)$(_DIR_DEBUG_IPHONESIMULATOR)
endif

extract_base_sdk:
	$(_createBuildDirectories)
	$(_extractArmV6)
	$(_extractArmV7)
	$(_extractArm64)    
	$(_extracti386)
	$(_extractx8664)    
