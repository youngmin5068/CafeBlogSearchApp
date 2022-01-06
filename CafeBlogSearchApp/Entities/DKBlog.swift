//
//  DKBlog.swift
//  CafeBlogSearchApp
//
//  Created by 김영민 on 2022/01/06.
//

import Foundation

struct DKBlog : Decodable {
    let documents: [DKDocument]
}

struct DKDocument: Decodable {
    let title: String?
    let name: String?
    let thumbnail: String?
    let datetime: Date?
    
    enum CodingKeys: String, CodingKey {
        case title, thumbnail, datetime
        case name = "blogname"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try? values.decode(String?.self, forKey: .title)
        self.name = try? values.decode(String?.self, forKey: .title)
        self.thumbnail = try? values.decode(String?.self, forKey: .title)
        self.datetime = Date.parse(values, key: .datetime)
        
    }
}

//Json에 Date라는 것이 없기 때문에
extension Date {
    static func parse<K: CodingKey>(_ values: KeyedDecodingContainer<K>, key: K) -> Date? {
        guard let dateString =  try? values.decode(String.self,forKey: key),
              let date = from(dateString: dateString) else {
            return nil
        }
        
        return date
    }
    
    static func from(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        if let date = dateFormatter.date(from: dateString){
            return date
        }
        
        return nil
    }
}
