import Foundation
import FirebaseAuth
import FirebaseFirestore
import Firebase
import GoogleSignIn
import Combine

class AuthService: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isSignedIn = false
    
    static let shared = AuthService() // 싱글톤 인스턴스
    
    init() {
//        Task { try await loadUserData() }
    }
    
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            Task { try await loadUserData() }
        } catch {
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func createUser(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            try await self.uploadUserData(uid: result.user.uid, email: email)
            self.isSignedIn = true
            try await self.loadUserData()
            print("DEBUG: Successfully created user and loaded user data")
        } catch {
            print("DEBUG: Failed to register user with error \(error.localizedDescription)")
            throw error
        }
    }
    
    
//    @MainActor
//    func loadUserData() async throws {
//        self.userSession = Auth.auth().currentUser
//        guard let currentUid = self.userSession?.uid else {
//            print("DEBUG: No current user session found")
//            return
//        }
//        do {
//            self.currentUser = try await UserService.fetchUser(withUid: currentUid)
//            print("DEBUG: Successfully loaded user data for uid: \(currentUid)")
//        } catch {
//            print("DEBUG: Failed to load user data with error \(error.localizedDescription)")
//            throw error
//        }
//    }
    
    @MainActor
    func loadUserData() async throws {
        self.userSession = Auth.auth().currentUser
        guard let currentUid = self.userSession?.uid else {
            print("DEBUG: No current user session found")
            return
        }
        do {
            print("DEBUG: Attempting to fetch user data for uid: \(currentUid)")
            if let user = try await UserService.fetchUser(withUid: currentUid) {
                self.currentUser = user
                print("DEBUG: Successfully loaded user data for uid: \(currentUid)")
            } else {
                print("DEBUG: No user data found for uid: \(currentUid)")
                // 필요한 처리 추가
            }
        } catch {
            print("DEBUG: Failed to load user data with error \(error.localizedDescription)")
            throw error
        }
    }


    
    
    func signOut() {
        try? Auth.auth().signOut()
        self.userSession = nil
        self.currentUser = nil
        isSignedIn = false
    }
    
    private func uploadUserData(uid: String, email: String) async throws {
        let user = User(id: uid, email: email)
        self.currentUser = user
        do {
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser, merge: true)
            print("DEBUG: Successfully uploaded user data for uid: \(uid)")
        } catch {
            print("DEBUG: Failed to upload user data with error \(error.localizedDescription)")
            throw error
        }
    }
    
    
    
    // Google 로그인 및 회원가입 통합
    @MainActor
    func googleSignIn() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller")
            return
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            print("DEBUG: Failed to get Google user info")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        
        let authResult = try await Auth.auth().signIn(with: credential)
        self.userSession = authResult.user
        self.isSignedIn = true
        
        let uid = authResult.user.uid
           if let email = authResult.user.email {
               try await uploadUserData(uid: uid, email: email)
           } else {
               // email이 없을 경우에 대한 처리
               print("DEBUG: Email is nil for user with uid: \(uid)")
           }
        
        // 사용자 데이터 로드
        try await loadUserData()
    }
}
