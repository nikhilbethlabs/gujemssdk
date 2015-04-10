# Introduction #

Android SDK change history and downloads

# Details #

## Downloads (Google Drive) ##

[Android SDK Sample App Binary (APK)](https://drive.google.com/file/d/0B5R-ThsBtb-3X3A1RE80ZFRnQjQ/view?usp=sharing)

---

[Android SDK Library Project (Eclipse ADT)](https://drive.google.com/file/d/0B5R-ThsBtb-3M1dSV1Q2MnFEenM/view?usp=sharing)

---

[Android SDK Dokumentation (DE)](https://drive.google.com/file/d/0B5R-ThsBtb-3aXhKYmhjTFZZT3c/view?usp=sharing)

---

[Android SDK documentation (EN)](https://drive.google.com/file/d/0B5R-ThsBtb-3TnFIYjFoeDA0dGc/view?usp=sharing)
## Changelog ##

|**Version**      |**Loginformation**|
|:----------------|:-----------------|
|v 1.4|Compatibility with Android SDK Tools 23.0.5|
|  |Compatibility with Android SDK Platform-tools 21.0.0|
|  |Compatibility with Android 5.0 ("Lollipop", API21) and lower (>=API8)|
|  |Compatibility with Google Play Services 21.0.0|
|  |Removed all references to mOcean SDK|
|  |Removed Android Device ID|
|  |Added default backfill via Google|
|  |Added adsquare service (Remote Targeting Service ist drin)|
|  |Added weather targeting (Remote Targeting Service ist drin)|
|  |Added support for retina ads|
|  |Added ability to distinguish between large devices (i.e. tablets) and normal|
|  |Added velocity to GPS data|
|  |Added altitude to GPS data|
|  |Added Google Advertising Identifier|
|  |Changed Ad Requests from using AsyncTask to using IntentService|
|  |Fixed a bug where native tests ads would not be displayed|
|  |Fixed a bug where an ORMMA error would display when returning to an activity/a fragment|
|  |Fixed a bug where isHeadsetConnected would always return false|
|  |Fixed a bug where VAST XML starting with XML doc declaration was incorrectly parsed|
|  |Fixed a bug where ads would not scale to the ad view size (if ad was larger)|
|  |Fixed some static references that were prone to not being thread safe|
|  |Fixed clicking on test ads to open our web site|
|  |Updated the sample application (fragments, drawer, ...)|
|v 1.3.1.2|Fixed problems with Google Ads|
|v 1.3.1.1|Removed AdMob SDK|
|  |	Added Google Play Library|
|  |	Updated mOcean SDK to v1.3.2|
|v 1.3.1|Added English localization|
|  |	Added high resolution icons|
|  |	Added native adviews|
|  |	Added support for Android 4.4 (KitKat) Chrome webview|
|  |	Added ability to shorten geocoords via settings.xml|
|  |	Added test mode via settings.xml|
|  |	App manifest no longer needs SDK declarations (merged manifest)|
|  |	Fixed optimobile banner size|
|  |	Fixed Smartstream SDK resources|
|  |	Optimized optimobile in ListViews|
|  |	Reduced view swapping|
|  |	Removed deprecated InterstitialSwitchActivity|
|  |	Code merging and cleaning|
|  |	Compatibility with Android SDK Tools rev.22.3|
|  |	Compatibility with Android SDK Plattform-Tools rev.19|
|  |	More bugfixes|
|  |	Updated documentation|
|v 1.3       | Bugfixes |
|  |	New targeting methods |
|  |	New in-ad javascript methods |
|  |	Updated **Google AdMob Android SDK to v6.4.1** |
|  |	Updated **mOcean Android SDK to v3.0.3** |
|  |	Compatibility with **Android SDK Tools rev.22.0.5** |
|  |	Compatibility with **Android SDK Platform-Tools rev.18.0.1** |
|  |	**New ad format: video interstitial** |
|  |	**Interstitials no longer force portrait mode** |
|  |	"Cookie replacement" as Android device identifier alternative |
|  |	Transmission of version of Android SDK for compatibility concerns |
|  |	New SdkUtil methods for phone state access |
|v 1.2.5        | Listener Klassen für AdViews: onAdEmpty, onAdSuccess, onAdError |
|  |	Interstitials without target |
|  |	Interstitials as BroadcastReceivers instead of Activity |
|  |	optimobile Integration |
|  |	Google AdMob Integration |
|  |	Upgrade to ADT rev.21.x, adjusted resource handling |
|  |	Reworked connectivity class |
|  |	Adjusted permissions |
|  |	For listviews: New view **GuJEMSListAdView** |
|v 1.2.1        | Change in Android Resource Handling |
|v 1.0          | First Android SDK with XAXIS SDK Integration |