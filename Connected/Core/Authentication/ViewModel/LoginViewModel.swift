//
//  LoginViewModel.swift
//  Connected
//
//  Created by 정근호 on 10/7/24.
//

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
//    @Published var hasLogined = false
    
    @MainActor
    func signIn() async throws {
        try await AuthService.shared.login(withEmail: email, password: password)
    }
}
