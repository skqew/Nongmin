//
//  ArticleDetailViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/11/13.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit
import WebKit

class ArticleDetailViewController: UIViewController {
    @IBOutlet weak var webContainerView: UIView!
    @IBOutlet weak var toolBarView: UIView!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var partialArticleBtn: UIButton!
    @IBOutlet weak var ttsBtn: UIButton!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    public static var processPool = WKProcessPool()
    
    var articleUrl: String!
    var articleImg: String!
    
    private lazy var webView: WKWebView = {
        //let content = WKUserContentController()
        //content.add(self, name: "setExternalWeb")
        
        setCookieValue()
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.default()
        //config.userContentController = content
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpWebView()
        
        if let request = initRequest(articleUrl) {
            self.webView.load(request)
        }
        
        ttsBtn.isSelected = false
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
        } else if (UIDevice.current.orientation == .portrait) || (UIDevice.current.orientation == .portraitUpsideDown) {
            print("detectOrientation : portrait")
        }
    }
    
    @IBAction func toolBarBtnTapped(_ sender: UIButton) {
        if sender.tag == 20 {
            showSinglePaperView()
            
        } else if sender.tag == 30 {
            sender.isSelected.toggle()
            
            let script = "detailTTS()"
            self.webView.evaluateJavaScript(script, completionHandler: nil)
            
        } else if sender.tag == 40 {
            sender.isSelected.toggle()
            
            if sender.isSelected {
                let script = "execBookmark()"
                self.webView.evaluateJavaScript(script, completionHandler: nil)
            } else {
                
            }
            
        } else if sender.tag == 50 {
            let script = "snsLayer()"
            self.webView.evaluateJavaScript(script, completionHandler: nil)
            
        } else {
            self.navigationController?.popViewController(animated: true)
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
    
    func clearWebSiteCache() {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>,
                                                modifiedSince: date,
                                                completionHandler: {})
    }
    
    func setUpWebView() {
        self.clearWebSiteCache()
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
        self.webView.topAnchor.constraint(equalTo:safeArea.topAnchor).isActive = false
        self.webView.trailingAnchor.constraint(equalTo:safeArea.trailingAnchor).isActive = true
        self.webView.bottomAnchor.constraint(equalTo:safeArea.bottomAnchor).isActive = true
    }
    
    func showSinglePaperView() {
        let storyboard = UIStoryboard(name: "Paper", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "singlePaperVC") as! SinglePaperViewController
        
        if let imgUrl = articleImg {
            let imgNameArr = imgUrl.components(separatedBy: "_")
            let imgName = imgNameArr[0].dropFirst()
            
            let year = imgName.prefix(4)
            let month = "\(Array(imgName)[4])\(Array(imgName)[5])"
            let day = imgName.suffix(2)
            let imgUrl = "\(Const.ApiUrl.getPaperImageFile)\(year)/\(month)/\(day)/\(imgUrl)"
            
            vc.partialImgUrl = imgUrl
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        }
    }
}


extension ArticleDetailViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(">>>> commit url: \(webView.url?.absoluteString ?? "")")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(">>>> finish url: \(webView.url?.absoluteString ?? "")")
        
        let script = "articleHeaderHide()"
        self.webView.evaluateJavaScript(script, completionHandler: nil)
        
        let size = UserDefaults.Nongmin.value(forKey: .textSize) as? String ?? "txtSize3()"
        self.webView.evaluateJavaScript(size, completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
        return
    }
}


extension ArticleDetailViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Script Message Name: \(message.name)")
        print("Script Message Body: \(message.body)")
        
        switch message.name {
        case "setExternalWeb":
            if let script = message.body as? String, !script.isEmpty {
                let jsonDic = convertStringToDictionary(text: script)
                guard let value = jsonDic?["set"] as? String else { return }
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
