//
//  NoticeListViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/11/13.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit

class NoticeListViewController: UIViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var notiList = [NotiListData]()
    var newsList = [NotiListData]()
    var myActionList = [NotiListData]()
    
    var changeLoadData: Bool? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.selectedSegmentIndex = 0
        self.didChangeValue(segmentControl)
        
        getNotiList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "알림"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @IBAction func didChangeValue(_ sender: UISegmentedControl) {
        changeLoadData = sender.selectedSegmentIndex != 0
    }
    
    func getNotiList() {
        NewsService().requestNotiList() { response in
            if let result = response {
                let code = result["code"] as! String
                let message = result["message"] as! String
                
                if code == "10000" {
                    let data = result["data"] as! [JSONDictionary]
                    
                    self.notiList = data.compactMap { dictionary in
                        return NotiListData(dictionary :dictionary)
                    }
                    
                    for list in self.notiList {
                        if list.pushGubun1 == "001" {
                            self.newsList.append(list)
                        } else {
                            self.myActionList.append(list)
                        }
                    }
                    print(self.notiList)
                } else {
                    print("message: \(message)")
                }
            }
        }
    }
}


extension NoticeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if changeLoadData! {
            if myActionList.count > 0 {
                return myActionList.count
            } else {
                return 10
            }
        } else {
            return newsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "notiCell")
        let noti: NotiListData?
        
        if changeLoadData! {
            //noti = myActionList[indexPath.row]
            noti = myActionList.count > 0 ? myActionList[0] : newsList[0]
        } else {
            noti = newsList[indexPath.row]
        }
        
        if let categoryLabel = cell?.viewWithTag(10) as? UILabel {
            categoryLabel.text = noti?.pushCategoryTitle ?? ""
        }
        
        if let titleLabel = cell?.viewWithTag(20) as? UILabel {
            titleLabel.text = noti?.pushTitle ?? ""
        }
        
        if let dateLabel = cell?.viewWithTag(30) as? UILabel {
            let dateStrArr = noti?.registDatetime.components(separatedBy: "T")
            dateLabel.text = dateStrArr?[0]
        }
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !changeLoadData! {
            let noti: NotiListData? = newsList[indexPath.row]
            
            if let type = noti?.pushGubun2, type == "001005" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "noticeDetailVC") as! NoticeDetailViewController
                vc.sequence = noti?.pushParam1 ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
