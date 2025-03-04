//
//  AuthModel.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//

import Foundation
import Combine
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: AppUser? = nil
    @Published var firebaseuser: User? = nil
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var userRole: String = "user"
    @Published var isAdmin: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // отслеживаем изменения состояния аутентификации
        Auth.auth().addStateDidChangeListener { [weak self] auth, firebaseUser in
            if let firebaseUser = firebaseUser {
                self?.isAuthenticated = true
                // получаем роль и обновляем модель пользователя
                FirebaseService.shared.fetchUserRole(uid: firebaseUser.uid) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let role):
                            let appUser = AppUser(
                                id: firebaseUser.uid,
                                email: firebaseUser.email ?? "",
                                name: firebaseUser.displayName,
                                role: role
                            )
                            self?.user = appUser
                            self?.isAdmin = (role == .admin)
                        case .failure(let error):
                            self?.errorMessage = error.localizedDescription
                            // если ошибка, устанавливаем роль обычного юзера
                            let appUser = AppUser(
                                id: firebaseUser.uid,
                                email: firebaseUser.email ?? "",
                                name: firebaseUser.displayName,
                                role: .user
                            )
                            self?.user = appUser
                        }
                    }
                }
            } else {
                self?.user = nil
                self?.isAuthenticated = false
            }
        }
    }
    
    
    func signIn(email: String, password: String) {
        FirebaseService.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let appUser):
                    self?.user = appUser
                    self?.errorMessage = nil
                    self?.isAuthenticated = true
                    self?.isAdmin = (appUser.role == .admin)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    func signUp(email: String, password: String, confirmPassword: String) {
        guard password == confirmPassword else {
            self.errorMessage = "Passwords don't match"
            return
        }
        
        FirebaseService.shared.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let appUser):
                    self?.user = appUser
                    self?.errorMessage = nil
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    func signOut() {
        AuthService.shared.signOut { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.user = nil
                    self?.isAuthenticated = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
