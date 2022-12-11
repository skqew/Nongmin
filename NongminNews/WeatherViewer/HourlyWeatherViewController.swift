//
//  HourlyWeatherViewController.swift
//  NongminNews
//
//  Created by 박은지 on 2022/11/29.
//

import UIKit

class HourlyWeatherViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // XML parser
    var xmlDict = [String: Any]()
    var xmlDictArr:Array<[String:Any]> = []
    var currentElement = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView.delegate = self
        collectionView.dataSource = self
        
        setCurrentWeather()
        
    }
    
    
    func setCurrentWeather(){
        
        let location = LocationManager.shared.currentLocation
        
        let xmlParser = XMLParser(contentsOf: URL(string: "http://20.200.184.193/api/HourlyWeather.do?lon=\(location.coordinate.longitude)&lat=\(location.coordinate.latitude)")!)
        xmlParser?.delegate = self
        xmlParser?.parse()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 17
        
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HourlyWeatherCollectionViewCell
        
        if xmlDictArr.count == 0 { return cell }
        
        if indexPath.row == 0 {
            
            cell.stackView.alignment = .fill
//            cell.stackView.widthAnchor.constraint(equalTo: collectionView.widthAnchor).isActive = true
            cell.wf_Bt_label.textAlignment = .center
            cell.wf_Bt_label.clipsToBounds = true
            cell.wf_Bt_label.layer.cornerRadius = 12
            cell.wf_Bt_label.backgroundColor = .black
            cell.wf_Bt_label.textColor = .white
            
            cell.wf_Bt_label.text = "시간"
            
            cell.wf_icon_img.image = nil
            cell.wf_T1_label.text = "기온(℃)"
            cell.wf_Rh_label.text = "습도(%)"
            cell.wf_PciP_label.text = "강수확률(%)"
            cell.wf_Pci_label.text = "강수량(mm)"
            cell.wf_Wd_label.text = "풍향"
            cell.wf_Ws_label.text = "풍속(m/s)"
            
            cell.stackView.widthAnchor.constraint(equalToConstant: 80).isActive = true

            //            cell.wf_Ws_label.widthAnchor.constraint(equalToConstant: 100).isActive = true
            
        } else {
            
            //            DispatchQueue.main.async {
            
            let item = self.xmlDictArr[(indexPath.row)-1]
            
            cell.stackView.alignment = .center
            cell.stackView.widthAnchor.constraint(equalToConstant: 60).isActive = true

            cell.wf_Bt_label.backgroundColor = .white
            cell.wf_Bt_label.textColor = .black
            // 시간 형식 변경
            let dateStr = item["wf_Bt"] as? String ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmm"
            let convertDate = dateFormatter.date(from: dateStr) // Date 타입으로 변환
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "HH시"
            myDateFormatter.locale = Locale(identifier:"ko_KR") // PM, AM을 언어에 맞게 setting (ex: PM -> 오후)
            let convertStr = myDateFormatter.string(from: convertDate!)
            cell.wf_Bt_label.text = convertStr
            
            if let wf_icon = item["wf_icon"] as? String{
                cell.wf_icon_img.image = UIImage(named: "0\(wf_icon).png")
            }
            
            cell.wf_T1_label.text = (item["wf_T1"] as? String ?? "") + "°"
            cell.wf_Rh_label.text = item["wf_Rh"] as? String ?? ""
            cell.wf_PciP_label.text = item["wf_PciP"] as? String ?? ""
            if item["wf_Pci"] as? String ?? "" == "강수없음"{
                cell.wf_Pci_label.text = "0"
            } else {
                cell.wf_Pci_label.text = item["wf_Pci"] as? String ?? ""
            }
            cell.wf_Wd_label.text = item["wf_Wd"] as? String ?? ""
            cell.wf_Ws_label.text = item["wf_Ws"] as? String ?? ""
            
        }
        
        return cell
    }
    
}

extension HourlyWeatherViewController: XMLParserDelegate {
    
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
