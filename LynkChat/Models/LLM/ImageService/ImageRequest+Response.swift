//
//  ImageResponseData.swift
//  LynkChat
//
//  Created by Zabir Raihan on 01/01/2025.
//


struct ImageResponseData: Codable {
    let url: String
}

struct ImageAPIResponse: Codable {
    let data: [ImageResponseData]
}