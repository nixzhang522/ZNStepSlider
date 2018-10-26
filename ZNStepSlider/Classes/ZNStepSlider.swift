//
//  ZNStepSlider.swift
//  ZNStepSlider_Example
//
//  Created by Nix on 2018/10/23.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

func WithoutCAAnimation(code: () -> Void) {
    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    code()
    CATransaction.commit()
}

@IBDesignable
public class ZNStepSlider: UIControl {
    
    /// change with timer
    @IBInspectable public var value: CGFloat = 0.0 {
        didSet {
            guard isTouched else {
                self.setNeedsLayout()
                return
            }
        }
    }
    
    @IBInspectable public var index: Int = 0 {
        didSet {
            self.updateIndex()
            self.sendActions(for: .valueChanged)
        }
    }
    
    /// scales must not be empty
    public var scales: [CGFloat] = [] {
        didSet {
            self.updateIndex()
            self.setNeedsLayout()
        }
    }
    
    /// scale noraml color
    @IBInspectable public var scaleNormalColor: UIColor = UIColor.gray
    
    /// scale selected color
    @IBInspectable public var scaleSelectedColor: UIColor = UIColor.green
    
    /// scale radius
    @IBInspectable public var scaleCircleRadius: CGFloat = 1.5 {
        didSet {
            self.updateDiff()
            self.updateMaxRadius()
        }
    }
    
    /// track height
    @IBInspectable public var trackHeight: CGFloat = 3.0 {
        didSet {
            self.updateDiff()
        }
    }
    
    /// track color
    @IBInspectable public var trackColor: UIColor = UIColor.lightGray
    
    /// slider radius
    @IBInspectable public var sliderCircleRadius: CGFloat = 5.0 {
        didSet {
            self.updateMaxRadius()
        }
    }

    /// slider color
    @IBInspectable public var sliderCircleColor: UIColor = UIColor.red

    /// slider image
    @IBInspectable public var sliderCircleImage: UIImage?
    
    /// Whether to rest on the nearest scale after sliding, default false
    @IBInspectable public var isSliderScale = false
    
    var trackLayer: CAShapeLayer = CAShapeLayer.init()
    
    var sliderCircleLayer: CAShapeLayer = {
        var layer = CAShapeLayer.init()
        layer.contentsScale = UIScreen.main.scale
        return layer
    }()
    
    var scaleCirclesArray: [CAShapeLayer] = []
    
    var scaleCircleImages: [Int: UIImage] = [:]
    
    var animationLayouts = true
    
    var maxRadius: CGFloat = 0
    
    var diff: CGFloat = 0
    
    var startTouchPosition: CGPoint?
    
    var startSliderPosition: CGPoint?
    
    var contentSize: CGSize?
    
    var isTouched = false
    
    
    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    override public var intrinsicContentSize: CGSize {
        return contentSize!
    }
    
    override public func prepareForInterfaceBuilder() {
        self.updateMaxRadius()
        super.prepareForInterfaceBuilder()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layoutLayersAnimated(animationLayouts)
        animationLayouts = false
    }
    
    override public var tintColor: UIColor! {
        didSet {
            super.tintColor = tintColor
            self.setNeedsLayout()
        }
    }
    
    // MARK: - Private method
    func setup() {
        self.layer.addSublayer(self.sliderCircleLayer)
        self.layer.addSublayer(self.trackLayer)
        contentSize = self.bounds.size
        self.updateMaxRadius()
    }
    
    func updateDiff() {
        diff = CGFloat(sqrtf(max(0, powf(Float(self.scaleCircleRadius), 2.0)) - powf(Float(self.trackHeight * 0.5), 2.0)))
    }
    
    func updateIndex() {
        guard self.scales.count > 0 else {
            isSliderScale = false
            return
        }
        if index > self.scales.count - 1 {
            index = self.scales.count - 1
            value = scales[index]
            self.sendActions(for: .valueChanged)
        }
    }
    
