# NXMActionSheet

[![CI Status](http://img.shields.io/travis/nExmond/NXMActionSheet.svg?style=flat)](https://travis-ci.org/nExmond/NXMActionSheet)
[![Version](https://img.shields.io/cocoapods/v/NXMActionSheet.svg?style=flat)](http://cocoapods.org/pods/NXMActionSheet)
[![License](https://img.shields.io/cocoapods/l/NXMActionSheet.svg?style=flat)](http://cocoapods.org/pods/NXMActionSheet)
[![Platform](https://img.shields.io/cocoapods/p/NXMActionSheet.svg?style=flat)](http://cocoapods.org/pods/NXMActionSheet)
[![Language](https://img.shields.io/badge/swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)

## Preview

![demo](https://github.com/nExmond/NXMActionSheet/blob/master/Images/demo.gif)

## Requirements

Written as Swift 4 and tested on iOS 9.

## Installation

NXMActionSheet is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NXMActionSheet'
```

## Usage

```swift
import NXMActionSheet
```
### Basic

Chaining
```swift
//add items
add(imageViewData)
.add(datas: labelViewDataList)
.insert(twoButtonData, at: 0)
.end(oneButtonData)

```
Default views make it easy to show

```swift
NXMActionSheet()
            .add(NXMActionSheetData(.IMAGE(#imageLiteral(resourceName: "image"))))
            .add(NXMActionSheetData(.ACTIVITY_INDICATOR(.gray)))
            .add(NXMActionSheetData(.SLIDER(0.5, nil)))
            .add(NXMActionSheetData(.LABEL("Label")))
            .add(NXMActionSheetData(.BUTTON("Button", UIColor.brown, nil), withTouchClose: true))
            .show()
```


### Inherit & Custom
When using inheritance, be sure to include the following functions
```swift
class CustomActionSheet : NXMActionSheet {
    
    convenience init (withType:NXMActionSheetAnimationType = .SLIDE) {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
```

Create .xib and .swift with the same name and use it as follows
```swift
//ImageView
let imageView:CustomImageView = CustomImageView.loadUINibView()
imageView.ImageView.image = /*image*/
let imageViewData = NXMActionSheetData(.CUSTOM(imageView))
...
add(imageViewData)
```
please check the example for details



### Delegate
```swift
//require
func didSelectActionItem(_ actionSheet:NXMActionSheet, withData:NXMActionSheetData)

//optional
func actionSheetWillShow()
func actionSheetDidShow()
func actionSheetWillHide()
func actionSheetDidHide()
func actionSheetWillUpdate()
func actionSheetDidUpdate()
```

## !!
If content height in UITableView is larger than UIScreen height, scrolling is enabled.
However, if you set the scroll position on update, it is possible that the transition is not smooth.


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

nExmond, rnpfr254@naver.com

## License

NXMActionSheet is available under the MIT license. See the LICENSE file for more info.
