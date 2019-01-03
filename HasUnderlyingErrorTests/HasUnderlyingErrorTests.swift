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
@testable import HasUnderlyingError

class HasUnderlyingErrorSpec: QuickSpec {

    override func spec() {

        describe("Action which return value") {
            let scheduler: TestScheduler = TestScheduler(initialClock: 0)
            let disposeBag: DisposeBag = DisposeBag()
            let element: TestableObserver<String> = scheduler.createObserver(String.self)
            let secondElement: TestableObserver<String> = scheduler.createObserver(String.self)
            let trigger = PublishRelay<Void>()
            let action = Action<String, String> { Observable.just($0).sample(trigger) }
            let underlyingError: TestableObserver<Error> = scheduler.createObserver(Error.self)
            let deeplyUnderlyingError: TestableObserver<Error> = scheduler.createObserver(Error.self)

            context("execute while executing") {

                action.underlyingError
                    .bind(to: underlyingError)
                    .disposed(by: disposeBag)

                action.deeplyUnderlyingError
                    .bind(to: deeplyUnderlyingError)
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
                it("should not emit any deeplyUnderlyingError") {
                    expect(deeplyUnderlyingError.events.count).to(equal(0))
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
            var deeplyUnderlyingError: TestableObserver<Error>!

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
                deeplyUnderlyingError = scheduler.createObserver(Error.self)

                action.underlyingError
                    .bind(to: underlyingError)
                    .disposed(by: disposeBag)

                action.deeplyUnderlyingError
                    .bind(to: deeplyUnderlyingError)
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

                it("should emit only one deeplyUnderlyingError") {
                    expect(deeplyUnderlyingError.events.count).to(equal(1))
                    expect(deeplyUnderlyingError.events.first?.time).to(equal(30))
                    expect(deeplyUnderlyingError.events.first?.value.element).to(matchError(TestDeeplyUnderlyingError(input: "a")))
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

                it("should emit only one deeplyUnderlyingError") {
                    expect(deeplyUnderlyingError.events.count).to(equal(1))
                    expect(deeplyUnderlyingError.events.first?.time).to(equal(30))
                    expect(deeplyUnderlyingError.events.first?.value.element).to(matchError(TestDeeplyUnderlyingError(input: "a")))
                }
            }
        }
    }
}

private struct TestUnderlyingError: Error, Equatable {

    let message: String
    let error: TestDeeplyUnderlyingError

    init(input: String) {
        self.message = "Error \(input)"
        self.error = TestDeeplyUnderlyingError(input: input)
    }
}

extension TestUnderlyingError: HasUnderlyingError {

    var underlyingError: Error? {
        return error
    }
}

private struct TestDeeplyUnderlyingError: Error, Equatable {

    let message: String

    init(input: String) {
        self.message = "Deep error \(input)"
    }
}
