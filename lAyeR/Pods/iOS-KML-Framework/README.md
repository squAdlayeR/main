# iOS-KML-Framework

[![Version](http://cocoapod-badges.herokuapp.com/v/iOS-KML-Framework/badge.png)](http://cocoadocs.org/docsets/iOS-KML-Framework)
[![Platform](http://cocoapod-badges.herokuapp.com/p/iOS-KML-Framework/badge.png)](http://cocoadocs.org/docsets/iOS-KML-Framework)

This is a iOS framework for parsing/generating KML files.
This Framework parses the KML from a URL or Strings and create Objective-C Instances of KML structure. 

## Usage

```objc
#import "KML.h"
...

// Parsing the KML

KMLRoot *root = [KMLParser parseKMLWithString:kml];


// Generating the KML

KMLRoot *root = [KMLRoot new];

KMLDocument *doc = [KMLDocument new];
root.feature = doc;

KMLPlacemark *placemark = [KMLPlacemark new];
placemark.name = @"Simple placemark";
placemark.descriptionValue = @"Attached to the ground.";
[doc addFeature:placemark];

KMLPoint *point = [KMLPoint new];
placemark.geometry = point;

KMLCoordinate *coordinate = [KMLCoordinate new];
coordinate.latitude = 37.422f;
coordinate.longitude = -122.082f;
point.coordinate = coordinate;
```

## Requirements

- iOS 6.0 or later

## Installation

iOS-KML-Framework is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod 'iOS-KML-Framework', :git => 'https://github.com/FLCLjp/iOS-KML-Framework.git'

## Author

Watanabe Toshinori, t@flcl.jp

## License

iOS-KML-Framework is available under the MIT license. See the LICENSE file for more info.
