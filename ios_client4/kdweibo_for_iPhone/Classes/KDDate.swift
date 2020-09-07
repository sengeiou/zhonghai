//
//  DZDateHelper.swift
//  DZFoundation
//
//  Created by Darren Zheng on 16/5/2.
//  Copyright © 2016年 Darren Zheng. All rights reserved.
//


class KDDate: NSObject {
    
    
    class func timelapseAbsolute(_ fromeDate: Date?) -> TimeInterval {
        guard let fromeDate = fromeDate
            else { return -1 }
        let timeIntervalOffset = NSTimeZone(abbreviation: "HKT")!.secondsFromGMT
        let timeInterval = timeIntervalOffset - NSTimeZone.local.secondsFromGMT()
        let date = Date(timeIntervalSinceNow: TimeInterval(timeInterval))
        return abs(fromeDate.timeIntervalSince(date))
        //        return abs(fromeDateValue.timeIntervalSinceNow)
    }
    
    class func dateFromSendtime(_ sendTime: String?) -> Date? {
        guard let sendTimeValue = sendTime
            else { return nil }
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        var date = dateformatter.date(from: sendTimeValue)
        if date == nil {
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            date = dateformatter.date(from: sendTimeValue)
        }
        return date
    }
    
    // 1970 long -> Human readable date
    class func humanReadableDateFrom1970(_ sec: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: (sec / 1000))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateFormatter.locale = Locale.current
        let string = dateFormatter.string(from: date)
        return ContactUtils.xtDateFormatter(atTimeline: string)
    }
    
    // 此刻的NSDateComponents
    var currentDateComponents: DateComponents {
        return dateComponentsFromDate(Date())!
    }
    
    // NSDate -> NSDateComponents
    func dateComponentsFromDate(_ date: Date?) -> DateComponents? {
        guard let date = date
            else { return nil }
        return (Calendar.current as NSCalendar).components([
            .era,
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second,
            .weekday
            ], from: date)
    }
    
    // NSDateComponents -> NSDate
    func dateFromDateCompnents(_ components: DateComponents?) -> Date? {
        guard let components = components
            else { return nil }
        return Calendar.current.date(from: components)
    }
    
    // 判断两个日期是否同一天
    func isSameDays(_ date1: Date?, _ date2: Date?) -> Bool {
        guard let date1 = date1, let date2 = date2
            else { return false }
        let calendar = Calendar.current
        let comps1 = (calendar as NSCalendar).components([NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.day], from:date1)
        let comps2 = (calendar as NSCalendar).components([NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.day], from:date2)
        return (comps1.day == comps2.day) && (comps1.month == comps2.month) && (comps1.year == comps2.year)
    }
    
    /**
     计算明天/下周/几天后/几个小时后的日期， "周一 8:00"
     
     - parameter hourCount:       -
     - parameter minuteCount:     和hourCount配合，来表达几小时又几分钟后的时间
     - parameter hourInThatDay:   设定计算出来的那天的小时
     - parameter minuteInThatDay: 设定计算出来的那天的分钟
     - parameter showWeekday:     是否显示 “周一，周二..."
     
     - returns: ("周一 8:00", 相应的NSDate)
     */
    func next(baseDate: Date?, hourCount: Int, minuteCount: Int, hourInThatDay: Int?, minuteInThatDay: Int?, showWeekday: Bool) -> (title: String?, date: Date?) {
        guard let baseDate = baseDate
            else { return (nil, nil) }
        var comp = DateComponents()
        let currentCalendar = Calendar.current
        comp.hour = hourCount
        comp.minute = minuteCount
        if let targetDate = (currentCalendar as NSCalendar).date(byAdding: comp, to: baseDate, options: NSCalendar.Options(rawValue: 0)) {
            if var targetComp = dateComponentsFromDate(targetDate) {
                if let hourInThatDay = hourInThatDay {
                    targetComp.hour = hourInThatDay
                }
                if let minuteInThatDay = minuteInThatDay {
                    targetComp.minute = minuteInThatDay
                }
                let weekdayString: String?
                guard let weekday = targetComp.weekday else {
                    return (nil, nil)
                }
                switch weekday {
                case 1:
                    weekdayString = "周日"
                case 2:
                    weekdayString = "周一"
                case 3:
                    weekdayString = "周二"
                case 4:
                    weekdayString = "周三"
                case 5:
                    weekdayString = "周四"
                case 6:
                    weekdayString = "周五"
                case 7:
                    weekdayString = "周六"
                default:
                    weekdayString =  nil
                }
                if let weekdayString = weekdayString {
                    return ((showWeekday ? "\(weekdayString) ": "") + "\(targetComp.hour ?? 0):"  + (targetComp.minute == 0 ? "00" : "\(targetComp.minute ?? 0)"), dateFromDateCompnents(targetComp))
                } else {
                    return (nil, nil)
                }
            }
        }
        return (nil, nil)
    }
    
}
