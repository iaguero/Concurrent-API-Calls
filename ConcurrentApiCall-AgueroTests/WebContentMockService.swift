//
//  WebContentMockService.swift
//  ConcurrentApiCall-AgueroTests
//
//  Created by ignacia on 08/08/2024.
//

import Foundation
import Combine
@testable import ConcurrentApiCall_Aguero

class WebContentMockService: WebContentServiceProtocol {
    func fetchWebContent(from url: String) -> AnyPublisher<String?, any Error> {
        guard let url = URL(string: url) else {
            return Result.failure(ErrorType.invalidUrl(tried: url)).publisher.eraseToAnyPublisher()
        }
        
        let mockHTMLContent = "<p> Compass Hello World </p>"
        return Result.success(mockHTMLContent).publisher.eraseToAnyPublisher()
    }
}
