//
//  AppCommonUtil.swift
//  dietapp
//
//  Created by 조지운 on 2022/11/10.
//  copyright ⓒThe Farmers Newspaper. All rights reserved
//

import Foundation
import UIKit
import WebKit
import CoreTelephony
import Alamofire

class AppCommonUtil: NSObject {
    /**
     * 스토리보드에서 뷰컨트롤러를 로드한다.
     * - Author: Jiwoon
     * - Parameters:
     *   - name : 스토리보드 내 뷰 컨트롤러 ID
     *   - storyboardName : 스토리보드 명
     * - Returns: 스토리보드 내 ViewController ID를 가지는 ViewController
     */
    public static func viewController(name: String, storyboardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: name)
    }
    
    /**
     * 쿠키 설정
     * - Author: Jiwoon
     * - Parameters:
     *   - strKey : 쿠키 네임
     *   - value : 쿠키 밸류
     */
    static func setCookie(domain: String, strKey: String, value:String) {
        let fmt = DateFormatter()
        fmt.timeZone = TimeZone(abbreviation: "UTC")
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let expiredDate = Date(timeIntervalSinceNow: 86400*30*1) // 유효기간 1달
        let expireStr = fmt.string(from: expiredDate)
        let prop : [HTTPCookiePropertyKey: Any] = [
            .domain: domain,
            .path: "/",
            .name: strKey,
            .value: value,
            .secure: "FALSE",
            .expires: expireStr
        ]
        
        if let cookie = HTTPCookie(properties: prop) {
            WKWebsiteDataStore.default().httpCookieStore.setCookie(cookie, completionHandler: nil)
        } else {
            print("setCookie error")
        }
    }
    
    /**
     * 전체 쿠키 값 확인
     * - Author: Jiwoon
     */
    static func getAllCookieValue() {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                print("WKWebsiteDataStore cookie : \(cookie.name) // \(cookie.value)")
            }
        }
    }
    
    /**
     * 쿠키 값 확인
     * - Author: Jiwoon
     * - Parameters:
     *   - strKey : 쿠키 키
     * - Returns: 확인 된 쿠키 스트링 밸류
     */
    static func getCookieValue(strKey: String) -> String {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for item in cookies {
                if item.name == strKey {
                    return item.value
                }
            }
        }
        return "0"
    }
    
    /**
     * 전체 쿠키 정보 삭제
     * - Author: Jiwoon
     */
    static func removeAllCookies() {
        /*
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
         */
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("All cookies deleted")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("Cookie ::: \(record) deleted")
            }
        }
    }
    
    /**
     * 쿠키 정보 삭제
     * - Author: Jiwoon
     * - Parameters:
     *   - name : 쿠키 명
     */
    static func removeCookie(name: String) {
        /*
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if cookie.name == name {
                    HTTPCookieStorage.shared.deleteCookie(cookie)
                    break
                }
            }
        }
         */
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if cookie.name == name, !cookie.value.isEmpty {
                    WKWebsiteDataStore.default().httpCookieStore.delete(cookie, completionHandler: nil)
                }
            }
        }
    }
    
    /**
     * 앱 버전 확인
     * - Author: Jiwoon
     * - Returns: 앱 버전 short 스트링
     */
    public static func getAppVersion() -> String? {
        let info = Bundle.main.infoDictionary
        return info?["CFBundleShortVersionString"] as? String
    }
    
    /**
     * 디바이스 UUID 확인
     * - Author: Jiwoon
     * - Returns: UUID 스트링
     */
    public static func getUUID() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    /**
     * OS 버전 확인
     * - Author: Jiwoon
     * - Returns: OS버전
     */
    public static func getOsVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    /**
     * 디바이스모델 식별
     * - Author: Jiwoon
     * - Returns: 식별된 디바이스 모델
     */
    public static func getDeviceModel() -> String {
        return ""
    }
    
    /**
     * 폰 통신사명 확인
     * - Author: Jiwoon
     * - Returns: 식별된 통신사명
     */
    public static func getCarrierName() -> String {
        if #available(iOS 12.0, *) {
            if let providers = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders {
                /*
                providers.forEach { (key, value) in
                    print("key: \(key), carrier: \(value.carrierName ?? "")")
                } */
                if providers.first?.value.carrierName != nil {
                    return (providers.first?.value.carrierName)!
                } else {
                    return ""
                }
            } else {
                return ""
            }
        } else {
            let provider = CTTelephonyNetworkInfo().subscriberCellularProvider
            print("carrier: \(provider?.carrierName ?? "")")
            return provider?.carrierName ?? ""
        }
    }
    
    /**
     * 외부 브라우저 호출
     * - Author: Jiwoon
     * - Parameters:
     *   - link : 호출할 URL
     */
    public static func openExternal(_ link: String) {
        if let url = URL(string: link) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    /**
     * 현재 단말기가 노치를 포함하는 기기인지 체크
     * - Author: Jiwoon
     * - Returns: 노치를 포함하는 기기라면 True, 그렇지 않으면 False
     */
    public static func hasNotchDevice() -> Bool {
        var result = false
        if #available(iOS 11.0, *) {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                if let window = appDelegate.window {
                    result = window.safeAreaInsets.top > 20.0
                }
            }
        } else {
            let height = UIScreen.main.bounds.size.height
            result = (height == 812.0 || height == 896.0 || height == 844.0)
        }
        return result
    }
    
    /**
     * 해상도별 라벨 폰트 사이즈 조정
     * - Author: Jiwoon
     * - Parameters:
     *   - itemList : 사이즈 조정 대상 라벨 리스트
     */
    public static func resizeFont(_ itemList: [UIView]) {
        guard !itemList.isEmpty else {
            return
        }
        
        for item in itemList {
            if item.isKind(of: UILabel.self) {
                if let target = item as? UILabel {
                    let size = target.font.pointSize
                    let newFont = target.font.withSize(scaleFontSize(size))
                    target.font = newFont
                }
            } else if item.isKind(of: UIButton.self) {
                if let target = item as? UIButton {
                    if let size = target.titleLabel?.font.pointSize {
                        let newFont = target.titleLabel?.font.withSize(scaleFontSize(size))
                        target.titleLabel?.font = newFont
                    }
                }
            }
        }
    }
    
    /**
     * 폰트 스케일
     * - Author: Jiwoon
     * - Parameters:
     *   - size : 변경 사이즈
     * - Returns: 스케일된 사이즈
     */
    public static func scaleFontSize(_ size: CGFloat) -> CGFloat {
        // 스크린 사이즈
        let screenSize = UIScreen.main.bounds.size
        // 타겟 단말기 사이즈
        let defineSize = CGSize(width: 375, height: 667)
        
        var fTarget = CGFloat.zero
        var fDef = CGFloat.zero
        if abs(defineSize.width - screenSize.width) <= abs(defineSize.height - screenSize.height) {
            fDef = defineSize.width
            fTarget = screenSize.width
        } else {
            fDef = defineSize.height
            fTarget = screenSize.height
        }
        
        let rtnVal = roundf(Float((size * fTarget) / fDef))
        return CGFloat(rtnVal)
    }
    
    // 문자열을 날짜로
    public static func getStringToDate(strDate: String, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        return dateFormatter.date(from: strDate)!
    }
    
    // 날짜를 문자열로
    public static func getDateToString(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        return dateFormatter.string(from: date)
    }
}
