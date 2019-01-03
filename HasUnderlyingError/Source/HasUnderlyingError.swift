//
//  HasUnderlyingError.swift
//  HasUnderlyingError
//
//  Created by Khoi Truong Minh on 1/3/19.
//  Copyright © 2019 Khoi Truong Minh. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional

protocol HasUnderlyingError: Error {
    var underlyingError: Error? { get }
    var underlyingErrorOrSelf: Error { get }
    var deeplyUnderlyingError: Error? { get }
    var deeplyUnderlyingErrorOrSelf: Error { get }
}

extension HasUnderlyingError {

    var underlyingErrorOrSelf: Error {
        guard let underlyingError = underlyingError else { return self }
        return underlyingError
    }

    var deeplyUnderlyingError: Error? {
        guard let underlyingError = underlyingError else { return nil }
        guard let wrapperError = underlyingError as? HasUnderlyingError else { return underlyingError }
        return wrapperError.deeplyUnderlyingError
    }

    var deeplyUnderlyingErrorOrSelf: Error {
        guard let underlyingError = deeplyUnderlyingError else { return self }
        return underlyingError
    }
}

extension ObservableType where E: HasUnderlyingError {

    func getUnderlyingError() -> Observable<Error> {
        return self.map { $0.underlyingError }.filterNil()
    }

    func getUnderlyingErrorOrSelf() -> Observable<Error> {
        return self.map { $0.underlyingErrorOrSelf }
    }

    func getDeeplyUnderlyingError() -> Observable<Error> {
        return self.map { $0.deeplyUnderlyingError }.filterNil()
    }

    func getDeeplyUnderlyingErrorOrSelf() -> Observable<Error> {
        return self.map { $0.deeplyUnderlyingErrorOrSelf }
    }
}

