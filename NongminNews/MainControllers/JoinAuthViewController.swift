//
//  JoinAuthViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/08/12.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialBottomSheet

class JoinAuthViewController: UIViewController {
    @IBOutlet weak var phoneNumLabel: UILabel!
    @IBOutlet weak var codeBackgroundView: UIView!
    @IBOutlet weak var inputCodeTF: UITextField!
    
    @IBOutlet weak var requestCodeBtn: UIButton!
    @IBOutlet weak var confirmCodeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeBackgroundView.isHidden = true
        requestCodeBtn.layer.cornerRadius = 9
        
        phoneNumLabel.text = AppDelegate.pendingData
        //inputCodeTF.delegate = self
        
        confirmBtnToggle(isOn: false)
        inputCodeTF.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(phoneNumberReceived(_:)), name: NSNotification.Name("phoneNumber"), object: nil)
    }
    /*
    @objc func phoneNumberReceived(_ notification: Notification) {
        if let phone = notification.object as? String {
            phoneNumLabel.text = phone
        }
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        if sender.text?.isEmpty == true {
            confirmBtnToggle(isOn: false)
        } else {
            confirmBtnToggle(isOn: true)
        }
    }
    
    func confirmBtnToggle(isOn: Bool) {
        if isOn {
            confirmCodeBtn.isHidden = false
        } else {
            confirmCodeBtn.isHidden = true
        }
    }
    
    func showAgreementPopup() {
        let storyboard = UIStoryboard(name: "Popup", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "agreementPopupVC") as! AgreementPopupViewController
        vc.delegate = self
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: vc)
        bottomSheet.delegate = self
        bottomSheet.dismissOnDraggingDownSheet = false
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 435
        bottomSheet.scrimColor = UIColor.black.withAlphaComponent(0.7)
        
        present(bottomSheet, animated: true, completion: nil)
    }
    
    func showAuthFinishPopup() {
        let storyboard = UIStoryboard(name: "Popup", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "authFinishPopupVC") as! AuthFinishPopupViewController
        vc.delegate = self
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: vc)
        bottomSheet.delegate = self
        bottomSheet.dismissOnDraggingDownSheet = false
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = self.view.bounds.height
        bottomSheet.scrimColor = UIColor.black.withAlphaComponent(0.7)
        
        present(bottomSheet, animated: false, completion: nil)
    }
    
    @IBAction func requestConfirmCode(_ sender: UIButton) {
        //인증문자 요청 Api
        NewsService().requestAuthNumber(phone: phoneNumLabel.text ?? "") { response in
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
        
        codeBackgroundView.isHidden = false
        requestCodeBtn.setTitle("인증문자 다시 받기", for: .normal)
    }
    
    @IBAction func requestCodeAuth(_ sender: UIButton) {
        //인증번호 최종 확인 Api
        var json = [LoginData]()
        
        NewsService().requestAuthResult(phone: phoneNumLabel.text ?? "", authNum: inputCodeTF.text ?? "") { response in
            if let result = response {
                let code = result["code"] as! String
                let message = result["message"] as! String
                
                if code == "10000" {
                    let data = result["data"] as! [JSONDictionary]
                    
                    json = data.compactMap { dictionary in
                        return LoginData(dictionary :dictionary)
                    }
                    
                    // 결과값 저장
                    UserDefaults.Nongmin.set(json[0].authToken, forKey: .authToken)
                    UserDefaults.Nongmin.set(json[0].mktAgreeYn == "Y" ? true : false, forKey: .marketingTermsAgree)
                    APP_DELEGATE?.getUserData()
                    
                    DispatchQueue.main.async {
                        self.showAgreementPopup()
                    }
                } else {
                    print("message: \(message)")
                }
            }
        }
    }
}

extension JoinAuthViewController: MDCBottomSheetControllerDelegate {
    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
        print("Close Popup View!!!")
    }
    
    func bottomSheetControllerDidChangeYOffset(_ controller: MDCBottomSheetController, yOffset: CGFloat) {
        // 바텀 시트 위치
        print(yOffset)
    }
}
/*
extension JoinAuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
*/
extension JoinAuthViewController: CallbackDelegate {
    func confirmAction() {
        DispatchQueue.main.async {
            self.showAuthFinishPopup()
        }
    }
    
    func confirmOrCancelAction(isOk: Bool) {
        if isOk {
            print("Comfirm!!!!")
            self.navigationController?.popViewController(animated: false)
        } else {
            print("Cancel!!!!")
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func resultReturn(val: [String]) {
        print(val)
    }
}
