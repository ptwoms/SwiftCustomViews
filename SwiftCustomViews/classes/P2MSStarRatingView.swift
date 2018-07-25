//
//  P2MSStarRatingView.swift
//  SwiftCustomViews
//
//  Created by Pyae Phyo Myint Soe on 1/7/18.
//  Copyright © 2018 Pyae Phyo Myint Soe. All rights reserved.
//

import UIKit

//MARK: - star rating view renderer protocol
public protocol P2MSStarRatingViewRenderer: class {
    //index is added to allow the custom renderer to have different images for different indexes
    func renderSelected(context: CGContext, inRect: CGRect, index: Int)
    func renderNormal(context: CGContext, inRect: CGRect, index: Int)
}

//MARK: - default implementation of star rating view renderer
public class P2MSDefaultStarRenderer: P2MSStarRatingViewRenderer {
    var baseColor = UIColor.lightGray
    var selectedColor = UIColor.red
    
    private var cachedSelectedImage: UIImage?
    private var prevSize: CGSize = .zero //assumed that all stars will be the same size
    private var cachedNormalImage: UIImage?
    
    private func getStarImage(size: CGSize, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let contextRef = UIGraphicsGetCurrentContext() else {
            return nil
        }
        drawStar(context: contextRef, rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), color: color)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image
    }
    
    //make one star in rect filled with the color
    private func drawStar(context: CGContext, rect: CGRect, color: UIColor) {
        let size = rect.size
        let xCenter = Double(rect.origin.x + (size.width * 0.5))
        let yCenter = Double(rect.origin.y + (size.height * 0.5))
        let rX = Double(size.width * 0.5)
        let rY = Double(size.height * 0.5)
        let flip: Double = -1.0
        
        context.setFillColor(color.cgColor)
        context.setStrokeColor(color.cgColor)
        context.move(to: CGPoint(x: xCenter, y: rY * flip + yCenter))
        let theta: Double = 2.0 * .pi * (2.0 / 5.0)
        for i in 1 ..< 5 {
            let x: Double = Double(rX * sin(Double(i) * theta))
            let y: Double = Double(rY * cos(Double(i) * theta))
            context.addLine(to: CGPoint(x: x + xCenter, y: y * flip + yCenter))
        }
        context.closePath()
        context.fillPath()
    }
    
    public func renderSelected(context: CGContext, inRect: CGRect, index: Int) {
        if inRect.size == prevSize, let selectedImage = cachedSelectedImage {
            selectedImage.draw(in: inRect)
        }else if let newImage = getStarImage(size: inRect.size, color: selectedColor){
            newImage.draw(in: inRect)
            cachedSelectedImage = newImage
            prevSize = inRect.size
        }else{
            drawStar(context: context, rect: inRect, color: selectedColor)
            cachedSelectedImage = nil
        }
    }
    
    public func renderNormal(context: CGContext, inRect: CGRect, index: Int) {
        if inRect.size == prevSize, let normalImage = cachedNormalImage {
            normalImage.draw(in: inRect)
        }else if let newImage = getStarImage(size: inRect.size, color: baseColor){
            newImage.draw(in: inRect)
            cachedNormalImage = newImage
            prevSize = inRect.size
        }else{
            drawStar(context: context, rect: inRect, color: baseColor)
            cachedNormalImage = nil
        }
    }
}

//MARK: - Star rating callbacks
@objc public protocol P2MSStarRatingViewDelegate: class {
    func ratingChanged(count: Int)
    func ratingDone(count: Int)
}

//MARK: - Star rating view
public class P2MSStarRatingView: UIView {
    @IBInspectable public var noOfStars: Int = 5
    public private(set) var selectedStarCount: Int = 0
    @IBOutlet public weak var delegate: P2MSStarRatingViewDelegate? = nil
    public var gapBetweenStars: CGFloat = 10
    public var cancelOutsideTouch: Bool = false
    public var contentInsets: UIEdgeInsets = .zero
    public var starRenderer: P2MSStarRatingViewRenderer = P2MSDefaultStarRenderer()
    public var starSize: CGSize? {
        didSet{
            if let starSize = starSize {
                isStarSizeSet = true
                calculatedStarSize = starSize
            }else{
                isStarSizeSet = false
            }
            setNeedsDisplay()
        }
    }
    
