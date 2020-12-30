//
//  Work3DView.swift
//  FieldFab
//
//  Created by Robert Sale on 12/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct Work3DView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.verticalSizeClass) var sizeClass
    var body: some View {
        ZStack {
            if true {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            state.sheetsShown.cameraHelp = true
                        }, label: {
                            Image(systemName: "questionmark")
                                .padding()
                                .background(BlurEffectView())
                                .clipShape(Circle())
                        })
                    }
                    Spacer()
                }.zIndex(4).padding()
                ZStack(alignment: .bottom) {
                    VStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                state.work3DDrawerShown.toggle()
                            }
                        }, label: {
                            Image(systemName: "chevron.up")
                                .rotationEffect(Angle(degrees: state.work3DDrawerShown ? 180 : 0))
                                .font(.title)
                                .padding()
//                                .background(BlurEffectView())
//                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .animation(.easeInOut)
                        })
                    }
                    .zIndex(2).offset(x: 0, y: -80)
                    ZStack {
                        if state.work3DMeasurementSelected == .offsetx || state.work3DMeasurementSelected == .offsety {
                            Button(action: {
                                state.currentWork?.data[state.work3DMeasurementSelected].isNegative.toggle()
                            }, label: {
                                Image(systemName: state.currentWork?.data[state.work3DMeasurementSelected].isNegative ?? true ? "minus" : "plus")
                                    .frame(width: 30, height: 30)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            })
                            .zIndex(2)
                        }
                        HStack {
                            Spacer().frame(width: 8)
                            Picker(state.work3DMeasurementSelected.rawValue, selection: $state.work3DMeasurementSelected, content: {
                                Text("Width").tag(DuctData.MeasureKeys.width)
                                Text("Depth").tag(DuctData.MeasureKeys.depth)
                                Text("Length").tag(DuctData.MeasureKeys.length)
                                Text("Offset X").tag(DuctData.MeasureKeys.offsetx)
                                Text("Offset Y").tag(DuctData.MeasureKeys.offsety)
                                Text("T-Width").tag(DuctData.MeasureKeys.twidth)
                                Text("T-Depth").tag(DuctData.MeasureKeys.tdepth)
                            })
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 130, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            Spacer()
                            HStack {
                                NumberSlider(Binding<DuctMeasurement>(
                                    get: {
                                        state.currentWork?.data[state.work3DMeasurementSelected] ?? Duct().data[state.work3DMeasurementSelected]
                                    }, set: {
                                        state.currentWork?.data[state.work3DMeasurementSelected] = $0}
                                    ))
                                    .clipShape(Rectangle())
                            }
                            Spacer().frame(width: 8)
                        }
                    }
                    .font(.title)
                    .frame(height: 70)
                    .frame(maxWidth: .infinity)
                    .background(BlurEffectView(style: .prominent))
                    .zIndex(1)
                }.frame(maxHeight: .infinity).offset(x: 0, y: state.work3DDrawerShown ? 0 : 70).zIndex(1000)
            }
            DuctSCN().zIndex(1)
        }
        .edgesIgnoringSafeArea(.horizontal)
//        .popup(isPresented: Binding<Bool>(get: {
//            state.showHitTestTips && state.showHitTestTipsAgain
//        }, set: {
//            state.showHitTestTips = $0
//        }), type: .toast, position: .top, animation: .easeInOut, autohideIn: 8, closeOnTap: true, closeOnTapOutside: true, view: {
//            VStack {
//                Spacer().frame(width: 40, height: 140, alignment: .center)
//                VStack {
//                    Text("Try long-pressing one of the faces to make that side flat")
//                    Button(action: {
//                        state.showHitTestTipsAgain = false
//                    }, label: {Text("Don't show this again")})
//                }
//                .padding(.all, 4)
//                .background(BlurEffectView())
//                .clipShape(RoundedRectangle(cornerRadius: 5))
//            }
//        })
    }
}

struct Work3DView_Previews: PreviewProvider {
    static var previews: some View {
        Work3DView().environmentObject(AppState())
    }
}
