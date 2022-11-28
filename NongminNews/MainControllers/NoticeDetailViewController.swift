//
//  NoticeDetailViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/11/13.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit

class NoticeDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var returnToListBtn: UIButton!
    
    var sequence: String!
    var notiDetail: NotiDetailData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        returnToListBtn.layer.cornerRadius = 9
        
        getNotiDetail(seq: sequence)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "공지사항"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func getNotiDetail(seq: String) {
        NewsService().requestNotiDetail(seq: seq) { response in
            if let result = response {
                let code = result["code"] as! String
                let message = result["message"] as! String
                
                if code == "10000" {
                    let data = result["data"] as! JSONDictionary
                    
                    let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    self.notiDetail = try? JSONDecoder().decode(NotiDetailData.self, from: jsonData!)
                    
                    print(self.notiDetail as Any)
                     
                } else {
                    print("message: \(message)")
                }
            }
        }
    }
    
    @IBAction func returnToNotiList(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}


extension NoticeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        
        if indexPath.row == 0 {
            cell = self.tableView.dequeueReusableCell(withIdentifier: "headerCell")
            
            if let titleLabel = cell?.viewWithTag(10) as? UILabel {
                titleLabel.text = self.notiDetail.sendTitle
            }
            
            if let dateLabel = cell?.viewWithTag(20) as? UILabel {
                let dateStrArr = self.notiDetail.rsvDate.components(separatedBy: "T")
                dateLabel.text = dateStrArr[0]
            }
        } else {
            cell = self.tableView.dequeueReusableCell(withIdentifier: "bodyCell")
            
            if let bodyLabel = cell?.viewWithTag(10) as? UILabel {
                //let attributedString = NSMutableAttributedString(string: self.notiDetail.sendContent)
                let attributedString = NSMutableAttributedString(string: "이번주부터 디지털 농민신문 통합 시스템이 오픈합니다. 임직원 여러분들게서는 메뉴얼 및 교육을 참고해 주시고 지면 및 온라인 집배 시스템의 디지털화를 위한 첫걸음을 한마음으로 응원해주세요.\n\n감사합니다")
                let attributedText = attributedString.withLineSpacing(10)
                
                bodyLabel.attributedText = attributedText
                bodyLabel.textAlignment = .left
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
