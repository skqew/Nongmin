//
//  NetworkManager.swift
//  NongminNews
//
//  Created by 조지운 on 2022/09/27.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import Foundation
import Alamofire
import Reachability

/// 응답값으로 int를 리턴하는 핸들러
typealias selectedHandler = (Int) -> ()
/// 응답값으로 Map을 리턴하는 핸들러
typealias completeHandler = ([String : Any]?) -> ()
/// 응답값으로 Boolean을 리턴하는 핸들러
typealias resultHandler = (Bool) -> ()
/// 응답값으로 void를 리턴하는 핸들러
typealias voidHandler = () -> ()

final class NetworkManager {
    /// 네트워크 연결 유형
    enum ConnectionType {
        case wifi
        case cellular
        case notConnected
        case none
    }
    
    static let shared = NetworkManager()
    
    /// 네트워크 연결 상태 체크 매니저
    let reachability: Reachability?
    /// 네트워크 연결 상태
    var connectionType: ConnectionType = .none {
        didSet(newVal) {
            if connectionType == .none {
                connectionType = newVal
            } else {
                if connectionType != newVal {
                    connectionType = newVal
                    // 네트워크 변화를 감지하여 이벤트를 발생시키고자 할 때 사용
                    //NotificationCenter.default.post(name: .changeNetworkReachability, object: nil)
                }
            }
        }
    }
    
    private init() {
        reachability = try! Reachability()
    }
    
    private let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        return Session(configuration: configuration)
    }()
    
    /**
     * 공통 헤더 설정
     * - Author: Jiwoon
     * - Parameters:
     * - Returns: HTTPHeaders
     */
    private func setApiRequestHeader() -> HTTPHeaders? {
        let header: HTTPHeaders = [
            "X-AUTH-TOKEN": USER_DATA.authToken,
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "ios"
        ]
        
        return header
    }
    
    /**
     * 네트워크 상태 변화 체크
     * - Author: Jiwoon
     */
    public func startReachabilityNotifier() {
        reachability?.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                self.connectionType = .wifi
            } else {
                print("Reachable via Cellular")
                self.connectionType = .cellular
            }
        }
        reachability?.whenUnreachable = { _ in
            self.showNetworkErrorPopup {
                print("Not reachable")
            }
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    /*
    /**
     * Concurrency 방식 요청
     * - Author: Jiwoon
     * - Parameters:
     *   - url : 요청 할 URL
     *   - type : 응답값 타입
     *   - method : Get/Post
     *   - param: 파라미터
     */
    func requestJSON<T: Decodable>(_ url: URL,
                                   type: T.Type,
                                   method: HTTPMethod,
                                   param: Parameters? = nil) async throws -> T {
        
        let dataTask = session.request(url,
                                       method: method,
                                       parameters: param,
                                       encoding: URLEncoding.default).serializingDecodable(type)
        
        let response = await dataTask.response
        if response.response?.statusCode == 200 {
            print("\(String(describing: response.response!.statusCode))")
            print("\(response.result)")
        } else {
            fatalError("Error while fetching data")
        }
        
        let value = try await dataTask.value
        return value
    }
     */
}

