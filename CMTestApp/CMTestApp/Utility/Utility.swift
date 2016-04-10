//
//  Utility.swift
//  CMTestApp
//
//  Created by Karti on 08/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import Foundation
import UIKit
import ReachabilitySwift
import ObjectMapper
import Alamofire

class Utility: NSObject {
    
    static var standardUserDefaults = NSUserDefaults.standardUserDefaults()
    
    class func isNetworkReachable() -> Bool{
        do{
            let reachable = try Reachability.reachabilityForInternetConnection().isReachable()
            return reachable
        }
        catch{
            return false
        }
    }
    
    class func timestampToDateTransform() -> TransformOf<NSDate, Int>{
        
        return TransformOf<NSDate, Int>(fromJSON: { (value: Int?) -> NSDate? in
            guard let val = value else { return nil }
            return NSDate(timeIntervalSince1970: NSTimeInterval(val))
            }, toJSON: { (value: NSDate?) -> Int? in
            guard let val = value else { return nil }
            return Int(val.timeIntervalSince1970)
        })
    }
    
    class func instanciateWithIdentifier<T>(identifier: String, storyboard: String = "Main") -> T?{
        
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier(identifier) as? T
    }
    
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    class func printServiceResponses(response: Response<String, NSError>){
        
        print("-------------------><-------------------")
        if let body = response.request?.HTTPBody{
            print(NSString(data: body, encoding: NSUTF8StringEncoding))
        }
        print(response.request)
        print(response.response)
        print(NSString(data: response.data!, encoding: NSUTF8StringEncoding))
        print("-------------------><-------------------")
    }

    class func tryOpenUrl(url: NSURL) -> Bool{
        
        if UIApplication.sharedApplication().canOpenURL(url){
            UIApplication.sharedApplication().openURL(url)
            return true
        }else{
            return false
        }
    }
}
