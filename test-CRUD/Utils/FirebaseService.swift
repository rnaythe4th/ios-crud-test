//
//  FirebaseService.swift
//  test-CRUD
//
//  Created by May on 3.03.25.
//
import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class FirebaseService {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // загружает список товаров из коллекции products
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let documents = snapshot?.documents {
                let products = documents.compactMap { doc -> Product? in
                    let data = doc.data()
                    guard let name = data["name"] as? String,
                          let thumbURL = data["thumbURL"] as? String,
                          let imgURL = data["imgURL"] as? String,
                          let description = data["description"] as? String,
                          let price = data["price"] as? Double else { return nil }
                    
                    return Product(id: doc.documentID,
                                   name: name,
                                   description: description,
                                   price: price,
                                   thumbURL: thumbURL,
                                   imgURL: imgURL)
                }
                completion(.success(products))
            }
        }
    }
    
    // добавляет товар в коллекцию products
    func addProduct(id: String, name: String, description: String, price: Double, imageData: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let imageID = UUID().uuidString
        let storageRef = storage.reference().child("products/\(imageID).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let url = url else {
                    let err = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL not recieved"])
                    completion(.failure(err))
                    return
                }
                
                let data: [String: Any] = [
                    "name": name,
                    "description": description,
                    "price": price,
                    // пока что один URL для превью и для полного изображения, надо как-нибуль сделать создание превьюхи
                    "thumbURL": url.absoluteString,
                    "imgURL": url.absoluteString
                ]
                self.db.collection("products").document(id).setData(data) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
    func deleteProduct(product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        // удаление из Firestore
        db.collection("products").document(product.id).delete() {
            error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
        // удаление изображения из Storage
        storage.reference(forURL: product.thumbURL).delete() {
            error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func createOrder(order: Order, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("orders").addDocument(data: [
            "userID": order.userID,
            "products": order.products.map { [
                "id": $0.id,
                "name": $0.name,
                "price": $0.price,
                "quantity": $0.quantity
            ] },
            "total": order.total,
            "timestamp": Timestamp(date: order.timestamp)
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<AppUser, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = authResult?.user else {
                completion(.failure(NSError(domain: "AuthError", code: -1)))
                return
            }
            
            self.createUserRecord(uid: firebaseUser.uid, role: .user) { result in
                switch result {
                case .success:
                    let user = AppUser(
                        id: firebaseUser.uid,
                        email: email,
                        name: firebaseUser.displayName,
                        role: .user
                    )
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<AppUser, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = authResult?.user else {
                completion(.failure(NSError(domain: "AuthError", code: -1)))
                return
            }
            
            // получаем роль из Firestore
            self.fetchUserRole(uid: firebaseUser.uid) { result in
                switch result {
                case .success(let role):
                    let user = AppUser(
                        id: firebaseUser.uid,
                        email: email,
                        name: firebaseUser.displayName,
                        role: role
                    )
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // получает роль пользователя из Firestore
    func fetchUserRole(uid: String, completion: @escaping (Result<AppUser.Role, Error>) -> Void) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = snapshot?.data() {
                let roleString = data["role"] as? String ?? "user"
                let role = AppUser.Role(rawValue: roleString) ?? .user
                completion(.success(role))
            } else {
                // Если записи нет, создаем новую с ролью юзера
                self.createUserRecord(uid: uid, role: AppUser.Role.user) { _ in
                    completion(.success(.user))
                }
            }
        }
    }
    
    // создает запись пользователя в Firestore
    private func createUserRecord(uid: String, role: AppUser.Role, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(uid).setData([
            "role": role.rawValue
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
