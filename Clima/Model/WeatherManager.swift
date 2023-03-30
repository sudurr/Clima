//
//  WeatherManager.swift
//  Clima
//
//  Created by Судур Сугунушев on 07.12.2022.
//  Copyright © 2022 Sudur Sugunushev. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=d93f06f5dbff91bbb2f490c1a3442668&units=metric"
    
    var delegate: WeatherManagerDelegate?
   
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString:String){
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    print(error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                        }
                    }
                }
                task.resume()
            }
        }
        
        func parseJSON(_ weatherData: Data) -> WeatherModel? {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
                let id = decodedData.weather[0].id
                let name = decodedData.name
                let temp = decodedData.main.temp
                
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                return weather
                            
            } catch {
                delegate?.didFailWithError(error: error)
                print(error)
                return nil
            }
        }
    }