    //private section
    private var starStartX: CGFloat = 0, starEndX: CGFloat = 0
    private var calculatedStarSize: CGSize = .zero
    private var isStarSizeSet = false
    private var shouldAllowTouch = false
    private var ratingChangedClosure: ((_ count: Int) -> Void)?
    private var ratingDoneClosure: ((_ count: Int) -> Void)?
    
    override public var frame: CGRect {
        didSet{
            calculateStarSizeIfNeeded()
            setNeedsDisplay()
        }
    }
    
    override public var bounds: CGRect {
        didSet{
            calculateStarSizeIfNeeded()
            setNeedsDisplay()
        }
    }
    
    //beware of retain cycle when using this method
    public func setListener(ratingChanged: ((_ count: Int) -> Void)?, ratingDone: ((_ count: Int) -> Void)?){
        self.ratingDoneClosure = ratingDone
        self.ratingChangedClosure = ratingChanged
    }
    
    private func calculateStarSizeIfNeeded(){
        if !isStarSizeSet {
            let starWidthHeight = max(min(bounds.size.height-(contentInsets.top+contentInsets.bottom), (bounds.size.width-(gapBetweenStars*CGFloat(noOfStars)) - (contentInsets.left + contentInsets.right))/CGFloat(noOfStars)),20)
            calculatedStarSize = CGSize(width: starWidthHeight, height: starWidthHeight)
        }
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            UIGraphicsPushContext(context)
            starStartX = (rect.size.width - (CGFloat(noOfStars) * calculatedStarSize.width) - (CGFloat(noOfStars - 1) * gapBetweenStars))/2;
            let starStartY = (rect.size.height - calculatedStarSize.height)/2
            var curRect = CGRect(x: starStartX, y: starStartY, width: calculatedStarSize.width, height: calculatedStarSize.height)
            for index in 1...noOfStars {
                if index <= selectedStarCount {
                    starRenderer.renderSelected(context: context, inRect: curRect, index: index)
                }else{
                    starRenderer.renderNormal(context: context, inRect: curRect, index: index)
                }
                curRect.origin.x += calculatedStarSize.width + gapBetweenStars
            }
            starEndX = curRect.origin.x //pad gapBetweenStars at the end
            UIGraphicsPopContext()
        }
    }
    
    private func starSelected(count: Int){
        if count != selectedStarCount {
            selectedStarCount = count
            delegate?.ratingChanged(count: selectedStarCount)
            ratingChangedClosure?(selectedStarCount)
            setNeedsDisplay()
        }
    }
    
    private func determine(location: CGPoint?, done: Bool){
        guard let curLoc = location else {
            return
        }
        if curLoc.x >= starStartX && curLoc.x <= starEndX {
            let curStar = min(Int((curLoc.x - starStartX)/(CGFloat(calculatedStarSize.width)+gapBetweenStars)) + 1, noOfStars)
            starSelected(count: curStar)
        }else if curLoc.x < starStartX {
            starSelected(count: 0)
        }
        if done {
            delegate?.ratingDone(count: selectedStarCount)
            ratingDoneClosure?(selectedStarCount)
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        shouldAllowTouch = true
        determine(location: touches.first?.location(in: self), done: false)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if shouldAllowTouch, let locationInSelf = touches.first?.location(in: self) {
            if self.bounds.contains(locationInSelf) {
                determine(location: locationInSelf, done: false)
            }else if cancelOutsideTouch {
                touchesEnded(touches, with: event)
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if shouldAllowTouch {
            shouldAllowTouch = false
            determine(location: touches.first?.location(in: self), done: true)
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if shouldAllowTouch {
            shouldAllowTouch = false
            determine(location: touches.first?.location(in: self), done: true)
        }
    }
}
