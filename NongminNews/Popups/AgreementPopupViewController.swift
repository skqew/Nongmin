//
//  AgreementPopupViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/08/12.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit
import SafariServices

class AgreementPopupViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var allCheckBox: UIButton!
    @IBOutlet weak var firstCheckBox: UIButton!
    @IBOutlet weak var secondCheckBox: UIButton!
    @IBOutlet weak var thirdCheckBox: UIButton!
    @IBOutlet weak var fourthCheckBox: UIButton!
    
    var delegate: CallbackDelegate?
    var isAcceptAll: Bool = false
    
    var checkBoxArr: [UIButton] = []
    //var selectedBoxArr: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCheckBox()
        
        backgroundView.layer.cornerRadius = 20
        nextBtn.layer.cornerRadius = 9
        
        nextBtnToggle(isOn: isAcceptAll)
    }
    
    @IBAction func checkBoxChangeAll(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        for button in checkBoxArr {
            if sender.isSelected {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
        
        checkSelectedState()
    }
    
    @IBAction func checkBoxTapped(_ sender: UIButton) {
        for button in checkBoxArr {
            if button.tag == sender.tag {
                button.isSelected.toggle()
                
                if !button.isSelected {
                    allCheckBox.isSelected = false
                }
                checkSelectedState()
                return
            }
        }
        
        /*
        sender.isSelected.toggle()
        if sender.isSelected {
            selectedBoxArr.append(sender)
            print(selectedBoxArr.count)
        } else {
            if let index = selectedBoxArr.firstIndex(where: { $0.tag == sender.tag }) {
                selectedBoxArr.remove(at: index)
                print(selectedBoxArr.count)
            }
        }
         */
    }
    
    @IBAction func infoBtnTapped(_ sender: UIButton) {
        let url: URL!
        
        if sender.tag == 10 {
            url = URL(string: Const.WebUrl.memberTerms)
        } else if sender.tag == 20 {
            url = URL(string: Const.WebUrl.personalInfo)
        } else if sender.tag == 30 {
            url = URL(string: Const.WebUrl.personalInfoShare)
        } else {
            url = URL(string: Const.WebUrl.personalInfoShare)
        }
        /*
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        */
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .pageSheet
        
        present(safariVC, animated: true, completion: nil)
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        NewsService().sendMarketingAgree(agreeYn: isAcceptAll ? "Y" : "N") { response in
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
        
        self.delegate?.confirmAction()
        self.dismiss(animated: true)
    }
    
    func initCheckBox() {
        allCheckBox.isSelected = false
        firstCheckBox.isSelected = false
        secondCheckBox.isSelected = false
        thirdCheckBox.isSelected = false
        fourthCheckBox.isSelected = false
        
        checkBoxArr = [firstCheckBox, secondCheckBox, thirdCheckBox, fourthCheckBox]
    }
    
    func checkSelectedState() {
        for button in checkBoxArr {
            if button.tag != 4, !button.isSelected {
                isAcceptAll = false
                nextBtnToggle(isOn: isAcceptAll)
                return
            }
        }
        
        isAcceptAll = true
        nextBtnToggle(isOn: isAcceptAll)
    }
    
    func nextBtnToggle(isOn: Bool) {
        if isOn {
            nextBtn.backgroundColor = UIColor.init(_colorLiteralRed: 0/255, green: 140/255, blue: 206/255, alpha: 1)
            nextBtn.isUserInteractionEnabled = true
        } else {
            nextBtn.backgroundColor = UIColor.init(_colorLiteralRed: 215/255, green: 215/255, blue: 215/255, alpha: 1)
            nextBtn.isUserInteractionEnabled = false
        }
    }
}
