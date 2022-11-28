//
//  PaperMainViewController.swift
//  NongminNews
//
//  Created by 조지운 on 2022/08/29.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit
import Alamofire
import CenteredCollectionView

class PaperMainViewController: UIViewController, PagingScrollViewDelegate, PagingScrollViewDataSource {
    @IBOutlet weak var pagingControl: PagingScrollView!
    
    @IBOutlet weak var pageSelectView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var topBarBaseView: UIView!
    @IBOutlet weak var pageNumberLabel: UILabel!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    @IBOutlet weak var bottomBaseView: UIView!
    @IBOutlet weak var bottomlandscapeView: UIView!
    @IBOutlet weak var bottomBtnStack: UIStackView!
    @IBOutlet weak var pageSlider: CustomSlider!
    @IBOutlet weak var articleSearchBar: UISearchBar!
    
    @IBOutlet weak var bottonSafetyHeight: NSLayoutConstraint!
    @IBOutlet weak var pageSelectViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pageSliderTopHeight: NSLayoutConstraint!
    @IBOutlet weak var pageSliderBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var thunmbnailTopHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomBaseViewHeight: NSLayoutConstraint!
    
    //private let pagingControl:PagingScrollView = PagingScrollView()
    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
    
    var downloadUrlArr = [String]()
    var thumbnailUrlArr = [String]()
    var downloadedFiles = [URL]()
    var publishDateCalendar: [String] = []
    var selectedPublishDate: String!
    
    var articleDataArr = [[Article]]()
    //var articleDic: [Int : [Article]] = [:]
    var newslayerArr: [[CAShapeLayer]] = []
    var currentPageNum: Int = 1
    var sliderXPos: Int = 0
    var finalScale: CGFloat = 0
    var isPossiblePageSelectionView: Bool = false
    var topBarBottomLine = CALayer()
    
    // 쪽기사 좌표값 기준 가로 해상도
    let standardResX: CGFloat = 5180
    
