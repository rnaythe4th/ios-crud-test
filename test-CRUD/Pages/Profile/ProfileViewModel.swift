//
//  ProfileViewModel.swift
//  test-CRUD
//
//  Created by May on 4.03.25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var orders: [Order] = []
    
    private let db = Firestore.firestore()
    
    // для конкретного пользователя
    func fetchOrders(for userID: String) {
        db.collection("orders")
            .whereField("userID", isEqualTo: userID)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching orders: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("no docs")
                    return
                }
                
                let fetchedOrders: [Order] = documents.compactMap { doc in
                    let data = doc.data()
                    
                    guard let userID = data["userID"] as? String,
                          let total = data["total"] as? Double,
                          let timestamp = data["timestamp"] as? Timestamp,
                          let productsData = data["products"] as? [[String: Any]] else {
                        return nil
                    }
                    
                    let orderedProducts: [Order.OrderedProduct] = productsData.compactMap { productDict in
                        guard let id = productDict["id"] as? String,
                              let name = productDict["name"] as? String,
                              let price = productDict["price"] as? Double,
                              let quantity = productDict["quantity"] as? Int else {
                            return nil
                        }
                        return Order.OrderedProduct(id: id, name: name, price: price, quantity: quantity)
                    }
                    
                    return Order(id: doc.documentID,
                                 userID: userID,
                                 products: orderedProducts,
                                 total: total,
                                 timestamp: timestamp.dateValue())
                }
                
                DispatchQueue.main.async {
                    self?.orders = fetchedOrders
                }
            }
    }
}
