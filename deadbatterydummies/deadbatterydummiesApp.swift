//
//  deadbatterydummiesApp.swift
//  deadbatterydummies
//
//  Created by Joe Wilson on 2/2/26.
//

import SwiftUI
import AppKit

// Prevent app from quitting when alert window closes
class AppDelegate: NSObject, NSApplicationDelegate {
    var onboardingWindow: NSWindow?
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func showOnboarding(appState: AppState) {
        // Close existing if any
        onboardingWindow?.close()
        
        let onboardingView = OnboardingView(appState: appState) { [weak self] in
            self?.onboardingWindow?.close()
            self?.onboardingWindow = nil
            appState.hasCompletedOnboarding = true
        }
        
        let hostingController = NSHostingController(rootView: onboardingView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Welcome"
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        onboardingWindow = window
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct deadbatterydummiesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var appState = AppState.shared
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(appState: appState, showOnboarding: {
                appDelegate.showOnboarding(appState: appState)
            })
                .onAppear {
                    appState.start()
                    // Show onboarding on first launch
                    if !appState.hasCompletedOnboarding {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            appDelegate.showOnboarding(appState: appState)
                        }
                    }
                }
        } label: {
            Label {
                Text("Battery")
            } icon: {
                Image(systemName: menuBarIcon)
            }
        }
        .menuBarExtraStyle(.window)
    }
    
    private var menuBarIcon: String {
        let monitor = appState.batteryMonitor
        // Use brain icons to distinguish from macOS battery
        if monitor.isCharging {
            return "brain.head.profile.fill"
        }
        if monitor.batteryLevel <= appState.alertThreshold {
            return "brain.head.profile" // Outline = low/alert
        }
        return "brain.head.profile.fill" // Filled = good
    }
}
