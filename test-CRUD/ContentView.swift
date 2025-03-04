//
//  ContentView.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var cart = CartViewModel()
    
    var body: some View {
        TabView {
            ProductListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Products")
                }
            
            CartView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Cart")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
        .environmentObject(cart)
    }
}

#Preview {
    ContentView()
}
