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
    
    
    func fetctData<T : Decodable>(endpoint: String, type : T.Type) -> AnyPublisher<T, Error>{
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = getHeaders()
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ (data: Data, response: URLResponse) in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw NetworkError.badServerResponse
                }
                return data
            })
        
            .decode(type:  type.self, decoder: JSONDecoder())
            .retry(2)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func postData<T : Codable, R : Codable>(endpoint: String, requestBody: R? = nil,  type : T.Type) -> AnyPublisher<T, Error>{
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = getHeaders()
        do{
            request.httpBody = try JSONEncoder().encode(requestBody)
        }catch{
            return Fail(error: NetworkError.bodyPerseError)
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ (data: Data, response: URLResponse) in
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.responseError
                }
                if (200..<300).contains(httpResponse.statusCode){
                    return data
                }else{
                    if httpResponse.statusCode == 422{
                        throw NetworkError.validationError(data)
                    }
                    else {
                        throw NetworkError.unknown
                    }
                }
            })
            .decode(type:  type.self, decoder: JSONDecoder())
            .retry(2)
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
    case badServerResponse
    case responseError
    case unknown
    case bodyPerseError
    case validationError(Data)
}
 
