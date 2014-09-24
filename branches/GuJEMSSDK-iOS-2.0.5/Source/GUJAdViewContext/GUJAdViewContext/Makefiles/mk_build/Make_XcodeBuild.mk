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
# SDK Simulator
_cleanBuildDir_SDK          = `rm -rf $(_SOURCE_DIR_SDK)build/*`
_clean_SDK_ReleaseSimulator	= xcodebuild -project $(_PRJ_SDK) -target $(_TRGT_SDK_SIMULATOR) -configuration $(_CONFIG_RELEASE) -sdk $(_SDK_IPHONE_SIMULATOR) -arch $(_ARCH_IPHONE_SIMULATOR) clean
_clean_SDK_DebugSimulator	= xcodebuild -project $(_PRJ_SDK) -target $(_TRGT_SDK_SIMULATOR) -configuration $(_CONFIG_DEBUG)   -sdk $(_SDK_IPHONE_SIMULATOR) -arch $(_ARCH_IPHONE_SIMULATOR) clean
_build_SDK_ReleaseSimulator = xcodebuild -project $(_PRJ_SDK) -target $(_TRGT_SDK_SIMULATOR) -configuration $(_CONFIG_RELEASE) -sdk $(_SDK_IPHONE_SIMULATOR) -arch $(_ARCH_IPHONE_SIMULATOR) $(__NO_DEBUG) build
_build_SDK_DebugSimulator 	= xcodebuild -project $(_PRJ_SDK) -target $(_TRGT_SDK_SIMULATOR) -configuration $(_CONFIG_DEBUG)   -sdk $(_SDK_IPHONE_SIMULATOR) -arch $(_ARCH_IPHONE_SIMULATOR) $(__DEBUG)    build

# SDK iPhoneOS
_clean_SDK_ReleaseiPhoneOS	= xcodebuild -project $(_PRJ_SDK) -target $(_TRGT_SDK_IPHONEOS) -configuration $(_CONFIG_RELEASE) -arch $(_ARCH_IPHONE_OS) clean
_clean_SDK_DebugiPhoneOS	= xcodebuild -project $(_PRJ_SDK) -target $(_TRGT_SDK_IPHONEOS) -configuration $(_CONFIG_DEBUG)   -arch $(_ARCH_IPHONE_OS) clean
_build_SDK_ReleaseiPhoneOS	= xcodebuild -project $(_PRJ_SDK) -target $(_TRGT_SDK_IPHONEOS) -configuration $(_CONFIG_RELEASE) -arch $(_ARCH_IPHONE_OS) $(__NO_DEBUG) build
_build_SDK_DebugiPhoneOS	= xcodebuild -project $(_PRJ_SDK) -target $(_TRGT_SDK_IPHONEOS) -configuration $(_CONFIG_DEBUG)   -arch $(_ARCH_IPHONE_OS) $(__DEBUG)    build

# SDK copy build
_copy_SDK_ReleaseiPhoneOS 	= `cp -a $(_SOURCE_DIR_SDK)$(_BUILD_DIR)$(_RELEASE_DIR_IPHONEOS)*.h  $(_RELEASE_DIR_RELEASE_IPHONEOS) && \
				   cp -a $(_SOURCE_DIR_SDK)$(_BUILD_DIR)$(_RELEASE_DIR_IPHONEOS)*.a  $(_RELEASE_DIR_RELEASE_IPHONEOS) && \
				   cp -a $(_SOURCE_DIR_SDK)$(_BUILD_DIR)$(_RELEASE_DIR_SIMULATOR)*.h $(_RELEASE_DIR_RELEASE_SIMULATOR) && \
				   cp -a $(_SOURCE_DIR_SDK)$(_BUILD_DIR)$(_RELEASE_DIR_SIMULATOR)*.a $(_RELEASE_DIR_RELEASE_SIMULATOR)`

_copy_SDK_DebugiPhoneOS 	= `cp -a $(_SOURCE_DIR_SDK)$(_BUILD_DIR)$(_DEBUG_DIR_IPHONEOS)*.h  $(_RELEASE_DIR_DEBUG_IPHONEOS) && \
				   cp -a $(_SOURCE_DIR_SDK)$(_BUILD_DIR)$(_DEBUG_DIR_IPHONEOS)*.a  $(_RELEASE_DIR_DEBUG_IPHONEOS) && \
				   cp -a $(_SOURCE_DIR_SDK)$(_BUILD_DIR)$(_DEBUG_DIR_SIMULATOR)*.h $(_RELEASE_DIR_DEBUG_SIMULATOR) && \
				   cp -a $(_SOURCE_DIR_SDK)$(_BUILD_DIR)$(_DEBUG_DIR_SIMULATOR)*.a $(_RELEASE_DIR_DEBUG_SIMULATOR)`