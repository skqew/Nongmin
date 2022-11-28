//
//  CustomSlider.swift
//  NongminNews
//
//  Created by 조지운 on 2022/09/20.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 11.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
}
