//
//  Accounts.swift
//  Assingment
//
//  Created by Sulthan on 09/03/25.
//

import Foundation

struct Account: Codable {
    var actName: String
    let actid: String
    
    enum CodingKeys: String, CodingKey {
        case actName = "ActName"
        case actid = "actid"
    }
}

