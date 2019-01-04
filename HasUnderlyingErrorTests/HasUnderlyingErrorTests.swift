//
//  HasUnderlyingErrorTests.swift
//  HasUnderlyingErrorTests
//
//  Created by Khoi Truong Minh on 1/2/19.
//  Copyright © 2019 Khoi Truong Minh. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxCocoa
import RxTest
import Action
import Moya
@testable import HasUnderlyingError

class HasUnderlyingErrorSpec: QuickSpec {

    override func spec() {

        describe("Error with 2 level nested error") {
            let topLevelError = TestUnderlyingError(input: "a")

            it("should return a TestLevelOneUnderlyingError for underlyingError") {
                expect(topLevelError.underlyingError).to(matchError(TestLevelOneUnderlyingError.self))
            }
            it("should return a TestLevelOneUnderlyingError for orUnderlyingError()") {
                expect(topLevelError.orUnderlyingError()).to(matchError(TestLevelOneUnderlyingError.self))
            }
            it("should return a TestLevelTwoUnderlyingError for deepestUnderlyingError") {
                expect(topLevelError.deepestUnderlyingError).to(matchError(TestLevelTwoUnderlyingError.self))
            }
            it("should return a TestLevelTwoUnderlyingError for orDeepestUnderlyingError()") {
                expect(topLevelError.orDeepestUnderlyingError()).to(matchError(TestLevelTwoUnderlyingError.self))
            }
        }

        describe("Error without any nested error") {
            let error = TestLevelOneUnderlyingError.normal

            it("should return nil for underlyingError") {
                expect(error.underlyingError).to(beNil())
            }
            it("should return a TestLevelTwoUnderlyingError for deepestUnderlyingError") {
                expect(error.deepestUnderlyingError).to(beNil())
            }
            it("should return itself for orUnderlyingError()") {
                expect(error.orUnderlyingError()).to(matchError(TestLevelOneUnderlyingError.normal))
            }
            it("should return itself for orDeepestUnderlyingError()") {
                expect(error.orDeepestUnderlyingError()).to(matchError(TestLevelOneUnderlyingError.normal))
            }
        }
    }
}

class ActionHasUnderlyingErrorSpec: QuickSpec {

    override func spec() {

        describe("Action which return value") {
            let scheduler: TestScheduler = TestScheduler(initialClock: 0)
            let disposeBag: DisposeBag = DisposeBag()
            let element: TestableObserver<String> = scheduler.createObserver(String.self)
            let secondElement: TestableObserver<String> = scheduler.createObserver(String.self)
            let trigger = PublishRelay<Void>()
            let action = Action<String, String> { Observable.just($0).sample(trigger) }
            let underlyingError: TestableObserver<Error> = scheduler.createObserver(Error.self)
            let deepestUnderlyingError: TestableObserver<Error> = scheduler.createObserver(Error.self)

            context("execute while executing") {

                action.underlyingError
                    .bind(to: underlyingError)
                    .disposed(by: disposeBag)

                action.deepestUnderlyingError
                    .bind(to: deepestUnderlyingError)
                    .disposed(by: disposeBag)

                scheduler.scheduleAt(10) {
                    action.execute("a").bind(to: element).disposed(by: disposeBag)
                }

                scheduler.scheduleAt(20) {
                    action.execute("b").bind(to: secondElement).disposed(by: disposeBag)
                }

                scheduler.scheduleAt(30) {
                    trigger.accept(())
                }

                scheduler.start()

                it("should not emit any underlyingError") {
                    expect(underlyingError.events.count).to(equal(0))
                }
                it("should not emit any deepestUnderlyingError") {
                    expect(deepestUnderlyingError.events.count).to(equal(0))
                }
            }
        }

        describe("Action which return error") {
            var scheduler: TestScheduler!
            var disposeBag: DisposeBag!
            var element: TestableObserver<String>!
            var secondElement: TestableObserver<String>!
            var trigger: PublishRelay<Void>!
            var action: Action<String, String>!
            var underlyingError: TestableObserver<Error>!
            var deepestUnderlyingError: TestableObserver<Error>!

            beforeEach {
                scheduler = TestScheduler(initialClock: 0)
                disposeBag = DisposeBag()
                element = scheduler.createObserver(String.self)
                secondElement = scheduler.createObserver(String.self)
                trigger = PublishRelay<Void>()
                action = Action<String, String> { input in
                    trigger.flatMapLatest { Observable<String>.error(TestUnderlyingError(input: input)) }
                }
                underlyingError = scheduler.createObserver(Error.self)
                deepestUnderlyingError = scheduler.createObserver(Error.self)

                action.underlyingError
                    .bind(to: underlyingError)
                    .disposed(by: disposeBag)

                action.deepestUnderlyingError
                    .bind(to: deepestUnderlyingError)
                    .disposed(by: disposeBag)
            }

            context("excute while not executing") {

                beforeEach {

                    scheduler.scheduleAt(10) {
                        action.execute("a").bind(to: element).disposed(by: disposeBag)
                    }

                    scheduler.scheduleAt(30) {
                        trigger.accept(())
                    }

                    scheduler.start()
                }

                it("should emit only one underlyingError") {
                    expect(underlyingError.events.count).to(equal(1))
                    expect(underlyingError.events.first?.time).to(equal(30))
                    expect(underlyingError.events.first?.value.element).to(matchError(TestUnderlyingError(input: "a")))
                }

                it("should emit only one deepestUnderlyingError") {
                    expect(deepestUnderlyingError.events.count).to(equal(1))
                    expect(deepestUnderlyingError.events.first?.time).to(equal(30))
                    expect(deepestUnderlyingError.events.first?.value.element)
                        .to(matchError(TestLevelTwoUnderlyingError(input: "a")))
                }
            }

            context("execute while executing") {

                beforeEach {

                    scheduler.scheduleAt(10) {
                        action.execute("a").bind(to: element).disposed(by: disposeBag)
                    }

                    scheduler.scheduleAt(20) {
                        action.execute("b").bind(to: secondElement).disposed(by: disposeBag)
                    }

                    scheduler.scheduleAt(30) {
                        trigger.accept(())
                    }

                    scheduler.start()
                }

                it("should emit only one underlyingError") {
                    expect(underlyingError.events.count).to(equal(1))
                    expect(underlyingError.events.first?.time).to(equal(30))
                    expect(underlyingError.events.first?.value.element).to(matchError(TestUnderlyingError(input: "a")))
                }

                it("should emit only one deepestUnderlyingError") {
                    expect(deepestUnderlyingError.events.count).to(equal(1))
                    expect(deepestUnderlyingError.events.first?.time).to(equal(30))
                    expect(deepestUnderlyingError.events.first?.value.element)
                        .to(matchError(TestLevelTwoUnderlyingError(input: "a")))
                }
            }
        }
    }
}

