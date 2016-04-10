//
//  CMErrorManager.swift
//  CMTestApp
//
//  Created by Karti on 08/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import Foundation
import ObjectMapper

public typealias ErrorFormat = (code: Int, title: String, message: String)

public struct ErrorTypes{
    
    static let GenericError: ErrorFormat        = (99, "Error!", "Something went wrong. Please try again after sometime.")
    static let ReachabilityError:ErrorFormat    = (98, "No network connectivity" , "CMTestApp requires Network Connectivity. Please check your internet and try again.")
}

class EMRErrorManager {
    
    class func checkErrorResponse(error: NSError?, jsonString: String) -> ErrorFormat?{
        
        if let errorResponse = Mapper<ErrorModel>().map(jsonString) where errorResponse.code != nil && errorResponse.message != nil{
            
            return (error == nil ? 97 : error!.code, "Error!", errorResponse.message!)
            
        }else if let err = error{
            
            return (err.code, "Error!", err.localizedDescription)
        }
        return nil
    }
}

//Considering error response "{"code": "NOT_FOUND", "message": "Mail with id 1 is not found"}"
class ErrorModel: Mappable{
    
    var message: String?
    var code: String?
    
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        message     <- map["message"]
        code        <- map["code"]
    }
    
}
