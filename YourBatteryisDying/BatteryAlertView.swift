//
//  BatteryAlertView.swift
//  Your Battery Is Dying
//
//  Created by Joe Wilson on 2/2/26.
//

import SwiftUI
import AppKit

struct BatteryAlertView: View {
    let batteryLevel: Int
    let onSnooze: () -> Void
    let onDismiss: () -> Void

    @State private var isAnimating = false
    @State private var eventMonitor: Any?
    @State private var appearAnimation = false
    @State private var confirmingDismiss = false

    var body: some View {
        ZStack {
            // Blurred background with gradient tint
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.red.opacity(0.15),
                            Color.purple.opacity(0.1),
                            Color.black.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea()

            // Glass card
            VStack(spacing: 28) {
                // Battery icon with warning
                ZStack {
                    // Outer pulsing ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(isAnimating ? 1.3 : 1.0)
                        .opacity(isAnimating ? 0 : 0.6)
                        .animation(
                            .easeOut(duration: 2.0).repeatForever(autoreverses: false),
                            value: isAnimating
                        )

                    // Glass circle background
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 160, height: 160)
                        .overlay(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color.red.opacity(0.3), Color.clear],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 80
                                    )
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .scaleEffect(isAnimating ? 1.02 : 0.98)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: isAnimating
                        )

                    Image(systemName: "battery.0percent")
                        .font(.system(size: 70, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .red.opacity(0.5), radius: 15)
                }

                // Warning text
                VStack(spacing: 10) {
                    Text("YOUR BATTERY IS DYING")
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text("\(batteryLevel)%")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                        .shadow(color: .red.opacity(0.3), radius: 10)

                    Text("Plug in your charger now!")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                // Buttons — swap between normal and confirm states inline
                if confirmingDismiss {
                    // Inline confirmation — no system dialogs
                    VStack(spacing: 12) {
                        Text("You downloaded this app for a reason.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 16) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    confirmingDismiss = false
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.system(size: 16))
                                    Text("Go back")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(.regularMaterial)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)

                            Button(action: onDismiss) {
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16))
                                    Text("Dismiss anyway")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundStyle(.white.opacity(0.7))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .transition(.opacity)
                    .padding(.top, 16)
                } else {
                    // Normal buttons
                    HStack(spacing: 16) {
                        // Snooze button
                        Button(action: onSnooze) {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 18))
                                Text("Snooze 5 min")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(.regularMaterial)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)

                        // Dismiss button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                confirmingDismiss = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                Text("Dismiss")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.red, .red.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
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
                            )
                        }
                        .buttonStyle(.plain)
                        .shadow(color: .red.opacity(0.4), radius: 15, y: 5)
                    }
                    .transition(.opacity)
                    .padding(.top, 16)
                }

                // Keyboard hint
                Text("Press Escape to dismiss")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 8)
            }
            .padding(50)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 40, y: 20)
            )
            .scaleEffect(appearAnimation ? 1.0 : 0.8)
            .opacity(appearAnimation ? 1.0 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimation = true
            }
            isAnimating = true
            setupKeyboardMonitor()
        }
        .onDisappear {
            removeKeyboardMonitor()
        }
    }

    private func setupKeyboardMonitor() {
        removeKeyboardMonitor()
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Escape (53) = always dismiss directly (safety valve)
            if event.keyCode == 53 {
                onDismiss()
                return nil
            }
            // Space (49) or Return (36) = snooze
            if event.keyCode == 49 || event.keyCode == 36 {
                onSnooze()
                return nil
            }
            return event
        }
    }

    private func removeKeyboardMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

#Preview {
    BatteryAlertView(batteryLevel: 7, onSnooze: {}, onDismiss: {})
        .frame(width: 800, height: 600)
}