class MoyaErrorHasUnderlyingErrorSpec: QuickSpec {

    override func spec() {

        describe("MoyaError.underlying") {

            let testUnderlyingError = TestUnderlyingError(input: "a")
            let moyaError = MoyaError.underlying(testUnderlyingError, nil)

            it("should return testUnderlyingError for underlyingError") {
                expect(moyaError.underlyingError).to(matchError(testUnderlyingError))
            }
            it("should return TestLevelTwoUnderlyingError for deepestUnderlyingError") {
                expect(moyaError.deepestUnderlyingError).to(matchError(TestLevelTwoUnderlyingError(input: "a")))
            }
            it("should return testUnderlyingError for orUnderlyingError()") {
                expect(moyaError.orUnderlyingError()).to(matchError(testUnderlyingError))
            }
            it("should return TestLevelTwoUnderlyingError for orDeepestUnderlyingError()") {
                expect(moyaError.orDeepestUnderlyingError()).to(matchError(TestLevelTwoUnderlyingError(input: "a")))
            }
        }

        describe("MoyaError which is not underlying") {

            let moyaError = MoyaError.requestMapping("test")

            it("should return nil for underlyingError") {
                expect(moyaError.underlyingError).to(beNil())
            }
            it("should return nil for deepestUnderlyingError") {
                expect(moyaError.deepestUnderlyingError).to(beNil())
            }
            it("should return moyaError for orUnderlyingError()") {
                expect(moyaError.orUnderlyingError()).to(matchError(moyaError))
            }
            it("should return moyaError for orDeepestUnderlyingError()") {
                expect(moyaError.orDeepestUnderlyingError()).to(matchError(moyaError))
            }
        }
    }
}

private struct TestUnderlyingError: Error, Equatable {

    let message: String
    let error: TestLevelOneUnderlyingError

    init(input: String) {
        self.message = "Error \(input)"
        self.error = .underlying(TestLevelTwoUnderlyingError(input: input))
    }
}

extension TestUnderlyingError: HasUnderlyingError {

    var underlyingError: Error? {
        return error
    }
}

private enum TestLevelOneUnderlyingError: Error {
    case normal
    case underlying(Error)
}

extension TestLevelOneUnderlyingError: HasUnderlyingError {

    var underlyingError: Error? {
        guard case .underlying(let error) = self else { return nil }
        return error
    }
}

extension TestLevelOneUnderlyingError: Equatable {

    static func == (lhs: TestLevelOneUnderlyingError, rhs: TestLevelOneUnderlyingError) -> Bool {
        switch (lhs, rhs) {
        case (.normal, .normal):
            return true
        case (.normal, .underlying), (.underlying, .normal):
            return false
        case (.underlying(let lhsError), .underlying(let rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)
        }
    }
}

private struct TestLevelTwoUnderlyingError: Error, Equatable {

    let message: String

    init(input: String) {
        self.message = "Deep error \(input)"
    }
}
