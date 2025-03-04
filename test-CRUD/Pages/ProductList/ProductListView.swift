//
//  ProductListView.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductListModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    private let spacing: CGFloat = 12
    private let horizontalPadding: CGFloat = 16
    
    // ширина плитки с учетом отступов и промежутка между двумя колонками
    private var itemWidth: CGFloat {
        (UIScreen.main.bounds.width - horizontalPadding * 2 - spacing) / 2
    }
    
    // фиксированные колонки с заданной шириной и промежутком
    private var columns: [GridItem] {
        [GridItem(.fixed(itemWidth), spacing: spacing),
         GridItem(.fixed(itemWidth), spacing: spacing)]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(viewModel.products) { product in
                        ProductPreviewCard(
                            product: product,
                            itemWidth: itemWidth
                        )
                        .onTapGesture {
                            viewModel.selectedProduct = product
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
            .navigationTitle("Products")
            // это для админа, пока надо подумать (в чек-листе)
            .toolbar {
                if authViewModel.isAdmin {
                    NavigationLink {
                        AddProductView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .refreshable { viewModel.fetchProducts() }
            .onAppear { viewModel.fetchProducts() }
            .sheet(item: $viewModel.selectedProduct) { product in
                ProductDetailsView(product: product)
            }
        }
    }
}

