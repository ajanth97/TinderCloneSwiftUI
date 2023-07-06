//
//  HomeViewModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 27/10/22.
//

import Foundation
import SwiftUI

class HomeViewModel: NSObject, ObservableObject {
    
    override init(){
        super.init()
        self.userProfiles.shuffle()
    }
    
    @Published var userProfiles: [ProfileCardModel] = [
        ProfileCardModel(userId: "1", name: "Nozomi", age: 25, pictures: [UIImage(imageLiteralResourceName: "1"),]),
        ProfileCardModel(userId: "2", name: "Hikari", age: 22, pictures: [UIImage(imageLiteralResourceName: "2"),]),
        ProfileCardModel(userId: "3", name: "Ayaka", age: 23, pictures: [UIImage(imageLiteralResourceName: "3"),]),
        ProfileCardModel(userId: "4", name: "Moe", age: 26, pictures: [UIImage(imageLiteralResourceName: "4"),]),
        ProfileCardModel(userId: "5", name: "Aya", age: 19, pictures: [UIImage(imageLiteralResourceName: "5"),]),
        ProfileCardModel(userId: "6", name: "Miyu", age: 24, pictures: [UIImage(imageLiteralResourceName: "6"),]),
    ]

    
    func swipeUser(user: ProfileCardModel, hasLiked: Bool) {
        print("Swiped on \(user) and Liked : \(hasLiked)")
    }
    
}
