//
//  AlertActionConvertible.swift
//  CafeBlogSearchApp
//
//  Created by 김영민 on 2022/01/04.
//

import UIKit

protocol AlertActionConvertible {
    var title: String {get}
    var style: UIAlertAction.Style {get}
}
