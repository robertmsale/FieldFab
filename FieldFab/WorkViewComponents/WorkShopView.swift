//
//  WorkShopView.swift
//  FieldFab
//
//  Created by Robert Sale on 12/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct WorkShopView: View {
    typealias Face = DuctData.FaceAndAll
    @Binding var data: Duct
    @State var tabEdge: DuctTab.Edge = .top
    @Environment(\.verticalSizeClass) var sizeClass
    @EnvironmentObject var state: AppState
    let sw = UIScreen.main.bounds.size
    init(data: Binding<Duct>) {
        _data = data
    }
    var facePicker: some View {
        Picker("", selection: Binding<Face>(get: {state.selectedFace}, set: {state.selectedFace = $0})) {
            Text(Face.front.rawValue).tag(Face.front)
            Text(Face.back.rawValue).tag(Face.back)
            Text(Face.left.rawValue).tag(Face.left)
            Text(Face.right.rawValue).tag(Face.right)
            Text(Face.all.rawValue).tag(Face.all)
        }.pickerStyle(SegmentedPickerStyle())
    }
    var content: some View {
            Group() {
                VStack(alignment: .center, spacing: 0) {
                    if sizeClass == .regular {
                        facePicker
                    }
                    if state.selectedFace != .all {
                        DuctSideView(face: state.selectedFace.noAll, duct: $data)
                            .animation(.easeInOut)
                            .aspectRatio(1, contentMode: .fit)
                    } else {
                        VStack {
                            HStack {
                                DuctSideView(face: .front, showMeasurements: false, duct: $data).aspectRatio(1, contentMode: .fit).animation(.easeInOut)
                                DuctSideView(face: .back, showMeasurements: false, duct: $data).aspectRatio(1, contentMode: .fit).animation(.easeInOut)
                            }
                            HStack {
                                DuctSideView(face: .left, showMeasurements: false, duct: $data).aspectRatio(1, contentMode: .fit).animation(.easeInOut)
                                DuctSideView(face: .right, showMeasurements: false, duct: $data).aspectRatio(1, contentMode: .fit).animation(.easeInOut)
                            }
                        }
                    }
                }.padding()
                VStack {
                    if sizeClass != .regular {
                        facePicker
                    }
                    VStack {
                        Form {
                            Section(header: Text("Measurements")) {
                                HStack {
                                    Text("Units")
                                    Spacer()
                                    Picker("\(data.data.depth.value.unit.symbol)", selection: Binding(get: {
                                        data.data.depth.value.unit
                                    }, set: { (k, v) in
                                        data.data.width.value.convert(to: k)
                                        data.data.depth.value.convert(to: k)
                                        data.data.length.value.convert(to: k)
                                        data.data.offsetx.value.convert(to: k)
                                        data.data.offsety.value.convert(to: k)
                                        data.data.twidth.value.convert(to: k)
                                        data.data.tdepth.value.convert(to: k)
                                    }), content: {
                                        Text("Inches").tag(UnitLength.inches)
                                        Text("Feet").tag(UnitLength.feet)
                                        Text("Meters").tag(UnitLength.meters)
                                        Text("Centimeters").tag(UnitLength.centimeters)
                                        Text("Millimeters").tag(UnitLength.millimeters)
                                    }).pickerStyle(WheelPickerStyle()).frame(width: 120, height: 30, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 5))
                                }
                                HStack {
                                    Text("Width:")
                                    Spacer()
                                    NumberSlider($data.data.width).fixedSize(horizontal: true, vertical: false)
                                }
                                HStack {
                                    Text("Depth:")
                                    Spacer()
                                    NumberSlider($data.data.depth).fixedSize(horizontal: true, vertical: false)
                                }
                                HStack {
                                    Text("Length:")
                                    Spacer()
                                    NumberSlider($data.data.length).fixedSize(horizontal: true, vertical: false)
                                }
                                HStack {
                                    Text("Offset X:")
                                    Spacer()
                                    NumberSlider($data.data.offsetx, isNegatable: true).fixedSize(horizontal: true, vertical: false)
                                }
                                HStack {
                                    Text("Offset Y:")
                                    Spacer()
                                    NumberSlider($data.data.offsety, isNegatable: true).fixedSize(horizontal: true, vertical: false)
                                }
                                HStack {
                                    Text("T Width:")
                                    Spacer()
                                    NumberSlider($data.data.twidth).fixedSize(horizontal: true, vertical: false)
                                }
                                HStack {
                                    Text("T Depth:")
                                    Spacer()
                                    NumberSlider($data.data.tdepth).fixedSize(horizontal: true, vertical: false)
                                }
                            }
                            Section(header: Text("Tabs")) {
                                Picker("Edge", selection: $tabEdge, content: {
                                    ForEach(DuctTab.Edge.allCases, content: {e in
                                        Text(e.rawValue).tag(e)
                                    })
                                }).pickerStyle(SegmentedPickerStyle())
                                
                                TabLengthPicker(face: state.selectedFace, edge: tabEdge, data: $data.data.tabs[state.selectedFace.noAll, tabEdge])
                                TabTypePicker(face: state.selectedFace, edge: tabEdge, data: $data.data.tabs[state.selectedFace.noAll, tabEdge])
                            }
                        }
                    }
//                    .popup(isPresented: Binding<Bool>(get: {
//                        state.showWorkShopTips && state.showWorkShopTipsAgain
//                    }, set: {
//                        state.showWorkShopTips = $0
//                    }), type: .toast, position: .bottom, animation: .easeInOut, autohideIn: 8, closeOnTap: true, closeOnTapOutside: true, view: {
//                        VStack {
//                            VStack {
//                                Text("Swipe left and right to switch between menues")
//                                Button(action: {
//                                    state.showWorkShopTipsAgain = false
//                                }, label: {Text("Don't show this again").foregroundColor(.blue)})
//                            }
//                            .padding(.all, 4)
//                            .background(Color.green)
//                            .foregroundColor(.white)
//                            .clipShape(RoundedRectangle(cornerRadius: 5))
//                            Spacer().frame(width: 40, height: 140, alignment: .center)
//                        }.opacity(state.showWorkShopTips ? 1 : 0)
//                    })
                }
            }
    }
    var body: some View {
        ZStack {
            HStack {
                if sizeClass == .regular {
                    VStack { content }
                }
                else {
                    content
                }
            }
        }
    }
}

#if DEBUG
struct WorkShopView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(Duct()) {
            WorkShopView(data: $0).environmentObject(AppState())
        }
    }
}
#endif
