# StickyHeaderTabController

[![CI Status](http://img.shields.io/travis/bchrobot/StickyHeaderTabController.svg?style=flat)](https://travis-ci.org/bchrobot/StickyHeaderTabController)
[![Version](https://img.shields.io/cocoapods/v/StickyHeaderTabController.svg?style=flat)](http://cocoapods.org/pods/StickyHeaderTabController)
[![License](https://img.shields.io/cocoapods/l/StickyHeaderTabController.svg?style=flat)](http://cocoapods.org/pods/StickyHeaderTabController)
[![Platform](https://img.shields.io/cocoapods/p/StickyHeaderTabController.svg?style=flat)](http://cocoapods.org/pods/StickyHeaderTabController)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

StickyHeaderTabController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'StickyHeaderTabController'
```

## Usage

### StickyHeaderView
- width is set by `StickyHeaderTabController`
- height should be set by you
    - must not have priority >= 700 in order for stretch on vertical bounce to work.
    - be careful of compression resistance of subviews, especially imageviews.

### StickyHeroView
- width is set by `StickyHeaderTabController`
- height should be set by you
    - must not have any priorities lower than 250.

## Author

Benjamin Chrobot, benjamin.chrobot@alum.mit.edu

## License

StickyHeaderTabController is available under the MIT license. See the LICENSE file for more info.

