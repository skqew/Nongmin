//
//  WeeklyWeatherViewController.swift
//  NongminNews
//
//  Created by 박은지 on 2022/12/01.
//

import UIKit

class WeeklyWeatherViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // XML parser
    var xmlDict = [String: Any]()
    var xmlDictArr:Array<[String:Any]> = []
    var currentElement = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.setCurrentWeather()
        
    }

    
    func setCurrentWeather(){
        
        let location = LocationManager.shared.currentLocation
        
        let xmlParser = XMLParser(contentsOf: URL(string: "http://20.200.184.193/api/WeeklyWeather.do?lon=\(location.coordinate.longitude)&lat=\(location.coordinate.latitude)")!)
        xmlParser?.delegate = self
        xmlParser?.parse()
        
        self.collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.xmlDictArr.count < 8{
            return self.xmlDictArr.count+1
        }
        return 9
        
    }
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        return size
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WeeklyWeatherCollectionViewCell
        
        if xmlDictArr.count == 0 { return cell }
        
        
        if indexPath.row == 0 {
            
            cell.stackView.alignment = .fill

            cell.wl_Bt_label.textAlignment = .center
            cell.wl_Bt_label.clipsToBounds = true
            cell.wl_Bt_label.layer.cornerRadius = 12
            cell.wl_Bt_label.backgroundColor = .black
            cell.wl_Bt_label.textColor = .white
            
            cell.wl_Bt_label.text = "날짜"
            cell.wl_iconAM_img.image = nil
            cell.wl_Tmx_label.text = "최고기온(℃)"
            cell.wl_Tmn_label.text = "최저기온(℃)"
            cell.wl_PciM_label.text = "오전 강수확률(%)"
            cell.wl_PciA_label.text = "오전 강수확률(%)"
                        
        } else {
            
            //            DispatchQueue.main.async {
            let item = self.xmlDictArr[(indexPath.row)-1]
            
            cell.stackView.alignment = .center
            cell.stackView.widthAnchor.constraint(equalToConstant: 50).isActive = true

            cell.wl_Bt_label.backgroundColor = .white
            cell.wl_Bt_label.textColor = .black
            // 시간 형식 변경
            let dateStr = item["wl_Bt"] as? String ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            let convertDate = dateFormatter.date(from: dateStr) // Date 타입으로 변환
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "MM/dd"
            myDateFormatter.locale = Locale(identifier:"ko_KR") // PM, AM을 언어에 맞게 setting (ex: PM -> 오후)
            let convertStr = myDateFormatter.string(from: convertDate!)
            cell.wl_Bt_label.text = convertStr
            
            if let wl_iconAM = item["wl_iconAM"] as? String{
                cell.wl_iconAM_img.image = UIImage(named: "0\(wl_iconAM).png")
            }
            
            cell.wl_Tmx_label.text = item["wl_Tmx"] as? String ?? ""
            cell.wl_Tmn_label.text = item["wl_Tmn"] as? String ?? ""
            cell.wl_PciM_label.text = item["wl_PciM"] as? String ?? ""
            cell.wl_PciA_label.text = item["wl_PciA"] as? String ?? ""

        }
        
        return cell
    }
    
}


extension WeeklyWeatherViewController: XMLParserDelegate {
    
    //MARK:- XML Parser
    
    // XML 파서가 시작 테그를 만나면 호출됨
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "item" {
            xmlDict = [:]
        } else {
            currentElement = elementName
        }
        
    }
    
    // XML 파서가 종료 테그를 만나면 호출됨
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            xmlDictArr.append(xmlDict)
        }
    }
    
    // 현재 테그에 담겨있는 문자열 전달
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if xmlDict[currentElement] == nil {
                xmlDict.updateValue(string, forKey: currentElement)
            }
        }
        
    }
    
    // 에러시, abortParsing()사용시
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error){
        print(parseError)
    }
    
    
}

