//
//  MakeSideFlatSheet.swift
//  FieldFab
//
//  Created by Robert Sale on 10/5/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

enum PickerSide: String, CaseIterable, Identifiable {
    case front
    case back
    case left
    case right
    
    var id: String { self.rawValue }
}
enum PickerRoundTo: CGFloat, CaseIterable, Identifiable {
    case half = 0.5
    case quarter = 0.25
    case eighth = 0.125
    case sixteenth = 0.0625
    case thirtySecond = 0.03125
    
    var id: CGFloat { self.rawValue }
}

struct ThreeDMenuSheet: View {
    @EnvironmentObject var al: AppLogic
    @Environment(\.colorScheme) var colorScheme
    @State var tabSideSelected: TabSide = .top
    @State var tabMenuState: TabMenuShowing = .main
    
    enum TabMenuShowing {
        case main, length, type
    }
    
    func tabMenu() -> AnyView {
        switch tabMenuState {
            case .main:
                return AnyView(
                    Text("Main")
                )
            case .type:
                return AnyView(
                    Text("Type")
                )
            case .length:
                return AnyView(
                    Text("Length")
                )
        }
    }
    
    func getSideText() -> DuctSides {
        switch al.selectedSide {
            case .back: return .back
            case .front: return .front
            case .left: return .left
            case .right: return .right
        }
    }
    
    func getRoundToText() -> String {
        switch al.selectedRoundTo {
            case .half: return "1/2"
            case .quarter: return "1/4"
            case .eighth: return "1/8"
            case .sixteenth: return "1/16"
            case .thirtySecond: return "1/32"
        }
    }
    
    func renderMainControls(g: GeometryProxy) -> some View {
        return VStack {
            Picker("Side", selection: $al.selectedSide) {
                Text("Front").tag( DuctFace.front )
                Text("Back").tag ( DuctFace.back  )
                Text("Left").tag ( DuctFace.left  )
                Text("Right").tag( DuctFace.right )
            }.pickerStyle(SegmentedPickerStyle())
            GeometryReader { bg in
                DuctSideView(g: bg, side: getSideText()).environmentObject(al)
            }
            .frame(width: min(g.size.width, g.size.height) * 0.8, height: min(g.size.height, g.size.width) * 0.8)
            HStack {
                Text("Round to: ")
                Picker("Round to", selection: $al.selectedRoundTo) {
                    Text("1/2").tag(PickerRoundTo.half)
                    Text("1/4").tag(PickerRoundTo.quarter)
                    Text("1/8").tag(PickerRoundTo.eighth)
                    Text("1/16").tag(PickerRoundTo.sixteenth)
                    Text("1/32").tag(PickerRoundTo.thirtySecond)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            VStack {
                Divider()
                HStack {
                    Text("Display Helpers")
                    Spacer()
                    Toggle("", isOn: $al.threeDViewHelpersShown)
                }
                Divider()
            }
            HStack {
                Button(action: {
                    switch al.selectedSide {
                        case .front: al.makeSideFlat(side: .front)
                        case .back: al.makeSideFlat(side: .back)
                        case .left: al.makeSideFlat(side: .left)
                        case .right: al.makeSideFlat(side: .right)
                    }
                    al.threeDMenuShown = false
                }, label: {
                    Text("Make Side Flat")
                })
                .padding()
                .background(AppColors.ControlBG[colorScheme])
                .cornerRadius(15)
            }
        }
    }
    
    func genTypePicker() -> AnyView {
        switch tabSideSelected {
            case .top, .bottom: return AnyView(
                Picker(selection: $al.tabs[al.selectedSide, tabSideSelected, 1], label: Text(al.tabs[al.selectedSide, tabSideSelected, 1].asText), content: {
                    Text(TabType.none.asText).tag(TabType.none)
                    Text(TabType.straight.asText).tag(TabType.straight)
                    Text(TabType.tapered.asText).tag(TabType.tapered)
                    Text(TabType.slock.asText).tag(TabType.slock)
                    Text(TabType.drive.asText).tag(TabType.drive)
                    Text(TabType.foldIn.asText).tag(TabType.foldIn)
                    Text(TabType.foldOut.asText).tag(TabType.foldOut)
                })
                .frame(width: 200, height: 60)
                .clipped()
            )
            case .left, .right: return AnyView(
                Picker(selection: $al.tabs[al.selectedSide, tabSideSelected, 1], label: Text(al.tabs[al.selectedSide, tabSideSelected, 1].asText), content: {
                    Text(TabType.none.asText).tag(TabType.none)
                    Text(TabType.slock.asText).tag(TabType.slock)
                    Text(TabType.foldIn.asText).tag(TabType.foldIn)
                })
                .frame(width: 200, height: 60)
                .clipped()
            )
        }
    }
    
    var body: some View {
        GeometryReader { g in
            ScrollView {
                VStack {
                    renderMainControls(g: g)
                    Divider()
                    VStack {
                        Text("Tabs").font(.title3)
                        HStack {
                            Picker("Tab", selection: $tabSideSelected) {
                                Text("Top").tag(TabSide.top)
                                Text("Bottom").tag(TabSide.bottom)
                                Text("Left").tag(TabSide.left)
                                Text("Right").tag(TabSide.right)
                            }.pickerStyle(SegmentedPickerStyle())
                        }
                        VStack {
                            HStack {
                                Text("Type")
                                Spacer()
                                genTypePicker()
                            }
                            Divider()
                            HStack {
                                Text("Length")
                                Spacer()
                                Picker(selection: $al.tabs[al.selectedSide, tabSideSelected, 1.0], label: Text(""), content: {
                                    Text(TabLength.none.asText).tag(TabLength.none)
                                    Text(TabLength.inch.asText).tag(TabLength.inch)
                                    Text(TabLength.half.asText).tag(TabLength.half)
                                    Text(TabLength.threeEighth.asText).tag(TabLength.threeEighth)
                                })
                                .frame(width: 200, height: 60)
                                .clipped()
                            }
                        }.padding()
                    }
                    Spacer()
                    
                }.padding()
            }
        }
    }
}

#if DEBUG
struct MakeSideFlatSheet_Previews: PreviewProvider {
    static var previews: some View {
        ThreeDMenuSheet().environmentObject(AppLogic())
    }
}
#endif
