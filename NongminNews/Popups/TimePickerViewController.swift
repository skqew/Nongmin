//
//  TimePickerViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/08/23.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit

class TimePickerViewController: UIViewController {
    @IBOutlet weak var timePicker: UIDatePicker!
    public var settedBtn: UIButton!
    private var timeVal: String!
    
    var delegate: CallbackDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 14
        components.minute = 50
            
        timePicker.setDate(calendar.date(from: components)!, animated: false)
         */
        
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ko_KR")
        dateformatter.dateFormat = "a hh:mm"
        
        if let val = settedBtn.currentTitle {
            let time: Date = dateformatter.date(from: val)!
            timePicker.setDate(time, animated: false)
        }
    }
    
    @IBAction func timePicked(_ sender: UIDatePicker) {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "ko_KR")
        //24시 모드
        //dateformatter.dateFormat = "HH:mm"
        //오전,오후 12시 모드
        dateformatter.dateFormat = "a hh:mm"
        timeVal = dateformatter.string(from: sender.date)
        
        self.delegate?.resultReturn(val: [String(settedBtn.tag), timeVal])
    }
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        self.delegate?.confirmAction()
        self.dismiss(animated: true)
    }
}
