//
//  CMServiceList.swift
//  CMTestApp
//
//  Created by Karti on 08/04/16.
//  Copyright © 2016 KartiCodes. All rights reserved.
//

import UIKit

class CMServiceList: NSObject {
    
    private static let Base = "http://localhost:8088/api/"
    
    //MARK: - Messages
    private static let MessagesBase = Base + "message/"
    
    static let GetMessages          = MessagesBase
    static let GetMessageById       = MessagesBase + "%d"
    static let DeleteMessageById    = MessagesBase + "%d"

}
