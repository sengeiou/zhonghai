
//
//  KDTextView.swift
//  kdweibo
//
//  Created by Darren Zheng on 16/5/27.
//  Copyright © 2016年 www.kingdee.com. All rights reserved.
//

/**
 富文本控件
 
 支持：
 富文本展示和点击
 聊天气泡样式（子集）的便捷方法
 
 用例:
 cell.contentTextView.attributedText = KDRichTextView.renderedText(text, patternOptionSet: [.Emotion], font: FS3, textColor: FC1)
 
 */
class KDRichTextView: UITextView {
    
    // 关键字点击回调
    var onKeywordTap: ((_ linkPrefix: String, _ keyword: String) -> Void)?
    
    // 关键字长按回调
    var onLongPress: ((_ gestureRecognizer: UILongPressGestureRecognizer) -> Void)?
    
    // 无视
    override init(frame: CGRect, textContainer: NSTextContainer?) { super.init(frame: frame, textContainer: textContainer) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    convenience init() {
        self.init(frame: CGRect.zero, textContainer: nil)
        // Act like a UILabel
        textContainer.lineFragmentPadding = 0
        textContainerInset = UIEdgeInsets.zero
        bounces = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isOpaque = true
        isEditable = false
        isSelectable = true
        isUserInteractionEnabled = true
        delegate = self
        isScrollEnabled = false
    }
    
    // 根据自身内容算高，默认打开，若要自己计算高度，则在初始化后自行关闭
    func selfSizing(_ enable: Bool) {
        isScrollEnabled = !enable
    }
    
    func setNumberOflines(_ lineCount: Int) {
        textContainer.maximumNumberOfLines = lineCount
    }
    
    // 根据keyword构造，富文本系统消息用
    @objc class func renderedText(_ text: NSString,
                                  font: UIFont,
                                  textColor: UIColor,
                                  keyword: String?) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text as String)
        attributedString.dz_setFont(font)
        attributedString.dz_setTextColor(textColor)
        attributedString.dz_setTextAlignment(.center)
        if KDString.isSolidString(keyword) {
            text.dz_ranges(of: keyword).forEach {
                attributedString.dz_setLink(with: $0 as! NSRange, url: URL(fileURLWithPath: "\(KDRegex.SystemKeywordPrefix)\(keyword)"))
            }
        }
        return attributedString
    }
    
    // 聊天富文本构造
    @objc class func renderedText(_ text: NSString,
                                  patternOptionSet: KDRegexPatternOption,
                                  font: UIFont,
                                  textColor: UIColor) -> NSMutableAttributedString {
        let text = text.replacingOccurrences(of: "\t", with: "")
        let attributedString = NSMutableAttributedString(string: text)
        // 处理表情
        while let result = KDRegex.firstMatchEmotionInText(attributedString.string)?.results.first {
            let code = (attributedString.string as NSString).substring(with: result.range)
            let name = KDExpressionCode.codeString(toImageName: code)
            if KDString.isSolidString(name) {
                attributedString.dz_setImage(withName: name, range: result.range, font: font)
            } else {
                break
            }
        }
        
        attributedString.dz_setFont(font)
        attributedString.dz_setTextColor(textColor)
        // 处理关键字
        for match in KDRegex.matchesInText(attributedString.string, patternOptionSet: patternOptionSet) {
            switch match.pattern {
            case KDRegexPatternOption.at:
                for result in match.results {
                    if let keyword: NSString = KDString.substringWithNSRange(result.range, text: attributedString.string) as! NSString {
                        var pureKeyword = keyword
                        if keyword.hasPrefix("@") {
                            pureKeyword = (keyword as NSString).substring(from: 1) as NSString
                        }
                        let url = URL(fileURLWithPath: "\(KDRegex.AtPrefix)\(pureKeyword)")
                        if result.range.location + result.range.length <= (text as NSString).length {
                            attributedString.dz_setLink(with: result.range, url:url)
                        }
                    }
                }
            case KDRegexPatternOption.URL:
                for result in match.results {
                    if let keyword = KDString.substringWithNSRange(result.range, text: attributedString.string) {
                        let url = URL(fileURLWithPath: "\(KDRegex.URLPrefix)\(keyword)")
                        attributedString.dz_setLink(with: result.range, url:url)
                    }
                }
            case KDRegexPatternOption.phone:
                for result in match.results {
                    if let keyword = KDString.substringWithNSRange(result.range, text: attributedString.string) {
                        let url = URL(fileURLWithPath: "\(KDRegex.PhonePrefix)\(keyword)")
                        attributedString.dz_setLink(with: result.range, url:url)
                    }
                }
            case KDRegexPatternOption.keyword:
                for result in match.results {
                    if let keyword = KDString.substringWithNSRange(result.range, text: attributedString.string) {
                        let url = URL(fileURLWithPath: "\(KDRegex.KeywordPrefix)\(keyword)")
                        attributedString.dz_setLink(with: result.range, url:url)
                    }
                }
            default:
                break
            }
        }
        return attributedString
    }
}

