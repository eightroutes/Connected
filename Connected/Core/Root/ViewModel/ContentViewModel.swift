import FirebaseAuth
import FirebaseFirestore

class ContentViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()

    init() {
        setupAuthStateListener()
    }
    
    func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            self.userSession = user
            if let user = user {
                print("User logged in: \(user.uid)")
                self.fetchCurrentUser(uid: user.uid)
            } else {
                print("User logged out")
                self.currentUser = nil
            }
        }
    }
    
    func fetchCurrentUser(uid: String) {
        let document = db.collection("users").document(uid)
        document.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    self.currentUser = try document.data(as: User.self)
                    print("Current user fetched: \(self.currentUser)")
                } catch {
                    print("Error decoding user: \(error)")
                }
            } else {
                print("User document does not exist")
                self.currentUser = nil
            }
        }
    }
    
    deinit {
        if let handle = authStateListener {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
