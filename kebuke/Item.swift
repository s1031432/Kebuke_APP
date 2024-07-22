//
//  Item.swift
//  kebuke
//
//  Created by 黃翊唐 on 2024/7/21.
//

import UIKit

class Price: Codable {
    let l: Int
    let m: Int
    
    init(l: Int, m: Int) {
        self.l = l
        self.m = m
    }
}
class Item: Codable {
    let imageUrl: String
    let name: String
    let description: String
    let price: Price
    
    init(imageUrl: String, name: String, description: String, price: Price) {
        self.imageUrl = imageUrl
        self.name = name
        self.description = description
        self.price = price
    }
}
