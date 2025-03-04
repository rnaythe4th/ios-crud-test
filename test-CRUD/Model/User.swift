//
//  User.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import Foundation

struct AppUser: Identifiable, Codable {
    let id: String
    let email: String
    let name: String?
    let role: Role
    
    enum Role: String, Codable {
        case user    // обычный юзер
        case admin   // админ
    }
}

