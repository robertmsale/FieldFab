//
//  Controls.swift
//  FieldFab
//
//  Created by Robert Sale on 9/4/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

func returnBinding(_ x: AppLogicField) -> Binding<AppLogicField> {
    return Binding.constant(x)
}

struct Controls: View {
    @EnvironmentObject var al: AppLogic
    @EnvironmentObject var db: DB
    @Environment(\.colorScheme) var colorScheme
    @State var incrementIndex: Int = 0
    
    var body: some View {
        
        HeaderView("Settings", opt: [.fillTopEdge, .overlay]) {
            GeometryReader { g in
                ZStack {
                    ScrollView {
                        Spacer(minLength: 100)
                        VStack(alignment: .center, spacing: 8.0) {
                            VStack() {
                                HStack() {
                                    Button(action: {
                                        let d = DimensionsData(
                                            name: al.sessionName,
                                            createdOn: Date(),
                                            tabs: TabsData(),
                                            length: al.length.original,
                                            width: al.width.original,
                                            depth: al.depth.original,
                                            offsetX: al.offsetX.original,
                                            offsetY: al.offsetY.original,
                                            isTransition: al.isTransition,
                                            tWidth: al.tWidth.original,
                                            tDepth: al.tDepth.original,
                                            id: UUID())
                                        db.dimensions.append(d)
                                        db.persist()
                                    }, label: {
                                        Text("Save").font(.title)
                                    })
                                    Spacer()
                                    Button(action: {
                                        al.shareSheetContent = [al.url]
                                        al.shareSheetShown.toggle()
                                    }, label: {
                                        Image(systemName: "square.and.arrow.up").font(.title)
                                    })
                                    Spacer()
                                    Button(action: {
                                        al.loadDuctworkViewShown = true
                                    }, label: {
                                        Text("Load").font(.title)
                                    })
                                }.padding(.bottom)
                                VStack {
                                    HStack {
                                        Text("Session Name").font(.headline)
                                        Spacer()
                                    }
                                    TextField("Session Name", text: $al.sessionName)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 10)
                                        .background(AppColors.ControlBG[colorScheme])
                                        .cornerRadius(10)
                                }
                                .padding(.bottom)
                                Divider()
                                HStack() {
                                    Text("Increment by")
                                    Spacer()
                                    HStack(alignment: .center) {
                                        Button(action: {
                                            switch al.increments {
                                                case .half: al.increments = .quarter
                                                case .quarter: al.increments = .eighth
                                                case .eighth: al.increments = .sixteenth
                                                case .sixteenth: al.increments = .thirtysecond
                                                default: al.increments = .half
                                            }
                                        }, label: {
                                            Image(systemName: "arrow.left")
                                        })
                                        Spacer()
                                        Text(Fraction(al.increments.rawValue).text("n/d"))
                                        Spacer()
                                        Button(action: {
                                            switch al.increments {
                                                case .half: al.increments = .thirtysecond
                                                case .quarter: al.increments = .half
                                                case .eighth: al.increments = .quarter
                                                case .sixteenth: al.increments = .eighth
                                                default: al.increments = .sixteenth
                                            }
                                        }, label: {
                                            Image(systemName: "arrow.right")
                                        })
                                    }
                                    .padding(.horizontal, 16.0)
                                    .padding(.vertical, 8.0)
                                    .background(/*@START_MENU_TOKEN@*/Color(hue: 1.0, saturation: 0.016, brightness: 0.51, opacity: 0.112)/*@END_MENU_TOKEN@*/)
                                    .frame(width: 180)
                                    .cornerRadius(10)
                                }
                                Spacer(minLength: 30)
                                VStack {
                                    HStack {
                                        Text("Width").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $al.width, fullStep: true, stepSize: al.increments).frame(height: 42).padding(.horizontal)
                                    HStack {
                                        Text("Depth").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $al.depth, fullStep: true, stepSize: al.increments).frame(height: 42).padding(.horizontal)
                                    HStack {
                                        Text("Length").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $al.length, fullStep: true, stepSize: al.increments).frame(height: 42).padding(.horizontal)
                                    HStack {
                                        Text("Offset X").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $al.offsetX, fullStep: true, stepSize: al.increments).frame(height: 42).padding(.horizontal)
                                    HStack {
                                        Text("Offset Y").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $al.offsetY, fullStep: true, stepSize: al.increments).frame(height: 42).padding(.horizontal)
                                }
                                Divider()
                                HStack {
                                    Text("Is Transition?")
                                    Spacer()
                                    Toggle("", isOn: $al.isTransition)
                                        .gesture(TapGesture().onEnded({_ in
                                            al.toggleTransition()
                                        }))
                                        .padding(.trailing, 2)
                                }
                                Divider()
                                VStack {
                                    HStack {
                                        Text("Transition Width").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $al.tWidth, fullStep: true, stepSize: al.increments).frame(height: 42).padding(.horizontal).disabled(!self.al.isTransition)
                                    HStack {
                                        Text("Transition Depth").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $al.tDepth, fullStep: true, stepSize: al.increments).frame(height: 42).padding(.horizontal).disabled(!self.al.isTransition)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        Divider()
                        HStack {
                            Button(action: {al.helpViewShown.toggle()}, label: {
                                Image(systemName: "questionmark.circle")
                            })
                            Spacer()
                            Button(action: {al.aboutViewShown.toggle()}, label: {
                                Text("About")
                            })
                        }.font(.title).padding(.horizontal, 30)
                        Spacer(minLength: 100)
                    }
                    .frame(width: min(g.size.width, 520), height: g.size.height)
                    .position(x: g.size.width / 2, y: g.size.height / 2)
                    
                }
//                .edgesIgnoringSafeArea(.top)
//                .padding(.horizontal, 20)
//                .padding(.vertical, 100)
            }
        }
    }
}
    


struct Controls_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            Controls()
                .environmentObject(AppLogic())
                .environmentObject(
                    DB([
                        DimensionsData(
                            name: "Derpa",
                            createdOn: Date(),
                            tabs: TabsData(),
                            length: 5,
                            width: 16,
                            depth: 20,
                            offsetX: 1,
                            offsetY: 0,
                            isTransition: true,
                            tWidth: 20,
                            tDepth: 16,
                            id: UUID())
                    ]))
        }
    }
}
