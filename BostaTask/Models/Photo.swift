//
//  Photo.swift
//  BostaTask
//
//  Created by Dodo's Mac on 12/02/2025.
//

import Foundation


struct Photo: Codable {
    let id: Int
    let albumId: Int
    let title: String
    let url: String
    let thumbnailUrl: String 
}
