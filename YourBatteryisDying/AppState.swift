//
//  AppState.swift
//  Your Battery Is Dying
//
//  Created by Joe Wilson on 2/2/26.
//

import SwiftUI
import Observation
import ServiceManagement
import AppKit

@Observable
@MainActor
class AppState {
    static let shared = AppState()

    let batteryMonitor: BatteryMonitor
    let alertManager: AlertManager

    // @Observable expands properties to computed via @ObservationTracked,
    // which conflicts with @AppStorage. All @AppStorage vars MUST be
    // @ObservationIgnored, then exposed via computed properties that
    // call access()/withMutation() so SwiftUI still reacts to changes.
    @ObservationIgnored
    @AppStorage("alertThreshold") private var alertThresholdStorage: Int = 7
    @ObservationIgnored
    @AppStorage("playSoundWithAlert") private var playSoundWithAlertStorage: Bool = true
    @ObservationIgnored
    @AppStorage("launchAtLogin") private var launchAtLoginStorage: Bool = false
    @ObservationIgnored
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboardingStorage: Bool = false
    @ObservationIgnored
    private let isRunningTestsOverride: Bool?

    var alertThreshold: Int {
        get {
            access(keyPath: \.alertThreshold)
            return alertThresholdStorage
        }
        set {
            withMutation(keyPath: \.alertThreshold) {
                alertThresholdStorage = newValue
            }
        }
    }

    var playSoundWithAlert: Bool {
        get {
            access(keyPath: \.playSoundWithAlert)
            return playSoundWithAlertStorage
        }
        set {
            withMutation(keyPath: \.playSoundWithAlert) {
                playSoundWithAlertStorage = newValue
            }
        }
    }

    var launchAtLogin: Bool {
        get {
            access(keyPath: \.launchAtLogin)
            return launchAtLoginStorage
        }
        set {
            withMutation(keyPath: \.launchAtLogin) {
                launchAtLoginStorage = newValue
                updateLaunchAtLogin(newValue)
            }
        }
    }

    var hasCompletedOnboarding: Bool {
        get {
            access(keyPath: \.hasCompletedOnboarding)
            return hasCompletedOnboardingStorage
        }
        set {
            withMutation(keyPath: \.hasCompletedOnboarding) {
                hasCompletedOnboardingStorage = newValue
            }
        }
    }
    
    private var isStarted = false
    private var snoozeTask: Task<Void, Never>?

    private var isRunningTests: Bool {
        if let override = isRunningTestsOverride {
            return override
        }
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    init(
        batteryMonitor: BatteryMonitor = BatteryMonitor(),
        alertManager: AlertManager = AlertManager(),
        isRunningTestsOverride: Bool? = nil,
        syncLaunchAtLoginOnInit: Bool = true
    ) {
        self.batteryMonitor = batteryMonitor
        self.alertManager = alertManager
        self.isRunningTestsOverride = isRunningTestsOverride

        // Sync launch at login state with system on init
        if syncLaunchAtLoginOnInit && !isRunningTests {
            syncLaunchAtLoginState()
        }
    }
    
    private func syncLaunchAtLoginState() {
        let status = SMAppService.mainApp.status
        launchAtLoginStorage = (status == .enabled)
    }
    
    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to update launch at login: \(error)")
            // Revert the storage if failed
            launchAtLoginStorage = !enabled
        }
    }
    
    func start() {
        if isRunningTests || isStarted {
            return
        }
        isStarted = true

        // Wire IOKit callback → alert check on every battery change
        batteryMonitor.onBatteryUpdate = { [weak self] in
            self?.checkBatteryAndAlert()
        }
        batteryMonitor.startMonitoring()

        // Initial check
        checkBatteryAndAlert()
    }
    
    func stop() {
        batteryMonitor.stopMonitoring()
        isStarted = false
    }
    
    func checkBatteryAndAlert() {
        // Auto-dismiss alert if user plugged in
        if batteryMonitor.isPluggedIn {
            if alertManager.isShowingAlert {
                print("[Battery] User plugged in - auto-dismissing alert")
                alertManager.dismissAllAlerts()
            }
            if snoozeTask != nil {
                snoozeTask?.cancel()
                snoozeTask = nil
            }
            return
        }
        
        if batteryMonitor.shouldShowAlert(threshold: alertThreshold) {
            print("[Battery] Showing low battery alert at \(batteryMonitor.batteryLevel)%")
            showAlert()
        }
    }
    
    func showAlert() {
        if playSoundWithAlert {
            playAlertSound()
        }
        alertManager.showAlert(batteryLevel: batteryMonitor.batteryLevel, onSnooze: { @MainActor in
            AppState.shared.snoozeAlert()
        }, onDismiss: { @MainActor in
            AppState.shared.batteryMonitor.resetAlertState()
        })
    }
    
    func showTestAlert() {
        if playSoundWithAlert {
            playAlertSound()
        }
        // For testing - show alert regardless of battery level
        alertManager.showAlert(batteryLevel: batteryMonitor.batteryLevel, onSnooze: { @MainActor in
            // Snooze test alert too
            AppState.shared.snoozeAlert()
        }, onDismiss: { @MainActor in
            // Don't reset alert state for test alerts
        })
    }
    
    func snoozeAlert() {
        alertManager.dismissAllAlerts()
        // Snooze for 5 minutes
        snoozeTask?.cancel()
        snoozeTask = Task {
            try? await Task.sleep(for: .seconds(300)) // 5 minutes
            if !Task.isCancelled {
                checkBatteryAndAlert()
            }
        }
    }
    
    private func playAlertSound() {
        if let sound = NSSound(named: "Sosumi") {
            sound.play()
        } else {
            NSSound.beep()
        }
    }
}
