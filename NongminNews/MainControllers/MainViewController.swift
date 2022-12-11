//
//  MainViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/08/09.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit
import WebKit
import CenteredCollectionView
import MaterialComponents.MaterialBottomSheet

protocol CallbackDelegate {
    func confirmAction()
    func confirmOrCancelAction(isOk: Bool)
    func resultReturn(val: [String])
}

class WebViewProcessPool: WKProcessPool {
    static let shared = WebViewProcessPool()
    private override init() {
        super.init()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainViewController: UIViewController {
    @IBOutlet weak var splashView: UIView!
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var webContainerView: UIView!
    @IBOutlet weak var menuWebContainerView: UIView!
    @IBOutlet weak var paperContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var publishDateLabel: UILabel!
    @IBOutlet weak var todayHeadlineNewsBtn: UIButton!
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var bottomTabbarView: UIView!
    @IBOutlet weak var safeAreaView: UIView!
    
    @IBOutlet weak var wn_icon: UIImageView?
    @IBOutlet weak var wn_T1_label: UILabel?
    @IBOutlet weak var wn_T1D_label: UILabel?
    @IBOutlet weak var wn_Mx_label: UILabel?
    @IBOutlet weak var wn_Mn_label: UILabel?
    
    @IBOutlet weak var mainTabbarHeight: NSLayoutConstraint!
    @IBOutlet var tabBarBtns:[UIButton] = []
    
    // XML parser
    var xmlDict = [String: Any]()
    var xmlDictArr:Array<[String:Any]> = []
    var currentElement = ""
    
    var pageInfoArr = [PaperData]()
    var paperThumnailArr = [String]()
    var selectedIndex: Int = 0
    var previousIndex: Int = 0
    
    var isFirstLoad: Bool = true
    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
    
    public static var processPool = WKProcessPool()
    
    private lazy var paperBadge: UIView = {
        let view = UIView()
        let badgeSize = 8
        let btnSize = tabBarBtns[0].frame.size
        
        view.layer.cornerRadius = CGFloat(badgeSize/2)
        view.layer.frame = CGRect(x: Int(btnSize.width/2)+badgeSize+4 , y:badgeSize+3, width: badgeSize, height: badgeSize)
        view.backgroundColor = .red
        return view
    }()
    
    private lazy var favoriteBadge: UIView = {
        let view = UIView()
        let badgeSize = 8
        let btnSize = tabBarBtns[0].frame.size
        
        view.layer.cornerRadius = CGFloat(badgeSize/2)
        view.layer.frame = CGRect(x: Int(btnSize.width/2)+badgeSize+4 , y:badgeSize+3, width: badgeSize, height: badgeSize)
        view.backgroundColor = .red
        return view
    }()
    
    private lazy var webView: WKWebView = {
        let content = WKUserContentController()
        //content.add(self, name: "viewAppPage")
        //content.add(self, name: "execWebLogin")
        //content.add(self, name: "execLogout")
        
        setCookieValue()
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.userContentController = content
        config.allowsInlineMediaPlayback = true
        config.preferences = preferences
        config.processPool = WebViewProcessPool.shared
        
        let wv = WKWebView(frame: .zero, configuration: config)
        //wv.scrollView.delegate = self
        wv.navigationDelegate = self
        wv.uiDelegate = self
        wv.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            wv.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        wv.allowsBackForwardNavigationGestures = true
        wv.allowsLinkPreview = false
        
        return wv
    }()
    
    private lazy var menuWebView: WKWebView = {
        let content = WKUserContentController()
        content.add(self, name: "viewAppPage")
        content.add(self, name: "viewAppPath")
        content.add(self, name: "execLogout")
        
        setCookieValue()
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.default()
        config.userContentController = content
        config.allowsInlineMediaPlayback = true
        config.preferences = preferences
        config.processPool = WebViewProcessPool.shared
        
        let wv = WKWebView(frame: .zero, configuration: config)
        //wv.scrollView.delegate = self
        //wv.navigationDelegate = self
        //wv.uiDelegate = self
        wv.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            wv.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        //wv.allowsBackForwardNavigationGestures = true
        //wv.allowsLinkPreview = false

        return wv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // 최근 12개호 지면 일자 및 썸네일 조회
        guard let url = URL(string: Const.ApiUrl.getPageInfo) else { return }
        requestPageInfo(url: url)
        
        setUpWebView()
        setUpMenuWebView()
        //bottomTabbarView.layer.cornerRadius = 20
        //bottomTabbarView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainTabbarHeight.constant = isDisplayZoomed ? 58 : 68
        bottomTabbarView.cornerShadow()
        tabBarBtns[selectedIndex].isSelected = true
        tabBarBtns[selectedIndex].addSubview(paperBadge)
        tabBarBtns[2].addSubview(favoriteBadge)
        
        let weatherViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.weatherView.addGestureRecognizer(weatherViewTapGesture)
        
        // 위경도 가져오기
        LocationManager.shared.getCurrentLocation()
//        self.setCurrentWeather()
        
        
        self.createTodayHeadlineBtn()
        
        if let request = initRequest(Const.WebUrl.appMenu) {
            self.menuWebView.load(request)
            self.menuWebContainerView.isHidden = true
        }
        
        if AppDelegate.pendingData.isEmpty {
            if let request = initRequest(Const.WebUrl.main) {
                self.webView.load(request)
            }
            
            logoImgView.alpha = 0
            UIView.animate(withDuration: 1.5, animations: { [self] in
                logoImgView.alpha = 1
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.splashView.removeFromSuperview()
            }
        } else {
            logoImgView.alpha = 0
            UIView.animate(withDuration: 1.5, animations: { [self] in
                logoImgView.alpha = 1
            })
            
            DispatchQueue.main.async {
                self.showStartJoinPopup()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        refreshMainWebView()
        refreshMenuWebView()
        
        let isRotate = APP_DELEGATE?.shouldSupportAllOrientation ?? false
        if !isRotate {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
    
    func requestPageInfo(url: URL) {
        PaperService().getPaperData(url: url) { info in
            _ = info.map { data in
                let year = data.publishDate.prefix(4)
                let month = "\(Array(data.publishDate)[4])\(Array(data.publishDate)[5])"
                let day = data.publishDate.suffix(2)
                
                let imgNameArr = data.imgFile.components(separatedBy: ".")
                let imgName = imgNameArr[0] as String
                let thumbnail = imgName + "x640.jpg"
                
                let imgUrl = "\(Const.ApiUrl.getPaperImageFile)\(year)/\(month)/\(day)/\(thumbnail)"
                
                self.paperThumnailArr.append(imgUrl)
                self.pageInfoArr.append(data)
            }
            
            if self.pageInfoArr.count != 0 {
                self.setUpPaperMainView()
            }
        }
    }
    
    func initRequest(_ link: String) -> URLRequest? {
        if let url = URL(string: link) {
            var request = URLRequest(url: url
                                     , cachePolicy: .reloadIgnoringLocalCacheData
                                     , timeoutInterval: 15.0)
            //setRequestHeader(&request)
            return request
        }
        return nil
    }
    /*
     func setRequestHeader(_ request: inout URLRequest) {
     let token = USER_DATA.authToken
     
     request.setValue("application/json", forHTTPHeaderField: "Content-Type")
     request.setValue("ios", forHTTPHeaderField: "Platform")
     
     if token.isEmpty {
     request.setValue("", forHTTPHeaderField: "Authorization")
     } else {
     request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
     }
     }
     */
    
    func setCookieValue() {
        let urlString = Const.target.nongminApiUrl
        let url = URL(string: urlString)
        
        let domain = url?.host ?? ""
        let uuid = AppCommonUtil.getUUID() ?? ""
        let version = AppCommonUtil.getAppVersion() ?? ""
        let osVer = AppCommonUtil.getOsVersion()
        let deviceModel = AppCommonUtil.getDeviceModel()
        let platform = "ios"
        let carrier = AppCommonUtil.getCarrierName()
        let token =  USER_DATA.authToken
        
        let cookies = [
            "X-AUTH-TOKEN": token,
            "deviceModel": deviceModel,
            "carrier": carrier,
            "osVer": osVer,
            "version": version,
            "uuid": uuid,
            "platform": platform
        ]
        
        for (key, val) in cookies {
            AppCommonUtil.setCookie(domain: domain, strKey: key, value: val)
        }
    }
    
    func setUpWebView() {
        webContainerView.addSubview(self.webView)
        
        let horConstraint = NSLayoutConstraint(item: self.webView, attribute: .centerX, relatedBy: .equal,
                                               toItem: self.webContainerView, attribute: .centerX,
                                               multiplier: 1.0, constant: 0.0)
        let verConstraint = NSLayoutConstraint(item: self.webView, attribute: .centerY, relatedBy: .equal,
                                               toItem: self.webContainerView, attribute: .centerY,
                                               multiplier: 1.0, constant: 0.0)
        let widConstraint = NSLayoutConstraint(item: self.webView, attribute: .width, relatedBy: .equal,
                                               toItem: self.webContainerView, attribute: .width,
                                               multiplier: 1.0, constant: 0.0)
        let heiConstraint = NSLayoutConstraint(item: self.webView, attribute: .height, relatedBy: .equal,
                                               toItem: self.webContainerView, attribute: .height,
                                               multiplier: 1.0, constant: 0.0)
        self.webContainerView.addConstraints([horConstraint, verConstraint, widConstraint, heiConstraint])
        
        let safeArea = self.view.safeAreaLayoutGuide
        self.webView.leadingAnchor.constraint(equalTo:safeArea.leadingAnchor).isActive = true
        self.webView.topAnchor.constraint(equalTo:safeArea.topAnchor).isActive = true
        self.webView.trailingAnchor.constraint(equalTo:safeArea.trailingAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo:safeArea.bottomAnchor).isActive = false
    }
    
    func setUpMenuWebView() {
        menuWebContainerView.addSubview(self.menuWebView)
        
        let horConstraint = NSLayoutConstraint(item: self.menuWebView, attribute: .centerX, relatedBy: .equal,
                                               toItem: self.menuWebContainerView, attribute: .centerX,
                                               multiplier: 1.0, constant: 0.0)
        let verConstraint = NSLayoutConstraint(item: self.menuWebView, attribute: .centerY, relatedBy: .equal,
                                               toItem: self.menuWebContainerView, attribute: .centerY,
                                               multiplier: 1.0, constant: 0.0)
        let widConstraint = NSLayoutConstraint(item: self.menuWebView, attribute: .width, relatedBy: .equal,
                                               toItem: self.menuWebContainerView, attribute: .width,
                                               multiplier: 1.0, constant: 0.0)
        let heiConstraint = NSLayoutConstraint(item: self.menuWebView, attribute: .height, relatedBy: .equal,
                                               toItem: self.menuWebContainerView, attribute: .height,
                                               multiplier: 1.0, constant: 0.0)
        self.menuWebContainerView.addConstraints([horConstraint, verConstraint, widConstraint, heiConstraint])
        
        let safeArea = self.view.safeAreaLayoutGuide
        self.menuWebView.leadingAnchor.constraint(equalTo:safeArea.leadingAnchor).isActive = true
        self.menuWebView.topAnchor.constraint(equalTo:safeArea.topAnchor).isActive = true
        self.menuWebView.trailingAnchor.constraint(equalTo:safeArea.trailingAnchor).isActive = true
        self.menuWebView.bottomAnchor.constraint(equalTo:safeArea.bottomAnchor).isActive = false
    }
    
    func setUpPaperMainView() {
        // Get the reference to the CenteredCollectionViewFlowLayout (REQURED)
        centeredCollectionViewFlowLayout = (collectionView.collectionViewLayout as! CenteredCollectionViewFlowLayout)
        
        // Modify the collectionView's decelerationRate (REQURED)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.showsHorizontalScrollIndicator = false
        
        // Assign delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        
        print("\(view.bounds.width),\(view.bounds.height)")
        print("\(collectionView.bounds.width),\(collectionView.bounds.height)")
        // Configure the required item size (REQURED)
        
        if isDisplayZoomed {
            centeredCollectionViewFlowLayout.itemSize = CGSize(
                width: 186,
                height: 252
            )
        } else {
            let itemSize: CGSize!
            if view.bounds.height == 667 {
                itemSize = CGSize(width: 186,height: 252)
            } else {
                itemSize = CGSize(width: 256,height: 347)
            }
            centeredCollectionViewFlowLayout.itemSize = itemSize
        }
        
        // Configure the optional inter item spacing (OPTIONAL)
        centeredCollectionViewFlowLayout.minimumLineSpacing = 20
        
        let dateVal = getDateFromString(dateStr: pageInfoArr[0].publishDate)
        self.publishDateLabel.text = getDayOfWeek(date: dateVal)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.showWeatherView()
    }
    
    
    func setCurrentWeather(){

        let location = LocationManager.shared.currentLocation

        let xmlParser = XMLParser(contentsOf: URL(string: "http://20.200.184.193/api/CurrentWeather.do?lon=\(location.coordinate.longitude)&lat=\(location.coordinate.latitude)")!)
        xmlParser?.delegate = self
        xmlParser?.parse()
        
//        let xmlParserManager = XMLParserManager.shared
//            xmlParserManager.setCurrentWeather()
        
        DispatchQueue.main.async {
            
            let item = self.xmlDictArr.first

            self.wn_T1_label?.text = (item?["wn_T1"] as? String ?? "") + "℃"
            self.wn_T1D_label?.text = "어제보다" + (item?["wn_T1D"] as? String ?? "") + " ℃↑"
            self.wn_T1D_label?.text = item?["wn_T1D"] as? String ?? ""
            self.wn_Mn_label?.text = "최저 " + (item?["wn_Mn"] as? String ?? "") + "℃"
            self.wn_Mx_label?.text = "최고 " + (item?["wn_Mx"] as? String ?? "") + "℃"
            if let wn_icon = item?["wn_icon"] as? String {
                self.wn_icon?.image = UIImage(named: "0\(wn_icon).png")
            }
            
        }


    }
    
    func createTodayHeadlineBtn() {
        todayHeadlineNewsBtn.layer.borderWidth = 0.8
        todayHeadlineNewsBtn.layer.borderColor = UIColor.init(_colorLiteralRed: 215/255, green: 215/255, blue: 215/255, alpha: 1).cgColor
        todayHeadlineNewsBtn.layer.cornerRadius = 20
        
        let attributedString = NSMutableAttributedString(string: "   ")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "icon_headline_bell")
        imageAttachment.bounds = CGRect(x: 0, y: -3, width: 16, height: 17)
        attributedString.append(NSAttributedString(attachment: imageAttachment))
        attributedString.append(NSAttributedString(string: "  오늘의 주요뉴스   "))
        
        let imageAttachment2 = NSTextAttachment()
        imageAttachment2.image = UIImage(named: "icon_headline_arrow")
        imageAttachment2.bounds = CGRect(x: 0, y: -7, width: 24, height: 24)
        attributedString.append(NSAttributedString(attachment: imageAttachment2))
        todayHeadlineNewsBtn.setAttributedTitle(attributedString, for: .normal)
    }
    
    @IBAction func tabChanged(sender: UIButton) {
        previousIndex = selectedIndex
        selectedIndex = sender.tag
        
        tabBarBtns[previousIndex].isSelected = false
        sender.isSelected = true
        
        self.menuWebContainerView.isHidden = true
        
        if selectedIndex == 0 {
            self.paperContainerView.isHidden = false
            
        } else if selectedIndex == 4 {
            if previousIndex == 0 {
                self.paperContainerView.isHidden = false
            } else {
                self.paperContainerView.isHidden = true
            }
            showAppSetView()
            
        } else {
            self.paperContainerView.isHidden = true
            
            if selectedIndex == 1 {
                // 뉴스 메인
                if !isFirstLoad {
                    if let request = initRequest(Const.WebUrl.main) {
                        self.webView.load(request)
                        isFirstLoad = false
                    }
                }
            } else if selectedIndex == 2 {
                // 관심뉴스
                if let request = initRequest(Const.WebUrl.favoriteNews) {
                    self.webView.load(request)
                    isFirstLoad = false
                }
            } else {
                // 소통광장
                if let request = initRequest(Const.WebUrl.commuPlaza) {
                    self.webView.load(request)
                    isFirstLoad = false
                }
            }
        }
    }
    
    @IBAction func showAppMenu(_ sender: UIButton) {
        self.menuWebContainerView.isHidden = false
    }
    
    @IBAction func showLoginView(_ sender: UIButton) {
        showLoginView()
    }
    
    @IBAction func showTodayHeadlineNewsView(sender: UIButton) {
        if let request = initRequest(Const.WebUrl.todayHeadline) {
            self.webView.load(request)
            self.paperContainerView.isHidden = true
        }
    }
    
    @objc func refreshMenuWebView() {
        if let request = initRequest(Const.WebUrl.appMenu) {
            self.menuWebView.load(request)
        }
    }
    
    func refreshMainWebView() {
        if let request = initRequest(Const.target.nongminWebUrl) {
            self.webView.load(request)
        }
    }
    
    func showLoginView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAppSetView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "appSetVC") as! AppSetViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showNoticeListView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "noticeListVC") as! NoticeListViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showWeatherView() {
        
        let storyboard = UIStoryboard(name: "Weather", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "WeatherNaviVC") as! UINavigationController
        let vc = naviVC.viewControllers.first as! WeatherViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func showStartJoinPopup() {
        let storyboard = UIStoryboard(name: "Popup", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "startJoinPopupVC") as! StartJoinPopupViewController
        vc.delegate = self
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: vc)
        bottomSheet.delegate = self
        bottomSheet.dismissOnDraggingDownSheet = false
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 200
        bottomSheet.scrimColor = UIColor.black.withAlphaComponent(0.7)
        
        present(bottomSheet, animated: true, completion: nil)
    }
    
    func hideBottomBar() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.bottomTabbarView.frame = CGRect(x: self.bottomTabbarView.frame.origin.x, y: (self.view.frame.height + self.bottomTabbarView.frame.height), width: self.bottomTabbarView.frame.width, height: self.bottomTabbarView.frame.height)
            self.safeAreaView.isHidden = true
        })
    }
    
    func showBottomBar() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.bottomTabbarView.frame = CGRect(x: self.bottomTabbarView.frame.origin.x, y: self.view.frame.height - self.bottomTabbarView.frame.height - self.safeAreaView.frame.height, width: self.bottomTabbarView.frame.width, height: self.bottomTabbarView.frame.height)
            self.safeAreaView.isHidden = false
        })
    }
    
    func getDateFromString(dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        guard let convertDate = dateFormatter.date(from: dateStr) else { return Date() }
        
        return convertDate
    }
    
    func getDayOfWeek(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateStr = dateFormatter.string(from: date)
        
        let formatter = DateFormatter()
        //formatter.dateFormat = "EEEEE" //"금"
        formatter.dateFormat = "EEEE" //"금요일"
        formatter.locale = Locale(identifier:"ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        let weekDayStr = formatter.string(from: date)
        
        let convertStr = "\(dateStr) [\(weekDayStr)]"
        return convertStr
    }
}


