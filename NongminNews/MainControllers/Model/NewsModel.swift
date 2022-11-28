//
//  NewsModel.swift
//  NongminNews
//
//  Created by 조지운 on 2022/11/10.
//  copyright ⓒThe Farmers Newspaper. All rights reserved
//

import Foundation

// MARK: - 사용자 데이터

struct CommonUserData: Codable {
    var authToken: String = ""
    var userId: String = ""
    var userClass: String = ""
    var isAutoLogin: Bool = false
}


// MARK: - 로그인 응답 데이터

struct LoginData: Codable {
    var authToken: String
    var mktAgreeYn: String
    
    init?(dictionary: JSONDictionary) {
        guard let authToken = dictionary["X-AUTH-TOKEN"] as? String,
              let mktAgreeYn = dictionary["MARKETING_REGIST_YN"] as? String
        else {
            return nil
        }
        self.authToken = authToken
        self.mktAgreeYn = mktAgreeYn
    }
}


// MARK: - 푸시 뉴스 알림 목록

struct NotiListData: Codable {
    var pushGubun1: String
    var pushGubun2: String
    var pushTitle: String
    var registDatetime: String
    var pushCategoryTitle: String
    var pushParam1: String
    var pushParam2: String
    var pushParam3: String
    
    init?(dictionary: JSONDictionary) {
        guard let pushGubun1 = dictionary["pushGubun1"] as? String,
              let pushGubun2 = dictionary["pushGubun2"] as? String,
              let pushTitle = dictionary["pushTitle"] as? String,
              let registDatetime = dictionary["registDatetime"] as? String,
              let pushCategoryTitle = dictionary["pushCategoryTitle"] as? String,
              let pushParam1 = dictionary["pushParam1"] as? String,
              let pushParam2 = dictionary["pushParam2"] as? String,
              let pushParam3 = dictionary["pushParam3"] as? String
        else {
            return nil
        }
        self.pushGubun1 = pushGubun1
        self.pushGubun2 = pushGubun2
        self.pushTitle = pushTitle
        self.registDatetime = registDatetime
        self.pushCategoryTitle = pushCategoryTitle
        self.pushParam1 = pushParam1
        self.pushParam2 = pushParam2
        self.pushParam3 = pushParam3
    }
}


// MARK: - 공지 사항 상세 조회

struct NotiDetailData: Codable {
    var rsvDate: String
    var sendContent: String
    var sendLink: String
    var rsvYn: String
    var sendTitle: String
    var rsvTime: String
    var sendStateCode: String
    
    init?(dictionary: JSONDictionary) {
        guard let rsvDate = dictionary["rsvDate"] as? String,
              let sendContent = dictionary["sendContent"] as? String,
              let sendLink = dictionary["sendLink"] as? String,
              let rsvYn = dictionary["rsvYn"] as? String,
              let sendTitle = dictionary["sendTitle"] as? String,
              let rsvTime = dictionary["rsvTime"] as? String,
              let sendStateCode = dictionary["sendStateCode"] as? String
        else {
            return nil
        }
        self.rsvDate = rsvDate
        self.sendContent = sendContent
        self.sendLink = sendLink
        self.rsvYn = rsvYn
        self.sendTitle = sendTitle
        self.rsvTime = rsvTime
        self.sendStateCode = sendStateCode
    }
}