extension KDRichTextView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        let onTapURL = {
            if let decodeText = URL.absoluteString.removingPercentEncoding {
                let filePathHeader = "file:///"
                
                var contentText = decodeText as NSString
                
                if decodeText.hasPrefix(filePathHeader) {
                    contentText = (decodeText as NSString).substring(from: filePathHeader.characters.count) as NSString
                }
                
                var keyword: String?
                var linkPrefix: String?
                if contentText.hasPrefix(KDRegex.KeywordPrefix) {
                    keyword = (contentText as NSString).substring(from: KDRegex.KeywordPrefix.characters.count)
                    linkPrefix = KDRegex.KeywordPrefix
                } else if contentText.hasPrefix(KDRegex.AtPrefix) {
                    keyword = (contentText as NSString).substring(from: KDRegex.AtPrefix.characters.count)
                    linkPrefix = KDRegex.AtPrefix
                } else if contentText.hasPrefix(KDRegex.PhonePrefix) {
                    keyword = (contentText as NSString).substring(from: KDRegex.PhonePrefix.characters.count)
                    linkPrefix = KDRegex.PhonePrefix
                } else if contentText.hasPrefix(KDRegex.URLPrefix) {
                    keyword = (contentText as NSString).substring(from: KDRegex.URLPrefix.characters.count)
                    linkPrefix = KDRegex.URLPrefix
                } else if contentText.hasPrefix(KDRegex.SystemKeywordPrefix) {
                    keyword = (contentText as NSString).substring(from: KDRegex.SystemKeywordPrefix.characters.count)
                    linkPrefix = KDRegex.SystemKeywordPrefix
                } else if contentText.isEqual(to: ASLocalizedString("Notice_Quick_Create")) {
                    keyword = contentText as String
                    linkPrefix = KDRegex.CustomKeywordPrefix
                }
                
                if let linkPrefix = linkPrefix, let keyword = keyword {
                    self.onKeywordTap?(linkPrefix, keyword)
                }
            }
        }
        
        // ios 8+
        // check for long press event
        var isLongPress = false
        var longpressGesture: UILongPressGestureRecognizer?
        if let ges = textView.gestureRecognizers {
            for recognizer in ges {
                if recognizer is UILongPressGestureRecognizer {
                    if recognizer.state == UIGestureRecognizerState.began {
                        isLongPress = true
                        longpressGesture = recognizer as? UILongPressGestureRecognizer
                        
                    }
                }
            }
        }
        if isLongPress {
            if let longpressGesture = longpressGesture {
                onLongPress?(longpressGesture)
            }
        } else {
            onTapURL()
        }
        
        return false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        return false
    }
    
    // disable textview selectable
    override var canBecomeFirstResponder : Bool { return false }
    func textViewDidChangeSelection(_ textView: UITextView) {
        if NSEqualRanges(textView.selectedRange, NSMakeRange(0, 0)) == false {
            textView.selectedRange = NSMakeRange(0, 0);
        }
    }
    
    // 解决scrollEnable打开，tableViewCell的scroll事件被textView拦截，方式是检测点击的是不是关键字
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if #available(iOS 8.0, *) {
            var results = [Bool]()
            if let range = characterRange(at: point) {
                let start = range.start
                let end = range.end
                let startOffset = offset(from: beginningOfDocument, to: start)
                let endOffset = offset(from: beginningOfDocument, to: end)
                let nsrange = NSMakeRange(startOffset, endOffset - startOffset)
                attributedText.enumerateAttributes(in: nsrange, options: [], using: { (attris, range, stop) in
                    if attris[NSLinkAttributeName] != nil {
                        results += [true]
                    }
                })
            }
            return results.count > 0
        } else {
            return true
        }
    }
    
}