// MARK: - Non Concurrency
extension NetworkManager {
    /**
     * POST 요청
     * - Author: Jiwoon
     * - Parameters:
     *   - url : 요청 할 URL
     *   - param : 파라미터
     *   - header : 요청 헤더
     *   - complete: 요청 결과 콜백 핸들러
     */
    public func requestPost(withUrl url: String, param: Parameters?, header: HTTPHeaders?, complete: @escaping ([String: Any]?) -> ()) {
        // 요청할 URL 확인
        guard !url.isEmpty else {
            return
        }
        print(">>>>>> requestUrl: \(url)")
        
        // 요청 헤더 확인
        var requestHeader = header != nil ? header : setApiRequestHeader()
        requestHeader?.add(name: "Content-Type", value: "application/json")
        requestHeader?.add(name: "Accept", value: "application/json")
        
        // check network reachability
        if let manager = NetworkReachabilityManager(host: url) {
            if !manager.isReachable {
                self.showNetworkPostError(url: url, param: param, header: header, complete: complete)
                return
            }
        }
        
        // Request
        let request = AF.request(url,
                                 method: .post,
                                 parameters: param,
                                 encoding: JSONEncoding.default,
                                 headers: requestHeader, interceptor: nil, requestModifier: nil).validate()
        //request.responseDecodable(of: News.self) { response in
        request.responseJSON { response in
            switch response.result {
            case .success(let data):
                if let data = response.data {
                    print(String(data: data, encoding: .utf8)!)
                }
                print(">>>>>>>> Success requesting data: \(data)")
                complete(data as? [String : Any])
            case .failure(let error):
                print(">>>>>>>> Failed to request Post Network with Error: \(error.localizedDescription)")
                /*
                if response.response?.statusCode == 503 {
                    self.showNetworkPostError(url: url, param: param, header: header, complete: complete)
                }
                 */
                complete(nil)
            }
        }
        /*
        request.responseJSON { response in
            switch response.result {
            case .success(let data):
                guard let json = data as? [String: Any] else {
                    complete(nil)
                    return
                }
                print(">>>>>>>> Success requesting data: \(json)")
                complete(json)
            case .failure(let error):
                print(">>>>>>>> Failed to request Post Network with Error: \(error.localizedDescription)")
                
                if response.response?.statusCode == 503 {
                    self.showNetworkPostError(url: url, param: param, header: header, complete: complete)
                }
                complete(nil)
            }
        }
         */
    }
    
    /**
     * PUT 요청
     * - Author: Jiwoon
     * - Parameters:
     *   - url : 요청 할 URL
     *   - param : 파라미터
     *   - header : 요청 헤더
     *   - complete: 요청 결과 콜백 핸들러
     */
    public func requestPut(withUrl url: String, param: Parameters?, header: HTTPHeaders?, complete: @escaping ([String: Any]?) -> ()) {
        // 요청할 URL 확인
        guard !url.isEmpty else {
            return
        }
        print(">>>>>> requestUrl: \(url)")
        
        // 요청 헤더 확인
        var requestHeader = header != nil ? header : setApiRequestHeader()
        requestHeader?.add(name: "Content-Type", value: "application/json")
        requestHeader?.add(name: "Accept", value: "application/json")
        
        // check network reachability
        if let manager = NetworkReachabilityManager(host: url) {
            if !manager.isReachable {
                self.showNetworkPostError(url: url, param: param, header: header, complete: complete)
                return
            }
        }
        
        // Request
        let request = AF.request(url,
                                 method: .put,
                                 parameters: param,
                                 encoding: JSONEncoding.default,
                                 headers: requestHeader, interceptor: nil, requestModifier: nil).validate()
        //request.responseDecodable(of: News.self) { response in
        request.responseJSON { response in
            switch response.result {
            case .success(let data):
                if let data = response.data {
                    print(String(data: data, encoding: .utf8)!)
                }
                print(">>>>>>>> Success requesting data: \(data)")
                complete(data as? [String : Any])
            case .failure(let error):
                print(">>>>>>>> Failed to request Post Network with Error: \(error.localizedDescription)")
                
                if response.response?.statusCode == 503 {
                    self.showNetworkPostError(url: url, param: param, header: header, complete: complete)
                }
                complete(nil)
            }
        }
        /*
        request.responseJSON { response in
            switch response.result {
            case .success(let data):
                guard let json = data as? [String: Any] else {
                    complete(nil)
                    return
                }
                print(">>>>>>>> Success requesting data: \(json)")
                complete(json)
            case .failure(let error):
                print(">>>>>>>> Failed to request Post Network with Error: \(error.localizedDescription)")
                
                if response.response?.statusCode == 503 {
                    self.showNetworkPostError(url: url, param: param, header: header, complete: complete)
                }
                complete(nil)
            }
        }
         */
    }
    
