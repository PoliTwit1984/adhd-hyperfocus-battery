//
//  OnboardingView.swift
//  Your Battery Is Dying
//
//  Created by Joe Wilson on 2/2/26.
//

import SwiftUI

struct OnboardingView: View {
    let appState: AppState
    let onComplete: () -> Void
    
    @State private var currentPage = 0
    @State private var appearAnimation = false
    
    private let totalPages = 5
    
    var body: some View {
        ZStack {
            // Glass background with dynamic color
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [
                            pageColor.opacity(0.15),
                            Color.black.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main content with custom page transitions
                ZStack {
                    // Page 0: Welcome
                    if currentPage == 0 {
                        WelcomePage()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                    
                    // Page 1: How it works
                    if currentPage == 1 {
                        HowItWorksPage()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                    
                    // Page 2: Setup - Alert threshold
                    if currentPage == 2 {
                        ThresholdSetupPage(appState: appState)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                    
                    // Page 3: Setup - Preferences
                    if currentPage == 3 {
                        PreferencesSetupPage(appState: appState)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                    
                    // Page 4: All set
                    if currentPage == 4 {
                        AllSetPage()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom controls
                VStack(spacing: 20) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? pageColor : Color.secondary.opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button(action: { withAnimation { currentPage -= 1 } }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Back")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                }
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(.regularMaterial)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Spacer()
                        
                        if currentPage < totalPages - 1 {
                            Button(action: { withAnimation { currentPage += 1 } }) {
                                HStack(spacing: 6) {
                                    Text("Next")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [pageColor, pageColor.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.white.opacity(0.3), .clear],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                        .padding(2)
                                )
                            }
                            .buttonStyle(.plain)
                            .shadow(color: pageColor.opacity(0.3), radius: 10, y: 5)
                            .keyboardShortcut(.return, modifiers: [])
                        } else {
                            Button(action: onComplete) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                    Text("Get Started")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 36)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.green, .green.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.white.opacity(0.4), .clear],
                                                startPoint: .top,
                                                endPoint: .center
                                            )
                                        )
                                        .padding(2)
                                )
                            }
                            .buttonStyle(.plain)
                            .shadow(color: .green.opacity(0.4), radius: 15, y: 5)
                            .keyboardShortcut(.return, modifiers: [])
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 32)
                }
                .frame(height: 120)
                .background(.ultraThinMaterial)
            }
        }
        .frame(width: 700, height: 620)
        .scaleEffect(appearAnimation ? 1.0 : 0.95)
        .opacity(appearAnimation ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }
    
    private var pageColor: Color {
        switch currentPage {
        case 0: return .purple
        case 1: return .red
        case 2: return .orange
        case 3: return .blue
        case 4: return .green
        default: return .purple
        }
    }
}

// MARK: - Page 0: Welcome

struct WelcomePage: View {
    @State private var iconScale: CGFloat = 0.5
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 140, height: 140)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.purple.opacity(0.2), radius: 20, y: 10)
                
                Image(systemName: "battery.75percent")
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .purple.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(iconScale)
            
            // Text
            VStack(spacing: 12) {
                Text("Welcome to")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                Text("Your Battery Is Dying")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Full-screen alerts you can't ignore")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.purple)
                
                Text("When you're in the zone, tiny notifications don't stand a chance.\nThis app makes sure you never lose work to a dead battery.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 60)
                    .padding(.top, 8)
            }
            .opacity(contentOpacity)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
            }
        }
    }
}

// MARK: - Page 1: How It Works

struct HowItWorksPage: View {
    @State private var iconScale: CGFloat = 0.5
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.red.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 140, height: 140)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.red.opacity(0.2), radius: 20, y: 10)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(iconScale)
            
            // Text
            VStack(spacing: 12) {
                Text("How It Works")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Impossible to ignore")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.red)
                
                Text("When your battery hits your chosen threshold, a beautiful\nfull-screen alert takes over all your displays.\n\nNo more missed warnings. No more dead laptops mid-flow.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 60)
                    .padding(.top, 8)
            }
            .opacity(contentOpacity)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
            }
        }
    }
}

// MARK: - Page 2: Threshold Setup (Interactive)

