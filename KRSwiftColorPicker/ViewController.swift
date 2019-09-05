//
//  ViewController.swift
//  KRSwiftColorPicker
//
//  Created by Krishnarjun on 04/09/19.
//  Copyright © 2019 Krishnarjun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var outputColorView: UIView!
    
    @IBOutlet weak var colorPickerView: KRColorPicker!
    
    @IBOutlet weak var brightnessPicker: KRColorPicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPickerView.delegate = self
        colorPickerView.type = .color
        outputColorView.layer.cornerRadius = outputColorView.bounds.width / 2
        
        brightnessPicker.delegate = self

        brightnessPicker.type = .brightness
    }
}

extension ViewController: KRColorPickerDelegate {
    func valuePicked(_ color: UIColor, type: KRColorPicker.PickerType, _ brightness: CGFloat) {
        outputColorView.backgroundColor = color
        outputColorView.addShadow(40, opacity: brightness)
    }
}

extension UIView {
    
    func addShadow(_ radius: CGFloat, color: UIColor = .white, opacity: CGFloat) {
        layer.cornerRadius = bounds.width / 2
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: radius, height: radius)
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: CGRect(x: bounds.minX - 40, y: bounds.minY - 40, width: bounds.width, height: bounds.height)).cgPath
        layer.shadowOpacity = Float(opacity)
        layer.masksToBounds = false
        layer.shouldRasterize = true
    }
}