extension MainViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Script Message Name: \(message.name)")
        print("Script Message Body: \(message.body)")
        
        switch message.name {
        case "viewAppPage":
            self.menuWebContainerView.isHidden = true
            
            if let script = message.body as? String, !script.isEmpty {
                //let jsonDic = convertStringToDictionary(text: script)
                //guard let value = jsonDic?["set"] as? String else { return }
                
                if script == "noticePage" {
                    showNoticeListView()
                } else if script == "configPage" {
                    showAppSetView()
                } else if script == "loginPage" {
                    showLoginView()
                } else if script == "menuClose" {
                    if let request = initRequest(Const.WebUrl.appMenu) {
                        self.menuWebView.load(request)
                    }
                }
            }
        case "viewAppPath":
            self.menuWebContainerView.isHidden = true
            self.paperContainerView.isHidden = true
            
            if let script = message.body as? String, !script.isEmpty {
                let url = "\(Const.target.nongminWebUrl)\(script)"
                
                if let request = initRequest(url) {
                    self.webView.load(request)
                    isFirstLoad = false
                }
            }
        case "execLogout":
            if let script = message.body as? String, !script.isEmpty {
                APP_DELEGATE?.logout()
                
                self.menuWebContainerView.isHidden = true
                
                let url = "\(Const.target.nongminWebUrl)\(script)"
                
                if let request = initRequest(url) {
                    self.webView.load(request)
                    refreshMenuWebView()
                    isFirstLoad = false
                }
            }
        default:
            break
        }
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("JSON 파싱 에러")
            }
        }
        return nil
    }
}


