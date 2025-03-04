//
//  ProductListModel.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import Foundation
import Combine

class ProductListModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var selectedProduct: Product?
    
    func fetchProducts() {
        FirebaseService.shared.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    self?.products = products
                case .failure(let error):
                    print("Error fetching products: \(error.localizedDescription)")
                    self?.products = []
                }
            }
        }
    }
}

