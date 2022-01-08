//
//  FilterViewModel.swift
//  CafeBlogSearchApp
//
//  Created by 김영민 on 2022/01/08.
//

import RxSwift
import RxCocoa

struct FilterViewModel {
    let sortButtonTapped = PublishRelay<Void>()
    let shouldUpdateType: Observable<Void>
    
    init() {
        self.shouldUpdateType = sortButtonTapped
            .asObservable()
    }
}
