//
//  RegistrationViewModel.swift
//  Connected
//
//  Created by 정근호 on 10/7/24.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @MainActor
    func createUser() async throws {
        try await AuthService.shared.createUser(email: email, password: password)
        
        // 회원가입 시 자동 로그아웃
        AuthService.shared.signOut()
        email = ""
        password = ""
    }

}
