//
//  XMLParserManager.swift
//  NongminNews
//
//  Created by 박은지 on 2022/12/08.
//

import Foundation
import UIKit

//final class XMLParserManager: NSObject{
//
//    static let shared = XMLParserManager()
//
//    // XML parser
//    var xmlDict = [String: Any]()
//    var xmlDictArr:Array<[String:Any]> = []
//    var currentElement = ""
//
//
//    public func setCurrentWeather(){
//
//        let location = LocationManager.shared.currentLocation
//
//        let xmlParser = XMLParser(contentsOf: URL(string: "http://20.200.184.193/api/CurrentWeather.do?lon=\(location.coordinate.longitude)&lat=\(location.coordinate.latitude)")!)
//        xmlParser?.delegate = self
//        xmlParser?.parse()
//        
//    }
//
//    // MainVC를 가져올 때 까지 반복
//    func startMainVC() {
//
//        let vc: MainViewController? = self.getMainVC()
//
//        if vc != nil {
//            if vc!.isViewLoaded {
//                vc?.setCurrentWeather()
//                return
//            }
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(100)) {
//            self.startMainVC()
//        }
//
//    }
//
//    func getMainVC() -> MainViewController? {
//
//        var vc: MainViewController?
//
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//
//        if let nvc = appDelegate?.window?.rootViewController as? UINavigationController {
//
//            if nvc.isKind(of: UINavigationController.self) {
//                for child in nvc.viewControllers {
//
//                    if child.isKind(of: MainViewController.self) {
//                        vc = child as? MainViewController
//                    }
//                }
//            }
//        }
//        return vc
//    }
//
//
//
//
//}

////MARK: - CLLocationManagerDelegate
//extension XMLParserManager: XMLParserDelegate {
//    
//    // XML 파서가 시작 테그를 만나면 호출됨
//    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        
//        if elementName == "item" {
//            xmlDict = [:]
//        } else {
//            currentElement = elementName
//        }
//        
//    }
//    
//    // XML 파서가 종료 테그를 만나면 호출됨
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        
//        if elementName == "item" {
//            xmlDictArr.append(xmlDict)
//        }
//    }
//    
//    // 현재 테그에 담겨있는 문자열 전달
//    func parser(_ parser: XMLParser, foundCharacters string: String) {
//        
//        if !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            if xmlDict[currentElement] == nil {
//                xmlDict.updateValue(string, forKey: currentElement)
//            }
//        }
//        
//    }
//    
//    // 에러시, abortParsing()사용시
//    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error){
//        print(parseError)
//    }
//    
//}
