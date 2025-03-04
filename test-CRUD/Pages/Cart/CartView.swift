//
//  CartView.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import SwiftUI

struct CartView: View {
    @EnvironmentObject var cart: CartViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLoginAlert = false
    @State private var navigateToLogin = false
    @State private var isEditing = false
    @State private var selection = Set<String>()
    
    private let accentColor = Color(red: 0.2, green: 0.5, blue: 0.8)
    private let lightBackground = Color(red: 0.95, green: 0.97, blue: 1.0)
    
    var body: some View {
        NavigationView {
            Group {
                if cart.cartItems.isEmpty {
                    emptyCartView
                } else {
                    cartContentView
                }
            }
            .navigationTitle("Cart")
            .toolbar { editingToolbarItem }
            .alert(isPresented: $showLoginAlert) { loginAlert }
            .background(navigationLink)
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("Cart is Empty")
                .font(.title3)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var cartContentView: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(cart.cartItems) { item in
                        cartItemView(item: item)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(lightBackground)
            
            checkoutSection
        }
    }
    
    private func cartItemView(item: CartItem) -> some View {
        HStack(alignment: .top, spacing: 16) {
            if isEditing {
                selectionButton(for: item.id)
            }
            
            AsyncImage(url: URL(string: item.product.thumbURL)) { phase in
                Group {
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                        //.aspectRatio(contentMode: .fit)
                    } else if phase.error != nil {
                        Color.gray.opacity(0.3)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 80, height: 80)
            }
            .frame(width: 80, height: 80)
            .background(Color.gray.opacity(0.1))
            .clipped()
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.product.name)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(2)
                
                Text("$\(item.product.price, specifier: "%.2f")")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                quantityStepper(for: item)
                
                Text("Total: $\(item.product.price * Double(item.quantity), specifier: "%.2f")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(accentColor)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func selectionButton(for id: String) -> some View {
        Button {
            withAnimation {
                if selection.contains(id) {
                    selection.remove(id)
                } else {
                    selection.insert(id)
                }
            }
        } label: {
            Image(systemName: selection.contains(id) ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22))
                .foregroundColor(selection.contains(id) ? accentColor : Color.gray.opacity(0.5))
        }
        .transition(.scale)
    }
    
    private func quantityStepper(for item: CartItem) -> some View {
        HStack {
            Text("Quantity:")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button {
                    cart.updateQuantity(for: item.product.id, newQuantity: max(1, item.quantity - 1))
                } label: {
                    Image(systemName: "minus")
                        .font(.caption.weight(.bold))
                        .frame(width: 24, height: 24)
                        .background(accentColor.opacity(0.1))
                        .foregroundColor(accentColor)
                        .cornerRadius(4)
                }
                
                Text("\(item.quantity)")
                    .font(.system(size: 14, weight: .medium))
                    .frame(minWidth: 20)
                
                Button {
                    cart.updateQuantity(for: item.product.id, newQuantity: min(10, item.quantity + 1))
                } label: {
                    Image(systemName: "plus")
                        .font(.caption.weight(.bold))
                        .frame(width: 24, height: 24)
                        .background(accentColor.opacity(0.1))
                        .foregroundColor(accentColor)
                        .cornerRadius(4)
                }
            }
        }
    }
    
    private var checkoutSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Total:")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Text("$\(cart.totalSum(), specifier: "%.2f")")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(accentColor)
            }
            .padding(.horizontal)
            
            if !selection.isEmpty && isEditing {
                Button {
                    withAnimation {
                        cart.remove(itemsIDs: selection)
                        selection.removeAll()
                    }
                } label: {
                    Text("Remove selected (\(selection.count))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .padding(.horizontal)
            }
            
            Button {
                placeOrder()
            } label: {
                Text("Place order")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.top)
        .background(Color.white)
    }
    
    private var editingToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(isEditing ? "Done" : "Edit") {
                withAnimation(.easeInOut) {
                    isEditing.toggle()
                    if !isEditing { selection.removeAll() }
                }
            }
            .foregroundColor(accentColor)
        }
    }
    
    private var loginAlert: Alert {
        Alert(
            title: Text("Login Required"),
            message: Text("Log In to your account to place order"),
            primaryButton: .default(Text("Sign In")) {
                navigateToLogin = true
            },
            secondaryButton: .cancel()
        )
    }
    
    private var navigationLink: some View {
        NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
            EmptyView()
        }
    }
    
    
    private func placeOrder() {
        guard let userID = authViewModel.user?.id else {
            showLoginAlert = true
            return
        }
        
        let total = cart.totalSum()
        let orderedProducts = cart.cartItems.map { cartItem in
            Order.OrderedProduct(id: cartItem.product.id,
                                 name: cartItem.product.name,
                                 price: cartItem.product.price,
                                 quantity: cartItem.quantity)
        }
        
        let order = Order(id: UUID().uuidString,
                          userID: userID,
                          products: orderedProducts,
                          total: total,
                          timestamp: Date())
        
        FirebaseService.shared.createOrder(order: order) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    cart.clearCart()
                case .failure(let error):
                    print("Error placing order: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(CartViewModel())
            .environmentObject(AuthViewModel())
    }
}
