import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import IQKeyboardManagerSwift
import GoogleSignIn


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        print(db)
        
        
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        // Google 로그인 URL 처리
        return GIDSignIn.sharedInstance.handle(url)
    }
    
}



@main
struct ConnectedApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    
}
