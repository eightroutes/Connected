//
//  LoginViewModel.swift
//  Connected
//
//  Created by 정근호 on 11/1/24.
//

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    
//    @Published var hasLogined = false
    
    @MainActor
    func signIn() async throws {
        do {
            try await AuthService.shared.login(withEmail: email, password: password)
        } catch {
            // 로그인 실패 시 오류 메시지를 업데이트
            DispatchQueue.main.async {
                self.errorMessage = "Invalid email or password. Please try again."
            }
            throw error
        }
    }
}
