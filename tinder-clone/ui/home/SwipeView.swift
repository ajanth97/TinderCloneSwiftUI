//
//  SwipeView.swift
//  tinder-clone
//
//

import SwiftUI
import os
import SwiftCSVExport


enum SwipeAction{
    case swipeLeft, swipeRight, doNothing
}

let hasLikedField = "hasLiked"

struct SwipeView: View {
    @Binding var profiles: [ProfileCardModel]
    @State var swipeAction: SwipeAction = .doNothing
    @EnvironmentObject var writeCSV:CSV
    @EnvironmentObject var arcontroller: ARController
    //Bool: true if it was a like (swipe to the right
    var onSwiped: (ProfileCardModel, Bool) -> ()
    
    var body: some View {
        VStack{
            Spacer()
            VStack{
                ZStack{
                    Text("no-more-profiles").font(.title3).fontWeight(.medium).foregroundColor(Color(UIColor.systemGray)).multilineTextAlignment(.center)
                    ForEach(profiles.indices, id: \.self){ index  in
                        let model: ProfileCardModel = profiles[index]
                        
                        
                        if(index == profiles.count - 1){
                            SwipeableCardView(model: model, swipeAction: $swipeAction, onSwiped: performSwipe)
                            
                        } else if(index == profiles.count - 2){
                            SwipeCardView(model: model)
                        }
                    }
                }
            }.padding()
            Spacer()
            HStack{
                Spacer()
                GradientOutlineButton(action:{swipeAction = .swipeLeft}, iconName: "multiply", colors: AppColor.dislikeColors)
                Spacer()
                GradientOutlineButton(action: {swipeAction = .swipeRight}, iconName: "heart", colors: AppColor.likeColors)
                Spacer()
            }.padding(.bottom)
        }
        .onAppear{
            if let headers = arcontroller.blendShapes?.map({return $0.key}) {
                var fields = headers as! NSArray
                fields = fields.adding(hasLikedField) as NSArray
                writeCSV.fields = fields
                writeCSV.rows = NSArray()
            }
        }
    }
    
    private func performSwipe(userProfile: ProfileCardModel, hasLiked: Bool){
        removeTopItem()
        onSwiped(userProfile, hasLiked)
    }
    
    private func removeTopItem(){
        profiles.removeLast()
    }
    
    
}

//Swipe functionality
struct SwipeableCardView: View {

    private let nope = "NOPE"
    private let like = "LIKE"
    private let screenWidthLimit = UIScreen.main.bounds.width * 0.5
    
    let model: ProfileCardModel
    @State private var dragOffset = CGSize.zero
    @Binding var swipeAction: SwipeAction
    @EnvironmentObject var arcontroller: ARController
    @EnvironmentObject var writeCSV:CSV
    let swipeLogger = Logger()
    
    var onSwiped: (ProfileCardModel, Bool) -> ()
    
