//
//  BatteryMonitor.swift
//  Your Battery Is Dying
//
//  Created by Joe Wilson on 2/2/26.
//

import Foundation
import IOKit.ps

@Observable
@MainActor
class BatteryMonitor {
    var batteryLevel: Int = 100
    var isCharging: Bool = false
    var isOnBattery: Bool = true

    var isPluggedIn: Bool {
        !isOnBattery
    }

    /// Called after every IOKit update so AppState can check thresholds
    var onBatteryUpdate: (() -> Void)?

    @ObservationIgnored
    nonisolated(unsafe) private var runLoopSource: CFRunLoopSource?
    private var lastAlertLevel: Int? = nil

    // Callback context to bridge C callback to Swift.
    // nonisolated(unsafe) is safe here because the IOKit callback only reads this
    // to dispatch onto MainActor — all actual property access happens on MainActor.
    nonisolated(unsafe) private static var sharedInstance: BatteryMonitor?

    init() {
        BatteryMonitor.sharedInstance = self
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            updateBatteryLevel()
        }
    }

    deinit {
        // deinit is nonisolated in Swift 6, so clean up the run loop source directly
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .defaultMode)
        }
    }

    func startMonitoring() {
        if let source = IOPSNotificationCreateRunLoopSource({ _ in
            // This callback fires whenever battery state changes
            Task { @MainActor in
                BatteryMonitor.sharedInstance?.updateBatteryLevel()
                BatteryMonitor.sharedInstance?.onBatteryUpdate?()
            }
        }, nil)?.takeRetainedValue() {
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .defaultMode)
            runLoopSource = source
        }

        // Get initial reading
        updateBatteryLevel()
    }
    
    func stopMonitoring() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .defaultMode)
            runLoopSource = nil
        }
    }
    
    func updateBatteryLevel() {
        let oldCharging = isCharging
        let oldLevel = batteryLevel

        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array

        // No battery present (e.g. desktop Mac) — nothing to update
        guard !sources.isEmpty else { return }

        for source in sources {
            if let info = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] {
                // Get current capacity (percentage)
                if let capacity = info[kIOPSCurrentCapacityKey as String] as? Int {
                    batteryLevel = capacity
                }
                
                // Check if charging
                if let charging = info[kIOPSIsChargingKey as String] as? Bool {
                    isCharging = charging
                }
                
                // Check power source type
                if let powerSource = info[kIOPSPowerSourceStateKey as String] as? String {
                    isOnBattery = (powerSource == kIOPSBatteryPowerValue as String)
                }
            }
        }
        
        // Log state changes
        if oldCharging != isCharging {
            print("[Battery] Charging state changed: \(oldCharging) -> \(isCharging)")
        }
        if oldLevel != batteryLevel {
            print("[Battery] Battery level: \(batteryLevel)%")
        }
    }
    
    /// Check if alert should be shown based on threshold
    /// Returns true only if we've crossed the threshold (prevents spam)
    func shouldShowAlert(threshold: Int) -> Bool {
        // Don't alert if on external power (even if not actively charging)
        if !isOnBattery {
            lastAlertLevel = nil
            return false
        }
        
        // Check if battery is at or below threshold
        if batteryLevel <= threshold {
            // Only alert if we haven't already alerted at this level or lower
            if let lastLevel = lastAlertLevel, lastLevel <= batteryLevel {
                return false
            }
            lastAlertLevel = batteryLevel
            return true
        } else if batteryLevel > threshold + 3 {
            // Reset alert state when battery goes above threshold + 3%
            // This allows a new alert when it drops again
            lastAlertLevel = nil
        }
        
        return false
    }
    
    /// Reset alert state (call after user dismisses alert)
    func resetAlertState() {
        lastAlertLevel = batteryLevel
    }
}
