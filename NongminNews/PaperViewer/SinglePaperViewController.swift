//
//  SinglePaperViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/11/13.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit

class SinglePaperViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var imageScrollView: ISVImageScrollView!
    @IBOutlet weak var toolBarView: UIView!
    
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    private var imageView: UIImageView?
    private var image: UIImage?
    
    var partialImgUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let imgUrl = self.partialImgUrl else { return }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: imgUrl)!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self!.image = image
                        
                        self!.imageView = UIImageView(image: self?.image)
                        self!.imageScrollView.imageView = self!.imageView
                        self!.imageScrollView.maximumZoomScale = 5.0
                        self!.imageScrollView.delegate = self
                    }
                }
            }
        }
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
            /*
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.imageScrollView.layoutSubviews()
            }
            */
        } else if (UIDevice.current.orientation == .portrait) || (UIDevice.current.orientation == .portraitUpsideDown) {
            print("detectOrientation : portrait")
            /*
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.imageScrollView.layoutSubviews()
            }
             */
        }
    }
    
    @IBAction func toolBarBtnTapped(_ sender: UIButton) {
        if sender.tag == 10 {
            
        } else if sender.tag == 20 {
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return self.imageView
    }
}
