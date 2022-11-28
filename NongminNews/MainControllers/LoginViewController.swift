//
//  LoginViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/10/15.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var memberLoginView: UIView!
    
    @IBOutlet weak var inputPhoneNumberTF: UITextField!
    @IBOutlet weak var inputCodeTF: UITextField!
    
    @IBOutlet weak var requestCodeBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    //public static var processPool = WKProcessPool()
    
    var shouldHideFirstView: Bool? {
        didSet {
            guard let shouldHideFirstView = self.shouldHideFirstView else { return }
            memberLoginView.isHidden = shouldHideFirstView
            webViewContainer.isHidden = !memberLoginView.isHidden
        }
    }
    
    private lazy var webView: WKWebView = {
        let content = WKUserContentController()
        content.add(self, name: "openExternalWeb")
        content.add(self, name: "execWebLogin")
        
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
        webViewContainer.addSubview(self.webView)
        
        let horConstraint = NSLayoutConstraint(item: webView, attribute: .centerX, relatedBy: .equal,
                                               toItem: webViewContainer, attribute: .centerX,
                                               multiplier: 1.0, constant: 0.0)
        let verConstraint = NSLayoutConstraint(item: webView, attribute: .centerY, relatedBy: .equal,
                                               toItem: webViewContainer, attribute: .centerY,
                                               multiplier: 1.0, constant: 0.0)
        let widConstraint = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal,
                                               toItem: webViewContainer, attribute: .width,
                                               multiplier: 1.0, constant: 0.0)
        let heiConstraint = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal,
                                               toItem: webViewContainer, attribute: .height,
                                               multiplier: 1.0, constant: 0.0)
        webViewContainer.addConstraints([horConstraint, verConstraint, widConstraint, heiConstraint])
        
        loadLoginWebView(url: Const.WebUrl.login)
        setTextFields()
        
        requestCodeBtn.layer.cornerRadius = 9
        loginBtn.layer.cornerRadius = 9
        
        segmentControl.selectedSegmentIndex = 0
        self.didChangeValue(segmentControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "로그인"
    }
    
    @IBAction func didChangeValue(_ sender: UISegmentedControl) {
        shouldHideFirstView = sender.selectedSegmentIndex != 0
    }
    
    @IBAction func requestConfirmCode(_ sender: UIButton) {
        //인증문자 요청 Api
        NewsService().requestAuthNumber(phone: inputPhoneNumberTF.text ?? "") { response in
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
        
        requestCodeBtn.setTitle("인증문자 다시 받기", for: .normal)
    }
    
    @IBAction func requestLogin(_ sender: UIButton) {
        //인증번호 최종 확인 Api
        NewsService().requestAuthResult(phone: inputPhoneNumberTF.text ?? "", authNum: inputCodeTF.text ?? "") { response in
            if let result = response {
                let code = result["code"] as! String
                let message = result["message"] as! String
                
                if code == "10000" {
                    let data = result["data"] as? JSONDictionary
                    let json = LoginData(dictionary: data!)
                    
                    // 결과값 저장
                    UserDefaults.Nongmin.set(json?.authToken, forKey: .authToken)
                    UserDefaults.Nongmin.set(json?.mktAgreeYn == "Y" ? true : false, forKey: .marketingTermsAgree)
                    
                    APP_DELEGATE?.getUserData()
                    MainViewController().setCookieValue()
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("message: \(message)")
                }
            }
        }
    }
    
    func getUserClass() {
        NewsService().requestUserClass() { response in
            if let result = response {
                let code = result["code"] as! String
                let message = result["message"] as! String
                
                if code == "10000" {
                    let data = result["data"] as! JSONDictionary
                    let grade = data["grade"] as! String
                    
                    UserDefaults.Nongmin.set(grade, forKey: .userClass)
                    APP_DELEGATE?.getUserData()
                    
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("message: \(message)")
                }
            }
        }
    }
    
    func setTextFields() {
        inputPhoneNumberTF.font = .systemFont(ofSize: 20)
        inputPhoneNumberTF.attributedPlaceholder = NSAttributedString(string: "핸드폰 번호를 입력하세요.", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        inputCodeTF.font = .systemFont(ofSize: 20)
        inputCodeTF.attributedPlaceholder = NSAttributedString(string: "인증번호를 입력하세요.", attributes:[NSAttributedString.Key.foregroundColor: UIColor.lightGray,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        inputPhoneNumberTF.delegate = self
        inputCodeTF.delegate = self
    }
    
    func validPhoneNumber(number: String) -> Bool {
        let regex = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: number)
    }
    
    func showRecheckPhoneNumberAlert() {
        if !inputPhoneNumberTF.text!.isEmpty && !validPhoneNumber(number: inputPhoneNumberTF.text!) {
            let alert = UIAlertController(title: "유효하지 않은 전화번호", message: "입력하신 전화번호를 다시 확인해 주세요.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
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
    
    func loadLoginWebView(url: String) {
        if let request = initRequest(url) {
            self.webView.load(request)
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
}


extension LoginViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches Began Execute")
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == inputPhoneNumberTF {
            showRecheckPhoneNumberAlert()
        }
    }
}


extension LoginViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print(">>>> commit url: \(webView.url?.absoluteString ?? "")")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(">>>> finish url: \(webView.url?.absoluteString ?? "")")
        
        let script = "execLoginTextbox('\(USER_DATA.userId)')"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
}

extension LoginViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Script Message Name: \(message.name)")
        print("Script Message Body: \(message.body)")
        
        switch message.name {
        case "execWebLogin":
            if let script = message.body as? String, !script.isEmpty {
                let jsonDic = convertStringToDictionary(text: script)
                
                let token = jsonDic?["jwt"]
                let userId = jsonDic?["idSave"]
                let loginKeepYn = jsonDic?["loginKeepYn"]
                
                print("\(token!), \(userId!), \(loginKeepYn!)")
                
                UserDefaults.Nongmin.set(token, forKey: .authToken)
                UserDefaults.Nongmin.set(userId, forKey: .userId)
                UserDefaults.Nongmin.set(loginKeepYn as! String == "Y" ? true : false, forKey: .isAutoLogin)
                
                APP_DELEGATE?.getUserData()
                
                if let pushToken = UserDefaults.Nongmin.value(forKey: .pushToken) {
                    APP_DELEGATE?.sendFCMTokenToServer(token: pushToken as! String)
                }
                
                getUserClass()
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
