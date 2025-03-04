//
//  CartViewModel.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    
    // добавляет товар в корзину с заданным количеством
    // если товар уже существует, увеличивает его количество
    func add(product: Product, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += quantity
        } else {
            let newItem = CartItem(id: product.id, product: product, quantity: quantity)
            cartItems.append(newItem)
        }
    }
    
    // обновляет количество товара в корзине
    func updateQuantity(for productID: String, newQuantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.product.id == productID }) {
            cartItems[index].quantity = newQuantity
        }
    }
    
    // возвращает общее количество единиц товара с указанным id в корзине
    func totalCount(for productID: String) -> Int {
        return cartItems.first(where: { $0.product.id == productID })?.quantity ?? 0
    }
    
    // удаляет товар из корзины по его id
    func remove(productID: String) {
        cartItems.removeAll { $0.id == productID }
    }
    
    // удаляет товары, идентификаторы которых содержатся в переданном наборе
    func remove(itemsIDs: Set<String>) {
        cartItems.removeAll { itemsIDs.contains($0.id) }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
    
    func totalSum() -> Double {
        cartItems.reduce(0.0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
}
