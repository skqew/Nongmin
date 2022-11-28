//
//  PaperService.swift
//  NongminNews
//
//  Created by 조지운 on 2022/11/09.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import Foundation
import Alamofire

class PaperService {
    // 지면 발행일자 조회(캘린더 세팅)
    func getPublishInfo(url: URL, completion: @escaping ([PublishInfo]) -> ()) {
        var pubInfo = [PublishInfo]()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                let jsonArr = json as? NSArray ?? []
                //let dictionary = json as! JSONDictionary
                //let infoDictionaries = jsonArr["articles"] as! [JSONDictionary]
                
                pubInfo = jsonArr.compactMap { dictionary in
                    return PublishInfo(dictionary :dictionary as! JSONDictionary)
                }
            }
            
            DispatchQueue.main.async {
                completion(pubInfo)
            }
            
        }.resume()
    }
    
    // 최근 12개호 지면 정보 조회 및 특정일자 지면 데이터 호출
    func getPaperData(url: URL, completion: @escaping ([PaperData]) -> ()) {
        var paper = [PaperData]()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                let jsonArr = json as? NSArray ?? []
                
                for item in jsonArr {
                    let jsonData = try? JSONSerialization.data(withJSONObject: item, options: .prettyPrinted)
                    let json = try? JSONDecoder().decode(PaperData.self, from: jsonData!)
                    
                    paper.append(json!)
                }
            }
            
            DispatchQueue.main.async {
                completion(paper)
            }
            
        }.resume()
    }
    
    // 기사 데이터 조회
    func getArticleData(url: URL, completion: @escaping ([Article]) -> ()) {
        var articles = [Article]()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                let jsonArr = json as? NSArray ?? []
                
                articles = jsonArr.compactMap { dictionary in
                    return Article(dictionary :dictionary as! JSONDictionary)
                }
            }
            
            DispatchQueue.main.async {
                completion(articles)
            }
            
        }.resume()
    }
}


extension URLSession {
    @available(iOS, deprecated: 15.0, message: "동 익스텐션은 iOS 15 이상은 사용할 필요 없음.")
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
}
