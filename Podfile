
require 'java-properties'
require 'plist'

properties = JavaProperties.load("app.properties")

facebookTracker = properties[:'app.tracker.facebook.class']
appsflayerTracker = properties[:'app.tracker.appsflyer.class']

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
  end
  

  if !(appsflayerTracker == nil || appsflayerTracker.empty?)
    pod 'AppsFlyerFramework', '=4.8.11'
    plist['AppTrackerClass'].push("wing.EventAppsflyer")
  end
  
  plist.save_plist('app/wing/Info.plist')
end






