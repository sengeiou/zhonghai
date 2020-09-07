//
//  KDCalendar.swift
//  DZFoundation
//
//  Created by Darren Zheng on 16/4/25.
//  Copyright © 2016年 Darren Zheng. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class KDCalendar: NSObject {
    
    static let sharedInstance = KDCalendar()
    let eventStore = EKEventStore()
    var eventId: String?
    var calendar: EKCalendar?
    var eventEditViewCompletion: ((_ event: EKEvent?) -> Void)?
    
    func requestAccess(_ result: ((_ succ: Bool) -> Void)?) {
        eventStore.requestAccess(to: EKEntityType.event) { (succ, error) in
            if let result = result {
                DispatchQueue.main.async { () -> Void in
                    result(succ)
                }
            }
        }
    }
    
    func eventWithId(_ eventId: String?) -> EKEvent? {
        guard let eventId = eventId
            else { return nil }
        return eventStore.event(withIdentifier: eventId)
    }
    
    func createCalendar(title: String?, color: UIColor?) {
        guard let title = title, let color = color
            else { return }
        
        // 确保不反复创建
        if self.calendar == nil {
            let calendars = eventStore.calendars(for: EKEntityType.event)
            for cal in calendars {
                if cal.title == title {
                    calendar = (cal as EKCalendar)
                    break
                }
            }
        }
        
        if calendar == nil {
            calendar = EKCalendar(for: EKEntityType.event, eventStore: eventStore)
            calendar!.title = title
            calendar!.cgColor = color.cgColor
            calendar!.source = eventStore.defaultCalendarForNewEvents.source
            do {
                try eventStore.saveCalendar(calendar!, commit: true)
            } catch {
                print("error")
            }
        }
    }
    
    func saveEvent(_ title: String?, startDate: Date?, endDate: Date?, location: String?, alarm: EKAlarm?, allDay: Bool)  -> String? {
        guard let calendar = calendar
            else { return nil }
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        if let title = title {
            event.title = title
        }
        if let startDate = startDate {
            event.startDate = startDate
        }
        if let endDate = endDate {
            event.endDate = endDate
        }
        if let location = location {
            event.location = location;
        }
        if let alarm = alarm {
            event.addAlarm(alarm)
        }
        event.isAllDay = allDay
        do {
            try eventStore.save(event, span: EKSpan.thisEvent)
            return event.eventIdentifier
        } catch {
            return nil
        }
    }
    
    func saveEvent(_ event: EKEvent?) -> String? {
        guard let event = event
            else { return nil }
        do {
            try eventStore.save(event, span: EKSpan.thisEvent)
            return event.eventIdentifier
        } catch {
            return nil
        }
    }
    
    func tryRemove() -> Bool {
        do {
            guard eventId != nil && eventStore.event(withIdentifier: eventId!) != nil
                else { return false }
            try eventStore.remove(eventStore.event(withIdentifier: eventId!)!, span: EKSpan.thisEvent)
            return true
        } catch {
            return false
        }
    }
    
    func verifyUserEventAuthorization() {
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
        case .authorized: print("Authorized")
        case .denied: print("Denied")
        case .notDetermined: print("NotDetermined")
        case .restricted: print("Restricted")
        }
    }
    
}

// MARK: - 事件编辑器
extension KDCalendar: EKEventEditViewDelegate {
    
    func presentEventEditView(_ inViewController: UIViewController?, event: EKEvent?, completion: ((_ event: EKEvent?) -> Void)?) {
        guard let inViewController = inViewController
            else { return }
        eventEditViewCompletion = completion
        let editVC = EKEventEditViewController()
        editVC.editViewDelegate = self
        editVC.eventStore = eventStore
        if let event = event {
            editVC.event = event
        }
        inViewController.present(editVC, animated: true, completion: nil)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .saved:
            eventEditViewCompletion?(controller.event)
        case .canceled: break
        case .deleted: break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - 事件查看器
extension KDCalendar: EKEventViewDelegate {
    
    func presentEventView(inViewController: UIViewController?, event: EKEvent?) {
        guard let inViewController = inViewController, let event = event
            else { return }
        let eventVC = EKEventViewController()
        eventVC.delegate = self
        eventVC.allowsEditing = true
        eventVC.event = event
        inViewController.present(UINavigationController(rootViewController:eventVC), animated: true, completion: nil)
    }
    
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        switch action {
        case .done: break
        case .responded: break
        case .deleted: break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - 日期编辑器
extension KDCalendar: EKCalendarChooserDelegate {
    
    func presentCalendarChooser(_ inViewController: UIViewController?) {
        guard let inViewController = inViewController
            else { return }
        let chooser = EKCalendarChooser(selectionStyle: EKCalendarChooserSelectionStyle.single, displayStyle: EKCalendarChooserDisplayStyle.writableCalendarsOnly, eventStore: self.eventStore)
        chooser.delegate = self
        chooser.showsDoneButton = true
        chooser.showsCancelButton = true
        inViewController.present(UINavigationController(rootViewController: chooser), animated: true, completion: nil)
    }
    
    func calendarChooserSelectionDidChange(_ calendarChooser: EKCalendarChooser) {
        print(calendarChooser.selectedCalendars)
    }
    
    func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
        print(calendarChooser.selectedCalendars)
        calendarChooser.dismiss(animated: true, completion: nil)
    }
    
    func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
        print(calendarChooser.selectedCalendars)
        calendarChooser.dismiss(animated: true, completion: nil)
        
    }
}
