//
//  PaperModel.swift
//  NongminNews
//
//  Created by 조지운 on 2022/09/27.
//  copyright ⓒThe Farmers Newspaper. All rights reserved.
//

import Foundation

struct PublishInfo: Codable {
    var infoSeq: Int
    var media: Int
    var publishDate: String
    var publishNum: Int
    var month: Int
    
    init?(dictionary: JSONDictionary) {
        guard let infoSeq = dictionary["infoSeq"] as? Int,
              let media = dictionary["media"] as? Int,
              let publishDate = dictionary["publishDate"] as? String,
              let publishNum = dictionary["publishNum"] as? Int,
              let month = dictionary["month"] as? Int
        else {
            return nil
        }
        self.infoSeq = infoSeq
        self.media = media
        self.publishDate = publishDate
        self.publishNum = publishNum
        self.month = month
    }
}

struct PaperData: Codable {
    var viewerSeq: Int
    var media: Int
    var publishDate: String
    var myun: Int
    var pdfFile: String
    var imgFile: String
    var articles: [Article]
    
    init?(dictionary: JSONDictionary) {
        guard let viewerSeq = dictionary["viewerSeq"] as? Int,
              let media = dictionary["media"] as? Int,
              let publishDate = dictionary["publishDate"] as? String,
              let myun = dictionary["myun"] as? Int,
              let pdfFile = dictionary["pdfFile"] as? String,
              let imgFile = dictionary["imgFile"] as? String,
              let articles = dictionary["articles"] as? [Article]
        else {
            return nil
        }
        self.viewerSeq = viewerSeq
        self.media = media
        self.publishDate = publishDate
        self.myun = myun
        self.pdfFile = pdfFile
        self.imgFile = imgFile
        self.articles = articles
    }
}

struct Article: Codable {
    var articleSeq: Int
    var media: Int
    var publishDate: String
    var title: String
    var myun: Int
    var area: String
    var areaFile: String
    var link: String
    var ctsId: String
    var storySiteId: String
    var infoSeq: Int
    
    init?(dictionary: JSONDictionary) {
        guard let articleSeq = dictionary["articleSeq"] as? Int,
              let media = dictionary["media"] as? Int,
              let publishDate = dictionary["publishDate"] as? String,
              let title = dictionary["title"] as? String,
              let myun = dictionary["myun"] as? Int,
              let area = dictionary["area"] as? String,
              let areaFile = dictionary["areaFile"] as? String,
              let link = dictionary["link"] as? String,
              let ctsId = dictionary["ctsId"] as? String,
              let storySiteId = dictionary["storySiteId"] as? String,
              let infoSeq = dictionary["infoSeq"] as? Int
        else {
            return nil
        }
        self.articleSeq = articleSeq
        self.media = media
        self.publishDate = publishDate
        self.title = title
        self.myun = myun
        self.area = area
        self.areaFile = areaFile
        self.link = link
        self.ctsId = ctsId
        self.storySiteId = storySiteId
        self.infoSeq = infoSeq
    }
}
