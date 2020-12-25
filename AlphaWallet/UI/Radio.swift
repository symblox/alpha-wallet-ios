//
//  Radio.swift
//  AlphaWallet
//
//  Created by tutrang on 11/20/20.
//

import UIKit

class Radio: UIView {
    
    var color: UIColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
    var padding: CGFloat = 5
    var isChecked: Bool = false {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard isChecked else {
            return
        }
        let maxSize = rect.size
        let width = maxSize.width - padding
        let height = maxSize.height - padding
        let size = width < height ? width : height

        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let origin = CGPoint(x: center.x - size / 2, y: center.y - size / 2)
        
        let ovalRect = CGRect(origin: origin, size: CGSize(width: size, height: size))
        let path = UIBezierPath(ovalIn: ovalRect)
        
        path.fill()
        
        let circleLayer = CAShapeLayer()
        circleLayer.fillColor = color.cgColor
        circleLayer.path = path.cgPath
        circleLayer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        layer.addSublayer(circleLayer)
    }
 
    convenience init (color: UIColor) {
        self.init()
        self.color = color
    }

    
}
