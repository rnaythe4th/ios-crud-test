//
//  AddProductView.swift
//  test-CRUD
//
//  Created by May on 4.03.25.
//

import SwiftUI

struct AddProductView: View {
    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var id = ""
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @EnvironmentObject var productVM: ProductListModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Info")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("ID", text: $id)
                    
                    // если изображение выбрано, показываем его
                    // иначе показываем кнопку для выбора
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                    } else {
                        Button("Select Image") {
                            showImagePicker = true
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Button("Add") {
                    uploadProduct()
                }
                .disabled(name.isEmpty || price.isEmpty)
            }
            .navigationTitle("Add new product")
            // показываем ImagePicker как sheet
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image)
            }
        }
    }
    
    private func uploadProduct() {
        guard let priceValue = Double(price),
              let imageData = image?.jpegData(compressionQuality: 0.8) else { return }
        
        FirebaseService.shared.addProduct(id: id, name: name, description: description, price: priceValue, imageData: imageData) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("successfully added")
                case .failure(let error):
                    print("error adding new product: \(error.localizedDescription)")
                }
            }
        }
        dismiss()
    }
}

struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddProductView()
            .environmentObject(ProductListModel())
    }
}
