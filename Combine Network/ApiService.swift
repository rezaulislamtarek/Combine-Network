//
//  ApiService.swift
//  Combine Network
//
//  Created by Rezaul Islam on 30/1/24.
//

import Foundation
import Combine

class APIService {
    private var cancellables = Set<AnyCancellable>()
    /*
    func getJSON<T: Decodable>() -> Future<T, Error> {
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: "baseUrl+endpoint") else{
                return promise(.failure(NetworkError.invalidURL))
            }
            
            var req = URLRequest(url: url)
            req.allHTTPHeaderFields = getHeaders()
            
            URLSession.shared.dataTaskPublisher(for: req)
                .retry(2)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else{
                        throw NetworkError.responseError
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
            
        }
    }*/
    
    
    func fetctData<T : Decodable>(endpoint: String, type : T.Type) -> AnyPublisher<T, Error>{
        print("Fetching...")
         let url = URLRequest(url: URL(string: endpoint)!)
        return URLSession.shared.dataTaskPublisher(for: URL(string: endpoint)!)
            .tryMap({ (data: Data, response: URLResponse) in
                print("response")
                return data
            })
             //.map(\.data)
             .decode(type:  type.self, decoder: JSONDecoder())
             .receive(on: DispatchQueue.main)
             .eraseToAnyPublisher()
     }
    
    
    
     
    
    private func getHeaders() -> [String: String] {
            var headers: [String: String] = [:]
            headers["Content-Type"] = "application/json"
            headers["Accept"] = "application/json"
            headers["Platform"] = "iOS"
            headers["locale"] = "bn"
            headers["Authorization"] = "pref.getBearerToken()"
            headers["X-Fcm-Device-Token"] = "RHConstraints.FCM_TOKEN"
            return headers
        }
}


enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        }
    }
}
