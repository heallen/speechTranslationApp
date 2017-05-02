//
//  LanguageData.swift
//  translator
//
//  Created by Allen He on 4/25/17.
//  Copyright © 2017 Allen He. All rights reserved.
//

import Foundation

class LanguageData{
    
    static var languages : [String] = ["English", "Spanish", "French", "Chinese", "German", "Italian", "Russian", "Japanese", "Korean"]
    static var languageCodes : [String] = ["en", "es", "fr", "zh", "de", "it", "ru", "ja", "ko"]
    static var languageCodesRegional : [String] = ["en-US", "es-ES", "fr-FR", "zh-CN", "de-DE", "it-IT", "ru-RU", "ja-JP", "ko-KR"]
    
    static func getLanguages() -> [String] {
        return languages
    }
    
    static func getLanguageCodes() -> [String] {
        return languageCodes
    }
    
    static func getLanguageCodesRegional() -> [String] {
        return languageCodesRegional
    }
}
