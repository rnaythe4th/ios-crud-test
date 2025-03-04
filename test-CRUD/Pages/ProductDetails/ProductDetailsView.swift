//
//  ProductDetailsView.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import SwiftUI

struct ProductDetailsView: View {
    let product: Product
    @EnvironmentObject var cart: CartViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showAddedAlert = false
    @State private var quantityToAdd: Int = 1
    private let accentColor = Color.blue
    
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            ScrollView {
                VStack(spacing: 20) {
                    productImage
                    
                    VStack(spacing: 16) {
                        Text(product.name)
                            .font(.system(size: 22, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Text(product.description)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                            .padding(.horizontal)
                    }
                }
            }
            
            bottomPanel
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .alert(isPresented: $showAddedAlert) { addAlert }
    }
    
    private var productImage: some View {
        AsyncImage(url: URL(string: product.imgURL)) { phase in
            Group {
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                } else if phase.error != nil {
                    Color.gray.opacity(0.1)
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
    
    private var bottomPanel: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                Text(String(format: "$%.2f", product.price))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(accentColor)
                
                Spacer()
                
                addToCartButton
            }
            .padding(16)
        }
        .background(Color.white)
    }
    
    private var addToCartButton: some View {
        Button(action: addToCart) {
            Text("Add to Cart")
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .overlay(alignment: .topTrailing) {
                    if cartCount > 0 {
                        Text("\(cartCount)")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .offset(x: 8, y: -8)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var cartCount: Int {
        cart.totalCount(for: product.id)
    }
    
    private var addAlert: Alert {
        Alert(
            title: Text("Added to Cart"),
            message: Text("\(product.name) successfully added to your cart"),
            dismissButton: .default(Text("OK"))
        )
    }
    
    private func addToCart() {
        cart.add(product: product, quantity: quantityToAdd)
        showAddedAlert = true
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
