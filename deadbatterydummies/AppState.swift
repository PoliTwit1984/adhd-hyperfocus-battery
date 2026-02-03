//
//  AppState.swift
//  deadbatterydummies
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
    
    let batteryMonitor = BatteryMonitor()
    let alertManager = AlertManager()
    
    @ObservationIgnored
    @AppStorage("alertThreshold") var alertThreshold: Int = 7
    
    @ObservationIgnored
    @AppStorage("playSoundWithAlert") var playSoundWithAlert: Bool = true
    
    @ObservationIgnored
    @AppStorage("launchAtLogin") private var launchAtLoginStorage: Bool = false
    
    @ObservationIgnored
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var launchAtLogin: Bool {
        get { launchAtLoginStorage }
        set {
            launchAtLoginStorage = newValue
            updateLaunchAtLogin(newValue)
        }
    }
    
    private var checkTask: Task<Void, Never>?
    private var snoozeTask: Task<Void, Never>?
    
    private init() {
        // Sync launch at login state with system on init
        syncLaunchAtLoginState()
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
        batteryMonitor.startMonitoring()
        
        // Check battery level periodically (backup to IOKit notifications)
        checkTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                checkBatteryAndAlert()
            }
        }
        
        // Initial check
        checkBatteryAndAlert()
    }
    
    func stop() {
        batteryMonitor.stopMonitoring()
        checkTask?.cancel()
        checkTask = nil
    }
    
    func checkBatteryAndAlert() {
        if batteryMonitor.shouldShowAlert(threshold: alertThreshold) {
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
                showAlert()
            }
        }
    }
    
    private func playAlertSound() {
        // Play system alert sound
        NSSound.beep()
        // Also play a more noticeable sound
        if let sound = NSSound(named: "Sosumi") {
            sound.play()
        }
    }
}
