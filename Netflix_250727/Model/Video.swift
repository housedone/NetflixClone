//
//  Video.swift
//  Netflix_250727
//
//  Created by 김우성 on 7/27/25.
//

import Foundation

struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable {
    let key: String
    let site: String
    let type: String
}
