//
//  DesignSliderProgress.swift
//  VTune
//
//  Created by Nova Arisma on 11/7/19.
//  Copyright © 2019 Jasmine Hanifa Mounir. All rights reserved.
//

import UIKit

@IBDesignable
class DesignSliderProgress: UISlider {

    @IBInspectable var thumbImage: UIImage? {didSet
        { setThumbImage(thumbImage, for: .normal)
            
    }


}
}
