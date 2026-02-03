//
//  BatteryMonitor.swift
//  deadbatterydummies
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
    
    private var runLoopSource: CFRunLoopSource?
    private var lastAlertLevel: Int? = nil
    
    // Callback context to bridge C callback to Swift
    nonisolated(unsafe) private static var sharedInstance: BatteryMonitor?
    
    init() {
        BatteryMonitor.sharedInstance = self
        updateBatteryLevel()
    }
    
    func startMonitoring() {
        // Create a run loop source that fires when power source info changes
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        if let source = IOPSNotificationCreateRunLoopSource({ context in
            // This callback fires whenever battery state changes
            Task { @MainActor in
                BatteryMonitor.sharedInstance?.updateBatteryLevel()
            }
        }, context)?.takeRetainedValue() {
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
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        
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
    }
    
    /// Check if alert should be shown based on threshold
    /// Returns true only if we've crossed the threshold (prevents spam)
    func shouldShowAlert(threshold: Int) -> Bool {
        // Don't alert if charging
        if isCharging {
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
