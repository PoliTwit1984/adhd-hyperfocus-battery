//
//  AboutView.swift
//  Your Battery Is Dying
//
//  Created by Joe Wilson on 2/2/26.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        VStack(spacing: 20) {
            // App icon placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [.red, .red.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .red.opacity(0.3), radius: 10, y: 5)

                Image(systemName: "battery.0percent")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(.white)
            }
            .padding(.top, 10)

            // App name and version
            VStack(spacing: 6) {
                Text("Your Battery Is Dying")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                Text("Version \(appVersion) (\(buildNumber))")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            // Description
            Text("Full-screen battery alerts you can't ignore. Never lose work to a dead laptop again.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Divider()
                .padding(.horizontal, 30)

            // Links
            VStack(spacing: 12) {
                // Privacy Policy
                Button(action: {
                    if let url = URL(string: "https://politwit1984.github.io/adhd-hyperfocus-battery/privacy") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(.blue)
                        Text("Privacy Policy")
                    }
                    .font(.system(size: 13))
                }
                .buttonStyle(.plain)

                // Support
                Button(action: {
                    if let url = URL(string: "https://politwit1984.github.io/adhd-hyperfocus-battery/support") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Support")
                    }
                    .font(.system(size: 13))
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Copyright
            Text("\u{00A9} 2026 Obey LLC")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)

            // Close button
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .padding(.bottom, 10)
        }
        .frame(width: 300, height: 400)
        .background(.regularMaterial)
    }
}

#Preview {
    AboutView()
}
