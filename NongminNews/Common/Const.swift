//
//  Const.swift
//  NongminNews
//
//  Created by 조지운 on 2022/09/27.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import Foundation
import UIKit

let APP_DELEGATE = UIApplication.shared.delegate as? AppDelegate

var USER_DATA = CommonUserData()

var isDisplayZoomed: Bool {
    return UIScreen.main.scale < UIScreen.main.nativeScale
}

class Const {
/// 농민신문 base url
    enum Target {
        case dev
        case prod
        
        var nongminApiUrl: String {
            switch self {
            case .dev:
                return "https://dev.nongmin.com" //"http://118.67.151.79:8081"
            case .prod:
                return "https://api.nongmin.co.kr"
            }
        }
        
        var nongminWebUrl: String {
            switch self {
            case .dev:
                return "https://dev.nongmin.com"
            case .prod:
                return "https://api.nongmin.co.kr"
            }
        }
    }
    
    static let target: Target = .dev
    //static let target: Target = .prod
    
    
    final class Pref {
        /// 토큰 값
        public static let token: String = "user_token"
        /// 앱 최초 실행 여부
        public static let isFirstRun: String = "isFirstRun"
        /// 앱 접근권한 화면 노출 여부
        public static let isShowAuthority: String = "isShowAuthority"
        /// 메인 코치마크 확인 버전 정보
        public static let mainCoachVer: String = "main"
        /// isUserLogin
        public static let isUserLogin: String = "is_user_login"
        /// 앱 스토어 url
        public static let appStoreUrl = "itms-apps://itunes.apple.com/app/id1267195053"
    }
    
    final class ApiUrl {
        /** NewsService*/
        /// FCM 토큰 서버 전송
        public static let sendFcmToken = "\(target.nongminApiUrl)/api/app/member/privateToken"
        /// 인증 문자 요청
        public static let getAuthNumber = "\(target.nongminApiUrl)/api/side/member/authNumberRequest"
        /// 인증 처리 결과 및 로그인 요청
        public static let getAuthResult = "\(target.nongminApiUrl)/api/side/member/authNumberConfirm"
        /// 마케팅 수신 동의 여부 전송
        public static let sendMktAgree = "\(target.nongminApiUrl)/api/app/member/selectAgreeSave"
        /// 푸시 알림 목록 요청
        public static let getNotiList = "\(target.nongminApiUrl)/api/app/user/pushHistory"
        /// 공지 사항 상세 요청
        public static let getNotiDetail = "\(target.nongminApiUrl)/api/app/notice"
        /// 사용자 등급 조회
        public static let getUserClass = "\(target.nongminApiUrl)/api/app/user/grade"
        
        /** PaperService */
        /// 지면 발행일자 조회
        public static let getPublishDate = "\(target.nongminApiUrl)/_/newspaper/api/info"
        /// 지면 발행일별 정보 조회(최신 12개호 썸네일)
        public static let getPageInfo = "\(target.nongminApiUrl)/_/newspaper/api/pages"
        /// 특정일자 지면 데이터 조회
        public static let getPaperData = "\(target.nongminApiUrl)/_/newspaper/api/pages?media=1&publishDate="
        /// 지면 이미지 파일 다운로드
        public static let getPaperImageFile = "\(target.nongminApiUrl)/_/newspaper/pages/"
        /// 특정일자 전체 기사 데이터 조회
        public static let getArticleData = "\(target.nongminApiUrl)/_/newspaper/api/articles?media=1&publishDate="
    }
    
    final class WebUrl {
        /// 메인
        public static let main = "\(target.nongminWebUrl)"
        /// 기사 열기
        public static let openArticle = "\(target.nongminWebUrl)/article/"
        /// 오늘의 주요뉴스
        public static let todayHeadline = "\(target.nongminWebUrl)/todaysMainNews"
        /// 관심뉴스
        public static let favoriteNews = "\(target.nongminWebUrl)/myPage/interestNewsList"
        /// 관심뉴스 설정
        public static let favoriteSet = "\(target.nongminWebUrl)/myPage/interestCustom"
        /// 소통광장 > 직거래마당
        public static let commuMarket = "\(target.nongminWebUrl)/sale/transactionList"
        /// 소통광장 > 소통마당
        public static let commuPlaza = "\(target.nongminWebUrl)/community/communicationList/all"
        /// 로그인
        public static let login = "\(target.nongminWebUrl)/app/login"
        /// 앱용 전체 메뉴
        public static let appMenu = "\(target.nongminWebUrl)/app/menu"
        /// 회원 약관
        public static let memberTerms = "\(target.nongminWebUrl)"
        /// 개인정보 수집 및 동의
        public static let personalInfo = "\(target.nongminWebUrl)"
        /// 개인정보 공유 및 제3자 제공 동의
        public static let personalInfoShare = "\(target.nongminWebUrl)"
    }
}
