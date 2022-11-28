//
//  AuthFinishPopupViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/08/12.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit

class AuthFinishPopupViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var startServiceBtn: UIButton!
    @IBOutlet weak var myNewsSetBtn: UIButton!
    
    var delegate: CallbackDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeLabel.text = "디지털 농민신문 구독 시작을 축하합니다."
        
        backgroundView.layer.cornerRadius = 20
        startServiceBtn.layer.cornerRadius = 9
        
        myNewsSetBtn.setUnderline()
    }
    
    @IBAction func startServiceBtnTapped(_ sender: Any) {
        self.delegate?.confirmOrCancelAction(isOk: true)
        self.dismiss(animated: true)
    }
    
    @IBAction func myNewsSetBtnTapped(_ sender: Any) {
        self.delegate?.confirmOrCancelAction(isOk: false)
        self.dismiss(animated: true)
    }
}

extension UIButton {
    func setUnderline() {
        guard let title = title(for: .normal) else { return }
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: title.count)
        )
        setAttributedTitle(attributedString, for: .normal)
    }
}
