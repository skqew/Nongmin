//
//  AppDelegate.swift
//  NongminNews
//
//  Created by 조지운 on 2022/08/09.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var shouldSupportAllOrientation = false
    public static var pendingData: String = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 앱 최초 실행 여부 확인
        let isRun = UserDefaults.Nongmin.bool(forKey: .isAlreadyRun)
        if !isRun {
            // 캐시 삭제
            URLCache.shared.removeAllCachedResponses()
            // 쿠키 초기화
            AppCommonUtil.removeAllCookies()
            // 최초 실행 완료 설정
            UserDefaults.Nongmin.set(true, forKey: .isAlreadyRun)
        }
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        registerRemotePush(application)
        
        // 네트워크 상태 리스너
        NetworkManager.shared.startReachabilityNotifier()
        
        // 로그인 유지 유무에 따라 사용자 정보 세팅
        let isAuto = UserDefaults.Nongmin.bool(forKey: .isAutoLogin)
        if isAuto {
            getUserData()
        } else {
            logout()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // 화면 회전 변수 값에 따라 화면 회전 활성화 지정
        if (shouldSupportAllOrientation) {
            return [.all]
        } else {
            return [.portrait, .portraitUpsideDown]
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func getUserData() {
        USER_DATA.authToken = UserDefaults.Nongmin.value(forKey: .authToken) as? String ?? ""
        USER_DATA.userId = UserDefaults.Nongmin.value(forKey: .userId) as? String ?? ""
        USER_DATA.userClass = UserDefaults.Nongmin.value(forKey: .userClass) as? String ?? ""
        USER_DATA.isAutoLogin = UserDefaults.Nongmin.bool(forKey: .isAutoLogin)
        
        print(USER_DATA)
    }
    
    func logout() {
        // 사용자 정보 초기화
        AppCommonUtil.removeCookie(name: "X-AUTH-TOKEN")
        
        USER_DATA = CommonUserData()
        
        UserDefaults.Nongmin.set("", forKey: .authToken)
        UserDefaults.Nongmin.set("", forKey: .userId)
        UserDefaults.Nongmin.set("", forKey: .userClass)
        UserDefaults.Nongmin.set(false, forKey: .isAutoLogin)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handleInComingDynamicLink(dynamicLink)
            return true
        }
        return true
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            print("incoming : \(incomingURL)")
            
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else {
                    print("error = \(error!.localizedDescription)")
                    return
                }
                
                if let dynamicLink = dynamicLink {
                    self.handleInComingDynamicLink(dynamicLink)
                }
            }
            
            if linkHandled {
                return true
            } else {
                if incomingURL.host == "cumembership.page.link" {
                    guard let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
                          let queryItems = components.queryItems else { return false }
                    if let link = queryItems.first(where:{ $0.name == "link" })?.value {
                        print("link = \(link)")
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func handleInComingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            return
        }
        
        print("url : \(url.absoluteString)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return }
        if let phone = queryItems.first(where:{ $0.name == "phone" })?.value {
            print("Phone Number = \(phone)")
            AppDelegate.pendingData = phone
            //NotificationCenter.default.post(name: NSNotification.Name("phoneNumber"), object: phone)
        }
    }
    
    func sendFCMTokenToServer(token: String) {
        NewsService().sendFCMToken(token: token) { response in
            if let result = response {
                let code = result["code"] as! String
                let message = result["message"] as! String
                
                if code == "10000" {
                    print("message: \(message)")
                } else {
                    print("message: \(message)")
                }
            }
        }
    }
}


// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    func registerRemotePush(_ application: UIApplication) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // FCM 토큰 갱신
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // 푸시 토큰 유저 디폴트 저장 or 푸시 토큰 서버 전달
        if USER_DATA.authToken.isEmpty {
            UserDefaults.Nongmin.set(fcmToken, forKey: .pushToken)
        } else {
            UserDefaults.Nongmin.set("", forKey: .pushToken)
            sendFCMTokenToServer(token: fcmToken ?? "")
        }
        
        print(fcmToken as Any)
        /*
        #if DEBUG
        Messaging.messaging().subscribe(toTopic: "notice_ios_test")
        #endif
        Messaging.messaging().subscribe(toTopic: "notice_ios")
         */
        
        Messaging.messaging().subscribe(toTopic: "topicPrimary_ios") { error in
          print("Subscribed to topicPrimary_ios topic")
        }
        
        Messaging.messaging().subscribe(toTopic: "topicFast_ios") { error in
          print("Subscribed to topicFast_ios topic")
        }
        
        Messaging.messaging().subscribe(toTopic: "topicNotice_ios") { error in
          print("Subscribed to topicNotice_ios topic")
        }
        
        Messaging.messaging().subscribe(toTopic: "topicNewspaper_ios") { error in
          print("Subscribed to topicNewspaper_ios topic")
        }
    }
    
    func remoteNotificationStatus(_ complete: @escaping (_ isEnabled: Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            DispatchQueue.main.async {
                complete(settings.authorizationStatus == .authorized)
            }
        })
    }
    
    // 앱이 Front일때 푸시 수신
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if let userInfo = notification.request.content.userInfo as? [String : Any] {
            print(userInfo)
            /*
            ["gcm.message_id": 1669364330811450,
             "aps": {
                alert =     {
                    body = "test\Ub0b4\Uc6a9";
                    title = "\Uc791\Uc131 \Ud558\Uc2e0 \Uac8c\Uc2dc\Uae00\Uc5d0 \Ub313\Uae00\Uc774 \Ucd94\Uac00 \Ub418\Uc5c8\Uc2b5\Ub2c8\Ub2e4.";
                };
            },
             "pushTitle": 작성 하신 게시글에 댓글이 추가 되었습니다.,
             "google.c.a.e": 1,
             "google.c.sender.id": 487954971646,
             "pushParam1": http://naver.com,
             "pushMessage": test내용,
             "google.c.fid": f2P3Lqv4f0_wqYogimWIrk]
             */
        }
        
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
    
    // 앱이 Background일때 푸시를 눌러서 구동
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let action = response.actionIdentifier
        if action.contains("UNNotificationDefaultActionIdentifier") {
            if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
                print(">>>>> received push info: \(userInfo)")
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            completionHandler()
        }
    }
}

