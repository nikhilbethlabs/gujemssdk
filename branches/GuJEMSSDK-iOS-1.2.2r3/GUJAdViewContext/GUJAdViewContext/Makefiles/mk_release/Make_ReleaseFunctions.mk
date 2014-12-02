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
# 2012/11 Sven Ewert (sven.ewert@somo.de)
#
#
_clean_build                = `rm -rf $(_BUILD_DIR)`
_clean_libraries            = `rm -rf $(_TARGET_DIR)`

_createBuildDirectories 	= `mkdir -p $(_BUILD_DIR_IPHONEOS_ARMV6) && \
                                mkdir -p $(_BUILD_DIR_IPHONEOS_ARMV7) && \
                                mkdir -p $(_BUILD_IPHONESIMULATOR_i386)`

_createTargetDirectories 	= `mkdir -p $(_TARGET_DIR_RELEASE)$(_DIR_RELEASE_IPHONEOS) && \
                                mkdir -p $(_TARGET_DIR_DEBUG)$(_DIR_DEBUG_IPHONEOS) && \
                                mkdir -p $(_TARGET_DIR_RELEASE)$(_DIR_RELEASE_IPHONESIMULATOR) && \
                                mkdir -p $(_TARGET_DIR_DEBUG)$(_DIR_DEBUG_IPHONESIMULATOR)` 
                   
# universal libs will cause errors in ORMMA
#&& \ mkdir -p $(_TARGET_DIR_RELEASE)$(_DIR_RELEASE_UNIVERSAL) 
#&& \ mkdir -p $(_TARGET_DIR_DEBUG)$(_DIR_DEBUG_UNIVERSAL)`

# EXTRACT
_extractArmV6               = `lipo -thin armv6 $(_SRC_LIB_LOC_IPHONEOS)$(_SOURCE_LIB_SDK)  -output $(_ARMV6_LIB_SDK_DIR) && \
                                mkdir -p $(_ARMV6_AR_DIR) && cd $(_ARMV6_AR_DIR) && ar -x ../$(_ARMV6_LIB_SDK) && rm -f __.SYMDEF && cd $(PWD)`

_extractArmV7               = `lipo -thin armv7 $(_SRC_LIB_LOC_IPHONEOS)$(_SOURCE_LIB_SDK)  -output $(_ARMV7_LIB_SDK_DIR) && \
                                mkdir -p $(_ARMV7_AR_DIR) && cd $(_ARMV7_AR_DIR) &&  ar -x ../$(_ARMV7_LIB_SDK) && rm -f __.SYMDEF && cd $(PWD)`

_extracti386                = `cp -a $(_SRC_LIB_LOC_IPHONSIMULATOR)$(_SOURCE_LIB_SDK_SIM) $(_i386_LIB_SDK_DIR) && \
                                mkdir -p $(_i386_AR_DIR) && cd $(_i386_AR_DIR) &&  ar -x ../$(_i386_LIB_SDK) && rm -f __.SYMDEF && cd $(PWD)`

# MERGE
_createMergedLibArmV6		= `cd $(_ARMV6_AR_DIR) && ar -rcs $(_ARMV6_LIB_MERGED) *.o  && rm -f *.o && mv $(_ARMV6_LIB_MERGED) ../ && cd $(PWD) && rm -Rf $(_ARMV6_AR_DIR)`

_createMergedLibArmV7		= `cd $(_ARMV7_AR_DIR) && ar -rcs $(_ARMV7_LIB_MERGED) *.o  && rm -f *.o && mv $(_ARMV7_LIB_MERGED) ../ && cd $(PWD) && rm -Rf $(_ARMV7_AR_DIR)`

_createMergedLibi386		= `cd $(_i386_AR_DIR) && ar -rcs $(_i386_LIB_MERGED) *.o  && rm -f *.o && mv $(_i386_LIB_MERGED) ../ && cd $(PWD) && rm -Rf $(_i386_AR_DIR)`


# BUILD
_copyMergedLibi386Library	= `cp -a $(_BUILD_IPHONESIMULATOR_i386)$(_i386_LIB_MERGED) $(_LIB_IPHONESIMULATOR)`

_createFatiPhoneOSLibrary	= `lipo -arch armv6 $(_BUILD_DIR_IPHONEOS_ARMV6)$(_ARMV6_LIB_MERGED) -arch armv7 $(_BUILD_DIR_IPHONEOS_ARMV7)$(_ARMV7_LIB_MERGED) -create -output $(_LIB_IPHONEOS)`

_createFatUniversalLibrary  = 

# universal libs will cause errors in ORMMA
_createFatUniversalLibrary_ = `lipo -arch armv6 $(_BUILD_DIR_IPHONEOS_ARMV6)$(_ARMV6_LIB_MERGED) -arch armv7 $(_BUILD_DIR_IPHONEOS_ARMV7)$(_ARMV7_LIB_MERGED) -arch i386 $(_BUILD_IPHONESIMULATOR_i386)$(_i386_LIB_MERGED) -create -output $(_LIB_UNIVERSAL)`


clean: clean_traget clean_build

clean_traget:
	$(_clean_libraries)

clean_build: 
	$(_clean_build)