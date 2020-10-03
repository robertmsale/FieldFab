//
//  LoadDuctworkListItemView.swift
//  FieldFab
//
//  Created by Robert Sale on 10/2/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct LoadDuctworkListItemView: View {
    var dimensions: DimensionsData
    @State var dataShown: Bool = false
    @State var previewShown: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var al: AppLogic
    @EnvironmentObject var db: DB
    
    func fmtDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: dimensions.createdOn)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(dimensions.name).font(.title)
                Spacer()
                Button(action: {
                    var url = "fieldfab://load?name=\(dimensions.name)&"
                    url += "length=\(dimensions.length.description)&"
                    url += "width=\(dimensions.width.description)&"
                    url += "depth=\(dimensions.depth.description)&"
                    url += "offsetX=\(dimensions.offsetX.description)&"
                    url += "offsetY=\(dimensions.offsetY.description)&"
                    url += "tWidth=\(dimensions.tWidth.description)&"
                    url += "tDepth=\(dimensions.tDepth.description)&"
                    url += "isTransition=\(dimensions.isTransition.description)"
                    guard let data = URL(string: url) else { return }
                    let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                })
                .padding(.trailing)
                Button(action: {
                    db.dimensions = db.dimensions.filter({d in d.id != dimensions.id})
                    db.persist()
                }, label: {
                    Image(systemName: "trash")
                })
                .foregroundColor(.red)
                .padding(.trailing)
                Button(action: {
                    al.length = dimensions.length.toFraction(al.roundTo)
                    al.width = dimensions.width.toFraction(al.roundTo)
                    al.depth = dimensions.depth.toFraction(al.roundTo)
                    al.offsetX = dimensions.offsetX.toFraction(al.roundTo)
                    al.offsetY = dimensions.offsetY.toFraction(al.roundTo)
                    al.tWidth = dimensions.tWidth.toFraction(al.roundTo)
                    al.tDepth = dimensions.tDepth.toFraction(al.roundTo)
                    al.isTransition = dimensions.isTransition
                    al.sessionName = dimensions.name
                }, label: {
                    Text("Load")
                })
            }
            HStack(alignment: .center) {
                Text(fmtDate())
                Spacer()
                Button(action: {
                    withAnimation {
                        dataShown.toggle()
                    }
                }, label: {
                    Image(systemName: "chevron.up")
                        .font(.title)
                        .rotationEffect(Angle(degrees: dataShown ? 0 : 180))
                        .animation(.easeInOut, value: dataShown)
                })
            }
            Divider().opacity(dataShown ? 1 : 0)
            if dataShown {
                VStack {
                    VStack {
                        HStack {
                            Text("Length: ")
                            FText(Fraction(dimensions.length), true)
                            Spacer()
                        }
                        HStack {
                            Text("Width: ")
                            FText(Fraction(dimensions.width), true)
                            Spacer()
                        }
                        HStack {
                            Text("Depth: ")
                            FText(Fraction(dimensions.depth), true)
                            Spacer()
                        }
                        HStack {
                            Text("Offset X: ")
                            FText(Fraction(dimensions.offsetX), true)
                            Spacer()
                        }
                    }
                    Spacer()
                    VStack {
                        HStack {
                            Text("Is Transition: ")
                            Text(dimensions.isTransition ? "True" : "False").font(.headline)
                            Spacer()
                        }
                        HStack {
                            Text("T Width: ")
                            FText(Fraction(dimensions.tWidth), true)
                            Spacer()
                        }
                        HStack {
                            Text("T Depth: ")
                            FText(Fraction(dimensions.tDepth), true)
                            Spacer()
                        }
                        HStack {
                            Text("Offset Y: ")
                            FText(Fraction(dimensions.offsetY), true)
                            Spacer()
                        }
                    }
                }
            }
            Button(action: {
                withAnimation {
                    previewShown = true
                }
            }, label: {
                Text("Show Preview")
            })
            .opacity(!previewShown ? 1 : 0)
            
            if previewShown {
                ThreeDPreview(dimensions: Dimensions(from: dimensions), shown: $previewShown)
                    .frame(height: 200)
                    .transition(.scale)
            }
        }
        .padding(.all)
        .background(AppColors.ControlBG[colorScheme])
        .cornerRadius(15)
    }
}

struct LoadDuctworkListItemView_Previews: PreviewProvider {
    static var previews: some View {
            LoadDuctworkListItemView(dimensions:
                DimensionsData(
                name: "DerpaSherpa",
                createdOn: Date(),
                tabs: TabsData(),
                length: 5,
                width: 16.5,
                depth: 20,
                offsetX: 1,
                offsetY: 0,
                isTransition: true,
                tWidth: 20,
                tDepth: 16,
                id: UUID()))
                .environment(\.colorScheme, .dark)
                .environmentObject(AppLogic())
    }
}
