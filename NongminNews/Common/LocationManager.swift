//
//  LocationManager.swift
//  NongminNews
//
//  Created by 박은지 on 2022/12/08.
//

import UIKit
import Foundation
import CoreLocation

final class LocationManager: NSObject{
    
    static let shared = LocationManager()
    
    let locationManager = CLLocationManager()
    public var currentLocation = CLLocation()
    
    // 위경도값 가져오기
    public func getCurrentLocation(){
        
//        DispatchQueue.main.async {
            // 아이폰 설정에서 위치 서비스가 켜진 상태라면
            if CLLocationManager.locationServicesEnabled() {
                print("위치 서비스 On 상태")
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // 거리 정확도 설정
                self.locationManager.requestWhenInUseAuthorization() // 사용자에게 허용 여부 Aler
                self.locationManager.startUpdatingLocation() // 위치 정보 받아오기 시작

            } else {
                print("위치 서비스 Off 상태")
            }
//        }
        
    }
    
}

//MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    // 위치 서비스에 대한 권한 확인
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("위치 사용 권한 허용")
        }
        if status == .denied {
            print("위치 사용 권한 거부")
        }
        if status == .restricted || status == .notDetermined {
            print("위치 사용 권한 대기 상태")
        }

    }
    
    // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("didUpdateLocations")
        if let location = locations.first {
            
            print("위도 : \(location.coordinate.latitude)")
            print("경도 : \(location.coordinate.longitude)")
            
            self.currentLocation = self.locationManager.location ?? CLLocation(latitude: 0, longitude: 0)
            
            startMainVC()
            
            locationManager.stopUpdatingLocation()
            

        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    // MainVC를 가져올 때 까지 반복
    func startMainVC() {
        
        let vc: MainViewController? = self.getMainVC()
        
        if vc != nil {
            if vc!.isViewLoaded {
                vc?.setCurrentWeather()
                return
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(100)) {
            self.startMainVC()
        }
        
    }
    
    func getMainVC() -> MainViewController? {
        
        var vc: MainViewController?
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        if let nvc = appDelegate?.window?.rootViewController as? UINavigationController {
            
            if nvc.isKind(of: UINavigationController.self) {
                for child in nvc.viewControllers {
                    
                    if child.isKind(of: MainViewController.self) {
                        vc = child as? MainViewController
                    }
                }
            }
        }
        return vc
    }
    
}
