//
//  ProfileView.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    private let accentColor = Color.blue
    
    var body: some View {
        NavigationView {
            Group {
                if authViewModel.isAuthenticated, let user = authViewModel.user {
                    authenticatedView(user: user)
                } else {
                    guestView
                }
            }
            .navigationTitle("Profile")
        }
    }
    
    private func authenticatedView(user: AppUser) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Профиль пользователя
                // надо бы ещё автарки добавить
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.3))
                    
                    VStack(spacing: 4) {
                        Text(user.name ?? user.email ?? "Regular User")
                            .font(.title3.weight(.semibold))
                        
                        if user.email.lowercased() == "admin@example.com" {
                            Text("Administrator")
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.top, 24)
                
                // Список заказов
                VStack(alignment: .leading, spacing: 16) {
                    Text("Order History")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if profileViewModel.orders.isEmpty {
                        Text("You don't have any orders")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(profileViewModel.orders) { order in
                                orderCard(order: order)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Кнопка выхода
                Button(action: authViewModel.signOut) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.bottom)
        }
        .onAppear {
            profileViewModel.fetchOrders(for: user.id)
        }
    }
    
    private func orderCard(order: Order) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // дата в виде заголовка будет
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate(order.timestamp))
                    .font(.subheadline.weight(.semibold))
                
                Text("ID: \(order.id)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            // список товаров в заказе
            VStack(spacing: 8) {
                ForEach(order.products) { product in
                    HStack {
                        Text(product.name)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("\(product.quantity) × $\(product.price, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Divider()
            
            // итоговая сумма
            HStack {
                Text("Total:")
                    .font(.subheadline)
                
                Spacer()
                
                Text("$\(order.total, specifier: "%.2f")")
                    .font(.subheadline.weight(.semibold))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var guestView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "person.crop.circle.badge.questionmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .foregroundColor(.gray.opacity(0.3))
            
            Text("Sign In to access orders history")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            VStack(spacing: 12) {
                NavigationLink(destination: LoginView()) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(accentColor)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: RegistrationView()) {
                    Text("Create account")
                        .font(.headline)
                        .foregroundColor(accentColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(accentColor, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
