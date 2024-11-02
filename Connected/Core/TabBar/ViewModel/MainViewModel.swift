//
//  MainViewModel.swift
//  Connected
//
//  Created by 정근호 on 10/11/24.
//

import Foundation

class MainViewModel: ObservableObject {
    @Published var users = [User]()
    
   
    
    init() {
        Task {
            try await fetchAllUsers()
        }
    }
    
    @MainActor
    func fetchAllUsers() async throws {
        self.users = try await UserService.fetchAllUsers()
    }
    

}
