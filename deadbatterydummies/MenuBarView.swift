//
//  MenuBarView.swift
//  deadbatterydummies
//
//  Created by Joe Wilson on 2/2/26.
//

import SwiftUI

struct MenuBarView: View {
    @Bindable var appState: AppState
    var showOnboarding: () -> Void
    @State private var showingAbout = false
    @State private var isHoveringTest = false
    @State private var isHoveringAbout = false
    @State private var isHoveringOnboarding = false
    @State private var isHoveringQuit = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Battery status section - glass header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Glass icon container
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        Image(systemName: batteryIcon)
                            .font(.system(size: 22))
                            .foregroundStyle(batteryColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(appState.batteryMonitor.batteryLevel)%")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        
                        Text(statusText)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if appState.batteryMonitor.isCharging {
                        ZStack {
                            Circle()
                                .fill(.green.opacity(0.2))
                                .frame(width: 32, height: 32)
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        batteryColor.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Glass divider
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(height: 1)
            
            // Threshold slider section
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Alert Threshold")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(appState.alertThreshold)%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.red.opacity(0.15))
                        )
                }
                
                // Custom glass slider track
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track background
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .frame(height: 8)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        // Filled portion
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.red, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geometry.size.width * CGFloat(appState.alertThreshold) / 50.0), height: 8)
                    }
                }
                .frame(height: 8)
                
                Slider(value: Binding(
                    get: { Double(appState.alertThreshold) },
                    set: { appState.alertThreshold = Int($0) }
                ), in: 1...50, step: 1)
                .tint(.red)
                .opacity(0.01) // Hidden but functional
                .frame(height: 20)
                .offset(y: -14)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            // Glass divider
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(height: 1)
            
            // Settings toggles with glass style
            VStack(alignment: .leading, spacing: 8) {
                GlassToggleRow(
                    isOn: Binding(
                        get: { appState.launchAtLogin },
                        set: { appState.launchAtLogin = $0 }
                    ),
                    icon: "power",
                    iconColor: .blue,
                    label: "Launch at Login"
                )
                
                GlassToggleRow(
                    isOn: Binding(
                        get: { appState.playSoundWithAlert },
                        set: { appState.playSoundWithAlert = $0 }
                    ),
                    icon: "speaker.wave.2",
                    iconColor: .purple,
                    label: "Play Sound"
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Glass divider
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(height: 1)
            
            // Test button - glass style
            GlassMenuButton(
                icon: "exclamationmark.triangle.fill",
                iconColor: .orange,
                label: "Test Alert Now",
                shortcut: "⌘T",
                isHovering: isHoveringTest
            ) {
                appState.showTestAlert()
            }
            .onHover { isHoveringTest = $0 }
            
            // Glass divider
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(height: 1)
            
            // About button
            GlassMenuButton(
                icon: "info.circle",
                iconColor: .blue,
                label: "About",
                shortcut: nil,
                isHovering: isHoveringAbout
            ) {
                showingAbout = true
            }
            .onHover { isHoveringAbout = $0 }
            
            // Show Onboarding button
            GlassMenuButton(
                icon: "sparkles",
                iconColor: .purple,
                label: "Show Welcome Guide",
                shortcut: nil,
                isHovering: isHoveringOnboarding
            ) {
                showOnboarding()
            }
            .onHover { isHoveringOnboarding = $0 }
            
            // Glass divider
            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(height: 1)
            
            // Quit button
            GlassMenuButton(
                icon: "power",
                iconColor: .red,
                label: "Quit",
                shortcut: "⌘Q",
                isHovering: isHoveringQuit
            ) {
                NSApplication.shared.terminate(nil)
            }
            .onHover { isHoveringQuit = $0 }
        }
        .frame(width: 280)
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private var batteryIcon: String {
        let monitor = appState.batteryMonitor
        if monitor.isCharging {
            return "bolt.fill"
        }
        if monitor.batteryLevel <= appState.alertThreshold {
            return "brain.head.profile"
        }
        return "brain.head.profile.fill"
    }
    
    private var batteryColor: Color {
        let monitor = appState.batteryMonitor
        if monitor.isCharging {
            return .green
        }
        if monitor.batteryLevel <= appState.alertThreshold {
            return .red
        }
        if monitor.batteryLevel <= 20 {
            return .orange
        }
        return .primary
    }
    
    private var statusText: String {
        let monitor = appState.batteryMonitor
        if monitor.isCharging {
            return "Charging..."
        }
        if monitor.batteryLevel <= appState.alertThreshold {
            return "Below alert threshold!"
        }
        return monitor.isOnBattery ? "On battery" : "Power connected"
    }
}

// MARK: - Glass Components

struct GlassToggleRow: View {
    @Binding var isOn: Bool
    let icon: String
    let iconColor: Color
    let label: String
    
    var body: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 28, height: 28)
                
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(iconColor)
            }
            
            Text(label)
                .font(.system(size: 13))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}

struct GlassMenuButton: View {
    let icon: String
    let iconColor: Color
    let label: String
    let shortcut: String?
    let isHovering: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(isHovering ? 0.25 : 0.15))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .foregroundStyle(iconColor)
                }
                
                Text(label)
                    .font(.system(size: 13))
                
                Spacer()
                
                if let shortcut = shortcut {
                    Text(shortcut)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.ultraThinMaterial)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .background(
                isHovering ?
                    AnyShapeStyle(Color.white.opacity(0.1)) :
                    AnyShapeStyle(Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MenuBarView(appState: AppState.shared, showOnboarding: {})
}
