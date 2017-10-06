# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2017-10-06
### Fixed
- Pod spec screenshot location.

## [0.2.0] - 2017-10-06
### Added
- `stickyHeaderTabController(_, didUpdateCompoundHeaderHeight:)` delegate method.
- Screenshots to Cocoapod spec.

### Fixed
- Content jump due to short tab content being pinned to tab bar after switching tabs.

## [0.1.0] - 2017-10-05
### Added
- Static profile components.
- Example project profile.
- Selected state for tab bar.
- Proper calculations for tab contentInset.
- Scrolling of sticky components.
- Synchronization of horizontal scrolling and tab selection.
- Customization of `StickyHeaderTabBarView`.
- Name label position and cover photo blur animations based on scroll.

### Changed
- Updated copyright notices.
- TabBar bottom border is now drawn rather than it's own subview.

### Fixed
- Vertical scrolling of tabs within horizontal container.
- Tab bar width calculation.

## 0.0.1 - 2017-09-21
### Added
- This CHANGELOG file.

[Unreleased]: https://github.com/bchrobot/StickyHeaderTabController/compare/0.2.1...HEAD
[0.2.1]: https://github.com/bchrobot/StickyHeaderTabController/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/bchrobot/StickyHeaderTabController/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/bchrobot/StickyHeaderTabController/compare/0.0.1...0.1.0
