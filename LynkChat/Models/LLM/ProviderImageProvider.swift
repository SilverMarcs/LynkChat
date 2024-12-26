//
//  ProviderImageProvider.swift
//  LynkChat
//
//  Created by Zabir Raihan on 26/12/2024.
//

import Foundation

protocol ProviderImageProvider {
    var color: String { get }  // Assuming color is a hex string
    var imageName: String { get }  // Keep the existing ProviderType enum
}
