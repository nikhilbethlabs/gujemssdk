_BASE_BUILD_DIR_		= $(PROJECT_DIR)/../GUJ_EMS_SDK_BUNDLE/
_LOG_DIR_			= $(_BASE_BUILD_DIR_)BuildLog/

__LOGFILE__			= $(_LOG_DIR_)Build.log

_MAKEFILE_DIR_BUILD		= mk_build/
_MAKEFILE_DIR_RELEASE		= mk_release/

_cleanBuildDir			= `rm -Rf $(_BASE_BUILD_DIR_)`
_createLogDir			= `mkdir -p $(_LOG_DIR_)`
_cleanLogDir			= `rm -Rf $(_LOG_DIR_)`

_make_base_sdk_release 		= `make -f $(_MAKEFILE_DIR_BUILD)Make_Base.mk release_base_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`
_make_base_sdk_debug 		= `make -f $(_MAKEFILE_DIR_BUILD)Make_Base.mk debug_base_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`

_make_ormma_sdk_release 	= `make -f $(_MAKEFILE_DIR_BUILD)Make_Ormma.mk release_ormma_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`
_make_ormma_sdk_debug 		= `make -f $(_MAKEFILE_DIR_BUILD)Make_Ormma.mk debug_ormma_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`
_make_ormma_resources 		= `make -f $(_MAKEFILE_DIR_BUILD)Make_Ormma.mk release_ormma_resources MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_)  >> $(__LOGFILE__)`

_make_mocean_sdk_release 	= `make -f $(_MAKEFILE_DIR_BUILD)Make_Mocean.mk release_mocean_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`
_make_mocean_sdk_debug 		= `make -f $(_MAKEFILE_DIR_BUILD)Make_Mocean.mk debug_mocean_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`

_make_xaxsis_sdk_release 	= `make -f $(_MAKEFILE_DIR_BUILD)Make_Xaxsis.mk release_xaxsis_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`
_make_xaxsis_sdk_debug 		= `make -f $(_MAKEFILE_DIR_BUILD)Make_Xaxsis.mk debug_xaxsis_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`

_make_adviewctx_sdk_release 	= `make -f $(_MAKEFILE_DIR_BUILD)Make_AdViewContext.mk release_adviewctx_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`
_make_adviewctx_sdk_debug 	= `make -f $(_MAKEFILE_DIR_BUILD)Make_AdViewContext.mk debug_adviewctx_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`

_make_external_sdks 		= `make -f $(_MAKEFILE_DIR_BUILD)Make_3rdparty.mk prepare_all_extrenal_sdks MAKEFILE_DIR=$(_MAKEFILE_DIR_BUILD) BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`


_release_ormma_sdk 		= `make -f $(_MAKEFILE_DIR_RELEASE)Make_ReleaseOrmmaSDK.mk build_ormma_sdk RELEASE=YES MAKEFILE_DIR=$(_MAKEFILE_DIR_RELEASE) _BUILD_LOG_DIR=$(_LOG_DIR_) BINARY_DIR=$(_BASE_BUILD_DIR_)Build/ BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`
_debug_ormma_sdk 		= `make -f $(_MAKEFILE_DIR_RELEASE)Make_ReleaseOrmmaSDK.mk build_ormma_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_RELEASE) _BUILD_LOG_DIR=$(_LOG_DIR_) BINARY_DIR=$(_BASE_BUILD_DIR_)Build/ BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`

_release_mocean_sdk 		= `make -f $(_MAKEFILE_DIR_RELEASE)Make_ReleaseMoceanSDK.mk build_mocean_sdk RELEASE=YES MAKEFILE_DIR=$(_MAKEFILE_DIR_RELEASE) _BUILD_LOG_DIR=$(_LOG_DIR_) BINARY_DIR=$(_BASE_BUILD_DIR_)Build/ BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`
_debug_mocean_sdk 		= `make -f $(_MAKEFILE_DIR_RELEASE)Make_ReleaseMoceanSDK.mk build_mocean_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_RELEASE) _BUILD_LOG_DIR=$(_LOG_DIR_) BINARY_DIR=$(_BASE_BUILD_DIR_)Build/ BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`

