import WebKit
import UserNotifications
import SwiftUI

struct LibreWidgetSetupView: View {

    @State private var username = appConfiguration.username
    @State private var password = appConfiguration.password
    @State private var connected = appConfiguration.connected

    @State private var alertMessage = ""
    @State private var alertVisible = false

    @State private var navigateToEventView = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    func statusMessage() -> String {
        switch connected {
            case .connected: return Strings.connectionConnected
            case .connecting: return Strings.connectionConnecting
            case .disconnected: return Strings.connectionDisconnected
            case .failed: return Strings.connectionFailed
            case .locked: return Strings.connectionLocked
        }
    }

    func statusColor() -> Color {
        switch connected {
            case .connected: return .lwGreen
            case .connecting: return .lwUnknown
            case .disconnected: return .lwYellow
            case .failed: return .lwOrange
            case .locked: return .lwRed
        }
    }

    func showAlert(message: String) {
        alertMessage = message
        alertVisible = true
    }

    func viewLoaded() {
        if (connected == .connected) {
            navigateToEventView = true
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text(Strings.productName)
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                    .font(.customFont)
                    .foregroundColor(.lwGreen)
                    .alert(alertMessage, isPresented: $alertVisible) {
                        Button("OK", role: .cancel) {
                        }
                    }
                Form {
                    Section(header: Text(Strings.credentialsHeader), footer: Text(Strings.credentialsFooter.attributed)) {
                        TextField(text: $username, prompt: Text(Strings.usernameLabel)) {
                            Text(Strings.usernamePlaceholder)
                        }.textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .onChange(of: username) { _ in
                                appConfiguration.connected = .disconnected
                            }
                        SecureField(text: $password, prompt: Text(Strings.passwordLabel)) {
                            Text(Strings.passwordPlaceholder)
                        }.onChange(of: appConfiguration.password) { _ in
                            appConfiguration.connected = .disconnected
                        }
                    }
                    
                    Section {
                        Button(Strings.connect) {
                            tryToConnect()
                        }
                    }
                    .disabled(username.isBlank || password.isBlank)

                    Section {
                        // make toggle and use as notiffication configuration only
                        Button("Notification") {
                            let center = UNUserNotificationCenter.current()

                                center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                                    if granted {
                                        print("Yay!")



                                        let content = UNMutableNotificationContent()
                                        content.title = "Late wake up call"
                                        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
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
                                        center.add(request)

                                    } else {
                                        print("D'oh")
                                    }
                                }
                        }

                    }

                    if connected == .connected {
                        Text(Strings.disclaimer.attributed)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                        Section {
                            NavigationLink(destination: EventView(), isActive: $navigateToEventView) {
                                Text(Strings.newEntry)
                            }
                        }
                    }
                }.disabled(connected == .connecting || connected == .locked)
                Text(statusMessage())
                    .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            }.overlay {
                if connected == .connecting {
                    ZStack {
                        Color(white: 0, opacity: 0.25)
                        ProgressView().tint(.white)
                    }
                }
            }.background(LinearGradient(
                colors: [.white, .white, statusColor()],
                startPoint: .top,
                endPoint: .bottom)
            ).onReceive(timer) { time in
                // TODO: synchronize by common method
                connected = appConfiguration.connected
            }.onAppear {
                     viewLoaded()
                 }
        }
    }

    private func tryToConnect() {
        appConfiguration.username = username
        appConfiguration.password = password
        appConfiguration.connected = .connecting
        libreViewAPI.resetAuthentication()
        libreViewAPI.fetchCurrentGlucoseEntry { glucose, error in
            if glucose != nil {
                appConfiguration.connected = .connected
            } else {
                if error is Int && error as? Int == FetchStatus.LOCKED {
                    appConfiguration.connected = .locked
                } else {
                    appConfiguration.connected = .failed
                }
            }
        }
    }
}

struct LibreWidgetSetupView_Previews: PreviewProvider {
    static var previews: some View {
        LibreWidgetSetupView()
    }
}
