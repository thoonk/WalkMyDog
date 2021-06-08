//
//  FcstAPIManager.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation
import Alamofire
import RxSwift

final class FcstAPIManager {
    private enum URLType {
        case weather
        case pm
    }
    
    static let shared = FcstAPIManager()
    private init() {}
    
    // MARK: - combine Weather and PM Data
    /// FcstModel을 Observable타입으로 만들어 반환하는 함수
    func fetchFcstData(lat: String, lon: String) -> Observable<[FcstModel]> {
        return Observable.create() { emitter in
            self.combineWeatherAndPM(lat: lat, lon: lon) { result, err  in
                if err != nil {
                    emitter.onError(err!)
                } else{
                    emitter.onNext(result!)
                }
            }
            return Disposables.create()
        }
    }
    
    /// weather과 PM 데이터를 FcstModel에 합쳐서 넘기는 함수
    private func combineWeatherAndPM(
        lat: String,
        lon: String,
        completion: @escaping ([FcstModel]?, Error?) -> Void) {
        
        var fcst = [FcstModel]()
        let urlStringForWeather = "\(self.createUrl(URLType.weather))&lat=\(lat)&lon=\(lon)"
        self.requestFcstWeather(with: urlStringForWeather) { result in
            switch result {
            case .success(let data):
                for i in 0 ..< data.count {
                    fcst.append(FcstModel(weekWeather: data[i], weekPM: nil))
                }
            case .failure(let err):
                print("RequestError in weather")
                completion(nil, err)
            }
        }
        
        let urlStringForPM = "\(self.createUrl(URLType.pm))&lat=\(lat)&lon=\(lon)"
        self.requestPMData(with: urlStringForPM) { result in
            switch result {
            case .success(let data):
                for i in 0..<fcst.count {
                    fcst[i].weekPM = data[i]
                }
                completion(fcst, nil)
            case .failure(let err):
                print("RequestError in pm")
                completion(nil, err)
            }
        }
    }
    // MARK: - Forecast Weather
    /// alamofire를 사용해서 날씨 API를 호출하여 JSON 타입의 데이터를 얻는 함수
    private func requestFcstWeather(
        with url: String,
        completion: @escaping (Result<[WeatherFcst], Error>) -> Void) {
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
    
    /// JSON 타입의 데이터를 WeatherFcstData 모델로 디코딩 및 가공하는 함수
    private func parseWeatherJSON(_ data: Any) -> [WeatherFcst]? {
        do {
            let weatherData = try JSONSerialization
                .data(withJSONObject: data, options: .prettyPrinted)
            let result = try JSONDecoder().decode(WeatherFcstData.self, from: weatherData)
            var weathers: [WeatherFcst] = []
            
            // 8일치의 날씨 중 현재로부터 가까운 5일치 데이터만 사용
            for i in 0..<result.daily.count-3 {
                let currentData = result.daily[i]
                let weekDate: String = Date(timeIntervalSince1970: currentData.dt)
                    .toLocalized(with: result.timezone, by: "day")
                let minTemp = currentData.temp.min
                let maxTemp = currentData.temp.max
                let weatherId = currentData.weather[0].id
                
                let dailyWeather = WeatherFcst(
                    conditionId: weatherId,
                    minTemp: minTemp,
                    maxTemp: maxTemp,
                    dateTime: weekDate)
                weathers.append(dailyWeather)
            }
            return weathers
        } catch {
            print("Weather Fcst JSON Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Forecast PM
    /// alamofire를 사용해서 미세먼지 API를 호출하여 JSON 타입의 데이터를 얻는 함수
    private func requestPMData(
        with url: String,
        completion: @escaping (Result<[[PMModel]], Error>) -> Void) {
        AF.request(url).responseJSON { response in
            switch response.result {
            case.success(let data):
                guard let pmModel = self.parsePMJSON(data) else { return }
                completion(.success(pmModel))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    /// JSON 타입의 데이터를 PMData 모델로 디코딩 및 가공하는 함수
    private func parsePMJSON(_ data: Any) -> [[PMModel]]? {
        do {
            let pmData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let result = try JSONDecoder().decode(PMData.self, from: pmData)
            var pmDay: [PMModel] = []
            var pms: [[PMModel]] = []
            
            for i in 0..<result.list.count {
                let dt = Date(timeIntervalSince1970: result.list[i].dt)
                    .toLocalized(with: "KST", by: "normal")
                let time = dt.split(separator: " ")
                let pm10 = result.list[i].components.pm10
                let pm25 = result.list[i].components.pm25
                
                if pmDay.count == 3 {
                    pms.append(pmDay)
                    pmDay = []
                }
                
                if dt >= Date().toLocalized(with: "KST", by: "short") {
                    if time[1] == "09:00" || time[1] == "14:00" || time[1] == "19:00" {
                        let pm = PMModel(dateTime: dt, pm10: pm10, pm25: pm25)
                        pmDay.append(pm)
                    }
                }
            }
            
            // 4일치만 줄 때 대비하여 더미 데이터 추가
            if pms.count == 4 {
                for _ in 0..<3 {
                    let pm = PMModel(dateTime: "-", pm10: -0.1234, pm25: -0.1234)
                    pmDay.append(pm)
                }
                pms.append(pmDay)
            }
            
            return pms
        } catch {
            print("PM Fcst JSON Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - URL
    /// URLType에 맞춰 baseUrl을 해당 URL로 만들어주는 함수
    private func createUrl(_ type: URLType) -> String {
        var urlString = C.baseUrl
        
        switch type {
        case .weather:
            urlString += "/onecall?units=metric&exclude=hourly,minutely,current&"
        case .pm:
            urlString += "/air_pollution/forecast?"
        }
        urlString += "appid=\(C.apiKey)"
        
        return urlString
    }
}
