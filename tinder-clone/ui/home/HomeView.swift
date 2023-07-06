//
//  HomeView.swift
//  Tinder 2
//
//  Created by Alejandro Piguave on 31/12/21.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var showMatchView = false

    var body: some View {
        ZStack{
            VStack{
                CameraView()
                SwipeView(
                        profiles: $homeViewModel.userProfiles,
                        onSwiped: { userModel, hasLiked in
                            homeViewModel.swipeUser(user: userModel, hasLiked: hasLiked)
                        }
                    )
                }
            }
      
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal){
                Image(systemName: "heart").resizable().scaledToFit().frame(height: 35)
                        .foregroundGradient(colors: AppColor.appColors)
                        .frame(maxWidth: .infinity)
            }
        }
    }

}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
