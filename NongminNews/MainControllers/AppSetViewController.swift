//
//  AppSetViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/08/22.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialBottomSheet

class AppSetViewController: UITableViewController {
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var myPageBtn: UIButton!
    
    @IBOutlet weak var fontSizeSampleLabel: UILabel!
    @IBOutlet weak var fontSizeBtn1: UIButton!
    @IBOutlet weak var fontSizeBtn2: UIButton!
    @IBOutlet weak var fontSizeBtn3: UIButton!
    @IBOutlet weak var fontSizeBtn4: UIButton!
    @IBOutlet weak var fontSizeBtn5: UIButton!
    
    @IBOutlet weak var startTimeBtn: UIButton!
    @IBOutlet weak var endTimeBtn: UIButton!
    
    @IBOutlet weak var notiSetSwitch: UISwitch!
    @IBOutlet weak var noDisturbSwitch: UISwitch!
    @IBOutlet weak var headlineNewsSwitch: UISwitch!
    @IBOutlet weak var breakingNewsSwitch: UISwitch!
    @IBOutlet weak var ourFarmNewsSwitch: UISwitch!
    @IBOutlet weak var interestNewsSwitch: UISwitch!
    @IBOutlet weak var myActionSwitch: UISwitch!
    
    var fontSizeBtnArr: [UIButton] = []
    var selectedIndex: Int = 2
    var previousIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: .leastNonzeroMagnitude))
        }
        
        loginBtn.layer.borderWidth = 0.8
        loginBtn.layer.borderColor = UIColor.init(_colorLiteralRed: 215/255, green: 215/255, blue: 215/255, alpha: 1).cgColor
        loginBtn.layer.cornerRadius = 20
        
        myPageBtn.layer.borderWidth = 0.8
        myPageBtn.layer.borderColor = UIColor.init(_colorLiteralRed: 215/255, green: 215/255, blue: 215/255, alpha: 1).cgColor
        myPageBtn.layer.cornerRadius = 20
        
        if USER_DATA.authToken.isEmpty {
            loginBtn.isHidden = false
            myPageBtn.isHidden = true
            
            setLoginBtn(sender: loginBtn)
        } else {
            loginBtn.isHidden = true
            myPageBtn.isHidden = false
            
            setMyPageBtn(sender: myPageBtn)
        }
        
        startTimeBtn.layer.cornerRadius = 9
        endTimeBtn.layer.cornerRadius = 9
        
        initFontSizeBtns()
        initSwitchStatus()
        setFooterView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "설정"
    }
    
    @IBAction func setLoginBtn(sender: UIButton) {
        loginBtn.isHidden = false
        myPageBtn.isHidden = true
        
        let attributedString = NSMutableAttributedString(string: "  ")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "icon_small_login")
        imageAttachment.bounds = CGRect(x: 0, y: -4, width: 18, height: 18)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: "  로그인 하기   "))
        
        let imageAttachment2 = NSTextAttachment()
        imageAttachment2.image = UIImage(named: "icon_headline_arrow")
        imageAttachment2.bounds = CGRect(x: 0, y: -7, width: 24, height: 24)
        attributedString.append(NSAttributedString(attachment: imageAttachment2))
        loginBtn.setAttributedTitle(attributedString, for: .normal)
    }
    
    @IBAction func setMyPageBtn(sender: UIButton) {
        loginBtn.isHidden = true
        myPageBtn.isHidden = false
        
        let attributedString = NSMutableAttributedString(string: "  ")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "icon_small_login")
        imageAttachment.bounds = CGRect(x: 0, y: -4, width: 18, height: 18)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: "  마이페이지로 가기   "))
        
        let imageAttachment2 = NSTextAttachment()
        imageAttachment2.image = UIImage(named: "icon_headline_arrow")
        imageAttachment2.bounds = CGRect(x: 0, y: -7, width: 24, height: 24)
        attributedString.append(NSAttributedString(attachment: imageAttachment2))
        myPageBtn.setAttributedTitle(attributedString, for: .normal)
    }
    
    @IBAction func showTimePicker(_ sender: UIButton) {
        sender.setTitleColor(UIColor(red: 237/255, green: 28/255, blue: 36/255, alpha: 1), for: .normal)
        
        let storyboard = UIStoryboard(name: "Popup", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "timePickerPopupVC") as! TimePickerViewController
        vc.settedBtn = sender
        vc.delegate = self
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: vc)
        bottomSheet.delegate = self
        bottomSheet.dismissOnDraggingDownSheet = true
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 234
        bottomSheet.scrimColor = UIColor.black.withAlphaComponent(0.2)
        
        present(bottomSheet, animated: true, completion: nil)
    }
    
    @IBAction func fontSizeBtnTapped(_ sender: UIButton) {
        previousIndex = selectedIndex
        selectedIndex = (sender.tag / 10) - 1
        
        fontSizeBtnArr[previousIndex].isSelected = false
        fontSizeBtnArr[selectedIndex].isSelected = true
        
        if sender.tag == 10 {
            fontSizeSampleLabel.font = UIFont.systemFont(ofSize: 13)
            UserDefaults.Nongmin.set("txtSize1()", forKey: .textSize)
        } else if sender.tag == 20 {
            fontSizeSampleLabel.font = UIFont.systemFont(ofSize: 15)
            UserDefaults.Nongmin.set("txtSize2()", forKey: .textSize)
        } else if sender.tag == 30 {
            fontSizeSampleLabel.font = UIFont.systemFont(ofSize: 18)
            UserDefaults.Nongmin.set("txtSize3()", forKey: .textSize)
        } else if sender.tag == 40 {
            fontSizeSampleLabel.font = UIFont.systemFont(ofSize: 20)
            UserDefaults.Nongmin.set("txtSize4()", forKey: .textSize)
        } else {
            fontSizeSampleLabel.font = UIFont.systemFont(ofSize: 22)
            UserDefaults.Nongmin.set("txtSize5()", forKey: .textSize)
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.tag == 0 {
            
        } else if sender.tag == 1 {
            
        } else if sender.tag == 2 {
            
        } else if sender.tag == 3 {
            
        } else if sender.tag == 4 {
            
        } else if sender.tag == 5 {
            
        } else if sender.tag == 6 {
            
        } else {
            
        }
    }
    
    func initFontSizeBtns() {
        let selectedColor = UIColor(red: 0/255, green: 140/255, blue: 206/255, alpha: 1)
        
        fontSizeBtn1.setBackgroundColor(.white, for: .normal)
        fontSizeBtn1.setBackgroundColor(selectedColor, for: .selected)
        
        fontSizeBtn2.setBackgroundColor(.white, for: .normal)
        fontSizeBtn2.setBackgroundColor(selectedColor, for: .selected)
        
        fontSizeBtn3.setBackgroundColor(.white, for: .normal)
        fontSizeBtn3.setBackgroundColor(selectedColor, for: .selected)
        
        fontSizeBtn4.setBackgroundColor(.white, for: .normal)
        fontSizeBtn4.setBackgroundColor(selectedColor, for: .selected)
        
        fontSizeBtn5.setBackgroundColor(.white, for: .normal)
        fontSizeBtn5.setBackgroundColor(selectedColor, for: .selected)
        
        fontSizeBtnArr = [fontSizeBtn1, fontSizeBtn2, fontSizeBtn3, fontSizeBtn4, fontSizeBtn5]
        fontSizeBtnArr[selectedIndex].isSelected = true
    }
    
    func initSwitchStatus() {
        notiSetSwitch.isOn = true
        noDisturbSwitch.isOn = true
        headlineNewsSwitch.isOn = true
        breakingNewsSwitch.isOn = true
        ourFarmNewsSwitch.isOn = true
        interestNewsSwitch.isOn = false
        myActionSwitch.isOn = false
    }
    
    func setFooterView() {
        let footer = UIView(frame: CGRect(x: 0, y: self.view.frame.size.height - 88, width: self.view.frame.size.width, height: 88))
        footer.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
        
        let footerLabel = UILabel(frame: CGRect(x: 20, y: 50, width: 120, height: 20))
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        
        footerLabel.text = "앱 정보(v\(version))"
        footerLabel.textAlignment = .left
        footer.addSubview(footerLabel)
        
        self.tableView.tableFooterView = footer
    }
    
    func contentsOfDirectoryAtPath(path: String) -> [String]? {
        guard let paths = try? FileManager.default.contentsOfDirectory(atPath: path) else { return nil}
        return paths.map { aContent in (path as NSString).appendingPathComponent(aContent)}
    }
    
    func getListOfDirectories() -> [String]?{
        let searchPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        let allContents = contentsOfDirectoryAtPath(path: searchPath)
        return allContents
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            //return CGFloat.leastNormalMagnitude
            return 1
        } else {
            return 10
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        if section == 0 {
            headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)
            headerView.backgroundColor = UIColor.lightGray
        } else {
            headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 10)
            headerView.backgroundColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
        }
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 114
        } else if indexPath.section == 1 {
            return 144
        } else if indexPath.section == 2 {
            if indexPath.row == 1 {
                return 0
            } else {
                return 71
            }
        } else {
            if indexPath.row == 0 {
                return 71
            } else {
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3, indexPath.row == 0 {

            let alert = UIAlertController(title: "데이터 삭제", message: "다운로드 받은 지면 데이터를 모두 삭제 하시겠습니까?", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "확인", style: .default, handler: {_ in
                //let arr = self.getListOfDirectories()
                //print(arr as Any)
                
                let fileManager = FileManager.default
                do {
                    let documentDirectoryURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let fileURLs = try fileManager.contentsOfDirectory(at: documentDirectoryURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    
                    if fileURLs.count > 0 {
                        for url in fileURLs {
                           try fileManager.removeItem(at: url)
                        }
                        
                        let alert = UIAlertController(title: "삭제 완료", message: "다운로드 받은 지면 데이터가 모두 삭제 되었습니다.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        let alert = UIAlertController(title: "데이터 없음", message: "다운로드 받은 지면 데이터가 없습니다.", preferredStyle: .alert)
                        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                } catch {
                    print(error)
                }
            })
            
            let cancle = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(action)
            alert.addAction(cancle)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension AppSetViewController: MDCBottomSheetControllerDelegate {
    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
        print("Close Popup View!!!")
        
        startTimeBtn.setTitleColor(.black, for: .normal)
        endTimeBtn.setTitleColor(.black, for: .normal)
    }
    
    func bottomSheetControllerDidChangeYOffset(_ controller: MDCBottomSheetController, yOffset: CGFloat) {
        // 바텀 시트 위치
        print(yOffset)
    }
}

extension AppSetViewController: CallbackDelegate {
    func confirmAction() {
        startTimeBtn.setTitleColor(.black, for: .normal)
        endTimeBtn.setTitleColor(.black, for: .normal)
    }
    
    func confirmOrCancelAction(isOk: Bool) {
        if isOk {
            print("Comfirm!!!!")
        } else {
            print("Cancel!!!!")
        }
    }
    
    func resultReturn(val: [String]) {
        if val[0] == "10" {
            startTimeBtn.setTitle(val[1], for: .normal)
        } else {
            endTimeBtn.setTitle(val[1], for: .normal)
        }
    }
}


extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        self.setBackgroundImage(backgroundImage, for: state)
    }
}