extension MainViewController: MDCBottomSheetControllerDelegate {
    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
        print("Close Popup View!!!")
    }
    
    func bottomSheetControllerDidChangeYOffset(_ controller: MDCBottomSheetController, yOffset: CGFloat) {
        // 바텀 시트 위치
        print(yOffset)
    }
}


extension MainViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(">>>> commit url: \(webView.url?.absoluteString ?? "")")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(">>>> finish url: \(webView.url?.absoluteString ?? "")")
        //splashView.removeFromSuperview()
    }
}


extension MainViewController: CallbackDelegate {
    func confirmAction() {
        splashView.removeFromSuperview()
        
        if let request = initRequest(Const.WebUrl.main) {
            self.webView.load(request)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "joinAuthVC") as! JoinAuthViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func confirmOrCancelAction(isOk: Bool) {
        if isOk {
            // 지면 홈 화면 이동
            if let request = initRequest(Const.WebUrl.main) {
                self.webView.load(request)
                splashView.removeFromSuperview()
            }
        } else {
            // 관심뉴스 살정 페이지로 이동
            if let request = initRequest(Const.WebUrl.favoriteSet) {
                self.webView.load(request)
                self.paperContainerView.isHidden = true
                splashView.removeFromSuperview()
            }
        }
    }
    
    func resultReturn(val: [String]) {
        print(val)
    }
}
/*
 extension MainViewController: UIScrollViewDelegate {
 func scrollViewDidScroll(_ scrollView: UIScrollView) {
 let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
 
 if translation.y == 0 { return }
 if translation.y > 0 {
 // Scroll Down
 showBottomBar()
 } else {
 // Scroll Up
 hideBottomBar()
 }
 }
 }
 */
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Cell #\(indexPath.row)")
        paperBadge.removeFromSuperview()
        
