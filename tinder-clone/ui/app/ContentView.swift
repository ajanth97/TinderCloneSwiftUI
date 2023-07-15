//
//  ContentView.swift
//  tinder-clone
//
//  Created by Ajanth Kumarakuruparan on 2023/07/06.
//

import SwiftUI
import SwiftCSVExport

extension CSV : ObservableObject{
    
}

struct ContentView: View {
    @StateObject private var arcontroller = ARController()
    @StateObject private var writeCSV = CSV()
    
    var body: some View {
        NavigationView{
            HomeView().environmentObject(arcontroller).environmentObject(writeCSV)
        }
    }
}
