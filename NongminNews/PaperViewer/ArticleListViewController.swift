//
//  ArticleListViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/11/20.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit

class ArticleListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedDate: String!
    var articleDataArr = [[Article]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: .leastNonzeroMagnitude))
        }
        
        guard let paperUrl = URL(string: "\(Const.ApiUrl.getPaperData)20221104") else { return }
        //guard let paperUrl = URL(string: "\(Const.ApiUrl.getPaperData)\(selectedDate!)") else { return }
        self.requestPaperData(url: paperUrl)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        APP_DELEGATE?.shouldSupportAllOrientation = true
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.detectOrientation), name: NSNotification.Name("UIDeviceOrientationDidChangeNotification"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 화면이 가릴때 마다 화면 회전 변수 비활성화
        APP_DELEGATE?.shouldSupportAllOrientation = false
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UIDeviceOrientationDidChangeNotification"), object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("landscape")
        } else {
            print("portrait")
        }
    }
    
    @objc func detectOrientation() {
        if (UIDevice.current.orientation == .landscapeLeft) || (UIDevice.current.orientation == .landscapeRight) {
            print("detectOrientation : landscapeLeft")
        } else if (UIDevice.current.orientation == .portrait) || (UIDevice.current.orientation == .portraitUpsideDown) {
            print("detectOrientation : portrait")
        }
    }
    
    @IBAction func closeView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func requestPaperData(url: URL) {
        PaperService().getPaperData(url: url) { info in
            _ = info.map { data in
                // 지면별 기사 데이터 배열 생성
                self.articleDataArr.append(data.articles)
            }
            self.tableView.reloadData()
        }
    }
}


extension ArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        headerView.backgroundColor = UIColor.white
        
        let tltleLabel = UILabel()
        tltleLabel.frame = CGRect(x: 20, y: 20, width: 50, height: 25)
        tltleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        tltleLabel.text = "\(articleDataArr[section][0].myun)면"
        headerView.addSubview(tltleLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        
        let lineView = UIView()
        lineView.frame = CGRect(x: 0, y: 24, width: self.view.frame.width, height: 1)
        lineView.backgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        
        if section < articleDataArr.count - 1 {
            footerView.addSubview(lineView)
        }
        
        return footerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return articleDataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleDataArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell")
        let article = articleDataArr[indexPath.section][indexPath.row]
        
        if let articleImg = cell?.viewWithTag(10) as? UIImageView {
            let year = article.publishDate.prefix(4)
            let month = "\(Array(article.publishDate)[4])\(Array(article.publishDate)[5])"
            let day = article.publishDate.suffix(2)
            
            // 원본 이미지 다운로드 url 배열 생성
            let imgUrl = "\(Const.ApiUrl.getPaperImageFile)\(year)/\(month)/\(day)/\(article.areaFile)"
            //articleImg.load(url: URL(string: imgUrl)!)
            
            articleImg.image = UIImage(named: "paper_thumb")
            
        }
        
        if let titleLabel = cell?.viewWithTag(20) as? UILabel {
            let attributedString = NSMutableAttributedString(string: "농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사 농민신문 기사") //article.title
            let attributedText = attributedString.withLineSpacing(4)
            
            titleLabel.attributedText = attributedText
            titleLabel.textAlignment = .left
        }
        
        if let bodyLabel = cell?.viewWithTag(30) as? UILabel {
            let attributedString = NSMutableAttributedString(string: "동해물과 백두산이 마르고 닳도록, 하느님이 보우하사 우리나라 만세. 무궁화 삼천리 화려강산, 대한사람 대한으로 길이 보전하세.동해물과 백두산이 마르고 닳도록, 하느님이 보우하사 우리나라 만세. 무궁화 삼천리 화려강산, 대한사람 대한으로 길이 보전하세.") //article.area
            let attributedText = attributedString.withLineSpacing(4)
            
            bodyLabel.attributedText = attributedText
            bodyLabel.textAlignment = .left
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Paper", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "articleDetailVC") as! ArticleDetailViewController
        
        let article = articleDataArr[indexPath.section][indexPath.row]
        
        vc.articleUrl = "\(Const.WebUrl.openArticle)20221117500223"
        //vc.articleUrl = "\(Const.WebUrl.openArticle)\(article.storySiteId)"
        vc.articleImg = article.areaFile
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