    var body: some View {
        SwipeCardView(model: model)
            .overlay(
                HStack{
                    Text(like).font(.largeTitle).bold().foregroundGradient(colors: AppColor.likeColors).padding().overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(LinearGradient(gradient: .init(colors: AppColor.likeColors),
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing), lineWidth: 4)
                    ).rotationEffect(.degrees(-30)).opacity(getLikeOpacity())
                    Spacer()
                    Text(nope).font(.largeTitle).bold().foregroundGradient(colors: AppColor.dislikeColors).padding().overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(LinearGradient(gradient: .init(colors: AppColor.dislikeColors),
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing), lineWidth: 4)
                    ).rotationEffect(.degrees(30)).opacity(getDislikeOpacity())
                    
                }.padding(.top, 45).padding(.leading, 20).padding(.trailing, 20)
                ,alignment: .top)
            .offset(x: self.dragOffset.width,y: self.dragOffset.height)
            .rotationEffect(.degrees(self.dragOffset.width * -0.06), anchor: .center)
            .simultaneousGesture(DragGesture(minimumDistance: 0.0).onChanged{ value in
                self.dragOffset = value.translation
            }.onEnded{ value in
                performDragEnd(value.translation)
                //print("onEnd: \(value.location)")
            }).onChange(of: swipeAction, perform: { newValue in
                if newValue != .doNothing {
                    performSwipe(newValue)
                }
                
            })
            .onAppear {
                //self.swipeLogger.debug("Displaying profile...")
                //let blendShapesArr = arcontroller.blendShapes?.map{return $0.key}
                let row = arcontroller.blendShapes
                writeCSV.rows = writeCSV.rows.adding(row) as NSArray
                //print(writeCSV.rows)
                
            }
    }
    
    private func performSwipe(_ swipeAction: SwipeAction){
        withAnimation(.linear(duration: 0.3)){
            if(swipeAction == .swipeRight){
                self.dragOffset.width += screenWidthLimit * 2
            } else if(swipeAction == .swipeLeft){
                self.dragOffset.width -= screenWidthLimit * 2
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSwiped(model, swipeAction == .swipeRight)
        }
        self.swipeAction = .doNothing
    }
    
    private func performDragEnd(_ translation: CGSize){
        let translationX = translation.width
        if(hasLiked(translationX)){
            withAnimation(.linear(duration: 0.3)){
                self.dragOffset = translation
                self.dragOffset.width += screenWidthLimit
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwiped(model, true)
            }
        } else if(hasDisliked(translationX)){
            withAnimation(.linear(duration: 0.3)){
                self.dragOffset = translation
                self.dragOffset.width -= screenWidthLimit
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onSwiped(model, false)
            }
        } else{
            withAnimation(.default){
                self.dragOffset = .zero
            }
        }
    }
    
    private func hasLiked(_ value: Double) -> Bool{
        let ratio: Double = dragOffset.width / screenWidthLimit
        return ratio >= 1
    }
    
    private func hasDisliked(_ value: Double) -> Bool{
        let ratio: Double = -dragOffset.width / screenWidthLimit
        return ratio >= 1
    }
    
    private func getLikeOpacity() -> Double{
        let ratio: Double = dragOffset.width / screenWidthLimit;
        if(ratio >= 1){
            return 1.0
        } else if(ratio <= 0){
            return 0.0
        } else {
            return ratio
        }
    }
    
    private func getDislikeOpacity() -> Double{
        let ratio: Double = -dragOffset.width / screenWidthLimit;
        if(ratio >= 1){
            return 1.0
        } else if(ratio <= 0){
            return 0.0
        } else {
            return ratio
        }
    }
}

//Card design
struct SwipeCardView: View {
    let model: ProfileCardModel
    
    @State private var currentImageIndex: Int = 0
    
    var body: some View {
        
        ZStack(alignment: .bottom){
            GeometryReader{ geometry in
                Image(uiImage: model.pictures[currentImageIndex])
                    .centerCropped()
                    .gesture(DragGesture(minimumDistance: 0).onEnded({ value in
                        if value.translation.equalTo(.zero){
                            if(value.location.x <= geometry.size.width/2){
                                showPrevPicture()
                            } else { showNextPicture()}
                        }
                    }))
                }
            
            VStack{
                if(model.pictures.count > 1){
                    HStack{
                        ForEach(0..<model.pictures.count, id: \.self){ index in
                            Rectangle().frame(height: 3).foregroundColor(index == currentImageIndex ? .white : .gray).opacity(index == currentImageIndex ? 1 : 0.5)
                        }
                    }
                    .padding(.top, 6)
                    .padding(.leading)
                    .padding(.trailing)
                   
                }
                Spacer()
                VStack{
                    HStack(alignment: .firstTextBaseline){
                        Spacer()
                    }
                }
                .padding()
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(0.7, contentMode: .fit)
        .background(.white)
        .cornerRadius(10)
        .shadow(radius: 10)

    }
    
    private func showNextPicture(){
        if currentImageIndex < model.pictures.count - 1 {
            currentImageIndex += 1
        }
    }
    
    private func showPrevPicture(){
        if currentImageIndex > 0 {
            currentImageIndex -= 1
        }
    }
}
