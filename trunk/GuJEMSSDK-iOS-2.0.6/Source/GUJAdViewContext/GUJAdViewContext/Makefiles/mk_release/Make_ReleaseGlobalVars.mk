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

__BASE_DIR__                = ./

_BUILD_LOG_DIR              = $(__BASE_DIR__)BuildLog/
__LOGFILE__                 = $(_BUILD_LOG_DIR)BuildRelease.log

_AR_DIR                     = ar/
_BUNDLE_DIR                 = $(BASE_BUILD_DIR)Bundle/

_BUILD_DIR                  = $(__BASE_DIR__)SDKBuild/
_BUILD_DIR_IPHONEOS_ARMV7S 	= $(_BUILD_DIR)/armv7s/
_BUILD_DIR_IPHONEOS_ARMV7 	= $(_BUILD_DIR)/armv7/
_BUILD_DIR_IPHONEOS_ARM64 	= $(_BUILD_DIR)/arm64/

_BUILD_IPHONESIMULATOR_i386	= $(_BUILD_DIR)/i386/
_BUILD_IPHONESIMULATOR_x8664	= $(_BUILD_DIR)/x86_64/

_DIR_RELEASE_IPHONEOS 		= $(__BASE_DIR__)Release-iphoneos/
_DIR_RELEASE_IPHONESIMULATOR	= $(__BASE_DIR__)Release-iphonesimulator/

_DIR_DEBUG_IPHONEOS 		= $(__BASE_DIR__)Debug-iphoneos/
_DIR_DEBUG_IPHONESIMULATOR 	= $(__BASE_DIR__)Debug-iphonesimulator/

_DIR_RELEASE_UNIVERSAL		= Release-universal/
_DIR_DEBUG_UNIVERSAL		= Debug-universal/

_DIR_RESOURCES              = Resources/

_DIR_RELEASE                = Release/
_DIR_DEBUG                  = Debug/

_TARGET_DIR_RELEASE         = $(_TARGET_DIR)$(_DIR_RELEASE)
_TARGET_DIR_DEBUG           = $(_TARGET_DIR)$(_DIR_DEBUG)
