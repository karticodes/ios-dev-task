//
//  StringExtension.swift
//  CMTestApp
//
//  Created by Karti on 08/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import Foundation
import UIKit
import MapKit

public extension String{
    
    public func localized() -> String{
        
        return NSLocalizedString(self, comment: "")
    }
    
    func isEmail() throws -> Bool {
        return try validateRegex("^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
    }
    
    func validateRegex(regex: String) throws -> Bool{
        let regex = try NSRegularExpression(pattern: regex, options: [.CaseInsensitive])
        return regex.firstMatchInString(self, options: .ReportCompletion, range: NSMakeRange(0, self.characters.count)) != nil
    }
    
    mutating func append(other: String?){
        if let otherStr = other{
            self.appendContentsOf(" " + otherStr)
        }
    }
    
    func trim() -> String{
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

extension NSString{
    
    func trim() -> NSString{
        return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

public extension UIColor{
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0){
        
        self.init(red: (r/255.0), green: (g/255.0), blue: (b/255.0), alpha: a)
    }
    
    class func accentColor() -> UIColor{
        
        return UIColor(r: 33, g: 150, b: 243)
    }
}

public extension NSHTTPURLResponse{
    
    public func isSuccess() -> Bool{
        
        return [200, 201, 202, 203, 204, 206, 207, 208, 226].contains(statusCode)
    }
}

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}