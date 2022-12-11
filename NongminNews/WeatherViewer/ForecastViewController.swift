//
//  ForecastViewController.swift
//  NongminNews
//
//  Created by 박은지 on 2022/12/01.
//

import UIKit

class ForecastViewController: UIViewController {
    
    @IBOutlet var prevBtn: UIButton!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var pgView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    var currentPage = 0
    
    let viewsList:[UIViewController] = {
        let storyBoard = UIStoryboard(name: "Weather", bundle: nil)
        
        let vc1 = storyBoard.instantiateViewController(withIdentifier: "HourlyWeatherVC")
        let vc2 = storyBoard.instantiateViewController(withIdentifier: "WeeklyWeatherVC")
        
        return [vc1, vc2]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 앱 실행시 1번째 pageViewController 띄우기
        if let firstvc = viewsList.first{
            //setViewControllers(첫번째화면, direction: .forward(앞으로), .reverse(뒤로), animated: 애니메이션(Bool), completion: nil)
            pageViewController.setViewControllers([firstvc], direction: .forward, animated: true, completion: nil)
        }
        
        // 처음 화면에서 뒤로가면 안되니까 뒤로가기 버튼 막기 isEnabled = true(활성화), false(비활성화)
        prevBtn.isUserInteractionEnabled = false
        
        self.pgView.addSubview(pageViewController.view)
        
        //MARK: Main View안에 viewController 붙여넣기
        //pageViewController크기와 Main의 view크기와 맞춰서 addSubView로 main에 있는 view에 넣어준다.
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pgView.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.topAnchor.constraint(equalTo: pgView.topAnchor, constant: 0).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: pgView.bottomAnchor, constant: 0).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: pgView.trailingAnchor, constant: 0).isActive = true
        pageViewController.view.leadingAnchor.constraint(equalTo: pgView.leadingAnchor, constant: 0).isActive = true
        
        enabledBtn()

    }
    
    
    @IBAction func prevAction(_ sender: Any) {
        // 지금 페이지 - 1
        let prevPage = currentPage - 1
        //화면 이동 (지금 페이지에서 -1 페이지로 setView 합니다.)
        pageViewController.setViewControllers([viewsList[prevPage]], direction: .reverse, animated: true)
        
        //현재 페이지 잡아주기
        currentPage = pageViewController.viewControllers!.first!.view.tag
        enabledBtn()
    }
    
    @IBAction func backAction(_ sender: Any) {
        // 지금 페이지 + 1
        let backPage = currentPage + 1
        //화면 이동 (지금 페이지에서 -1 페이지로 setView 합니다.)
        pageViewController.setViewControllers([viewsList[backPage]], direction: .forward, animated: true)
        
        //현재 페이지 잡아주기
        currentPage = pageViewController.viewControllers!.first!.view.tag
        enabledBtn()
    }
    
    // 마지막페이지에 next버튼 막기, 첫페이지에 prev버튼 막기, 아니면 true 함수
    func enabledBtn() {
        
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.lightGray.cgColor

        if currentPage == 0 {
            self.prevBtn.isUserInteractionEnabled = false
            self.backBtn.isUserInteractionEnabled = true
            self.prevBtn.backgroundColor = .systemBlue
            self.backBtn.backgroundColor = .white
            self.prevBtn.titleLabel?.tintColor = .white
            self.backBtn.titleLabel?.tintColor = .black
        } else {
            self.prevBtn.isUserInteractionEnabled = true
            self.backBtn.isUserInteractionEnabled = false
            self.prevBtn.backgroundColor = .white
            self.backBtn.backgroundColor = .systemBlue
            self.prevBtn.titleLabel?.tintColor = .black
            self.backBtn.titleLabel?.tintColor = .white
        }
    }
    
}
