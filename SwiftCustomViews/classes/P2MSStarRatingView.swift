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
    func renderSelected(context: CGContext, inRect: CGRect)
    func renderNormal(context: CGContext, inRect: CGRect)
}

//MARK: - default implementation of star rating view renderer
public class P2MSDefaultStarRenderer: P2MSStarRatingViewRenderer {
    var baseColor = UIColor.lightGray
    var selectedColor = UIColor.red
    
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
    
    public func renderSelected(context: CGContext, inRect: CGRect) {
        drawStar(context: context, rect: inRect, color: selectedColor)
    }
    
    public func renderNormal(context: CGContext, inRect: CGRect) {
        drawStar(context: context, rect: inRect, color: baseColor)
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
    
    private func calculateStarSizeIfNeeded(){
        if !isStarSizeSet {
            let starWidthHeight = max(min(bounds.size.height-(contentInsets.top+contentInsets.bottom), (bounds.size.width-(gapBetweenStars*CGFloat(noOfStars)) - (contentInsets.left + contentInsets.right))/CGFloat(noOfStars)),20)
            calculatedStarSize = CGSize(width: starWidthHeight, height: starWidthHeight)
        }
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        if let context = UIGraphicsGetCurrentContext() {
            starStartX = (rect.size.width - (CGFloat(noOfStars) * calculatedStarSize.width) - (CGFloat(noOfStars - 1) * gapBetweenStars))/2;
            let starStartY = (rect.size.height - calculatedStarSize.height)/2
            var curRect = CGRect(x: starStartX, y: starStartY, width: calculatedStarSize.width, height: calculatedStarSize.height)
            for index in 1...noOfStars {
                if index <= selectedStarCount {
                    starRenderer.renderSelected(context: context, inRect: curRect)
                }else{
                    starRenderer.renderNormal(context: context, inRect: curRect)
                }
                curRect.origin.x += calculatedStarSize.width + gapBetweenStars
            }
            starEndX = curRect.origin.x
        }
    }
    
    private func starSelected(count: Int){
        if count != selectedStarCount {
            selectedStarCount = count
            delegate?.ratingChanged(count: selectedStarCount)
            setNeedsDisplay()
        }
    }
    
    private func determine(location: CGPoint?, done: Bool){
        guard let curLoc = location else {
            return
        }
        if curLoc.x >= starStartX && curLoc.y <= starEndX + gapBetweenStars {
            let curStar = min(Int((curLoc.x - starStartX)/(CGFloat(calculatedStarSize.width)+gapBetweenStars)) + 1, noOfStars)
            starSelected(count: curStar)
        }else if curLoc.x < starStartX {
            starSelected(count: 0)
        }
        if done {
            delegate?.ratingDone(count: selectedStarCount)
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        determine(location: touches.first?.location(in: self), done: false)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        determine(location: touches.first?.location(in: self), done: false)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        determine(location: touches.first?.location(in: self), done: true)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        determine(location: touches.first?.location(in: self), done: true)
    }

}