    /**
     * GET 요청
     * - Author: Jiwoon
     * - Parameters:
     *   - url : 요청 URL
     */
    public func requestGet(withUrl urlString: String, param:[String: String]?, complete: @escaping ([String: Any]?) -> ()) {
        // 요청 URL 확인
        guard !urlString.isEmpty else {
            return
        }
        print(">>>>>> requestUrl: \(urlString)")
        
        if var url = URL(string: urlString) {
            // URL parameter
            if let p = param {
                for key in p.keys {
                    if let value = p[key] {
                        url = url.appending(key, value: value)
                    }
                }
            }
            
            // check network reachablity
            if let manager = NetworkReachabilityManager(host: urlString) {
                if !manager.isReachable {
                    self.showNetworkGetError(url: urlString, param: param, complete: complete)
                    return
                }
            }
            
            // Request
            let request = AF.request(url,
                                     method: .get,
                                     parameters: nil,
                                     encoding: JSONEncoding.default,
                                     headers: setApiRequestHeader(), interceptor: nil, requestModifier: nil).validate()
            //request.responseDecodable(of: News.self) { response in
            request.responseJSON { response in
                switch response.result {
                case .success(let data):
                    if let data = response.data {
                        print(String(data: data, encoding: .utf8)!)
                    }
                    print(">>>>>>>> Success requesting data: \(data)")
                    complete(data as? [String : Any])
                case .failure(let error):
                    print(">>>>>>>> Failed to request GET Network with Error: \(error.localizedDescription)")
                    
                    if response.response?.statusCode == 503 {
                        self.showNetworkGetError(url: urlString, param: param, complete: complete)
                    }
                    complete(nil)
                }
            }
            /*
            request.responseJSON { response in
                switch response.result {
                case .success(let data):
                    guard let json = data as? [String: Any] else {
                        complete(nil)
                        return
                    }
                    print(">>>>>>>> Success requesting data: \(json)")
                    
                    if url.lastPathComponent == "urgentNotice" {
                        if let json = data as? [String: Any] {
                            if json["notice_title"] != nil && json["notice_contents"] != nil {
                                if let content = json["notice_contents"] as? String, !content.isEmpty {
                                    self.showNetworkGetError(url: urlString, param: param, complete: complete)
                                }
                            }
                        }
                    }
                    complete(json)
                case .failure(let error):
                    print(">>>>>>>> Failed to request GET Network with Error: \(error.localizedDescription)")
                    
                    if response.response?.statusCode == 503 {
                        self.showNetworkGetError(url: urlString, param: param, complete: complete)
                    }
                    complete(nil)
                }
            }
             */
        }
    }
    
    /**
     * 네트워크 GET 통신 오류 처리
     * - Author: Jiwoon
     * - Parameters:
     *   - url : 재요청 URL
     *   - param : 재요청 URL 파라미터
     */
    private func showNetworkGetError(url: String, param: [String: String]?, complete: @escaping ([String: Any]?) -> ()) {
        self.showNetworkErrorPopup {
            // 재요청
            self.requestGet(withUrl: url, param: param, complete: complete)
        }
    }
    
    /**
     * POST 네트워크 통신 오류 처리
     * - Author: Jiwoon
     * - Parameters:
     *   - url : 재요청 URL
     *   - param : 재요청 파라미터
     *   - header : 재요청 헤더
     */
    private func showNetworkPostError(url: String, param: Parameters?, header: HTTPHeaders?, complete: @escaping ([String: Any]?) -> ()) {
        self.showNetworkErrorPopup {
            // 재요청
            self.requestPost(withUrl: url, param: param, header: header, complete: complete)
        }
    }
    
    /**
     * 네트워크 오류 팝업 노출
     * - Author: Jiwoon
     */
    public func showNetworkErrorPopup(_ retry: @escaping voidHandler) {
        let alert = UIAlertController(title: "네트워크 에러", message: "네트워크 상태가 불안정 합니다.", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        
        if let topVC = UIApplication.getMostTopViewController() {
            topVC.present(alert, animated: true, completion: nil)
        }
    }
    
    /**
     * 이미지 다운로드
     * - Author: Jiwoon
     * - Parameters:
     *   - url : 이미지 URL
     */
    public func downloadImage(url: String, complete: @escaping completeHandler) {
        AF.download(url, interceptor: nil, to: nil).responseData { response in
            switch response.result {
            case .success(let data):
                if let image = UIImage(data:  data) {
                    var result = [String: Any]()
                    result["image"] = image
                    complete(result)
                }
            case .failure(_):
                complete(nil)
            }
        }
    }
}
