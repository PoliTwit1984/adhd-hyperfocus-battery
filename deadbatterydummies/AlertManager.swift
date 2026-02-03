//
//  AlertManager.swift
//  deadbatterydummies
//
//  Created by Joe Wilson on 2/2/26.
//

import AppKit
import SwiftUI

@Observable
@MainActor
class AlertManager {
    var isShowingAlert: Bool = false
    private var alertWindows: [NSWindow] = []
    
    func showAlert(batteryLevel: Int, onSnooze: @escaping @MainActor () -> Void, onDismiss: @escaping @MainActor () -> Void) {
        guard !isShowingAlert else { return }
        isShowingAlert = true
        
        // Create an alert window for each screen
        for screen in NSScreen.screens {
            let alertWindow = createAlertWindow(
                for: screen,
                batteryLevel: batteryLevel,
                onSnooze: { [weak self] in
                    self?.dismissAllAlerts()
                    onSnooze()
                },
                onDismiss: { [weak self] in
                    self?.dismissAllAlerts()
                    onDismiss()
                }
            )
            alertWindows.append(alertWindow)
            alertWindow.makeKeyAndOrderFront(nil)
        }
        
        // Activate the app to bring windows to front
        NSApp.activate(ignoringOtherApps: true)
        
        // Safety: Auto-dismiss after 60 seconds in case user can't dismiss manually
        Task {
            try? await Task.sleep(for: .seconds(60))
            if isShowingAlert {
                dismissAllAlerts()
                onDismiss()
            }
        }
    }
    
    func dismissAllAlerts() {
        for window in alertWindows {
            window.close()
        }
        alertWindows.removeAll()
        isShowingAlert = false
    }
    
    private func createAlertWindow(for screen: NSScreen, batteryLevel: Int, onSnooze: @escaping () -> Void, onDismiss: @escaping () -> Void) -> NSWindow {
        let alertView = BatteryAlertView(batteryLevel: batteryLevel, onSnooze: onSnooze, onDismiss: onDismiss)
        let hostingController = NSHostingController(rootView: alertView)
        
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        
        window.contentViewController = hostingController
        // Use .floating instead of .screenSaver - still on top but won't hard lock
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = false
        window.hasShadow = false
        
        // Make it truly full screen
        window.setFrame(screen.frame, display: true)
        
        return window
    }
    
    // Emergency dismiss - call this if something goes wrong
    func emergencyDismiss() {
        dismissAllAlerts()
    }
}
