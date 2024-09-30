//
//  SignInViewModel.swift
//  Connected
//
//  Created by 정근호 on 9/23/24.
//

import Foundation
import FirebaseAuth
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift
import KakaoSDKUser
import KakaoSDKAuth


class SignInViewModel: ObservableObject {
    @Published var errorMessage: String?
    
    @Published var signState: signState = .signOut
    
    enum signState {
        case signIn
        case signOut
    }
//    @Published var isSignedIn = false
//        @StateObject private var profileviewModel = ProfileDetailViewModel()
    
    
    init() {
        print("signState: \(self.signState)")
//        self.signState = Auth.auth().currentUser != nil
    }
    
//    func checkAndUpdateSignInStatus() {
//        DispatchQueue.main.async { [weak self] in
//            self?.isSignedIn = Auth.auth().currentUser != nil && Auth.auth().currentUser?.uid != nil
//        }
//    }
    // MARK: - Google SignIn Function
    // 구글 로그인
    
    
        
    func googleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard error == nil else {
                self?.errorMessage = error?.localizedDescription
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.errorMessage = "Failed to get user information"
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    print("Successfully signed in with Google")
                    DispatchQueue.main.async {
                        self?.signState = .signIn
                    }
                }
            }
        }
    }
    
    // 구글 로그아웃
   func signOut() {
       // 1
       GIDSignIn.sharedInstance.signOut()
       
       do {
           // 2
           try Auth.auth().signOut()
           self.signState = .signOut
       } catch {
           print(error.localizedDescription)
       }
   }
    
    // MARK: - KakaoAuth SignIn Function
    func kakaoAuthSignIn() {
        if AuthApi.hasToken() { // 발급된 토큰이 있는지
            UserApi.shared.accessTokenInfo { _, error in // 해당 토큰이 유효한지
                if let error = error { // 에러가 발생했으면 토큰이 유효하지 않다.
                    self.openKakaoService()
                } else { // 유효한 토큰
                    self.loadingInfoDidKakaoAuth()
                }
            }
        } else { // 만료된 토큰
            self.openKakaoService()
        }
    }
    
    func openKakaoService() {
        if UserApi.isKakaoTalkLoginAvailable() { // 카카오톡 앱 이용 가능한지
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in // 카카오톡 앱으로 로그인
                if let error = error { // 로그인 실패 -> 종료
                    print("Kakao Sign In Error: ", error.localizedDescription)
                    return
                }
                
                _ = oauthToken // 로그인 성공
                self.loadingInfoDidKakaoAuth() // 사용자 정보 불러와서 Firebase Auth 로그인하기
            }
        } else { // 카카오톡 앱 이용 불가능한 사람
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in // 카카오 웹으로 로그인
                if let error = error { // 로그인 실패 -> 종료
                    print("Kakao Sign In Error: ", error.localizedDescription)
                    return
                }
                _ = oauthToken // 로그인 성공
                self.loadingInfoDidKakaoAuth() // 사용자 정보 불러와서 Firebase Auth 로그인하기
            }
        }
    }
    
    func loadingInfoDidKakaoAuth() {  // 사용자 정보 불러오기
        UserApi.shared.me { kakaoUser, error in
            if let error = error {
                print("카카오톡 사용자 정보 불러오는데 실패했습니다.")
                
                return
            }
            guard let email = kakaoUser?.kakaoAccount?.email else { return }
            guard let password = kakaoUser?.id else { return }
            guard let userName = kakaoUser?.kakaoAccount?.profile?.nickname else { return }
            
            self.signInWithEmail(email: email, password: String(password))
        }
    }
    func signInWithEmail(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                print("Successfully signed in with Email")
                DispatchQueue.main.async {
                    self!.signState = .signIn
                    
                }
            }
        }
    }
}
