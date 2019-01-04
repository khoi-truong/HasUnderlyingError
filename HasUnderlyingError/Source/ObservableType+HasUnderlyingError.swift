//
//  ObservableType+HasUnderlyingError.swift
//  HasUnderlyingError
//
//  Created by Khoi Truong Minh on 1/3/19.
//  Copyright © 2019 Khoi Truong Minh. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional

extension ObservableType where E: HasUnderlyingError {

    func takeUnderlyingError() -> Observable<Error> {
        return self.map { $0.underlyingError }.filterNil()
    }

    func orUnderlyingError() -> Observable<Error> {
        return self.map { $0.orUnderlyingError() }
    }

    func takeDeepestUnderlyingError() -> Observable<Error> {
        return self.map { $0.deepestUnderlyingError }.filterNil()
    }

    func orDeepestUnderlyingError() -> Observable<Error> {
        return self.map { $0.orDeepestUnderlyingError() }
    }
}
