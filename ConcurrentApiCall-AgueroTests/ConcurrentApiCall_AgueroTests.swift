//
//  ConcurrentApiCall_AgueroTests.swift
//  ConcurrentApiCall-AgueroTests
//
//  Created by ignacia on 08/08/2024.
//

import XCTest
import Combine
@testable import ConcurrentApiCall_Aguero

final class ConcurrentApiCall_AgueroTests: XCTestCase {

    private var viewModel: WebContentViewModel!
    private var cancellable = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        viewModel = WebContentViewModel(service: WebContentMockService())
    }

    func testValidURLFetchWebContent() throws {
        let exp = expectation(description: "fetchWebContentValidURL")
        let validURL = "https://www.compass.com/about"
        viewModel.service.fetchWebContent(from: validURL)
            .sink { completion in
                if case .failure = completion {
                    XCTFail("Expected to be a success but got a failure with url \(validURL)")
                }
            } receiveValue: { response in
                XCTAssertNotNil(response)
                exp.fulfill()
            }
            .store(in: &cancellable)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testInvalidURLFetchWebContent() throws {
        let exp = expectation(description: "fetchWebContentInvalidURL")
        let invalidURL = ""
        viewModel.service.fetchWebContent(from: invalidURL)
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error.localizedDescription, ErrorType.invalidUrl(tried: invalidURL).localizedDescription)
                    exp.fulfill()
                }
            } receiveValue: { response in
                XCTFail("Expected to be a failure but got a success with url \(invalidURL)")
            }
            .store(in: &cancellable)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSuccesWordCounter() {
        let content = "<p> Compass Hello World </p>"
        
        viewModel.wordCounter(from: content)
        XCTAssertNotNil(viewModel.wordCounterAnswer)
        XCTAssertEqual(viewModel.wordCounterAnswer?.count, 5)
    }
    
    func testErrorContentNilWordCounter() {
        let content: String? = nil
        
        viewModel.wordCounter(from: content)
        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertNil(viewModel.wordCounterAnswer)
    }
    
    func testErrorContentNilfindEvery10thChar() {
        let content: String? = nil
        
        viewModel.findEvery10thChar(from: content)
        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertTrue(viewModel.every10thCharacters.isEmpty)
    }
    
    func testSuccesfindEvery10thChar() {
        let content = "<p> Compass Hello World </p>"
        let expectedResult = [Character("s"), Character("r")]
        viewModel.findEvery10thChar(from: content)
        XCTAssertEqual(viewModel.every10thCharacters.count, 2)
        XCTAssertEqual(viewModel.every10thCharacters, expectedResult)
    }
    
    func testEvery10thAnswerSubscription() {
        let exp = expectation(description: "every10thAnswerSubscription")
        let content = "<p> Compass Hello World </p>"
        let expectedResult = "s r"
        
        viewModel.every10thAnswer.sink { answer in
            XCTAssertNotNil(answer)
            XCTAssertEqual(answer, expectedResult)
            exp.fulfill()
        }
        .store(in: &cancellable)
        
        viewModel.findEvery10thChar(from: content)
        wait(for: [exp], timeout: 5)
    }
    
    func testWordCounterAnswerSubscription() {
        let exp = expectation(description: "wordCounterAnswerSubscription")
        let content = "<p> Compass Hello World </p>"
        viewModel.wordCounter(from: content)
        
        viewModel.$wordCounterAnswer.sink { answer in
            XCTAssertNotNil(answer)
            XCTAssertEqual(answer?.count, 5)
            exp.fulfill()
        }
        .store(in: &cancellable)
        
        
        wait(for: [exp], timeout: 5)
    }
    
    func testRestEvery10thCharacter() {
        viewModel.resetEvery10thCharacters()
        XCTAssertTrue(viewModel.every10thCharacters.isEmpty)
    }
    
    func testShowErrorAlertSubscription() {
        let exp = expectation(description: "showErrorAlertSubscription")
        let content: String? = nil
        viewModel.wordCounter(from: content)
        
        viewModel.$showErrorAlert.sink { showError in
            XCTAssertTrue(showError)
            exp.fulfill()
        }
        .store(in: &cancellable)
        
        
        wait(for: [exp], timeout: 5)
    }
    
    func testIsLoadingSubscription() {
        let exp = expectation(description: "isLoadingSubscription")
        
        viewModel.$isLoading.sink { showError in
            XCTAssertFalse(showError)
            exp.fulfill()
        }
        .store(in: &cancellable)
        
        
        wait(for: [exp], timeout: 5)
    }
    
    func testSuccessZIPGetContentFormURL() {
        let exp = expectation(description: "successZIPGetContentFormURL")
        let validURL = "validURL"
        let wordCounterService = viewModel.service.fetchWebContent(from: validURL)
        let every10thCharService = viewModel.service.fetchWebContent(from: validURL)
        
        Publishers.Zip(every10thCharService, wordCounterService)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected to be a succes but got a failure with url \(validURL)")
                }
            }, receiveValue: { (every10thCharContent, wordCounterContent) in
                XCTAssertNotNil(every10thCharContent)
                XCTAssertNotNil(wordCounterContent)
                exp.fulfill()
            }).store(in: &cancellable)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testErrorZIPGetContentFormURL() {
        let exp = expectation(description: "errorZIPGetContentFormURL")
        let invalidURL = ""
        let wordCounterService = viewModel.service.fetchWebContent(from: invalidURL)
        let every10thCharService = viewModel.service.fetchWebContent(from: invalidURL)
        
        Publishers.Zip(every10thCharService, wordCounterService)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTAssertNotNil(error)
                    exp.fulfill()
                }
            }, receiveValue: { (every10thCharContent, wordCounterContent) in
                XCTFail("Expected to be a failure but got a success with url \(invalidURL)")
            }).store(in: &cancellable)
        
        wait(for: [exp], timeout: 5)
    }
}
