//
//  InputError.swift
//  LynkChat
//
//  Created by Zabir Raihan on 31/12/2024.
//

import Foundation

enum InputError: LocalizedError {
    case fileTooLarge(size: Int, maxSize: Int)
    case unsupportedAudioFormat
    case unsupportedFileType
    case tooManyFiles(current: Int, max: Int)
    case tooManyAudioFiles(max: Int)
    case imageNotSupported
    case imageCompressionFailed
    
    var errorDescription: String? {
        switch self {
        case .fileTooLarge(let size, let maxSize):
            return "File size (\(formatFileSize(size))) exceeds maximum allowed size (\(formatFileSize(maxSize)))"
        case .unsupportedAudioFormat:
            return "Unsupported audio format"
        case .unsupportedFileType:
            return "Unsupported file type"
        case .tooManyFiles(_, let max):
            return "Cannot add more files. Maximum number of files (\(max)) reached"
        case .tooManyAudioFiles(let max):
            return "Cannot add more audio files. Maximum number of audio files (\(max)) reached"
        case .imageNotSupported:
            return "Images are not supported in this context"
        case .imageCompressionFailed:
            return "Failed to compress image. Please try a different image."
        }
    }
    
    // Helper function to format file sizes in human-readable format
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB, .useBytes]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
