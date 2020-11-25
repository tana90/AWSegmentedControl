# AWSegmentedControl
## Simple - lightweight Segmented Control

## Features
- [x] Segment image support with resize feature
- [x] Animated when segment is changed
- [x] Very customizable
- [x] Written in Swift


### Examples

Created programatically 
```swift
lazy var segmentedControl: AWSegmentedControl! = {
        let segmentedControl = AWSegmentedControl()
        segmentedControl.delegate = self
        segmentedControl.selectionRoundedCorners = 22
        segmentedControl.imageSizeRatio = 0.7
        segmentedControl.selectionColor = .blue 
        segmentedControl.selectedSegmentTextColor = .white
        segmentedControl.segmentTextColor = .black
        segmentedControl.segments = [
            Segment(title: "Segment 1", image: "followers", selectedImage: "likes"),
            Segment(title: "Segment 2", image: "engagement"),
            Segment(title: "Segment 3", image: "likes")
        ]
        return segmentedControl
    }()
```

Loaded from XIB
```swift
import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private weak var segmentedControl: AWSegmentedControl!
    @IBOutlet private weak var textLabel: UILabel!

    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.delegate = self
        segmentedControl.segments = [
            Segment(title: "Segment 1", image: "followers", selectedImage: "likes"),
            Segment(title: "Segment 2", image: "engagement"),
            Segment(title: "Segment 3", image: "likes")
        ]
    }
}

extension ViewController: AWSegmentedControlDelegate {
    
    internal func segmented(control: AWSegmentedControl, didChange selectedIndex: Int) {
        textLabel.text = control.segment(of: selectedIndex)?.title
    }
}
```

## Requirements

- iOS 12.0+
- Swift 5.0+


## How it looks
<p align="left">
<img src="https://github.com/tana90/AWSegmentedControl/blob/master/example1-image.png?raw=true" width="357"/>
</p>


## Contributors
[@tana90]