//
//  Product.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import Foundation

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let thumbURL: String
    let imgURL: String
}
