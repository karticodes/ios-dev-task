//
//  MailDetailModel.swift
//  CMTestApp
//
//  Created by Karti on 09/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import UIKit
import ObjectMapper

class MailDetailModel: MailBase {

    var participants: [ParticipantModel]!
    var body: String!
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        participants    <- map["participants"]
        body            <- map["body"]
    }
}

class ParticipantModel: NSObject, Mappable {
    
    var name: String!
    var email: String!
    
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
        name        <- map["name"]
        email       <- map["email"]
    }
}
