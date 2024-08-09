//
//  WebContentViewModel.swift
//  ConcurrentApiCall-Aguero
//
//  Created by ignacia on 08/08/2024.
//

import Foundation
import Combine

class WebContentViewModel {
    var service: WebContentServiceProtocol
    var subscriptions = Set<AnyCancellable>()
    let wordCounterURL = "https://www.compass.com/about"
    let every10thCharURL = "https://www.compass.com/about"
    var wordCounterContent: String?
    var every10thCharContent: String?
    var every10thCharacters: [Character] = []
    
    let every10thAnswer = PassthroughSubject<String, Never>()
    @Published var isLoading: Bool = false
    @Published var wordCounterAnswer: [String]?
    @Published var showErrorAlert: Bool = false
    
    required init(service: WebContentServiceProtocol) {
        self.service = service
    }
    
    func didTapStarButton() {
        self.isLoading = true
        resetEvery10thCharacters()
        if (every10thCharContent == nil || wordCounterContent == nil) {
            getContentFormURL()
        } else {
            findEvery10thChar(from: every10thCharContent)
            wordCounter(from: wordCounterContent)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
            }
        }
    }
    
    func resetEvery10thCharacters() {
        every10thCharacters = []
    }
    
    func getContentFormURL() {
        let wordCounterService = service.fetchWebContent(from: wordCounterURL)
        let every10thCharService = service.fetchWebContent(from: every10thCharURL)
        
        Publishers.Zip(every10thCharService, wordCounterService)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self]  completion in
                guard let self = self else { return }
                self.isLoading = false
                if case .failure = completion {
                    self.showErrorAlert = true
                }
            }, receiveValue: { [weak self] (every10thCharContent, wordCounterContent) in
                guard let self = self else { return }
                self.every10thCharContent = every10thCharContent
                self.wordCounterContent = wordCounterContent
                self.findEvery10thChar(from: every10thCharContent)
                self.wordCounter(from: wordCounterContent)
            }).store(in: &subscriptions)
    }
    
    func findEvery10thChar(from content: String?) {
        guard let content = content  else {
            showErrorAlert = true
            return
        }
        
        for (index, char) in content.enumerated(){
            if (index >= 10) && (index % 10 == 0) {
                every10thCharacters.append(char)
            }
        }
        let answerString = every10thCharacters.map({$0.description}).joined(separator: " ")
        every10thAnswer.send(answerString)
    }
    
    func wordCounter(from content: String?) {
        guard let content = content  else {
            showErrorAlert = true
            return
        }
        
        wordCounterAnswer = content.components(separatedBy: .whitespacesAndNewlines)
    }
}
