//
//  KRColorPicker.swift
//  KRSwiftColorPicker
//
//  Created by Krishnarjun on 04/09/19.
//  Copyright © 2019 Krishnarjun. All rights reserved.
//

import UIKit

protocol KRColorPickerDelegate : class {
    func valuePicked(_ color: UIColor, type: KRColorPicker.PickerType, _ brightness: CGFloat)
}

class KRColorPicker: UIView {
    
    // MARK: - Type
    
    public enum PickerType: Int {
        case color
        case brightness
    }
    
    // MARK: - Constants
    
    let HUEMaxValue: CGFloat = 255
    let PercentMaxValue: CGFloat = 100
    
    // MARK: - Main public properties
    
    open weak var delegate: KRColorPickerDelegate!
    open var type: PickerType = .color
    open var currentColor: UIColor {
        get {
            return color
        }
        set(newCurrentColor) {
            color = newCurrentColor
            var hue: CGFloat = 0
            var s: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            if color.getHue(&hue, saturation: &s, brightness: &b, alpha: &a) {
                var needUpdate = false
                if hueValue != hue {
                    needUpdate = true
                }
                hueValue = hue
                saturationValue = s
                brightnessValue = b
                alphaValue = a
                
                if needUpdate && hueValue > 0 && hueValue < 1 {
                    update()
                    setNeedsDisplay()
                }
            }
        }
    }
    

    open var cornerRadius: CGFloat = 10.0
    
    // MARK: - Private properties
    
    fileprivate var color: UIColor = UIColor.clear
    fileprivate var currentSelectionY: CGFloat = 0.0
    fileprivate var currentSelectionX: CGFloat = 0.0
    fileprivate var hueImage: UIImage!
    fileprivate var hueValue: CGFloat = 0.0
    fileprivate var saturationValue: CGFloat = 1.0
    fileprivate var brightnessValue: CGFloat = 1.0
    fileprivate var alphaValue: CGFloat = 1.0
    
    // MARK: - Initialization
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        update()
    }
    
    // MARK: - Prerendering
    
    func generateHUEImage(_ size: CGSize) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        
        for x: Int in 0 ..< Int(size.width) {
            
            switch type {
            case .color:
                UIColor(hue: CGFloat(CGFloat(x) / size.width), saturation: 1.0, brightness: 1.0, alpha: 1.0).set()
                break
            case .brightness:
                UIColor(hue: 0, saturation: 0, brightness: CGFloat(CGFloat(x) / size.width), alpha: 1.0).set()
                break
            }
            
            let temp = CGRect(x: CGFloat(x), y: 0, width: 1, height: size.height)
            UIRectFill(temp)
        }
        
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Updating
    
    func update() {
        let offset = self.frame.size.height
        let halfOffset = offset * 0.5
        var size = self.frame.size
        size.width -= offset

        var value: CGFloat = 0
        switch type {
        case .color:
            value = hueValue
            break
        case .brightness:
            value = brightnessValue
            break
        }
        
        currentSelectionX = (value * size.width) + halfOffset
        currentSelectionY = (value * size.height) + halfOffset
        
        hueImage = generateHUEImage(size)
    }
    
    // MARK: - Drawing
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let radius = self.frame.size.height
        let halfRadius = radius * 0.5
        var circleX = currentSelectionX - halfRadius
        var circleY = currentSelectionY - halfRadius
        if circleX >= rect.size.width - radius {
            circleX = rect.size.width - radius
        }
        else if circleX < 0 {
            circleX = 0
        }
        if circleY >= rect.size.height - radius {
            circleY = rect.size.height - radius
        }
        else if circleY < 0 {
            circleY = 0
        }
        
        let circleRect =  CGRect(x: circleX, y: 0, width: radius, height: radius)
        let circleColor = currentColor
        var hueRect = rect
        
        if hueImage != nil {
            
            hueRect.size.width -= radius
            hueRect.origin.x += halfRadius
            hueImage.draw(in: hueRect)
        }
        
        let context = UIGraphicsGetCurrentContext()
        circleColor.set()
        context!.addEllipse(in: circleRect)
        context!.setFillColor(circleColor.cgColor)
        context!.fillPath()
        context!.strokePath()
        
    }
    
    // MARK: - Touch events
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = touches.first
        if let point = touch?.location(in: self) {
            handleTouch(point)
        }
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = touches.first
        if let point = touch?.location(in: self) {
            handleTouch(point)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: AnyObject? = touches.first
        if let point = touch?.location(in: self) {
            handleTouch(point)
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    // MARK: - Touch handling
    
    func handleTouch(_ touchPoint: CGPoint) {
        currentSelectionX = touchPoint.x
        currentSelectionY = touchPoint.y
        
        let offset = self.frame.size.height
        let halfOffset = offset * 0.5
        if currentSelectionX < halfOffset {
            currentSelectionX = halfOffset
        }
        else if currentSelectionX >= self.frame.size.width - halfOffset {
            currentSelectionX = self.frame.size.width - halfOffset
        }
        if currentSelectionY < halfOffset {
            currentSelectionY = halfOffset
        }
        else if currentSelectionY >= self.frame.size.height - halfOffset {
            currentSelectionY = self.frame.size.height - halfOffset
        }
        
        let value = CGFloat((currentSelectionX - halfOffset) / (self.frame.size.width - offset))
        
        switch type {
        case .color:
            hueValue = value
            break
        case .brightness:
            brightnessValue = value
            break
        }
        
        color = UIColor(hue: hueValue, saturation: saturationValue, brightness: 1, alpha: alphaValue)
        
        if delegate != nil {
            delegate.valuePicked(color, type: type, brightnessValue)
        }
        
        setNeedsDisplay()
    }
}





