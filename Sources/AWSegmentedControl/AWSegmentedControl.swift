//
//  AWSegmentedControl.swift
//  AWSegmentedControl
//
//  Created by Tana on 23.11.2020.
//

import UIKit

// MARK: - Segment

struct Segment {
    var title: String!
    var image: String?
}

public protocol AWSegmentedControlDelegate: class {
    func segmented(control: AWSegmentedControl, didChange index: Int)
}

// MARK: - UIControl

open class AWSegmentedControl: UIControl {
    
    @IBInspectable
    var selectedIndex: Int = 0 { didSet { moveSelection() } }
    @IBInspectable
    var minimumSegmentSize: CGSize = CGSize(width: 120, height: 22)
    @IBInspectable
    var selectionColor: UIColor = .orange
    var segments: [Segment] = [] { didSet { setupView() } }
    weak var delegate: AWSegmentedControlDelegate?
    
    open override var bounds: CGRect {
        didSet {
            contentScrollView.frame = bounds
            contentScrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
            setupView()
        }
    }
    
    lazy private var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        self.addSubview(scrollView)
        return scrollView
    }() { didSet { setupView() } }
    
    lazy private var selectionView: UIView = {
        let view = UIView()
        view.backgroundColor = selectionColor
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.tag = 100
        contentScrollView.addSubview(view)
        contentScrollView.sendSubviewToBack(view)
        return view
    }()
}

// MARK: - Designable

extension AWSegmentedControl {
    
    var segmentWidth: CGFloat {
        get {
            max(minimumSegmentSize.width, self.bounds.size.width / CGFloat(self.segments.count))
        }
    }
    var segmentHeight: CGFloat {
        get {
            max(minimumSegmentSize.height, bounds.size.height)
        }
    }
    var contentWidth: CGFloat {
        get {
            segmentWidth * CGFloat(segments.count)
        }
    }
    var contentHeight: CGFloat {
        get {
            segmentHeight
        }
    }
    
    func setupView() {
        removeViews()
        render()
        moveSelection()
    }
    
    func render() {
        
        var segmentPosition: CGPoint = {
            return CGPoint(x: 0, y: 0)
        }()
        
        segments.enumerated().forEach { (iterator, element) in
            let segmentButton = UIButton(frame: CGRect(x: segmentPosition.x,
                                                       y: segmentPosition.y,
                                                       width: segmentWidth,
                                                       height: segmentHeight))
            segmentButton.setTitle(element.title, for: .normal)
            if let image = UIImage(named: element.image ?? String()) {
                let resizedImage = resize(image: image,
                                          segmentHeight / 2,
                                          opaque: false,
                                          contentMode: .scaleAspectFit)
                segmentButton.setImage(resizedImage, for: .normal)
            }
            segmentButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            segmentButton.addTarget(self, action: #selector(changeSegmentAction(sender:)), for: .touchUpInside)
            contentScrollView.addSubview(segmentButton)
            segmentButton.tag = iterator
            
            segmentPosition.x += segmentWidth
        }
    }
    
    func moveSelection() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.selectionView.frame = CGRect(x: CGFloat(strongSelf.selectedIndex) * strongSelf.segmentWidth,
                                         y: 0,
                                         width: strongSelf.segmentWidth,
                                         height: strongSelf.segmentHeight)
        }
        
    }
    
    func removeViews() {
        contentScrollView.subviews.forEach { (view) in
            if view.tag < 100 {
                view.removeFromSuperview()
            }
        }
    }
}

// MARK: - Actions

extension AWSegmentedControl {
    
    @objc private func changeSegmentAction(sender: UIButton) {
        selectedIndex = sender.tag
        delegate?.segmented(control: self, didChange: selectedIndex)
    }
}

// MARK: - Helpers

extension AWSegmentedControl {
    
    func resize(image: UIImage,
                _ dimension: CGFloat,
                opaque: Bool,
                contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = image.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {
                width = dimension
                height = dimension / aspectRatio
            } else {
                height = dimension
                width = dimension * aspectRatio
            }
            
        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
