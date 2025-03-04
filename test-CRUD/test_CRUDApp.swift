//
//  test_CRUDApp.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//

import SwiftUI
import Firebase

@main
struct test_CRUDApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
