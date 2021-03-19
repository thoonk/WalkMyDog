//
//  Constants.swift
//  WalkMyDog
//
//  Created by 김태훈 on 2021/02/16.
//

import Foundation

struct C {
    static let apiKey = "APIKey"
    static let baseUrl = "https://api.openweathermap.org/data/2.5"
    
    struct Cell {
        static let weather = "weatherCell"
        static let puppy = "puppyCell"
        static let profile = "puppyProfileCell"
        static let record = "recordCell"
        static let check = "checkPuppyCell"
        static let species = "speciesCell"
    }
    
    struct Segue {
        static let homeToSetting = "fromHomeToSetting"
        static let settingToEdit = "fromSettingToEdit"
        static let homeToRecord = "fromHomeToRecord"
        static let recordToEdit = "fromRecordToEdit"
        static let checkToEdit = "fromCheckToEdit"
        static let editToSearch = "fromEditToSearch"
    }
    
    struct PuppyInfo {
        static let species = [
            "직접 입력", "골든 리트리버", "골든 두들", "그레이 하운드", "그레이트 데인", "그레이트 피레니즈", "그린란드견", "기슈견", "까나리오",
            "나폴리탄 마스티프", "뉴기니고산개", "뉴펀들랜드",
            "닥스훈트", "달마시안", "도고 아르헨티노", "도베르만 핀셔", "도사견", "동경이",
            "라사압소", "라페이로 도 알렌테조", "래브라도 리트리버", "레온베르거", "로트와일러", "리트리버",
            "마스티프", "말티즈", "맨체스터 테리어", "미니어쳐 불테리어", "미니어처 슈나우저", "미니어처 핀셔",
            "바셋 하운드", "버니즈 마운틴 독","베들링턴 테리어","벨지언 쉽독","보더 콜리","보르도 마스티프","보르조이","보비에 드 플랜더스",
            "보스턴 테리어","복서","불개","불도그","불리 쿠타","불마스티프","불테리어","브리어드","블러드 하운드","비글","비숑 프리제", "빠삐용",
            "사모예드","사플라니낙","삽살개","샤페이","세인트 버나드","세터","셔틀랜드 십독","솔로이츠 쿠인틀레","스코티쉬 테리어","스키퍼키",
            "스태퍼드셔 불테리어","스피츠","시바견","시베리안 허스키","시추","시코쿠견","실키 테리어",
            "아메리칸 불리","아메리칸 스태퍼드셔 테리어","아이디","아이리시 울프하운드","아키타견","아펜핀셔","아프간 하운드","알래스칸 말라뮤트",
            "알래스칸 클리카이","에스트렐라 마운틴 독","오브차카","올드 잉글리시 십독","요크셔 테리어","웨스트 하이랜드 화이트테리어","웰시 코기",
            "재패니즈 스피츠","재패니즈 친","잭 러셀 테리어","저먼 셰퍼드","제주개","진돗개",
            "차우차우", "치와와",
            "테리어", "티베탄 마스티프","티베탄 테리어",
            "파라오 하운드","패터데일 테리어","퍼그","페키니즈","포메라니안","포인터","폭스 테리어","폼피츠","푸들","푸미","풀리","풍산개","프렌치 불도그",
            "필라 브라질레이로","핏 불 테리어",
            "하바니즈","해리어"
            ]
    }
}
 
