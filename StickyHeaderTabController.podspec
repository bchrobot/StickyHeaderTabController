#
# Be sure to run `pod lib lint StickyHeaderTabController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'StickyHeaderTabController'
  s.version          = '0.2.0'
  s.summary          = 'Tabbed content controller with sticky header and hero.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Twitter profile-inspired tabbed content controller with sticky header and hero.
                       DESC

  s.homepage         = 'https://github.com/bchrobot/StickyHeaderTabController'
  s.screenshots      = 'https://github.com/slackhq/SlackTextViewController/raw/master/Screenshots/screenshot_01.png', 'https://github.com/slackhq/SlackTextViewController/raw/master/Screenshots/screenshot_02.png', 'https://github.com/slackhq/SlackTextViewController/raw/master/Screenshots/screenshot_03.png', 'https://github.com/slackhq/SlackTextViewController/raw/master/Screenshots/screenshot_04.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Benjamin Chrobot' => 'benjamin.chrobot@alum.mit.edu' }
  s.source           = { :git => 'https://github.com/bchrobot/StickyHeaderTabController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/bchrobot'

  s.ios.deployment_target = '9.0'

  s.source_files = 'StickyHeaderTabController/Classes/**/*'

  # s.resource_bundles = {
  #   'StickyHeaderTabController' => ['StickyHeaderTabController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

