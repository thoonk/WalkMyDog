//
//  FcstModel.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation

/// 날씨와 미세먼지 예보를 Observable로 합쳐 보내기 위한 모델
struct FcstModel {
    var weekWeather: WeatherFcst?
    var weekPM: [PMModel]?
}