_release_xaxsis_sdk 		= `make -f $(_MAKEFILE_DIR_RELEASE)Make_ReleaseXaxsisSDK.mk build_xaxsis_sdk RELEASE=YES MAKEFILE_DIR=$(_MAKEFILE_DIR_RELEASE) _BUILD_LOG_DIR=$(_LOG_DIR_) BINARY_DIR=$(_BASE_BUILD_DIR_)Build/ BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`
_debug_xaxsis_sdk 		= `make -f $(_MAKEFILE_DIR_RELEASE)Make_ReleaseXaxsisSDK.mk build_xaxsis_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_RELEASE) _BUILD_LOG_DIR=$(_LOG_DIR_) BINARY_DIR=$(_BASE_BUILD_DIR_)Build/ BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`

_release_adviewctx_sdk 		= `make -f $(_MAKEFILE_DIR_RELEASE)Make_ReleaseAdViewCtx.mk build_adview_sdk RELEASE=YES MAKEFILE_DIR=$(_MAKEFILE_DIR_RELEASE) _BUILD_LOG_DIR=$(_LOG_DIR_) BINARY_DIR=$(_BASE_BUILD_DIR_)Build/ BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`
_debug_adviewctx_sdk 		= `make -f $(_MAKEFILE_DIR_RELEASE)Make_ReleaseAdViewCtx.mk build_adview_sdk MAKEFILE_DIR=$(_MAKEFILE_DIR_RELEASE) _BUILD_LOG_DIR=$(_LOG_DIR_) BINARY_DIR=$(_BASE_BUILD_DIR_)Build/ BASE_BUILD_DIR=$(_BASE_BUILD_DIR_) >> $(__LOGFILE__)`

all: build_all all_sdks

build_all: clean build_base_sdk build_ormma_sdk build_mocean_sdk build_xaxsis_sdk build_adviewctx_sdk build_external_sdks

clean_log: 
	$(_cleanLogDir)

clean_build:
	$(_cleanBuildDir)

clean:	clean_build clean_log

ormma_sdk_release:
	$(_createLogDir)
	$(_release_ormma_sdk)

ormma_sdk_debug:
	$(_createLogDir)
	$(_debug_ormma_sdk)

ormma_sdk:
	$(_cleanLogDir)
	$(_createLogDir)
	$(_release_ormma_sdk)
	$(_debug_ormma_sdk)

mocean_sdk_release:
	$(_createLogDir)
	$(_release_mocean_sdk)

mocean_sdk_debug:
	$(_createLogDir)
	$(_debug_mocean_sdk)

mocean_sdk:
	$(_cleanLogDir)
	$(_createLogDir)
	$(_release_mocean_sdk)
	$(_debug_mocean_sdk)

xaxsis_sdk_release:
	$(_createLogDir)
	$(_release_xaxsis_sdk)

xaxsis_sdk_debug:
	$(_createLogDir)
	$(_debug_xaxsis_sdk)

xaxsis_sdk:
	$(_cleanLogDir)
	$(_createLogDir)
	$(_release_xaxsis_sdk)
	$(_debug_xaxsis_sdk)

adview_ctx_release:
	$(_createLogDir)
	$(_release_adviewctx_sdk)

adview_ctx_debug:
	$(_createLogDir)
	$(_debug_adviewctx_sdk)

adview_ctx:
	$(_cleanLogDir)
	$(_createLogDir)
	$(_release_adviewctx_sdk)
	$(_debug_adviewctx_sdk)

all_sdks:
	$(_cleanLogDir)
	$(_createLogDir)
	$(_release_adviewctx_sdk)
	$(_debug_adviewctx_sdk)	
	$(_release_xaxsis_sdk)
	$(_debug_xaxsis_sdk)
	$(_release_mocean_sdk)
	$(_debug_mocean_sdk)
	$(_release_ormma_sdk)
	$(_debug_ormma_sdk)

build_base_sdk:
	$(_createLogDir)
	$(_make_base_sdk_release)
	$(_make_base_sdk_debug)

build_ormma_sdk:
	$(_createLogDir)
	$(_make_ormma_sdk_release)
	$(_make_ormma_sdk_debug)
	$(_make_ormma_resources)

build_mocean_sdk:
	$(_createLogDir)
	$(_make_mocean_sdk_release)
	$(_make_mocean_sdk_debug)

build_xaxsis_sdk:
	$(_createLogDir)
	$(_make_xaxsis_sdk_release)
	$(_make_xaxsis_sdk_debug)

build_adviewctx_sdk:
	$(_createLogDir)
	$(_make_adviewctx_sdk_release)
	$(_make_adviewctx_sdk_debug)
	
build_external_sdks:
	$(_createLogDir)
	$(_make_external_sdks)
