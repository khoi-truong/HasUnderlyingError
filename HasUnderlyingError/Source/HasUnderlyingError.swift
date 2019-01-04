//
//  HasUnderlyingError.swift
//  HasUnderlyingError
//
//  Created by Khoi Truong Minh on 1/3/19.
//  Copyright © 2019 Khoi Truong Minh. All rights reserved.
//

import Foundation

protocol HasUnderlyingError: Error {
    var underlyingError: Error? { get }
    func orUnderlyingError() -> Error
    var deepestUnderlyingError: Error? { get }
    func orDeepestUnderlyingError() -> Error
}

extension HasUnderlyingError {

   func orUnderlyingError() -> Error {
        guard let underlyingError = underlyingError else { return self }
        return underlyingError
    }

    var deepestUnderlyingError: Error? {
        guard let underlyingError = underlyingError else { return nil }
        guard let wrapperError = underlyingError as? HasUnderlyingError else { return underlyingError }
        return wrapperError.deepestUnderlyingError
    }

    func orDeepestUnderlyingError() -> Error {
        guard let underlyingError = deepestUnderlyingError else { return self }
        return underlyingError
    }
}
