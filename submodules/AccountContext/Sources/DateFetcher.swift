//
//  DateFetcher.swift
//  _idx_AccountContext_B43244F8_ios_min9.0
//
//  Created by Andrey Buksha on 22.06.2022.
//

import Foundation
import SwiftSignalKit

public protocol DateFetcher {
    
    func fetchCurrentDate() -> Signal<Date?, NoError>
    
}


public final class DateFetcherImpl: DateFetcher {
    
    public init() {}
    
    public func fetchCurrentDate() -> Signal<Date?, NoError> {
        return .init { subsriber in
            let urlString = "http://worldtimeapi.org/api/timezone/Europe/Moscow"
            subsriber.putNext(nil)
            guard let url = URL(string: urlString) else {
                return ActionDisposable {}
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let dataTask = URLSession.shared.dataTask(with: request) { data, _, error in
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
                    jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                    do {
                        let dateResult = try jsonDecoder.decode(DateResult.self, from: data)
                        subsriber.putNext(dateResult.datetime)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            dataTask.resume()
            return ActionDisposable {}
        }
    }
    
}

fileprivate extension DateFetcherImpl {
    
    struct DateResult: Decodable {
        
        let datetime: Date
        
    }
    
}
