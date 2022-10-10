//
//  Extensions.swift
//  Logger7
//
//  Created by William Wilson on 05/10/2022.
//  Copyright © 2022 MacBook Pro. All rights reserved.
//

import Foundation


extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
