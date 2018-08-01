//
//  File.swift
//  Star
//
//  Created by Julian Jans on 31/07/2018.
//  Copyright © 2018 Julian Jans. All rights reserved.
//

import UIKit

@IBDesignable
class Rating: UIView {
    
    @IBInspectable var value: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var colour1: UIColor = UIColor.red
    @IBInspectable var colour2: UIColor = UIColor.orange
    @IBInspectable var colour3: UIColor = UIColor.green
    
    private var ratingColour: UIColor {
        switch value {
        case 0..<4:
            return colour1
        case 4..<7:
            return colour2
        default:
            return colour3
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func config() {
        backgroundColor = UIColor.darkGray
        mask = StarView(frame: bounds)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mask?.frame = bounds
    }
    
    override func draw(_ rect: CGRect) {
        ratingColour.setStroke()
        let line = UIBezierPath()
        line.lineWidth = bounds.size.height
        line.move(to: CGPoint(x: 0, y: bounds.size.height / 2))
        line.addLine(to: CGPoint(x: (value / 10) * bounds.size.width, y: bounds.size.height / 2))
        line.stroke()
    }
    
}

fileprivate class StarView: UIView {
    
    class Star : UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor.clear
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            backgroundColor = UIColor.clear
        }
        
        override func draw(_ rect: CGRect) {
            
            UIColor.black.setFill()
            
            // Star path code from Stack Overflow: https://stackoverflow.com/questions/18268079/drawrect-draw-star
            let polygonPath = UIBezierPath()
            
            let xCenter: CGFloat = bounds.width / 2
            let yCenter: CGFloat = bounds.height / 2
            
            let w = bounds.width
            let r = w / 2.0
            let flip: CGFloat = -1.0
            
            let polySide = CGFloat(5)
            
            let theta = 2.0 * Double.pi * Double(2.0 / polySide)
            
            polygonPath.move(to: CGPoint(x: xCenter, y: r * flip + yCenter))
            
            for i in 1..<Int(polySide) {
                let x: CGFloat = r * CGFloat( sin(Double(i) * theta) )
                let y: CGFloat = r * CGFloat( cos(Double(i) * theta) )
                polygonPath.addLine(to: CGPoint(x: x + xCenter, y: y * flip + yCenter))
            }
            
            polygonPath.fill()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func config() {
        backgroundColor = UIColor.clear
        subviews.forEach({$0.removeFromSuperview()})
        for _ in 0..<10 {
            let star = Star()
            addSubview(star)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (index, star) in subviews.enumerated() {
            star.frame = CGRect(x: (CGFloat(index) * (bounds.width / 10)), y: 0, width: bounds.width / 10, height: bounds.width / 10)
        }
    }

}
