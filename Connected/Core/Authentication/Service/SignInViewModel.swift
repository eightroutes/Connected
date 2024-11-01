////
////  SignInViewModel.swift
////  Connected
////
////  Created by 정근호 on 9/23/24.
////
//
//import Foundation
//import FirebaseAuth
//import FirebaseAuth
//import FirebaseCore
//import GoogleSignIn
//import GoogleSignInSwift
//
//
//
//class SignInViewModel: ObservableObject {
//    @Published var errorMessage: String?
//    
//    @Published var signState: signState = .signOut
//    
//    enum signState {
//        case signIn
//        case signOut
//    }
////    @Published var isSignedIn = false
////        @StateObject private var profileviewModel = ProfileDetailViewModel()
//    
//    
//    init() {
//        print("signState: \(self.signState)")
////        self.signState = Auth.auth().currentUser != nil
//    }
//    
////    func checkAndUpdateSignInStatus() {
////        DispatchQueue.main.async { [weak self] in
////            self?.isSignedIn = Auth.auth().currentUser != nil && Auth.auth().currentUser?.uid != nil
////        }
////    }
//    // MARK: - Google SignIn Function
//    // 구글 로그인
//    func googleLogin() {
//        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//        
//        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.configuration = config
//        
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = windowScene.windows.first,
//              let rootViewController = window.rootViewController else {
//            print("There is no root view controller")
//            return
//        }
//        
//        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
//            guard error == nil else {
//                self?.errorMessage = error?.localizedDescription
//                return
//            }
//            
//            guard let user = result?.user,
//                  let idToken = user.idToken?.tokenString else {
//                self?.errorMessage = "Failed to get user information"
//                return
//            }
//            
//            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
//            
//            Auth.auth().signIn(with: credential) { authResult, error in
//                if let error = error {
//                    self?.errorMessage = error.localizedDescription
//                } else {
//                    print("Successfully signed in with Google")
//                    DispatchQueue.main.async {
//                        self?.signState = .signIn
//                    }
//                }
//            }
//        }
//    }
//    
//    // 구글 로그아웃
//   func signOut() {
//       // 1
//       GIDSignIn.sharedInstance.signOut()
//       
//       do {
//           // 2
//           try Auth.auth().signOut()
//           self.signState = .signOut
//       } catch {
//           print(error.localizedDescription)
//       }
//   }
//    
//    
//    func signInWithEmail(email: String, password: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
//            if let error = error {
//                self?.errorMessage = error.localizedDescription
//            } else {
//                print("Successfully signed in with Email")
//                DispatchQueue.main.async {
//                    self!.signState = .signIn
//                    
//                }
//            }
//        }
//    }
//}
