//
//  DurationSlider.swift
//  VTune
//
//  Created by Stefani Kurnia Permata Dewi on 08/11/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit
@IBDesignable

class DurationSlider: UISlider {

    @IBInspectable var thumbImage: UIImage? {
        didSet{
            setThumbImage(thumbImage, for: .normal)
        }
    }

}
