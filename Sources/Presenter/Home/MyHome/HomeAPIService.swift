//
//  LogAPIService.swift
//  MatStar
//
//  Created by uiskim on 2022/10/25.
//  Copyright © 2022 Try-ing. All rights reserved.
//

import Foundation

enum HomeApiError: Error {
    case urlResponse
    case response
}

enum TokenType {
    case hasMate
    case noMate
}

private let fetchUserUrl = "https://comeit.site/users"

private let token = "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI2MmZlMTkyYS0yYWEzLTQ0ZGQtOWZhNS00MzhkY2FjZWU5YTAiLCJhdXRoIjoiVVNFUiJ9.XanwnrThXnsf5J-PzdbmDpDrTJ_dr3upvz6eL4OP4yUUZlYHY0-XJne5v03mGBx24ylGJAO9aa1i8LNVn0F5Ig"

private let mateToken = "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI1MDNhOTBhNC02NTk4LTQxOGMtOTBkZC0zZDM2NTQyZjQzZmIiLCJhdXRoIjoiVVNFUiJ9.DDBTdn3QFf_vQM_FPz_gqyEBuaBaOwfyAR48vlOTaULdgD8rAa7fkNytMzEPkdZDiaPkYkzZVq95ERqq7fpnAw"

class HomeAPIService {
    
    static func fetchUserAsync(tokenType: TokenType) async throws -> Data {
        let selectedToken: String
        guard let url = URL(string: fetchUserUrl) else {
            throw HomeApiError.urlResponse
        }
        var request = URLRequest(url: url)
        switch tokenType {
        case .hasMate:
            selectedToken = mateToken

        case .noMate:
            selectedToken = token
        }
        
        request.setValue(selectedToken, forHTTPHeaderField: "accessToken")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw HomeApiError.response
        }
        return data
    }
}