//
//  Model.swift
//  Combine Network
//
//  Created by Rezaul Islam on 2/2/24.
//

import Foundation

struct Product : Codable, Identifiable{
    var id : Int
    var title : String
    var image : String
}

struct User : Decodable{
    var id : Int
    var name : String
}
