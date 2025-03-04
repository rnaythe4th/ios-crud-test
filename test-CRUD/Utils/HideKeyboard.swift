//
//  HideKeyboard.swift
//  test-CRUD
//
//  Created by May on 4.03.25.
//
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
