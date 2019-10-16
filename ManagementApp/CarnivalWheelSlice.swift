//
//  CarnivalWheelSlice.swift
//  TTFortuneWheelSample
//
//  Created by Efraim Budusan on 11/1/17.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Foundation
import TTFortuneWheel

public class CarnivalWheelSlice: FortuneWheelSliceProtocol {
    
    public enum Style {
        case brickRed
        case sandYellow
        case babyBlue
        case deepBlue
        case deepPink
        case deepYellow
    }
    
    public var title: String
    public var degree: CGFloat = 0.0
    
    public var backgroundColor: UIColor? {
        switch style {
        case .brickRed: return TTUtils.uiColor(from:0xE27230)
        case .sandYellow: return TTUtils.uiColor(from:0xF7D565)
        case .babyBlue: return TTUtils.uiColor(from:0x93D0C4)
        case .deepBlue: return TTUtils.uiColor(from:0x2DABE2)
        case .deepPink: return TTUtils.uiColor(from:0xEA118D)
        case .deepYellow: return TTUtils.uiColor(from:0xFCEE23)
        }
    }
    
    public var fontColor: UIColor {
        return UIColor.black
    }
    
    public var offsetFromExterior:CGFloat {
        return 18.0
    }
    
    public var font: UIFont {
        switch style {
        case .brickRed:
            return UIFont(name: "Roboto-Regular", size: 12.0)!
        case .sandYellow:
            return UIFont(name: "Roboto-Regular", size: 12.0)!
        case .babyBlue:
            return UIFont(name: "Roboto-Regular", size: 12.0)!
        case .deepBlue:
            return UIFont(name: "Roboto-Regular", size: 12.0)!
        case .deepPink:
            return UIFont(name: "Roboto-Regular", size: 12.0)!
        case .deepYellow:
            return UIFont(name: "Roboto-Regular", size: 12.0)!
        }
    }
    
    public var stroke: StrokeInfo? {
        return StrokeInfo(color: UIColor.white, width: 1.0)
    }
    
    public var style:Style = .brickRed
    
    public init(title:String) {
        self.title = title
    }
    
    public convenience init(title:String, degree:CGFloat) {
        self.init(title:title)
        self.degree = degree
    }
    
}
