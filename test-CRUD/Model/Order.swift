//
//  Order.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//

import Foundation

struct Order: Identifiable, Codable {
    let id: String
    let userID: String
    let products: [OrderedProduct]
    // сумма заказа
    let total: Double
    let timestamp: Date
    
    // модель для представления товара в заказе
    struct OrderedProduct: Identifiable, Codable {
        // идентификатор товара
        let id: String
        let name: String
        // цена за единицу товара
        let price: Double
        // количество товара в заказе
        let quantity: Int
    }
}
