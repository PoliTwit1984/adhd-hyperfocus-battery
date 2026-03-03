//
//  AlertManager.swift
//  Your Battery Is Dying
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
    private var autoDismissTask: Task<Void, Never>?
    
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
        NSApp.activate()
        
        // Safety: Auto-dismiss after 60 seconds in case user can't dismiss manually
        autoDismissTask = Task {
            try? await Task.sleep(for: .seconds(60))
            if isShowingAlert {
                dismissAllAlerts()
                onDismiss()
            }
        }
    }
    
    func dismissAllAlerts() {
        autoDismissTask?.cancel()
        autoDismissTask = nil
        isShowingAlert = false
        // Grab windows and clear the array immediately
        let windows = alertWindows
        alertWindows.removeAll()
        // Defer actual window close to next run loop tick so the
        // button action that triggered this can finish first.
        // Closing synchronously destroys the view mid-action → hard lock.
        DispatchQueue.main.async {
            for window in windows {
                window.orderOut(nil)
                window.close()
            }
        }
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
