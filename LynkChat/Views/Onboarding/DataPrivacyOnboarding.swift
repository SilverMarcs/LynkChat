//
//  DataPrivacyOnboarding.swift
//  LynkChat
//
//  Created by Zabir Raihan on 21/04/2026.
//

import SwiftUI

struct DataPrivacyOnboarding: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Your Data & Privacy")
                    .font(.title)
                    .bold()
            }
            .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 14) {
                DataPrivacyRow(
                    icon: "text.bubble",
                    title: "What We Send",
                    detail: "Your messages, attachments, and conversation history are sent to Google's Gemini AI to generate responses."
                )

                DataPrivacyRow(
                    icon: "building.2",
                    title: "Who Receives It",
                    detail: "Your data is processed by Google (Gemini). The app uses a backend server to securely relay requests to Google's API."
                )

                DataPrivacyRow(
                    icon: "lock.shield",
                    title: "How It's Protected",
                    detail: "Data is transmitted securely over encrypted connections. We do not store or sell your data."
                )
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

private struct DataPrivacyRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    DataPrivacyOnboarding()
        .frame(width: 500, height: 500)
}
