//
//  CurrentAPIManager.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation
import Alamofire
import RxSwift

final class CurrentAPIManger {
    
    private enum URLType {
        case weather
        case pm
    }
    
    static let shared = CurrentAPIManger()
    private init() {}
    
    // MARK: - Request Current Weather
    /// FcstModel을 Observable타입으로 만들어 반환하는 함수
    func fetchWeatherData(lat: String, lon: String) -> Observable<WeatherCurrent> {
        return Observable.create() { emitter in
            let urlString = "\(self.createUrl(URLType.weather))&lat=\(lat)&lon=\(lon)"
            self.requestWeatherData(with: urlString) { result in
                switch result {
                case .success(let data):
                    emitter.onNext(data)
                case .failure(let err):
                    emitter.onError(err)
                }
            }
            return Disposables.create()
        }
    }
    
    /// alamofire를 사용해서 날씨 API를 호출하여 JSON 타입의 데이터를 얻는 함수
    private func requestWeatherData(
        with url: String,
        completion: @escaping (Result<WeatherCurrent, Error>) -> Void) {
        AF.request(url).responseJSON { response in
            switch response.result {
            case.success(let data):
                guard let weatherData = self.parseWeatherJSON(data) else { return }
                completion(.success(weatherData))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    /// JSON 타입의 데이터를 WeatherCurrent 모델로 디코딩 및 가공하는 함수
    private func parseWeatherJSON(_ data: Any) -> WeatherCurrent? {
        do {
            let weatherData = try JSONSerialization
                .data(withJSONObject: data, options: .prettyPrinted)
            let result = try JSONDecoder().decode(WeatherCurrentData.self, from: weatherData)
            let weather = WeatherCurrent(
                conditionId: result.weather[0].id,
                temperature: result.main.temp
            )
            return weather
            
        } catch {
            print("Current Weather JSON Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Request PM Weather
    /// PMModel을 Observable타입으로 만들어 반환하는 함수
    func fetchPMData(lat: String, lon: String) -> Observable<PMModel> {
        return Observable.create() { emitter in
            let urlString = "\(self.createUrl(URLType.pm))&lat=\(lat)&lon=\(lon)"
            self.requestPMData(with: urlString) { result in
                switch result {
                case .success(let data):
                    emitter.onNext(data)
                case .failure(let err):
                    emitter.onError(err)
                }
            }
            return Disposables.create()
        }
    }
    
    /// alamofire를 사용해서 미세먼지 API를 호출하여 JSON 타입의 데이터를 얻는 함수
    private func requestPMData(
        with url: String,
        completion: @escaping (Result<PMModel, Error>) -> Void) {
        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let data):
                guard let pmModel = self.parsePMJSON(data) else { return }
                completion(.success(pmModel))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    /// JSON 타입의 데이터를 PMData 모델로 디코딩 및 가공하는 함수
    private func parsePMJSON(_ data: Any) -> PMModel? {
        do {
            let pmData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let result = try JSONDecoder().decode(PMData.self, from: pmData)
            
            guard let jsonData = result.list.first else {
                return nil
            }

            let pmDate = Date(timeIntervalSince1970: jsonData.dt)
                .toLocalized(with: "KST", by: "day")
            let pm = PMModel(
                dateTime: pmDate,
                pm10: jsonData.components.pm10,
                pm25: jsonData.components.pm25
            )
            return pm
        } catch {
            print("Current PM JSON Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - URL
    /// URLType에 맞춰 baseUrl을 해당 URL로 만들어주는 함수
    private func createUrl(_ type: URLType) -> String {
        var urlString = C.baseUrl
        
        switch type {
        case .weather:
            urlString += "/weather?units=metric&"
        case .pm:
            urlString += "/air_pollution?"
        }
        urlString += "appid=\(C.apiKey)"
        
        return urlString
    }
}
