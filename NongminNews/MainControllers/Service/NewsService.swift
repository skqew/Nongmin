//
//  NewsService.swift
//  NongminNews
//
//  Created by 조지운 on 2022/09/27.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import Foundation
import Alamofire

typealias JSONDictionary = [String: Any]

class NewsService {
    /// FCM 토큰 전송
    func sendFCMToken(token: String, completion: @escaping completeHandler) {
        let url = Const.ApiUrl.sendFcmToken
        let parameter = ["pushPrivateToken" : token, "pushPlatform" : "IOS"]
        print("request url: \(url)")
        
        NetworkManager.shared.requestPut(withUrl: url, param: parameter, header: nil) { response in
            if let result = response {
                completion(result)
            } else {
                completion(nil)
            }
        }
    }
    
    /// 인증문자 발송 요청
    func requestAuthNumber(phone: String, completion: @escaping completeHandler) {
        let url = Const.ApiUrl.getAuthNumber
        let parameter = ["memberNumberPhone" : phone, "platformGubun" : "I", "platformHashValue" : ""]
        print("request url: \(url)")
        
        NetworkManager.shared.requestPut(withUrl: url, param: parameter, header: nil) { response in
            if let result = response {
                completion(result)
            } else {
                completion(nil)
            }
        }
    }
    
    // 인증 처리 결과 요청
    func requestAuthResult(phone: String, authNum: String, completion: @escaping completeHandler) {
        let url = Const.ApiUrl.getAuthResult
        let parameter = ["memberNumberPhone" : phone, "confirmNumber" : authNum]
        print("request url: \(url)")
        
        NetworkManager.shared.requestPost(withUrl: url, param: parameter, header: nil) { response in
            if let result = response {
                completion(result)
            } else {
                completion(nil)
            }
        }
    }
    
    // 이용약관 마케팅 수신 동의 여부 전송
    func sendMarketingAgree(agreeYn: String, completion: @escaping completeHandler) {
        let url = Const.ApiUrl.sendMktAgree
        let parameter = ["marketingYn" : agreeYn]
        print("request url: \(url)")
        
        NetworkManager.shared.requestPut(withUrl: url, param: parameter, header: nil) { response in
            if let result = response {
                completion(result)
            } else {
                completion(nil)
            }
        }
    }
    
    /// 푸시 알림 목록 조회
    func requestNotiList(completion: @escaping completeHandler) {
        let url = Const.ApiUrl.getNotiList
        print("request url: \(url)")
        
        NetworkManager.shared.requestGet(withUrl: url, param: nil, complete: { response in
            if let result = response {
                completion(result)
            } else {
                completion(nil)
            }
        })
    }
    
    /// 공지 사항 상세 조회
    func requestNotiDetail(seq: String, completion: @escaping completeHandler) {
        let url = Const.ApiUrl.getNotiDetail + "/\(seq)"
        print("request url: \(url)")
        
        NetworkManager.shared.requestGet(withUrl: url, param: nil, complete: { response in
            if let result = response {
                completion(result)
            } else {
                completion(nil)
            }
        })
    }
    
    /// 사용자 등급 조회
    func requestUserClass(completion: @escaping completeHandler) {
        let url = Const.ApiUrl.getUserClass
        print("request url: \(url)")
        
        NetworkManager.shared.requestGet(withUrl: url, param: nil, complete: { response in
            if let result = response {
                completion(result)
            } else {
                completion(nil)
            }
        })
    }
}