struct ThresholdSetupPage: View {
    let appState: AppState
    @State private var iconScale: CGFloat = 0.5
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.orange.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.orange.opacity(0.2), radius: 20, y: 10)
                
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(iconScale)
            
            // Text
            VStack(spacing: 8) {
                Text("Set Your Alert Threshold")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("When should we grab your attention?")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .opacity(contentOpacity)
            
            // Interactive threshold control
            VStack(spacing: 16) {
                // Big percentage display
                Text("\(appState.alertThreshold)%")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: appState.alertThreshold)
                
                // Slider
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { Double(appState.alertThreshold) },
                            set: { appState.alertThreshold = Int($0) }
                        ),
                        in: 1...50,
                        step: 1
                    )
                    .tint(.orange)
                    .frame(width: 300)
                    
                    HStack {
                        Text("1%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("50%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 300)
                }
                
                // Recommendation
                Text("Recommended: 7-10% gives you time to find your charger")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 8)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .opacity(contentOpacity)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
            }
        }
    }
}

// MARK: - Page 3: Preferences Setup (Interactive)

struct PreferencesSetupPage: View {
    let appState: AppState
    @State private var iconScale: CGFloat = 0.5
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.blue.opacity(0.2), radius: 20, y: 10)
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(iconScale)
            
            // Text
            VStack(spacing: 8) {
                Text("Configure Your Preferences")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Customize how the app works for you")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .opacity(contentOpacity)
            
            // Interactive preferences
            VStack(spacing: 0) {
                // Launch at Login toggle
                OnboardingToggleRow(
                    icon: "power",
                    iconColor: .blue,
                    title: "Launch at Login",
                    subtitle: "Start automatically when you log in",
                    isOn: Binding(
                        get: { appState.launchAtLogin },
                        set: { appState.launchAtLogin = $0 }
                    )
                )
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Play Sound toggle
                OnboardingToggleRow(
                    icon: "speaker.wave.2.fill",
                    iconColor: .purple,
                    title: "Play Alert Sound",
                    subtitle: "Audio alert for when you're wearing headphones",
                    isOn: Binding(
                        get: { appState.playSoundWithAlert },
                        set: { appState.playSoundWithAlert = $0 }
                    )
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .frame(width: 400)
            .opacity(contentOpacity)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
            }
        }
    }
}

struct OnboardingToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .tint(iconColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Page 4: All Set

struct AllSetPage: View {
    @State private var contentOpacity: Double = 0
    @State private var menuBarOpacity: Double = 0
    @State private var checkmarkScale: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Success header
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.green)
                    .scaleEffect(checkmarkScale)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("You're All Set!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Your hyperfocus is protected")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.green)
                }
            }
            .opacity(contentOpacity)
            
            // Menu bar preview
            VStack(spacing: 12) {
                Text("Look for this in your menu bar:")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                
                // Fake menu bar
                HStack(spacing: 0) {
                    Spacer()
                    
                    // Other fake menu bar icons
                    HStack(spacing: 16) {
                        Image(systemName: "wifi")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                        
                        Image(systemName: "battery.75percent")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                        
                        // Our icon - highlighted
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.purple.opacity(0.2))
                                .frame(width: 28, height: 22)
                            
                            Image(systemName: "battery.75percent")
                                .font(.system(size: 14))
                                .foregroundStyle(.purple)
                        }
                        
                        Text("Mon 9:15 PM")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .frame(width: 320)
                
                // Arrow pointing down
                Image(systemName: "arrow.down")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                
                // Mini preview of dropdown
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.purple.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: "battery.75percent")
                                .font(.system(size: 14))
                                .foregroundStyle(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("100%")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Text("Power connected")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(10)
                    
                    Divider()
                    
                    // Alert threshold row
                    HStack {
                        Text("Alert Threshold")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("7%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(.red.opacity(0.15))
                            )
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    // Toggle rows
                    VStack(spacing: 6) {
                        HStack {
                            Image(systemName: "power")
                                .font(.system(size: 10))
                                .foregroundStyle(.blue)
                            Text("Launch at Login")
                                .font(.system(size: 11))
                            Spacer()
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                        }
                        
                        HStack {
                            Image(systemName: "speaker.wave.2")
                                .font(.system(size: 10))
                                .foregroundStyle(.purple)
                            Text("Play Sound")
                                .font(.system(size: 11))
                            Spacer()
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
                .frame(width: 180)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
                )
            }
            .opacity(menuBarOpacity)
            
            // Final message
            Text("Click the battery icon in your menu bar to adjust settings or test the alert.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
                .opacity(contentOpacity)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                checkmarkScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                contentOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                menuBarOpacity = 1.0
            }
        }
    }
}

#Preview {
    OnboardingView(appState: AppState.shared, onComplete: {})
}
