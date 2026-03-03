//
//  YourBatteryIsDyingApp.swift
//  Your Battery Is Dying
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
        NSApp.activate()
    }
}

@main
struct YourBatteryIsDyingApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var appState = AppState.shared

    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    var body: some Scene {
        MenuBarExtra {
            if isRunningTests {
                EmptyView()
            } else {
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
        if monitor.isCharging {
            return "bolt.fill"
        }
        if monitor.batteryLevel <= appState.alertThreshold {
            return "battery.0percent"
        }
        return "battery.75percent"
    }
}