    func updateMaxRadius() {
        self.maxRadius = max(self.scaleCircleRadius, self.sliderCircleRadius);
    }
    
    func sliderPosition() -> CGFloat {
        return sliderCircleLayer.position.x - maxRadius
    }
    
    func layoutLayersAnimated(_ animated: Bool) {
        let calculateIndex = self.indexCalculate()
        let indexDiff = abs(calculateIndex - self.index)
        let left = calculateIndex - self.index < 0
        let contentWidth = self.bounds.width - 2 * maxRadius
        let sliderHeight = max(maxRadius, self.trackHeight / 2.0) * 2.0
        contentSize = CGSize(width: max(30.0, self.bounds.width), height: max(30.0, sliderHeight))
        if self.bounds.size != contentSize {
            if self.constraints.count > 0 {
                self.invalidateIntrinsicContentSize()
            }
            else {
                var newFrame = self.frame
                newFrame.size = contentSize!
                self.frame = newFrame
            }
        }
        
        let contentFrameY = (self.bounds.height - sliderHeight) / 2.0
        let contentFrame = CGRect(x: maxRadius, y: contentFrameY, width: contentWidth, height: sliderHeight)
        let circleFrameSide = self.scaleCircleRadius * 2.0
        let sliderDiameter = self.sliderCircleRadius * 2.0
        
        let oldPostion = sliderCircleLayer.position
        let oldPath = trackLayer.path
        
        if !animated {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        }
        
        sliderCircleLayer.path = nil
        sliderCircleLayer.contents = nil
        
        if let sliderImage = self.sliderCircleImage {
            sliderCircleLayer.frame = CGRect(x: 0, y: 0, width: max(sliderImage.size.width, 30), height: max(sliderImage.size.height, 30))
            sliderCircleLayer.contents = self.sliderCircleImage?.cgImage
            sliderCircleLayer.contentsGravity = kCAGravityCenter
        }
        else {
            let sliderFrameSide = max(self.sliderCircleRadius * 2.0, 30)
            let sliderDrawRect = CGRect(x: (sliderFrameSide - sliderDiameter) * 0.5, y: (sliderFrameSide - sliderDiameter) * 0.5, width: sliderDiameter, height: sliderDiameter)
            sliderCircleLayer.frame = CGRect(x: 0, y: 0, width: sliderFrameSide, height: sliderFrameSide)
            sliderCircleLayer.path = UIBezierPath.init(roundedRect: sliderDrawRect, cornerRadius: sliderFrameSide * 0.5).cgPath
            sliderCircleLayer.fillColor = self.sliderCircleColor.cgColor
        }
        
        let x = self.value * contentFrame.width
        sliderCircleLayer.position = CGPoint(x: contentFrame.origin.x + x, y: contentFrame.midY)
        
        if animated {
            let animation = CABasicAnimation.init(keyPath: "position")
            animation.duration = CATransaction.animationDuration()
            animation.fromValue = oldPostion
            sliderCircleLayer.add(animation, forKey: "position")
        }
        
        trackLayer.frame = CGRect(x: contentFrame.origin.x, y: contentFrame.midY - self.trackHeight * 0.5, width: contentFrame.width, height: self.trackHeight)
        trackLayer.path = self.fillingPath()
        trackLayer.backgroundColor = self.trackColor.cgColor
        trackLayer.fillColor = self.tintColor.cgColor
        
        if animated {
            let animation = CABasicAnimation.init(keyPath: "path")
            animation.duration = CATransaction.animationDuration()
            animation.fromValue = oldPath
            trackLayer.add(animation, forKey: "path")
        }
        
        scaleCirclesArray = self.clearExcessLayers(scaleCirclesArray)
        
        var animationTimeDiff: CGFloat = 0
        let duration = CGFloat(CATransaction.animationDuration())
        if indexDiff > 0 {
            animationTimeDiff = (left ? duration : -duration) / CGFloat(indexDiff)
        }
        var animationTime = left ? animationTimeDiff : duration + animationTimeDiff
        let circleAnimation = circleFrameSide / trackLayer.frame.width
        
        for (i,value) in self.scales.enumerated() {
            var scaleCircle: CAShapeLayer?
            if i < scaleCirclesArray.count {
                scaleCircle = scaleCirclesArray[i]
            }
            else {
                scaleCircle = CAShapeLayer.init()
                self.layer.addSublayer(scaleCircle!)
                scaleCirclesArray.append(scaleCircle!)
            }
            
            let x = value * contentFrame.width
            scaleCircle?.bounds = CGRect(x: 0, y: 0, width: circleFrameSide, height: circleFrameSide)
            scaleCircle?.position = CGPoint(x: contentFrame.origin.x + x, y: contentFrame.midY)
            
            let scaleCircleImage = self.scaleCircleCGImage(scaleCircle: scaleCircle!)
            if let scaleImage = scaleCircleImage {
                scaleCircle?.path = nil
                scaleCircle?.contents = scaleImage
            }
            else {
                scaleCircle?.path = UIBezierPath.init(rect: (scaleCircle?.bounds)!).cgPath
                scaleCircle?.contents = nil
            }
            
            if (animated) {
                if let scaleImage = scaleCircleImage {
                    let oldImage = scaleCircle?.contents as! CGImage
                    if (oldImage != scaleCircleImage) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            scaleCircle?.contents = scaleImage
                            let animation = CABasicAnimation.init(keyPath: "kZNTrackAnimation")
                            animation.duration = CFTimeInterval(duration * circleAnimation)
                            animation.fromValue = oldImage
                            scaleCircle?.add(animation, forKey: "kZNTrackAnimation")
                        }
                        animationTime = animationTime + animationTimeDiff
                    }
                } else {
                    let newColor = self.scaleCircleCGColor(scaleCircle: scaleCircle!)
                    let oldColor = scaleCircle?.fillColor
                    
                    if (newColor != scaleCircle?.fillColor) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            scaleCircle?.fillColor = newColor
                            let animation = CABasicAnimation.init(keyPath: "kZNTrackAnimation")
                            animation.duration = CFTimeInterval(duration * circleAnimation)
                            animation.fromValue = oldColor
                            scaleCircle?.add(animation, forKey: "kZNTrackAnimation")
                        }
                        animationTime = animationTime + animationTimeDiff
                    }
                }
            } else {
                if let scaleImage = scaleCircleImage {
                    scaleCircle?.contents = scaleImage
                } else {
                    scaleCircle?.fillColor = self.scaleCircleCGColor(scaleCircle: scaleCircle!)
                }
            }
        }
        
        if (!animated) {
            CATransaction.commit()
        }
        sliderCircleLayer.removeFromSuperlayer()
        self.layer.addSublayer(sliderCircleLayer)
    }
    
    func indexCalculate() -> Int {
        let position = self.sliderPosition()
        let width = self.bounds.width - maxRadius * 2
        var index = 0
        let count = self.scales.count
        for (i,item) in self.scales.enumerated() {
            if i == count - 1 {
                if (width * CGFloat(item) <= position) {
                    index = i
                    break
                }
            }
            else {
                let nextX = self.scales[i+1]
                let center = (nextX - item) * 0.5 + item
                if position >= item * width && position < center * width {
                    index = i
                    break
                }
                else if position >= center * width && position < nextX * width {
                    index = i + 1
                    break
                }
                else if item * width >= position {
                    index = i
                    break
                }
            }
        }
        return index
    }

    func fillingPath() -> CGPath {
        var fillRect = trackLayer.bounds
        fillRect.size.width = self.sliderPosition()
        return UIBezierPath.init(rect: fillRect).cgPath
    }
    
    func clearExcessLayers(_ layers: [CAShapeLayer]) -> [CAShapeLayer] {
        if layers.count > self.scales.count {
            let excessLayers = layers[self.scales.count...]
            for layer in excessLayers {
                layer.removeFromSuperlayer()
            }
            let effectiveLayers = layers[0..<self.scales.count]
            return Array(effectiveLayers)
        }
        return layers
    }
    
    func scaleCirclePosition(scaleCircle: CAShapeLayer) -> CGFloat {
        return scaleCircle.position.x - maxRadius
    }
    
    func scaleCircleCGColor(scaleCircle: CAShapeLayer) -> CGColor {
        return self.scaleCircleIsSeleceted(scaleCircle: scaleCircle) ? self.scaleSelectedColor.cgColor : self.scaleNormalColor.cgColor
    }
    
    func scaleCircleIsSeleceted(scaleCircle: CAShapeLayer) -> Bool {
        return self.sliderPosition() + diff >= self.scaleCirclePosition(scaleCircle: scaleCircle)
    }
    
    func scaleCircleCGImage(scaleCircle: CAShapeLayer) -> CGImage? {
        let select = self.scaleCircleIsSeleceted(scaleCircle: scaleCircle)
        return self.scaleCircleImageForState(select ? .selected : .normal)?.cgImage
    }
    
    func scaleCircleImageForState(_ state: UIControlState) -> UIImage? {
        let key = state == .selected ? 1 : 0
        return (scaleCircleImages[key] != nil) ? scaleCircleImages[key] : scaleCircleImages[0]
    }
    
    // MARK: - Touch
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        startTouchPosition = touch.location(in: self)
        startSliderPosition = sliderCircleLayer.position
        
        if sliderCircleLayer.frame.contains(startTouchPosition!) {
            isTouched = true
            return true
        }
        return false
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let position = (startSliderPosition?.x)! - ((startTouchPosition?.x)! - touch.location(in: self).x)
        let limitedPosition = min(max(maxRadius, position), self.bounds.width - maxRadius)
        
        WithoutCAAnimation {
            self.sliderCircleLayer.position = CGPoint(x: limitedPosition, y: sliderCircleLayer.position.y)
            self.trackLayer.path = self.fillingPath()
            let index = self.indexCalculate()
            for scaleCircle in scaleCirclesArray {
                let scaleCircleImage = self.scaleCircleCGImage(scaleCircle: scaleCircle)
                if let scacleImage = scaleCircleImage {
                    scaleCircle.contents = scacleImage
                }
                else {
                    scaleCircle.fillColor = self.scaleCircleCGColor(scaleCircle: scaleCircle)
                }
            }
            self.index = index
            
            if isSliderScale {
                self.value = self.scales[self.index]
            }
            else {
                value = (self.sliderCircleLayer.position.x - maxRadius) / (self.bounds.width - 2 * maxRadius)
            }
            self.sendActions(for: .valueChanged)
        }
        
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.endTouches()
    }
    
    override public func cancelTracking(with event: UIEvent?) {
        self.endTouches()
    }
    
    func endTouches() {
        isTouched = false
        let newIndex = self.indexCalculate()
        if newIndex != index {
            index = newIndex
            if isSliderScale {
                value = scales[index]
            }
            else {
                value = (self.sliderCircleLayer.position.x - maxRadius) / (self.bounds.width - 2 * maxRadius)
            }
            self.sendActions(for: .valueChanged)
        }
        animationLayouts = true
        self.setNeedsLayout()
    }
    
    // MARK: - Public
    public func setIndex(_ index: Int, animation: Bool) {
        self.animationLayouts = animation
        self.index = index
        self.value = self.scales[index]
    }
    
    public func setScaleCircleImage(_ image: UIImage, state: UIControlState) {
        if state == .normal {
            scaleCircleImages[0] = image
        }
        else {
            scaleCircleImages[1] = image
        }
        self.setNeedsLayout()
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
