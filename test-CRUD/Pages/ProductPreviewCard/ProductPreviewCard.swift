//
//  ProductPreviewCard.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import SwiftUI

struct ProductPreviewCard: View {
    let product: Product
    let itemWidth: CGFloat
    private let imageHeight: CGFloat = 160

    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: product.thumbURL)) { phase in
                Group {
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else if phase.error != nil {
                        Color.gray.opacity(0.2)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: itemWidth - 16, height: imageHeight)
                .clipped()
            }
            .cornerRadius(12)
            
            // название и цена
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(2)
                Text(String(format: "$%.2f", product.price))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)
            }
            .frame(width: itemWidth - 16, alignment: .leading)
            .padding(.bottom, 8)
        }
        .frame(width: itemWidth)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        // (показ только для админа)
        .overlay(alignment: .bottomTrailing) {
            if authViewModel.isAdmin {
                Button(action: {
                    FirebaseService.shared.deleteProduct(product: product) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                print("deleted successfully")
                            case .failure(let error):
                                print("Error fetching products: \(error.localizedDescription)")
                            }
                        }
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(6)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                }
                .padding(8)
            }
        }
    }
    
}
