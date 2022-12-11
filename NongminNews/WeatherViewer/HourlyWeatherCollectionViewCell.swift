//
//  HourlyWeatherCollectionViewCell.swift
//  NongminNews
//
//  Created by 박은지 on 2022/11/29.
//

import UIKit

class HourlyWeatherCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var wf_Bt_label: UILabel!
    @IBOutlet weak var wf_icon_img: UIImageView!
    @IBOutlet weak var wf_T1_label: UILabel!
    @IBOutlet weak var wf_Rh_label: UILabel!
    @IBOutlet weak var wf_PciP_label: UILabel!
    @IBOutlet weak var wf_Pci_label: UILabel!
    @IBOutlet weak var wf_Wd_label: UILabel!
    @IBOutlet weak var wf_Ws_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    
}