        let storyboard = UIStoryboard(name: "Paper", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "paperNaviVC") as! UINavigationController
        
        let vc = naviVC.viewControllers.first as! PaperMainViewController
        vc.selectedPublishDate = pageInfoArr[indexPath.row].publishDate
        
        naviVC.modalPresentationStyle = .fullScreen
        present(naviVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pageInfoArr.count < 13 {
            return pageInfoArr.count
        } else {
            return 12
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "Cell"), for: indexPath) as! PaperCollectionViewCell
        cell.paperImgView.load(url: URL(string: paperThumnailArr[indexPath.item])!)
        cell.paperImgView.layer.borderWidth = 0.5
        cell.paperImgView.layer.borderColor = UIColor.lightGray.cgColor
        cell.addShadow(offset: CGSize(width: 5, height: 5), color: UIColor.lightGray, opacity: 0.5, radius: 5)
        
        return cell
    }
    /*
     func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
     let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
     if (actualPosition.x > 0){
     // scroll to left
     print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage))")
     } else {
     // scroll to right
     print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage))")
     }
     }
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
        
        let dateVal = getDateFromString(dateStr: pageInfoArr[centeredCollectionViewFlowLayout.currentCenteredPage!].publishDate)
        self.publishDateLabel.text = getDayOfWeek(date: dateVal)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
    }
}



//MARK: - CLLocationManagerDelegate
extension MainViewController: XMLParserDelegate {
    
    // XML 파서가 시작 테그를 만나면 호출됨
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "item" {
            xmlDict = [:]
        } else {
            currentElement = elementName
        }
        
    }
    
    // XML 파서가 종료 테그를 만나면 호출됨
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            xmlDictArr.append(xmlDict)
        }
    }
    
    // 현재 테그에 담겨있는 문자열 전달
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if xmlDict[currentElement] == nil {
                xmlDict.updateValue(string, forKey: currentElement)
            }
        }
        
    }
    
    // 에러시, abortParsing()사용시
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error){
        print(parseError)
    }
    
}
