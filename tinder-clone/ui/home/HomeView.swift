//
//  HomeView.swift
//  Tinder 2
//
//  Created by Alejandro Piguave on 31/12/21.
//

import SwiftUI
import SwiftCSVExport

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var showMatchView = false
    @EnvironmentObject var writeCSV:CSV
    @State private var startSwiping = false
    
    
    var body: some View {
        ZStack{
            VStack{
                Button(action: {
                    self.startSwiping.toggle()
                }, label: {
                    Text("Start/Stop Swipping")
                })
                CameraView()
                if startSwiping{
                    SwipeView(
                        profiles: $homeViewModel.userProfiles,
                        onSwiped: { userModel, hasLiked in
                            homeViewModel.swipeUser(user: userModel, hasLiked: hasLiked)
                        }
                    )
                }
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
        .onAppear{
            self.homeViewModel.writeCSV = writeCSV
        }
    }

}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
