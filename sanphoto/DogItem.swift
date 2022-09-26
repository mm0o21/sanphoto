//
//  DogItem.swift
//  sanphoto
//
//  Created by Maoko Furuya on 2022/09/19.
//

import Foundation
import RealmSwift

class Pin: Object {
    //緯度
    @objc dynamic var latitude = ""
    //経度
    @objc dynamic var longitude = ""
    
    @objc dynamic var imageURL = ""
    
}