    private var isSearchBarFirstInit = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: Const.ApiUrl.getPublishDate) else { return }
        getPublishRecent(url: url)
        
        initPaperViewer(date: selectedPublishDate)
        
        if !hasNotchDevice() {
            bottonSafetyHeight.constant = 0
        }
        
        bottomBaseViewHeight.constant = isDisplayZoomed ? 58 : 68
        bottomlandscapeView.isHidden = true
        bottomBtnStack.isHidden = false
        
        let dateVal = getDateFromString(dateStr: selectedPublishDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateStr = dateFormatter.string(from: dateVal)
        self.selectedDateLabel.text = dateStr
        
        articleSearchBar.isHidden = true
        downloadProgressView.isHidden = true
        
        pageSelectView.isHidden = true
        pageSelectView.layer.cornerRadius = 50
        
        topBarBottomLine.frame = CGRect.init(x: 0, y: topBarBaseView.frame.height - 1, width: topBarBaseView.frame.width, height: 1)
        topBarBottomLine.backgroundColor = UIColor.lightGray.cgColor
        topBarBaseView.layer.addSublayer(topBarBottomLine)
        
        pageSlider.minimumTrackTintColor = UIColor(red: 159/255, green: 159/255, blue: 159/255, alpha: 1)
        pageSlider.maximumTrackTintColor = UIColor(red: 159/255, green: 159/255, blue: 159/255, alpha: 1)
        
        bottomBtnStack.cornerShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 화면이 보일때 마다 화면 회전 변수 활성화
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard isSearchBarFirstInit else { return }
        isSearchBarFirstInit = false
        initSearchBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func showSearchResultView() {
        self.dissmissKeyboard()
        articleSearchBar.isHidden = true
        
        let alert = UIAlertController(title: "준비중인 기능입니다", message: "입력하신 검색어 : \(articleSearchBar.text ?? "")", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: { self.articleSearchBar.text = "" })
    }
    
    @objc func detectOrientation() {
        if (UIDevice.current.orientation == .landscapeLeft) || (UIDevice.current.orientation == .landscapeRight) {
            print("detectOrientation : landscapeLeft")
            bottonSafetyHeight.constant = 0
            pageSelectViewHeight.constant = 330
            pageSliderTopHeight.constant = 0
            pageSliderBottomHeight.constant = 70
            thunmbnailTopHeight.constant = 0
            bottomBaseViewHeight.constant = 68
            bottomBtnStack.isHidden = true
            bottomlandscapeView.isHidden = false
            
            resizeTopBarBottomLine()
            pagingControl.reloadData()
            setUpThumbScrollView()
            
            //iOS 16 회전 딜레이
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.pagingControl.reloadData()
                self.resizeTopBarBottomLine()
            }
            
        } else if (UIDevice.current.orientation == .portrait) || (UIDevice.current.orientation == .portraitUpsideDown) {
            print("detectOrientation : portrait")
            bottonSafetyHeight.constant = 34
            pageSelectViewHeight.constant = 629
            pageSliderTopHeight.constant = 20
            pageSliderBottomHeight.constant = 197
            thunmbnailTopHeight.constant = 20
            bottomBaseViewHeight.constant = isDisplayZoomed ? 58 : 68
            bottomlandscapeView.isHidden = true
            bottomBtnStack.isHidden = false
            
            resizeTopBarBottomLine()
            pagingControl.reloadData()
            setUpThumbScrollView()
            
            //iOS 16 회전 딜레이
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.pagingControl.reloadData()
                self.resizeTopBarBottomLine()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func showCalendar(_ sender: UIButton) {
        let calendar = YYCalendar(specificCalendarLangType: .KOR,
                                  date: Useful.dateToString(Date(), format: "yyyyMMdd"),
                                  limitDate: publishDateCalendar,
                                  format: "yyyyMMdd") { [weak self] date in
            let convertDate = Useful.stringToDate(date, format: "yyyyMMdd")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            let dateStr = dateFormatter.string(from: convertDate!)
            self?.selectedDateLabel.text = dateStr
            
            self?.downloadUrlArr = [String]()
            self?.thumbnailUrlArr = [String]()
            self?.downloadedFiles = [URL]()
            self?.articleDataArr = [[Article]]()
            self?.newslayerArr = [[CAShapeLayer]]()
            self?.pagingControl.reloadData()
            
            let dateArr = dateStr.components(separatedBy: ".")
            self?.selectedPublishDate = dateArr[0] + dateArr[1] + dateArr[2]
            self?.initPaperViewer(date: (self?.selectedPublishDate)!)
        }
        calendar.show()
    }

    @IBAction func searchArticle(sender: UIButton) {
        articleSearchBar.isHidden.toggle()
        
        if articleSearchBar.isHidden {
            articleSearchBar.text = ""
            articleSearchBar.resignFirstResponder()
        }
    }
    
    @IBAction func tabChanged(sender: UIButton) {
        if sender.tag == 0 {
            self.dismiss(animated: true, completion: nil)
            
        } else if sender.tag == 1 {
            if isPossiblePageSelectionView {
                if pageSelectView.isHidden {
                    self.bottomBaseView.backgroundColor = UIColor.clear
                    self.showPageSelectView()
                }
            }
            /*
            if sender.isSelected {
                sender.isSelected = false
                hidePageSelectView()
            } else {
                sender.isSelected = true
                self.bottomBaseView.backgroundColor = UIColor.clear
                self.showPageSelectView()
            }
             */
        } else if sender.tag == 2 {
            let storyboard = UIStoryboard(name: "Paper", bundle: nil)
            let naviVC = storyboard.instantiateViewController(withIdentifier: "articleNaviVC") as! UINavigationController
            
            let vc = naviVC.viewControllers.first as! ArticleListViewController
            vc.selectedDate = selectedPublishDate
            
            naviVC.modalPresentationStyle = .fullScreen
            present(naviVC, animated: true, completion: nil)
            
        } else {
            
        }
    }
    
    @IBAction func sliderScrolled(_ sender: UISlider) {
        let xPos = Int(round(sender.value))
        
        if sliderXPos != xPos {
            sliderXPos = xPos
            collectionView.scrollToItem(at: IndexPath(row: sliderXPos, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    @IBAction func hidePageSelectView(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.bottomBaseView.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
            
            self.pageSelectView.frame = CGRect(x: self.pageSelectView.frame.origin.x, y: (self.view.frame.height + self.pageSelectView.frame.height), width: self.pageSelectView.frame.width, height: self.pageSelectView.frame.height)
        }, completion: {_ in
            self.pageSelectView.isHidden = true
        })
    }
    
    func initPaperViewer(date: String) {
        if let imgList = FileManager.allRecordedData(folderName: date) {
            guard let paperUrl = URL(string: "\(Const.ApiUrl.getPaperData)\(date)") else { return }
            self.requestPaperDataArticleOnly(url: paperUrl, list: imgList)
            
        } else {
            guard let paperUrl = URL(string: "\(Const.ApiUrl.getPaperData)\(selectedPublishDate!)") else { return }
            self.requestPaperData(url: paperUrl)
        }
    }

    func initSearchBar() {
        let searchTextField = articleSearchBar.searchTextField
        searchTextField.backgroundColor = .white
        //searchTextField.layer.borderColor = UIColor.white.cgColor
        //searchTextField.layer.borderWidth = 0
        searchTextField.placeholder = "검색어를 입력해 주세요."
        searchTextField.font = UIFont.systemFont(ofSize: 16)
        
        let img = UIImage(named: "paper_glass")
        let button = UIButton(type: .custom)
        button.setImage(img, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(showSearchResultView), for: .touchUpInside)
        
        searchTextField.rightView = button
        searchTextField.rightViewMode = UITextField.ViewMode.always
        
        articleSearchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
        articleSearchBar.delegate = self
    }
    
    func dissmissKeyboard() {
        articleSearchBar.resignFirstResponder()
    }
    
    func showArticleDetailView(info: String) {
        let storyboard = UIStoryboard(name: "Paper", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "articleDetailVC") as! ArticleDetailViewController
        
        let infoArr = info.components(separatedBy: ",")
        
        vc.articleUrl = "\(Const.WebUrl.openArticle)20221117500223"
        //vc.articleUrl = "\(Const.WebUrl.openArticle)\(infoArr[0])"
        vc.articleImg = infoArr[1]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func resizeTopBarBottomLine() {
        topBarBottomLine.frame = CGRect.init(x: 0, y: topBarBaseView.frame.height - 1, width: topBarBaseView.frame.width, height: 1)
    }
    
    func hasNotchDevice() -> Bool {
        var result = false
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let window = appDelegate.window {
                result = window.safeAreaInsets.top > 20.0
            }
        }
        return result
    }
    
    func getDateFromString(dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        guard let convertDate = dateFormatter.date(from: dateStr) else { return Date() }
        
        return convertDate
    }
    
    /*
    func getArticleInfo(url: URL) {
        PaperService().getArticleData(url: url) { info in
            _ = info.map { data in
                self.articleDateArr.append(data)
            }
            
            if self.articleDateArr.count != 0 {
                self.createArticleArea()
            }
        }
    }
    
    func createArticleArea() {
        var id = 1
        var arr: [Article] = []
        
        for (index, info) in articleDateArr.enumerated() {
            if info.myun == id {
                arr.append(info)
                
                if index == articleDateArr.count - 1 {
                    articleDic.updateValue(arr, forKey: id)
                }
            } else {
                articleDic.updateValue(arr, forKey: id)
                id = info.myun
                arr.append(info)
                
                if index == articleDateArr.count - 1 {
                    articleDic.updateValue(arr, forKey: id)
                }
            }
        }
    }
    */
    
    func getPublishRecent(url: URL) {
        PaperService().getPublishInfo(url: url) { info in
            _ = info.map { data in
                self.publishDateCalendar.append(data.publishDate)
            }
            print(self.publishDateCalendar)
        }
    }
    
    func requestPaperData(url: URL) {
        PaperService().getPaperData(url: url) { info in
            _ = info.map { data in
                let year = data.publishDate.prefix(4)
                let month = "\(Array(data.publishDate)[4])\(Array(data.publishDate)[5])"
                let day = data.publishDate.suffix(2)
                
                // 원본 이미지 다운로드 url 배열 생성
                var imgUrl = "\(Const.ApiUrl.getPaperImageFile)\(year)/\(month)/\(day)/\(data.imgFile)"
                self.downloadUrlArr.append(imgUrl)
                
                // 지면 이동용 썸네일 다운로드 url 배열 생성
                let imgNameArr = data.imgFile.components(separatedBy: ".")
                let imgName = imgNameArr[0] as String
                let thumbnail = imgName + "x640.jpg"
                imgUrl = "\(Const.ApiUrl.getPaperImageFile)\(year)/\(month)/\(day)/\(thumbnail)"
                self.thumbnailUrlArr.append(imgUrl)
                
                // 지면 기사 데이터 배열 생성
                self.articleDataArr.append(data.articles)
            }
            self.downloadPaperImage()
        }
    }
    
    func requestPaperDataArticleOnly(url: URL, list: [URL]) {
        PaperService().getPaperData(url: url) { info in
            _ = info.map { data in
                // 지면 기사 데이터 배열 생성
                self.articleDataArr.append(data.articles)
            }
            
            self.downloadedFiles = list
            
            if self.downloadedFiles.count > 1 {
                self.downloadedFiles.sort {($0.pathComponents.last?.components(separatedBy: ".").first)! < ($1.pathComponents.last?.components(separatedBy: ".").first)!}
            }
            self.setPagingControlView()
        }
    }
    
    func createPartialNewsLayer(info: [Article]) -> [CAShapeLayer] {
        var layerArr = [CAShapeLayer]()
        
        for data in info {
            let shapeLayer = CAShapeLayer()
            let apexStr = data.area
            shapeLayer.path = drawShapeLayer(pos: apexStr).cgPath
            shapeLayer.name = "\(data.storySiteId),\(data.areaFile)"
            layerArr.append(shapeLayer)
        }
        
        return layerArr
    }
    
    func downloadPaperImage() {
        let urls = downloadUrlArr.compactMap { URL(string: $0) }

        let folder = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(selectedPublishDate)
        
        let totalFileCnt: Float = Float(self.downloadUrlArr.count)
        let increaseValue: Float = 1 / totalFileCnt
        var pageChangeValue: Float = 0.0
        var totalProgress: Float = 0.0
        
        for url in urls {
            let destination: DownloadRequest.Destination = { _, _ in
                let fileURL = folder.appendingPathComponent(url.lastPathComponent)
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            /*
            AF.download(url, to: destination).response { responseData in
                switch responseData.result {
                case .success(let url):
                    guard let url = url else { return }
                    //self.urlLoad.append(url)

                case .failure(let error):
                    print(error)
                }
            }
            */
            self.downloadProgressView.isHidden = false
            
            AF.download(url, method: .get, parameters: nil, encoding: JSONEncoding.default, to: destination).downloadProgress { (progress) in
                let pageProgress = Float(progress.fractionCompleted) / totalFileCnt
                if progress.fractionCompleted == 1.0 {
                    pageChangeValue += Float(increaseValue)
                }
                totalProgress = pageChangeValue
                totalProgress += pageProgress
                print("Progress : \(Int(totalProgress * 100))%")
                self.downloadProgressView.progress = totalProgress
                
            }.response{ response in
                switch response.result {
                case .success(let url):
                    guard let url = url else { return }
                    self.downloadedFiles.append(url)
                    
                    if self.downloadedFiles.count == self.downloadUrlArr.count {
                        if self.downloadedFiles.count == 0 {
                            do {
                                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                let folderURL = documentsUrl.appendingPathComponent(self.selectedPublishDate)
                                try FileManager.default.removeItem(at: folderURL)
                            } catch {
                                print(error)
                            }
                            
                            let alert = UIAlertController(title: "다운로드 실패", message: "다운로드 된 지면 파일이 없습니다.", preferredStyle: .alert)
                            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                            alert.addAction(action)
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            self.downloadProgressView.isHidden = true
                            return
                        } else {
                            if self.downloadUrlArr.count > 1 {
                                self.downloadedFiles.sort {($0.pathComponents.last?.components(separatedBy: ".").first)! < ($1.pathComponents.last?.components(separatedBy: ".").first)!}
                            }
                            
                            self.downloadProgressView.isHidden = true
                            self.setPagingControlView()
                        }
                    }
                case .failure(let error):
                    print(error)
                    self.downloadProgressView.isHidden = true
                }
            }
        }
    }
    
    func setPagingControlView() {
        // 지면 페이징뷰 세팅
        //pagingControl.frame = self.view.bounds
        pagingControl.delegate = self
        pagingControl.dataSource = self
        pagingControl.backgroundColor = UIColor.clear
        //self.view.addSubview(pagingControl)
        pagingControl.reloadData()
        
        // 지면 쪽기사 레이어 생성
        for data in articleDataArr {
            let layer = createPartialNewsLayer(info: data)
            newslayerArr.append(layer)
        }
        
        // 지면 이동 썸네일뷰 세팅
        if isPossiblePageSelectionView {
            collectionView.reloadData()
        } else {
            setUpThumbScrollView()
        }
    }
    
    func showPageSelectView() {
        let indexPath = IndexPath(item: currentPageNum - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        
        pageSlider.maximumValue = Float(downloadedFiles.count) - 1
        pageSlider.value = Float(centeredCollectionViewFlowLayout.currentCenteredPage ?? 0)
        pageSlider.sendActions(for: .valueChanged)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.pageSelectView.frame = CGRect(x: self.pageSelectView.frame.origin.x, y: self.view.frame.height - self.pageSelectView.frame.height, width: self.pageSelectView.frame.width, height: self.pageSelectView.frame.height)
            
            self.pageSelectView.isHidden = false
        })
    }
    
    func setUpThumbScrollView() {
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
        
        if UIDevice.current.orientation.isLandscape {
            centeredCollectionViewFlowLayout.itemSize = CGSize(
                width: 110,
                height: 150
            )
            
            centeredCollectionViewFlowLayout.minimumLineSpacing = 20
        } else {
            centeredCollectionViewFlowLayout.itemSize = CGSize(
                width: 200,
                height: 272
            )
            // Configure the optional inter item spacing (OPTIONAL)
            centeredCollectionViewFlowLayout.minimumLineSpacing = 10
        }
        
        isPossiblePageSelectionView = true
    }
    
    func squarePathWithCenter(center: CGPoint, side: CGFloat) -> UIBezierPath {
        let squarePath = UIBezierPath()
        let startX = center.x - side / 2
        let startY = center.y - side / 2
        squarePath.move(to: CGPoint(x: startX, y: startY))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.addLine(to: CGPoint(x: startX + side, y: startY))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.addLine(to: CGPoint(x: startX + side, y: startY + side))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.addLine(to: CGPoint(x: startX, y: startY + side))
        squarePath.addLine(to: squarePath.currentPoint)
        squarePath.close()
        return squarePath
    }
    
    func drawShapeLayer(pos: String) -> UIBezierPath {
        let shapePath = UIBezierPath()
        var apexArr = pos.components(separatedBy: ",")
        apexArr.append(apexArr[0])
        
        apexArr.enumerated().forEach {
            let xyArr = $1.components(separatedBy: " ")
            let xVal = CGFloat(NSString(string: xyArr[0]).floatValue) * finalScale //0.075289575289575292
            let yVal = CGFloat(NSString(string: xyArr[1]).floatValue) * finalScale //0.075289575289575292
            
            if $0 == 0 {
                shapePath.move(to: CGPoint(x: xVal, y: yVal))
            } else {
                shapePath.addLine(to: CGPoint(x: xVal, y: yVal))
            }
        }
        
        return shapePath
        /*
        for apexPos in apexArr {
            let xyVal = apexPos.components(separatedBy: " ")
            
        }
         */
    }
    
    func pagingScrollView(_ pagingScrollView:PagingScrollView, willChangedCurrentPage currentPageIndex:NSInteger) {
        print("current page will be changed to \(currentPageIndex).")
        /*
        if currentPageIndex == 0 {
            let alert = UIAlertController(title: "", message: "유료회원 서비스입니다.\n이용을 위해서 서비스 결제가 필요합니다.\n결제는 PC를 통해 가능합니다.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default, handler: {_ in
                pagingScrollView.enableScroll()
            })
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
            
            pagingScrollView.disableScroll()
        }
         */
    }
    
    func pagingScrollView(_ pagingScrollView:PagingScrollView, didChangedCurrentPage currentPageIndex:NSInteger) {
        print("current page did changed to \(currentPageIndex).")
        self.pageNumberLabel.text = "\(currentPageIndex + 1)면"
        self.currentPageNum = currentPageIndex + 1
    }
    
    func pagingScrollView(_ pagingScrollView:PagingScrollView, layoutSubview view:UIView) {
        print("paging control call layoutsubviews.")
    }

    func pagingScrollView(_ pagingScrollView:PagingScrollView, recycledView view:UIView?, viewForIndex index:NSInteger) -> UIView {
        guard view == nil else { return view! }
        
        let zoomingView = ZoomingScrollView(frame: self.view.bounds)
        zoomingView.backgroundColor = UIColor.clear
        
        zoomingView.singleTapEvent = { touchPoint in
            self.view.endEditing(true)
            
            if self.newslayerArr.count > 0 {
                print(touchPoint)
                self.newslayerArr[index].forEach {
                    if $0.path!.contains(touchPoint) {
                        print($0.name!)
                        self.showArticleDetailView(info: $0.name!)
                    }
                }
            }
        }
        /*
        zoomingView.doubleTapEvent = {
            print("double tapped...")
        }
        */
        zoomingView.pinchTapEvent = {
            print("pinched...")
        }
        
        return zoomingView
    }
    
    func pagingScrollView(_ pagingScrollView:PagingScrollView, prepareShowPageView view:UIView, viewForIndex index:NSInteger) {
        guard let zoomingView = view as? ZoomingScrollView else { return }
        guard let zoomContentView = zoomingView.targetView as? ZoomContentView else { return }
        
        zoomContentView.zoomScrollViewSize = zoomingView.frame.size
        
        if let data = try? Data(contentsOf: downloadedFiles[index]), let paperImg = UIImage(data: data) {
            zoomContentView.image = paperImg
            print(zoomContentView.zoomContentImageSize)
            finalScale = ((paperImg.size.width) / standardResX) * (zoomContentView.zoomContentImageSize.width / (paperImg.size.width))
            
        } else {
            let alert = UIAlertController(title: "유효하지 않은 URL", message: downloadUrlArr[index], preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // just call this methods after set image for resizing.
        zoomingView.prepareAfterCompleted()
        //zoomingView.setMaxMinZoomScalesForCurrentBounds()
        zoomingView.addShadow(location: .bottom)
        
        /*
        if index == pagingControl.currentPageIndex {
            let newsLayer = CALayer()
            let newSize: CGSize = zoomContentView.zoomContentImageSize
            print(newSize)
            newsLayer.frame.size = newSize
            newsLayer.backgroundColor = UIColor.clear.cgColor
            zoomContentView.layer.addSublayer(newsLayer)
            
            let squareLayer = CAShapeLayer()
            let squareCenter = CGPoint(x: 50, y: 50)
            let square = squarePathWithCenter(center: squareCenter, side: 100)
            squareLayer.path = square.cgPath
            squareLayer.fillColor = UIColor.red.cgColor
            squareLayer.name = "12345"
            //newsLayer.addSublayer(squareLayer)
            //newslayerArr.append(squareLayer)
            
            let shapeLayer = CAShapeLayer()
            let apexStr = "472 2881,472 4780,2561 4780,2561 2881,2562 2881,2562 2617,472 2617"
            shapeLayer.path = drawShapeLayer(pos: apexStr).cgPath
            shapeLayer.fillColor = UIColor.green.cgColor
            shapeLayer.name = "67890"
            newsLayer.addSublayer(shapeLayer)
            //newslayerArr.append(shapeLayer)
        }
         */
    }
    
    func startIndexOfPageWith(pagingScrollView:PagingScrollView) -> NSInteger {
        return currentPageNum - 1
    }
    
    func numberOfPageWith(pagingScrollView:PagingScrollView) -> NSInteger {
        return downloadedFiles.count
    }
}

extension UIView {
    func cornerShadow(scale: Bool = true) {
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowRadius = 1
        layer.masksToBounds = false
    }
    
    enum VerticalLocation {
        case bottom
        case top
        case left
        case right
    }
    
    func addShadow(location: VerticalLocation, color: UIColor = .black, opacity: Float = 0.2, radius: CGFloat = 5.0) {
        switch location {
        case .bottom:
            addShadow(offset: CGSize(width: 0, height: 5), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -5), color: color, opacity: opacity, radius: radius)
        case .left:
            addShadow(offset: CGSize(width: -5, height: 0), color: color, opacity: opacity, radius: radius)
        case .right:
            addShadow(offset: CGSize(width: 5, height: 0), color: color, opacity: opacity, radius: radius)
        }
    }
    
    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.2, radius: CGFloat = 3.0) {
        //self.layer.cornerRadius = 20
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
}


extension PaperMainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentPageNum = indexPath.row + 1
        print("Selected Cell #\(indexPath.row)")
        /*
        if indexPath.row > 0 {
            let alert = UIAlertController(title: "", message: "유료회원 서비스입니다.\n이용을 위해서 서비스 결제가 필요합니다.\n결제는 PC를 통해 가능합니다.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default, handler: {_ in
                self.pagingControl.enableScroll()
            })
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
            
            pagingControl.disableScroll()
            self.pageSelectView.isHidden = true
            return
        }
        */
        pagingControl.jumpToPage(at: indexPath.row, animated: true)
        self.pageSelectView.isHidden = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloadedFiles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "Cell"), for: indexPath) as! PaperCollectionViewCell
        cell.pageNumberLabel.text = "\(indexPath.row + 1)면"
        
        if thumbnailUrlArr.count > 0 {
            cell.paperImgView.load(url: URL(string: thumbnailUrlArr[indexPath.item])!)
        } else {
            let imageData = try? Data(contentsOf: downloadedFiles[indexPath.item])
            let thumbnail = UIImage(data: imageData!)?.resizeImage(targetSize: CGSize(width: 640, height: 867))
            cell.paperImgView.image = thumbnail
        }
        
        cell.addShadow(offset: CGSize(width: 5, height: 5), color: UIColor.lightGray, opacity: 0.5, radius: 5)
        
        return cell
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
        pageSlider.value = Float(centeredCollectionViewFlowLayout.currentCenteredPage!)
        pageSlider.sendActions(for: .valueChanged)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
    }
}


extension PaperMainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
        
        let alert = UIAlertController(title: "준비중인 기능입니다", message: "입력하신 검색어 : \(searchBar.text ?? "")", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: { searchBar.text = "" })
    }
}
