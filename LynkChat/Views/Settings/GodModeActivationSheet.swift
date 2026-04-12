//
//  GodModeActivationSheet.swift
//  LynkChat
//

import SwiftUI

struct GodModeActivationSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var passphrase = ""
    @State private var failed = false

    @Environment(GodMode.self) var godMode

    var body: some View {
        VStack(spacing: 12) {
            SecureField("Passphrase", text: $passphrase)
                .textFieldStyle(.roundedBorder)

            if failed {
                Text("Incorrect passphrase.")
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Confirm") {
                    if godMode.tryActivate(passphrase: passphrase) {
                        dismiss()
                    } else {
                        failed = true
                        passphrase = ""
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
