//
//  MailModel.swift
//  CMTestApp
//
//  Created by Karti on 08/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreData

class MailBase: NSObject, Mappable{
    
    var subject: String!
    var preview: String!
    var isRead = false
    var isStarred = false
    var date: NSDate!
    var id: Int!
    
    required init?(_ map: Map) {
        //
    }
    
    func mapping(map: Map) {
        
        subject         <- map["subject"]
        preview         <- map["preview"]
        isRead          <- map["isRead"]
        isStarred       <- map["isStarred"]
        id              <- map["id"]
        date            <- (map["ts"], Utility.timestampToDateTransform())
    }
}

class MailModel: MailBase {
    
    var participants: [String]!

    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        participants    <- map["participants"]
    }
}
