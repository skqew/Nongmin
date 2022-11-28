//
//  StartJoinPopupViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/08/12.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit

class StartJoinPopupViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var delegate: CallbackDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.cornerRadius = 20
        confirmBtn.layer.cornerRadius = 9
    }
    
    @IBAction func confirmBtnTapped(_ sender: Any) {
        self.delegate?.confirmAction()
        self.dismiss(animated: true)
    }
}
