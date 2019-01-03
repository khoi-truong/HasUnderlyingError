//
//  Action+HasUnderlyingError.swift
//  HasUnderlyingError
//
//  Created by Khoi Truong Minh on 1/3/19.
//  Copyright © 2019 Khoi Truong Minh. All rights reserved.
//

import RxSwift
import Action

extension Action {

    var underlyingError: Observable<Error> {
        return self.errors.getUnderlyingError()
    }

    var deeplyUnderlyingError: Observable<Error> {
        return self.errors.getDeeplyUnderlyingError()
    }
}
