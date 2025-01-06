import Foundation

class UserStore: ObservableObject {
    static let shared = UserStore()
    
    @Published var firstName: String = UserDefaults.standard.string(forKey: "firstName") ?? ""
    @Published var lastName: String = UserDefaults.standard.string(forKey: "lastName") ?? ""
    
    private init() {}
    
    func saveUserInfo(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
        UserDefaults.standard.set(firstName, forKey: "firstName")
        UserDefaults.standard.set(lastName, forKey: "lastName")
    }
} 