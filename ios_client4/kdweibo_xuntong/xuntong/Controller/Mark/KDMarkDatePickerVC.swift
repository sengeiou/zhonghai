//
//  KDMarkDatePickerVC.swift
//  DZFoundation
//
//  Created by Darren Zheng on 16/4/27.
//  Copyright © 2016年 Darren Zheng. All rights reserved.
//
let  KD_APPNAME = "云之家"

func ASLocalizedString(_ key:String) -> String {
    let path = Bundle.main.path(forResource: UserDefaults.standard.string(forKey: "appLanguage"), ofType: "lproj")
    let str = Bundle.init(path: path!)?.localizedString(forKey: key, value: nil, table: "ASLocalized")
    return str!
}

import EventKit

let calendarTitle = KD_APPNAME
let calendarColor = UIColor(hexString: "3cbaff") // 3cbaff

final class KDMarkDatePickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    var buttonModels = [KDItem]()
    var calendar = KDCalendar()
    var dateHelper = KDDate()
    var model: KDMarkModel?
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(model: KDMarkModel) {
        self.init(nibName: nil, bundle: nil)
        self.model = model
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var eventTitle: String {
        if let model = model {
            switch model.type {
            case .image:
                return "图片-\(model.title ?? "")"
            case .link:
                if let icon = model.icon {
                    if !icon.lowercased().hasPrefix("http") {
                        return "\(model.header ?? "")"
                    }
                }
                fallthrough
            case .text: fallthrough
            default:
                return "\(model.text ?? "")"
            }
        } else {
            return ""
        }
    }
    
    var currentCreatedEvent: EKEvent?
    lazy var saveEventAlertView: UIAlertView = {
        let alertView = UIAlertView(title: ASLocalizedString("Mark_setsuccess"), message: ASLocalizedString("Mark_gotocalendar"), delegate: self, cancelButtonTitle:  ASLocalizedString("Global_Cancel"), otherButtonTitles: ASLocalizedString("Mark_viewcheck"))
        return alertView
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.kdBackgroundColor1()
        title = ASLocalizedString("Mark_setAlert")
        
        calendar.requestAccess { succ in
            if succ {
                self.calendar.createCalendar(title: calendarTitle, color: calendarColor)
            }
        }
        
        let currentDateCompnents = dateHelper.currentDateComponents
        let tomorrow8AMTuple = dateHelper.next(baseDate: Date(), hourCount: 24, minuteCount: 0, hourInThatDay: 8, minuteInThatDay: 0, showWeekday: true)
        let nextMonday8AMTuple = dateHelper.next(baseDate: Date(), hourCount: (9 - currentDateCompnents.weekday!) * 24, minuteCount: 0, hourInThatDay: 8, minuteInThatDay: 0, showWeekday: true)
        print(currentDateCompnents.minute)
        var laterTodayHourCount = 0
        var laterTodayMinuteCount = 0
        if currentDateCompnents.minute! < 30 {
            laterTodayHourCount = 3
            laterTodayMinuteCount = 30
        } else {
            laterTodayHourCount = 4
            laterTodayMinuteCount = 0
        }
        let laterTodayTuple = dateHelper.next(baseDate: Date(), hourCount: laterTodayHourCount, minuteCount: laterTodayMinuteCount, hourInThatDay: nil, minuteInThatDay: nil, showWeekday: false)
        
        var laterTodayButtonTitle = ""
        
        if dateHelper.isSameDays(Date(), laterTodayTuple.date) {
            laterTodayButtonTitle = ASLocalizedString("Mark_later")
        } else {
            laterTodayButtonTitle = ASLocalizedString("Mark_laterr")
        }
        
        func didPressLogic(_ startDate: Date?) {
            calendar.requestAccess { succ in
                if succ {
                    let event = EKEvent(eventStore: self.calendar.eventStore)
                    event.title = self.eventTitle
                    if let startDate = startDate {
                        event.startDate = startDate
                        event.alarms = [EKAlarm(absoluteDate: startDate)]
                        
                        if let endDate = self.dateHelper.next(baseDate: startDate, hourCount: 1, minuteCount: 0, hourInThatDay: nil, minuteInThatDay: nil, showWeekday: false).date {
                            event.endDate = endDate
                        }
                        
                        if let calendar = self.calendar.calendar {
                            event.calendar = calendar
                        }
                        
                        self.calendar.saveEvent(event)
                        self.currentCreatedEvent = event
                        
                        if let model = self.model, let currentCreatedEvent = self.currentCreatedEvent {
                            XTDataBaseDao.sharedDatabaseDaoInstance().insertMarkEvent(withMarkId: model.id, eventId: currentCreatedEvent.eventIdentifier)
                        }
                        self.saveEventAlertView.show()
                    }
                }
            }
        }
        buttonModels += [
            KDItem(title: laterTodayButtonTitle, subtitle: laterTodayTuple.title ?? "" , image: UIImage(named: "mark_tip_today"), highlightedImage: nil, onPress: { sender in
                didPressLogic(laterTodayTuple.date)
                KDEventAnalysis.eventCountly(event_mark_notify_today);
//                KDEventAnalysis.event(mark_set_alarm, attributes: [labe_mark_set_alarm_type: labe_mark_set_alarm_type_later_today])
            }),
//            KDItem(title: "明天", subtitle: tomorrow8AMTuple.title ?? "" , image: UIImage(named: "mark_tip_tomorrow"), highlightedImage: nil, onPress: { sender in
////                KDEventAnalysis.event(mark_set_alarm, attributes: [labe_mark_set_alarm_type: labe_mark_set_alarm_type_eightAM_tomorrow])
//                didPressLogic(tomorrow8AMTuple.date)
//            }),
//            KDItem(title: "下周", subtitle: nextMonday8AMTuple.title ?? "" , image: UIImage(named: "mark_tip_nextweek"), highlightedImage: nil, onPress: { sender in
////                KDEventAnalysis.event(mark_set_alarm, attributes: [labe_mark_set_alarm_type: labe_mark_set_alarm_type_eightAM_next_monday])
//                didPressLogic(nextMonday8AMTuple.date)
//            }),
            KDItem(title: ASLocalizedString("Mark_selectDate"), subtitle: nil, image: UIImage(named: "mark_tip_select"), highlightedImage: nil, onPress: { sender in
//                KDEventAnalysis.event(mark_set_alarm, attributes: [labe_mark_set_alarm_type: labe_mark_set_alarm_type_choose])
                KDEventAnalysis.eventCountly(event_mark_notify_someday);
                let event = EKEvent(eventStore: self.calendar.eventStore)
                event.title = self.eventTitle
                if let calendar = self.calendar.calendar {
                    event.calendar = calendar
                }
                self.calendar.presentEventEditView(self, event: event) { event in
                    if let model = self.model, let currentCreatedEvent = event {
                        XTDataBaseDao.sharedDatabaseDaoInstance().insertMarkEvent(withMarkId: model.id, eventId: currentCreatedEvent.eventIdentifier)
                    }
                }})
        ]
        view.addSubview(tableView)
        
        tableView.mas_makeConstraints { make in
            make?.edges.equalTo()(self.tableView.superview!)?.with().insets()(UIEdgeInsets.zero)
            return()
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 用户去系统设置取消日历权限的防御
        calendar.requestAccess { succ in
            if !succ {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.kdBackgroundColor1()
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellId)
            cell!.backgroundColor = UIColor.white
        }
        let model = buttonModels[indexPath.row]
        cell!.textLabel?.text = model.title
        cell!.detailTextLabel?.text = model.subtitle
        cell!.imageView!.image = model.image
        
        if model.subtitle == nil {
            cell!.accessoryType = .disclosureIndicator
        } else {
            cell!.accessoryType = .none
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = buttonModels[indexPath.row]
        model.onPress?(nil)
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView == saveEventAlertView {
            if buttonIndex != alertView.cancelButtonIndex {
//                KDEventAnalysis.event(mark_set_alarm_alert, attributes: [label_mark_set_alarm_alert_type: label_mark_set_alarm_alert_type_true])
                if let event = self.currentCreatedEvent {
                    self.calendar.presentEventEditView(self, event: event) { event in
                        
                    }
                }
            } else {
//                KDEventAnalysis.event(mark_set_alarm_alert, attributes: [label_mark_set_alarm_alert_type: label_mark_set_alarm_alert_type_false])
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
}

