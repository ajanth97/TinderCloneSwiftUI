//
//  HomeViewModel.swift
//  tinder-clone
//
//  Created by Alejandro Piguave on 27/10/22.
//

import Foundation
import SwiftUI
import SwiftCSVExport
import os


class HomeViewModel: NSObject, ObservableObject {
    var writeCSV:CSV
    let csvLogger: Logger
    override init(){
        writeCSV = CSV()
        self.csvLogger = Logger()
        super.init()
        self.userProfiles.shuffle()
    }
    
    @Published var userProfiles: [ProfileCardModel] = [
        ProfileCardModel(userId: "1", pictures: [UIImage(imageLiteralResourceName: "1"),]),
        ProfileCardModel(userId: "2", pictures: [UIImage(imageLiteralResourceName: "2"),]),
        ProfileCardModel(userId: "3", pictures: [UIImage(imageLiteralResourceName: "3"),]),
        ProfileCardModel(userId: "4", pictures: [UIImage(imageLiteralResourceName: "4"),]),
        ProfileCardModel(userId: "5", pictures: [UIImage(imageLiteralResourceName: "5"),]),
        ProfileCardModel(userId: "6", pictures: [UIImage(imageLiteralResourceName: "6"),]),
    ]

    
    func swipeUser(user: ProfileCardModel, hasLiked: Bool) {
        //csvLogger.log("Swiped on \(user) and Liked : \(hasLiked)")
        var oldRows = writeCSV.rows.dropLast(1) as! Array<Any>
        var currentRow = writeCSV.rows.lastObject as! Dictionary<String,Any>
        currentRow[hasLikedField] = hasLiked
        oldRows.append(currentRow)
        self.writeCSV.rows = oldRows as NSArray
    

        if self.userProfiles.count == 0 {
            self.csvLogger.debug("Finished all profiles")
            let currentTimestamp = Date()
            let timestampFormatter = DateFormatter()
            timestampFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let currentTimestampString = timestampFormatter.string(from: currentTimestamp)
            self.writeCSV.name = currentTimestampString
            let output = CSVExport.export(self.writeCSV)
            if output.result.isSuccess {
                guard let filePath = output.filePath else {
                    self.csvLogger.debug("Export Error: \(String(describing: output.message),privacy: .public)")
                    return
                }
                self.csvLogger.debug("File Path: \(filePath, privacy: .public)")
            } else {
                self.csvLogger.debug("Export Error: \(String(describing: output.message), privacy: .public)")
            }
        }
    }
    
}
