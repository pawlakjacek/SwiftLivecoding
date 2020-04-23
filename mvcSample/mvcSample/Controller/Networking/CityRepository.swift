//
//  CityRepository.swift
//  mvcSample
//
//  Created by Leszek Barszcz on 24/03/2020.
//  Copyright © 2020 lpb. All rights reserved.
//

import Foundation

struct CityRepository {
    static let address = "https://raw.githubusercontent.com/lutangar/cities.json/master/cities.json"

    static func getAllCities(_ completion: @escaping (([City]) -> Void)) {
        if let cities = PersistanceController.shared.fetch(City.self) {
            completion(cities)
            return
        }

        if let citiesURL = URL(string: address) {
            let datatask = URLSession.shared.dataTask(with: citiesURL) { data, response, error in
                guard let data = data,
                let contextKey = CodingUserInfoKey.context else {
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }

                do {
                    let decoder = JSONDecoder()

                    decoder.userInfo[contextKey] = PersistanceController.shared.context

                    let cities: [City] = try decoder.decode([City].self, from: data)
                    DispatchQueue.main.async {
                        PersistanceController.shared.save()
                        completion(cities)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            }
            datatask.resume()
        }
    }
}
