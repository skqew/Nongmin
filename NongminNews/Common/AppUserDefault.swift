//
//  AppUserDefault.swift
//  NongminNews
//
//  Created by 조지운 on 2022/11/10.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import Foundation

protocol KeyNamespaceable { }

extension KeyNamespaceable {
    private static func namespace(_ key: String) -> String {
        return "\(Self.self).\(key)"
    }
    
    static func namespace<T: RawRepresentable>(_ key: T) -> String where T.RawValue == String {
        return namespace(key.rawValue)
    }
}

protocol BoolUserDefaultable: KeyNamespaceable {
    associatedtype BoolDefaultKey: RawRepresentable
}

extension BoolUserDefaultable where BoolDefaultKey.RawValue == String {
    // Get
    static func bool(forKey key: BoolDefaultKey) -> Bool {
        let key = namespace(key)
        return UserDefaults.standard.bool(forKey: key)
    }
    
    // Set
    static func set(_ bool: Bool, forKey key: BoolDefaultKey) {
        let nameKey = namespace(key)
        UserDefaults.standard.set(bool, forKey: nameKey)
        UserDefaults.standard.synchronize()
    }
}

protocol ObjectUserDefaultable : KeyNamespaceable {
    associatedtype ObjectDefaultKey : RawRepresentable
}

extension ObjectUserDefaultable where ObjectDefaultKey.RawValue == String {
    // Get
    static func object(forKey key: ObjectDefaultKey) -> Any? {
        let key = namespace(key)
        return UserDefaults.standard.object(forKey: key)
    }
    
    // Set
    static func set(_ object: AnyObject, forKey key: ObjectDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
}

protocol ValueUserDefaultable : KeyNamespaceable {
    associatedtype ValueDefaultKey : RawRepresentable
}

extension ValueUserDefaultable where ValueDefaultKey.RawValue == String {
    // Get
    static func value(forKey key: ValueDefaultKey) -> Any? {
        let key = namespace(key)
        return UserDefaults.standard.value(forKey: key)
    }
    
    // Set
    static func set(_ value: Any?, forKey key: ValueDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Integer Defaults

protocol IntegerUserDefaultable : KeyNamespaceable {
    associatedtype IntegerDefaultKey : RawRepresentable
}

extension IntegerUserDefaultable where IntegerDefaultKey.RawValue == String {
    // Get
    static func integer(forKey key: IntegerDefaultKey) -> Int {
        let key = namespace(key)
        return UserDefaults.standard.integer(forKey: key)
    }
    
    // Set
    static func set(_ integer: Int, forKey key: IntegerDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(integer, forKey: key)
    }
}

// MARK: - URL Defaults

protocol URLUserDefaultable : KeyNamespaceable {
    associatedtype URLDefaultKey : RawRepresentable
}

extension URLUserDefaultable where URLDefaultKey.RawValue == String {
    // Get
    static func url(forKey key: URLDefaultKey) -> URL? {
        let key = namespace(key)
        return UserDefaults.standard.url(forKey: key)
    }
    
    // Set
    static func set(_ url: URL?, forKey key: URLDefaultKey) {
        let key = namespace(key)
        UserDefaults.standard.set(url, forKey: key)
    }
}


extension UserDefaults {
    struct Nongmin : BoolUserDefaultable, ValueUserDefaultable, IntegerUserDefaultable, URLUserDefaultable {
        private init() { }
        
        enum URLDefaultKey: String {
            /** 인트로 이미지 Url 저장된 값 */
            case introSplahImageUrl
        }
        
        enum IntegerDefaultKey: String {
            /** 인트로 스플래쉬 이미지 고유 ID ( 이미지 변경 여부 확인용 ) */
            case introSplahID
        }
        
        enum BoolDefaultKey : String {
            /** APP을 이미 최초 실행 했는지 여부 확인 */
            case isAlreadyRun
            /** 마케팅 활용 동의 **/
            case marketingTermsAgree
            /** 로그인 유지 여부 */
            case isAutoLogin
            
        }
        
        enum ValueDefaultKey: String {
            /** FCM 토큰 저장 */
            case pushToken
            /** 로그인 후 받는 인증 토큰 */
            case authToken
            /** 사용자 ID */
            case userId
            /** 사용자 회원 등급 */
            case userClass
            /** 기사 본문 글자크기 설정 */
            case textSize
        }
    }
}
