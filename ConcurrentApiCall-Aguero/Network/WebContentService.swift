//
//  WebContentService.swift
//  ConcurrentApiCall-Aguero
//
//  Created by ignacia on 08/08/2024.
//

import Foundation
import Combine

enum ErrorType: Error
{
    case network(url: String, description: String)
    case invalidUrl(tried: String)
    case error(title: String? = nil, description: String? = nil)
}

protocol WebContentServiceProtocol {
    func fetchWebContent(from url: String) -> AnyPublisher<String?, Error>
}

class WebContentService: WebContentServiceProtocol {
    func fetchWebContent(from stringURL: String) -> AnyPublisher<String?, Error> {
        guard let url = URL(string: stringURL) else {
            return Fail(error: ErrorType.invalidUrl(tried: stringURL)).eraseToAnyPublisher()
        }
        let request = URLRequest(url: url)
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { element -> String? in
                guard let response = element.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw ErrorType.network(url: url.absoluteString, description: "Bad request")
                }
                return String(data: element.data, encoding: .utf8)
            }
            .mapError({ error in
                return ErrorType.network(url: url.absoluteString, description: error.localizedDescription)
            })
            .eraseToAnyPublisher()
    }
}
