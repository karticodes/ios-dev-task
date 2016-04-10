//
//  CMServiceManager.swift
//  CMTestApp
//
//  Created by Karti on 08/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

public class CMServiceManager: NSObject{
    
    static let sharedInstance = CMServiceManager()
    
    public func performRequest(method: Alamofire.Method = .GET, url: String, parameters: [String: AnyObject]? = nil, headers: [String: String]? = nil, successHandler: () -> Void, failureHandler: (ErrorFormat) -> Void){
        
        guard Utility.isNetworkReachable() else { failureHandler(ErrorTypes.ReachabilityError); return }
        
        Alamofire.request(method, url, parameters: parameters, encoding: .URL, headers: headers).responseString(completionHandler: { (response) -> Void in
            Utility.printServiceResponses(response)
                        
            if let httpResponse = response.response where httpResponse.isSuccess(){
                successHandler()
            }else if let jsonStr = response.result.value, error = EMRErrorManager.checkErrorResponse(response.result.error, jsonString: jsonStr){
                failureHandler(error)
            }else{
                failureHandler(ErrorTypes.GenericError)
            }
        })
    }
    
    public func fetchRequest<T: Mappable>(method: Alamofire.Method = .GET, url: String, parameters: [String: AnyObject]? = nil, headers: [String: String]? = nil, successHandler: (T) -> Void, failureHandler: (ErrorFormat) -> Void){
        
        guard Utility.isNetworkReachable() else { failureHandler(ErrorTypes.ReachabilityError); return }
        
        Alamofire.request(method, url, parameters: parameters, encoding: .URL, headers: headers).responseString(completionHandler: { (response) -> Void in
            Utility.printServiceResponses(response)
            
            guard let jsonStr = response.result.value else { failureHandler(ErrorTypes.GenericError); return }
            
            if let httpResponse = response.response where httpResponse.isSuccess(), let parsed = Mapper<T>().map(jsonStr){
                successHandler(parsed)
            }else if let error = EMRErrorManager.checkErrorResponse(response.result.error, jsonString: jsonStr){
                failureHandler(error)
            }else{
                failureHandler(ErrorTypes.GenericError)
            }
        })
    }
    
    public func fetchArrayRequest<T: Mappable>(method: Alamofire.Method = .GET, url: String, parameters: [String: AnyObject]? = nil, headers: [String: String]? = nil, successHandler: ([T]) -> Void, failureHandler: (ErrorFormat) -> Void){
        
        guard Utility.isNetworkReachable() else { failureHandler(ErrorTypes.ReachabilityError); return }
        
        Alamofire.request(method, url, parameters: parameters, encoding: .URL, headers: headers).responseString(completionHandler: { (response) -> Void in
            Utility.printServiceResponses(response)
            
            guard let jsonStr = response.result.value else { failureHandler(ErrorTypes.GenericError); return }
            
            if let httpResponse = response.response where httpResponse.isSuccess(), let parsed = Mapper<T>().mapArray(jsonStr){
                successHandler(parsed)
            }else if let error = EMRErrorManager.checkErrorResponse(response.result.error, jsonString: jsonStr){
                failureHandler(error)
            }else{
                failureHandler(ErrorTypes.GenericError)
            }
        })
    }
}
