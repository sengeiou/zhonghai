//
//  KDRegex.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/19.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

struct KDRegexMatchModel {
    var pattern: KDRegexPatternOption
    var results: [NSTextCheckingResult]
}

final class KDRegex: NSObject {
    
    // 通用正则汇总，可扩展
    fileprivate static let KDRegexPatternEmotion = "\\[[^\\[\\]]+\\]"
    fileprivate static let KDRegexPatternAt = "[@]+(\\w|[-|.])*"
    fileprivate static let KDRegexPatternInvalidUrl = "\\d{1,3}.\\d{1,3}.\\d{1,3}.\\d{1,3}"
    fileprivate static let KDRegexPatternKeyword = "[今明后]天|[上中下]午|[早晚]上|开会"
    fileprivate static let KDRegexPatternNumberOnly = "^[0-9]*$"
    
    // link prefix, 点击用区分头
    static let URLPrefix = "url:"
    static let PhonePrefix = "tel:"
    static let KeywordPrefix = "kwd:"
    static let AtPrefix = "at:"
    static let SystemKeywordPrefix = "syskwd:"
    static let CustomKeywordPrefix = "customkwd:"

}

// MARK: 通用方法
private extension KDRegex {
    
    class func matchPattern(_ pattern: String?, text: String?) -> [NSTextCheckingResult] {
        guard let pattern = pattern, let text = text
            else { return [NSTextCheckingResult]() }
        return try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0)).matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
    }
    
    class func firstMatchPattern(_ pattern: String?, text: String?) -> NSTextCheckingResult? {
        guard let pattern = pattern, let text = text
            else { return nil }
        return try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0)).firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
    }
    
}

// MARK: 杂集 Miscellaneous
extension KDRegex {
    
    // 是否都为数字
    @objc class func isNumberOnlyInText(_ text: String?) -> Bool {
        guard let text = text, text.characters.count > 0
            else { return false }
        return matchPattern(KDRegex.KDRegexPatternNumberOnly, text: text).count > 0
    }
}

// MARK: 聊天气泡相关
extension KDRegex {
    
    // 检测 特定Type
    class func matchesInText(_ text: String?, patternOptionSet: KDRegexPatternOption) -> [KDRegexMatchModel] {
        var array = [KDRegexMatchModel]()
        guard let text = text
            else { return array }
        
        let atResults = atResultsInText(text)
        if patternOptionSet.contains(KDRegexPatternOption.at) && atResults.count > 0 {
            array += [KDRegexMatchModel(pattern:KDRegexPatternOption.at, results: atResults)]
        }

        var urlResults = urlResultsInText(text)
        for atResult in atResults {
            for urlResult in urlResults {
                if NSIntersectionRange(atResult.range, urlResult.range).location != NSNotFound {
                    if let idx = urlResults.index(of: urlResult) {
                        urlResults.remove(at: idx)
                    }
                }
            }
        }
        
        if patternOptionSet.contains(KDRegexPatternOption.URL) && urlResults.count > 0 {
            array += [KDRegexMatchModel(pattern:KDRegexPatternOption.URL, results: urlResults)]
        }
        
//        var phoneResults = phoneNumberResultsInText(text)
//        for atResult in atResultsInText(text) {
//            for phoneResult in phoneNumberResultsInText(text) {
//                if NSIntersectionRange(atResult.range, phoneResult.range).location != NSNotFound {
//                    if let idx = phoneResults.indexOf(phoneResult) {
//                        phoneResults.removeAtIndex(idx)
//                    }
//                }
//            }
//        }
//        
        
        let phoneResults = phoneNumberResultsInText(text)
        if patternOptionSet.contains(KDRegexPatternOption.phone) && phoneResults.count > 0 {
            array += [KDRegexMatchModel(pattern:KDRegexPatternOption.phone, results: phoneResults)]
        }

        let emotionResults = emotionResultsInText(text)
        if patternOptionSet.contains(KDRegexPatternOption.emotion) && emotionResults.count > 0  {
            array += [KDRegexMatchModel(pattern:KDRegexPatternOption.emotion, results: emotionResults)]
        }
        
        let keywordResults = keywordResultsInText(text)
        if patternOptionSet.contains(KDRegexPatternOption.keyword) && keywordResults.count > 0  {
            array += [KDRegexMatchModel(pattern:KDRegexPatternOption.keyword, results: keywordResults)]
        }
        return array
    }
    
    class func firstMatchEmotionInText(_ text: String?) -> KDRegexMatchModel? {
        guard let text = text
            else { return nil }
        if let match = firstMatchPattern(KDRegexPatternEmotion, text: text) {
            return KDRegexMatchModel(pattern:KDRegexPatternOption.emotion, results: [match])
        } else {
            return nil
        }
    }
    
    // 检测 电话号
    class func phoneNumberResultsInText(_ text: String?) -> [NSTextCheckingResult] {
        guard let text = text
            else { return [NSTextCheckingResult]() }
        let input = text
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        return detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
    }
    
    // 检测 表情
    class func emotionResultsInText(_ text: String?) -> [NSTextCheckingResult] {
        return matchPattern(KDRegexPatternEmotion, text: text)
    }
    
    // 检测 URL
    class func urlResultsInText(_ text: String?) -> [NSTextCheckingResult] {
        guard let text = text
            else { return [NSTextCheckingResult]() }
        let input = text
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        var matches = [NSTextCheckingResult]()
        for match in detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count)) {
            let urlString = (text as NSString).substring(with: match.range)
            if let firstComp = KDURLHelper.findHost(urlString) {
                if matchPattern(KDRegexPatternInvalidUrl, text: firstComp).count == 0 {
                    matches += [match]
                }
            }
        }
        return matches
    }
    
    // 检测 @提及
    class func atResultsInText(_ text: String?) -> [NSTextCheckingResult] {
        return matchPattern(KDRegexPatternAt, text: text)
    }
    
    // 检测 关键字
    class func keywordResultsInText(_ text: String?) -> [NSTextCheckingResult] {
        return matchPattern(KDRegexPatternKeyword, text: text)
    }
}
