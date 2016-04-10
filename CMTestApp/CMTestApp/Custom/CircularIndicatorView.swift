//
//  CircularIndicatorView.swift
//  CMTestApp
//
//  Created by Karti on 09/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import UIKit

@IBDesignable class CircularIndicatorView: UIView {

    @IBInspectable var indicatorColor: UIColor = UIColor.blueColor(){
        didSet{
            setNeedsDisplay()
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let diameter = min(CGRectGetWidth(rect), CGRectGetHeight(rect))
        let ovalPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, diameter, diameter))
        indicatorColor.setFill()
        ovalPath.fill()
    }
}
