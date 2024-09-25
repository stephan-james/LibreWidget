import SwiftUI
import BackgroundTasks

@main
struct LibreWidgetApp: App {

    @Environment(\.scenePhase) private var phase

    init() {
        if appConfiguration.connected != .connected {
            appConfiguration.connected = .disconnected
        }
    }

    func scheduleAppRefresh() {
        print("!!!!!!!!!!!! - scheduleAppRefresh")
        //let request = BGAppRefreshTaskRequest(identifier: "sjd.librewidget.notifier")
        //try? BGTaskScheduler.shared.submit(request)
    }

    var body: some Scene {
        WindowGroup {
            LibreWidgetSetupView()
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .background: scheduleAppRefresh()
            default: break
            }
        }
        .backgroundTask(.appRefresh("sjd.librewidget.notifier")) {
            // run
            // (lldb) e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"sjd.librewidget.notifier"]
            // in paused debugger to force

            let content = UNMutableNotificationContent()
            content.title = UUID().uuidString
            content.body = "Bla.bloop."
            content.categoryIdentifier = "alarm"
            content.userInfo = ["customData": "fizzbuzz"]
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.hour = 10
            dateComponents.minute = 30

            let trigger =
            UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            // UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            // TMP
            //center.removeAllPendingNotificationRequests()


            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)


        }
    }
}
