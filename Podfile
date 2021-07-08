
require 'java-properties'
require 'plist'

properties = JavaProperties.load("app.properties")

facebookTracker = properties[:'app.tracker.facebook.class']
facebookSchema = properties[:'app.tracker.facebook.scheme']
appsflayerGioTracker = properties[:'app.tracker.appsflyer_gio.class']

plist = Plist.parse_xml("app/wing/Info.plist")
plist['AppTrackerClass'].clear()

platform :ios, '9.0'
use_frameworks!

target "wing" do
  pod 'Google/Analytics'
  pod 'IgaworksCore', '= 2.4.3'
# pod 'ZBarSDK' [iOS uiwebview 대응으로 주석, 추후 개발]

  pod 'CryptoSwift', '=1.4.0'
  pod 'SwiftKeychainWrapper', '=3.0.1'

  if !(facebookTracker == nil || facebookTracker.empty?)
    pod 'FBSDKCoreKit', '=9.3.0'
    pod 'FBSDKLoginKit', '=9.3.0'
    pod 'FBSDKShareKit', '=9.3.0'
    plist['AppTrackerClass'].push("wing.EventFacebook")
    plist['LSApplicationQueriesSchemes'].push(facebookSchema)
    plist['NSUserTrackingUsageDescription'] = "개인에게 최적화된 광고를 제공하기 위해 사용자의 광고 활동 정보를 수집합니다."
  end
  

  if !(appsflayerGioTracker == nil || appsflayerGioTracker.empty?)
    pod 'AppsFlyerFramework', '=4.8.11'
    plist['AppTrackerClass'].push("wing.EventAppsflyer")
    plist['NSUserTrackingUsageDescription'] = "개인에게 최적화된 광고를 제공하기 위해 사용자의 광고 활동 정보를 수집합니다."
  end
  
  plist.save_plist('app/wing/Info.plist')
end






