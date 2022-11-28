//
//  UIView+Extension.swift
//  NongminNews
//
//  Created by 조지운 on 2022/08/09.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import UIKit

extension UIView {

    enum CustomConstraint: String {
        case width
        case height
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        
        get {
            return layer.borderWidth
        }
    }
    
    var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func screenshot(rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: rect, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func constraint(_ type: CustomConstraint) -> NSLayoutConstraint? {
        return constraints.filter { $0.identifier?.hasPrefix(type.rawValue) == true }.first
    }
    
    func clearConstraints() {
        for subview in self.subviews {
            subview.clearConstraints()
        }
        self.removeConstraints(self.constraints)
    }
    
    func height(constant: CGFloat) {
        setConstraint(value: constant, attribute: .height)
    }
    
    func width(constant: CGFloat) {
        setConstraint(value: constant, attribute: .width)
    }
    
    private func removeConstraint(attribute: NSLayoutConstraint.Attribute) {
        constraints.forEach {
            if $0.firstAttribute == attribute {
                removeConstraint($0)
            }
        }
    }
    
    private func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute) {
        removeConstraint(attribute: attribute)
        let constraint =
            NSLayoutConstraint(item: self,
                               attribute: attribute,
                               relatedBy: NSLayoutConstraint.Relation.equal,
                               toItem: nil,
                               attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                               multiplier: 1,
                               constant: value)
        self.addConstraint(constraint)
    }
    
    func matchSize(targetView: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let horConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal,
                                               toItem: targetView, attribute: .centerX,
                                               multiplier: 1.0, constant: 0.0)
        let verConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal,
                                               toItem: targetView, attribute: .centerY,
                                               multiplier: 1.0, constant: 0.0)
        let widConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal,
                                               toItem: targetView, attribute: .width,
                                               multiplier: 1.0, constant: 0.0)
        let heiConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal,
                                               toItem: targetView, attribute: .height,
                                               multiplier: 1.0, constant: 0.0)
        
        targetView.addConstraints([horConstraint, verConstraint, widConstraint, heiConstraint])
    }
    
    /**
     Simply zooming in of a view: set view scale to 0 and zoom to Identity on 'duration' time interval.
     
     - parameter duration: animation duration
     */
    func zoomIn(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform.identity
        }) { (animationCompleted: Bool) -> Void in
        }
    }
    
    /**
     Simply zooming out of a view: set view scale to Identity and zoom out to 0 on 'duration' time interval.
     
     - parameter duration: animation duration
     */
    func zoomOut(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform.identity
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }) { (animationCompleted: Bool) -> Void in
        }
    }
    
    /**
     Zoom in any view with specified offset magnification.
     
     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomInWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        let easeScale = 1.0 + easingOffset
        let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransform.identity
            }, completion: { (completed: Bool) -> Void in
            })
        })
    }
    
    /**
     Zoom out any view with specified offset magnification.
     
     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomOutWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        let easeScale = 1.0 + easingOffset
        let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            }, completion: { (completed: Bool) -> Void in
            })
        })
    }
}


extension URL {
    /**
     * URL 파라미터 추가
     * - Author: Jiwoon
     * - Parameters:
     *   - key : 파라미터 키
     *   - value : 파라미터 값
     * - Returns: 파라미터 추가된 URL
     */
    public func appending(_ key: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        var items: [URLQueryItem] = urlComponents.queryItems ??  []
        let item = URLQueryItem(name: key, value: value)
        items.append(item)
        urlComponents.queryItems = items
        return urlComponents.url!
    }
}


extension NSAttributedString {
    /**
     * 어트리뷰트 스트링 글자 간격 조정
     * - Author: Jiwoon
     * - Returns: 줄 간격 조정된 어트리뷰트 스트링
     */
    func withLineSpacing(_ spacing: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.lineSpacing = spacing
        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: string.count))
        
        return NSAttributedString(attributedString: attributedString)
    }
}


extension UIImage {
    /**
     * 이미지 리사이징
     * - Author: Jiwoon
     * - Parameters:
     *   - image : 대상 이미지
     *   - targetSize : 리사이징 규격
     * - Returns: resized UIImage
     */
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize (width: size.width * heightRatio, height : size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height :  size.height * widthRatio)
        }
        //newSize = CGSize(width: targetSize.width, height :  targetSize.height)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}


extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


extension FileManager {
    class func directoryUrl(folder: String) -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if folder.isEmpty {
            return paths.first
        } else {
            return paths.first?.appendingPathComponent(folder)
        }
    }
    
    class func allRecordedData(folderName: String) -> [URL]? {
        if let docuFolderUrl = FileManager.directoryUrl(folder: folderName) {
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: docuFolderUrl, includingPropertiesForKeys: nil)
                return directoryContents.filter{ $0.pathExtension == "jpg" }
            } catch {
                return nil
            }
        }
        return nil
    }
}


extension UIApplication {

    public class func getMostTopViewController(base: UIViewController? = nil) -> UIViewController? {

        var baseVC: UIViewController?
        if base != nil {
            baseVC = base
        }
        else {
            if #available(iOS 13, *) {
                baseVC = (UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .flatMap { $0.windows }
                            .first { $0.isKeyWindow })?.rootViewController
            }
            else {
                baseVC = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        
        if let naviController = baseVC as? UINavigationController {
            return getMostTopViewController(base: naviController.visibleViewController)

        } else if let tabbarController = baseVC as? UITabBarController, let selected = tabbarController.selectedViewController {
            return getMostTopViewController(base: selected)

        } else if let presented = baseVC?.presentedViewController {
            return getMostTopViewController(base: presented)
        }
        return baseVC
    }
}
