//
//  AWSegmentedControl.swift
//  AWSegmentedControl
//
//  Created by Tana on 23.11.2020.
//

import UIKit

// MARK: - AWSegmentedControlDelegate

public protocol AWSegmentedControlDelegate: class {
    func segmented(control: AWSegmentedControl, didChange selectedIndex: Int)
}

// MARK: Segment

public struct Segment {
    public var title: String!
    public var image: String?
    public var selectedImage: String?
    public init(title: String, image: String? = nil, selectedImage: String? = nil) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
    }
}

// MARK: - UIControl

open class AWSegmentedControl: UIControl {
    
    // MARK: Properties
    
    @IBInspectable
    public var selectionRoundedCorners: CGFloat = 2
    
    @IBInspectable
    public var selectedSegmentIndex: Int = 0 { didSet { moveSelection() } }
    
    @IBInspectable
    public var minimumSegmentSize: CGSize = CGSize(width: 120, height: 22)
    
    @IBInspectable
    public var selectionColor: UIColor = .orange
    
    @IBInspectable
    public var selectedSegmentTextColor: UIColor = .white
    
    @IBInspectable
    public var segmentTextColor: UIColor = .black
    
    @IBInspectable
    public var segmentTextFont: UIFont? = UIFont.systemFont(ofSize: 12)
    
    @IBInspectable
    public var imageSizeRatio: Double = 0.5
    
    public var segments: [Segment] = [] {
        didSet {
            contentScrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
            setupView()
        }
    }
    public weak var delegate: AWSegmentedControlDelegate?
    
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
        view.layer.cornerRadius = selectionRoundedCorners
        view.layer.masksToBounds = true
        view.tag = 100
        view.backgroundColor = selectionColor
        contentScrollView.addSubview(view)
        contentScrollView.sendSubviewToBack(view)
        return view
    }()
    
    public func segment(of index: Int) -> Segment? {
        guard index < segments.count else { return nil }
        return segments[index]
    }
}

// MARK: - Designable

extension AWSegmentedControl {
    
    private var segmentWidth: CGFloat {
        get {
            max(minimumSegmentSize.width, self.bounds.size.width / CGFloat(self.segments.count))
        }
    }
    
    private var segmentHeight: CGFloat {
        get {
            max(minimumSegmentSize.height, bounds.size.height)
        }
    }
    
    private var contentWidth: CGFloat {
        get {
            segmentWidth * CGFloat(segments.count)
        }
    }
    
    private var contentHeight: CGFloat {
        get {
            segmentHeight
        }
    }
    
    private func setupView() {
        removeViews()
        render()
        moveSelection()
    }
    
    private func render() {
        
        var segmentPosition: CGPoint = {
            return CGPoint(x: 0, y: 0)
        }()
        
        segments.enumerated().forEach { (iterator, element) in
            let segmentButton = UIButton(type: .custom)
            segmentButton.frame = CGRect(x: segmentPosition.x, y: segmentPosition.y,
                                         width: segmentWidth, height: segmentHeight)
            segmentButton.setTitle(element.title, for: .normal)
            set(imageName: selectedSegmentIndex == iterator ? element.selectedImage : element.image, for: segmentButton)
            segmentButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            segmentButton.addTarget(self, action: #selector(changeSegmentAction(sender:)), for: .touchUpInside)
            segmentButton.tag = iterator
            segmentButton.titleLabel?.font = segmentTextFont
            segmentButton.setTitleColor(selectedSegmentIndex == iterator ?
                                            selectedSegmentTextColor : segmentTextColor,
                                        for: .normal)
            
            contentScrollView.addSubview(segmentButton)
            segmentPosition.x += segmentWidth
        }
    }
    
    private func moveSelection() {
        guard segments.count > 0 else { return }
        if segments.count < selectedSegmentIndex { selectedSegmentIndex = segments.count - 1 }
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.selectionView.frame = CGRect(x: CGFloat(strongSelf.selectedSegmentIndex) * strongSelf.segmentWidth,
                                                    y: 0,
                                                    width: strongSelf.segmentWidth,
                                                    height: strongSelf.segmentHeight)
        }
        
        contentScrollView.subviews.forEach { (view) in
            if let segmentButton = view as? UIButton,
               segmentButton.tag < 100 {
                let index = segmentButton.tag
                let segment = segments[index]
                
                UIView.performWithoutAnimation {
                    set(imageName: selectedSegmentIndex == index ? segment.selectedImage : segment.image, for: segmentButton)
                    segmentButton.setTitleColor(selectedSegmentIndex == index ?
                                                    selectedSegmentTextColor : segmentTextColor,
                                                for: .normal)
                }
            }
        }
        
        delegate?.segmented(control: self, didChange: selectedSegmentIndex)
    }
    
    private func removeViews() {
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
        selectedSegmentIndex = sender.tag
    }
}

// MARK: - Helpers

extension AWSegmentedControl {
    
    private func set(imageName: String?, for button: UIButton) {
        guard let imageName = imageName, let image = UIImage(named: imageName) else { return }
        
        let resizedImage = resize(image: image,
                                  segmentHeight * CGFloat(min(0.9, max(imageSizeRatio, 0.2))),
                                  opaque: false,
                                  contentMode: .scaleAspectFit)
        
        button.setImage(resizedImage, for: .normal)
    }
    
    private func resize(image: UIImage,
                        _ dimension: CGFloat,
                        opaque: Bool,
                        contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = image.size
        let aspectRatio =  size.width / size.height
        
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
