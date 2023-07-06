//
//  ContentView.swift
//  tinder-clone
//
//  Created by Ajanth Kumarakuruparan on 2023/07/06.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var arcontroller = ARController()
    
    var body: some View {
        NavigationView{
            HomeView().environmentObject(arcontroller)
        }
    }
}

