//
//  AuthResModel.swift
//  ImageList
//
//  Created by Chandra Hasan on 17/04/24.
//

import Foundation

struct AuthResModel: Decodable {
    let access_token: String?
    let token_type: String?
    let refresh_token: String?
    let scope: String?
    let created_at: Int?
    let user_id: Int?
    let username: String?
    enum CodingKeys: String, CodingKey {
       case access_token
       case token_type
       case refresh_token
       case scope
       case created_at
       case user_id
       case username
    }
}

/*
 {
     "access_token": "o_mcidm_aCwz78lPv0aZIPEX97tn1MPefWl7z1gDMzA",
     "token_type": "Bearer",
     "refresh_token": "swkgN1UhBjM18Go3I6Aw5ac1ihVgtNGI8N6wuAn_mp8",
     "scope": "public read_photos",
     "created_at": 1713376536,
     "user_id": 16036173,
     "username": "chandra_hasan"
 }
 */
