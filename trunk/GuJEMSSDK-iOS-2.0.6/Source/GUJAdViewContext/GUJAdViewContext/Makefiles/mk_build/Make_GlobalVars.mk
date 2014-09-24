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
MAKEFILE_DIR                    = mk/

# BUILD PROCESS
__DEBUG                         = -DDEBUG=1
__NO_DEBUG                      = -DDEBUG=0

_CONFIG_RELEASE                 = Release
_CONFIG_DEBUG                   = Debug
_ARCH_IPHONE_OS                 = "armv7 armv7s arm64"
_ARCH_IPHONE_SIMULATOR          = i386
_SDK_IPHONE_SIMULATOR           = iphonesimulator

_RELEASE_DIR_IPHONEOS           = Release-iphoneos/
_RELEASE_DIR_SIMULATOR          = Release-iphonesimulator/

_DEBUG_DIR_IPHONEOS             = Debug-iphoneos/
_DEBUG_DIR_SIMULATOR            = Debug-iphonesimulator/

_RESOURCES_DIR                  = Resources/
_RELEASE_DIR                    = $(BASE_BUILD_DIR)Build/
_BUILD_DIR                      = build/

_RELEASE_DIR_RELEASE_IPHONEOS	= $(_RELEASE_DIR)$(_RELEASE_DIR_IPHONEOS)
_RELEASE_DIR_RELEASE_SIMULATOR	= $(_RELEASE_DIR)$(_RELEASE_DIR_SIMULATOR)

_RELEASE_DIR_DEBUG_IPHONEOS     = $(_RELEASE_DIR)$(_DEBUG_DIR_IPHONEOS)
_RELEASE_DIR_DEBUG_SIMULATOR	= $(_RELEASE_DIR)$(_DEBUG_DIR_SIMULATOR)

_RELEASE_DIR_RESOURCES          = $(_RELEASE_DIR)$(_RESOURCES_DIR)

_createReleaseDir               = `mkdir -p $(_RELEASE_DIR_RELEASE_SIMULATOR) && \
				   mkdir -p $(_RELEASE_DIR_RELEASE_IPHONEOS) && \
				   mkdir -p $(_RELEASE_DIR_DEBUG_SIMULATOR) && \
				   mkdir -p $(_RELEASE_DIR_DEBUG_IPHONEOS) && \
				   mkdir -p $(_RELEASE_DIR_RESOURCES)`

_cleanReleaseDir                = `rm -Rf $(_RELEASE_DIR)`
