//
//  NetworkService.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private init() { }
    
    func performRequest(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                completion(.success(data))
            } else {
                let error = NSError(domain: "NetworkService",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchImage(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        performRequest(url: url, completion: completion)
    }
}

