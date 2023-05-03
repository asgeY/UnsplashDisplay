//
//  UnsplashAPI.swift
//  UnsplashDisplay
//
//  Created by AsgeY on 4/26/23.
//

import Foundation
import SwiftUI

import Foundation

struct UnsplashAPI {
    static let apiKey = "YOUR API KEY"
    private static let baseURL = "https://api.unsplash.com"
    
    static func fetchImages(searchQuery: String? = nil, page: Int = 1, perPage: Int = 10, completion: @escaping ([UnsplashImage]) -> Void) {
        var urlString = "\(baseURL)/photos?client_id=\(apiKey)&page=\(page)&per_page=\(perPage)"
        if let searchQuery = searchQuery {
            urlString = "\(baseURL)/search/photos?client_id=\(apiKey)&query=\(searchQuery)&page=\(page)&per_page=\(perPage)"
        }

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching images: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Error: No data received")
                return
            }

            do {
                if searchQuery != nil {
                    let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                    DispatchQueue.main.async {
                        completion(searchResult.results)
                    }
                } else {
                    let photos = try JSONDecoder().decode([UnsplashImage].self, from: data)
                    DispatchQueue.main.async {
                        completion(photos)
                    }
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    
}


struct UnsplashImage: Decodable {
    let urls: Urls
    let user: User
    var title: String? {
        return user.name
    }
    
    var image: UIImage? = nil
    
    struct Urls: Codable {
        let small: String
    }
    
    struct User: Codable {
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case urls
        case user
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        urls = try container.decode(Urls.self, forKey: .urls)
        user = try container.decode(User.self, forKey: .user)
    }
}



struct URLS: Codable {
    let small: String
}

struct SearchResult: Decodable {
    let results: [UnsplashImage]
}

