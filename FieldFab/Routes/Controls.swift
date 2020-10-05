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
    @EnvironmentObject var aL: AppLogic
    @EnvironmentObject var db: DB
    @Environment(\.colorScheme) var colorScheme
    @State var incrementIndex: Int = 0
    @State var loadShown = false
    @State var aboutShown = false
    @State var helpShown = false
    
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
                                            name: aL.sessionName,
                                            createdOn: Date(),
                                            tabs: TabsData(),
                                            length: aL.length.original,
                                            width: aL.width.original,
                                            depth: aL.depth.original,
                                            offsetX: aL.offsetX.original,
                                            offsetY: aL.offsetY.original,
                                            isTransition: aL.isTransition,
                                            tWidth: aL.tWidth.original,
                                            tDepth: aL.tDepth.original,
                                            id: UUID())
                                        db.dimensions.append(d)
                                        db.persist()
                                    }, label: {
                                        Text("Save").font(.title)
                                    })
                                    Spacer()
                                    Button(action: {
                                        self.aL.shareSheetContent = [self.aL.url]
                                        self.aL.shareSheetShown.toggle()
                                    }, label: {
                                        Image(systemName: "square.and.arrow.up").font(.title)
                                    })
                                    Spacer()
                                    Button(action: {
                                        loadShown = true
                                    }, label: {
                                        Text("Load").font(.title)
                                    })
                                }.padding(.bottom)
                                VStack {
                                    HStack {
                                        Text("Session Name").font(.headline)
                                        Spacer()
                                    }
                                    TextField("Session Name", text: $aL.sessionName)
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
                                            switch self.aL.increments {
                                                case .half: self.aL.increments = .quarter
                                                case .quarter: self.aL.increments = .eighth
                                                case .eighth: self.aL.increments = .sixteenth
                                                case .sixteenth: self.aL.increments = .thirtysecond
                                                default: self.aL.increments = .half
                                            }
                                        }, label: {
                                            Image(systemName: "arrow.left")
                                        })
                                        Spacer()
                                        Text(Fraction(self.aL.increments.rawValue).text("n/d"))
                                        Spacer()
                                        Button(action: {
                                            switch self.aL.increments {
                                                case .half: self.aL.increments = .thirtysecond
                                                case .quarter: self.aL.increments = .half
                                                case .eighth: self.aL.increments = .quarter
                                                case .sixteenth: self.aL.increments = .eighth
                                                default: self.aL.increments = .sixteenth
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
                                    FStepper(val: $aL.width, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal)
                                    HStack {
                                        Text("Depth").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $aL.depth, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal)
                                    HStack {
                                        Text("Length").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $aL.length, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal)
                                    HStack {
                                        Text("Offset X").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $aL.offsetX, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal)
                                    HStack {
                                        Text("Offset Y").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $aL.offsetY, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal)
                                }
                                Divider()
                                HStack {
                                    Text("Is Transition?")
                                    Spacer()
                                    Toggle("", isOn: $aL.isTransition)
                                        .gesture(TapGesture().onEnded({_ in
                                            self.aL.toggleTransition()
                                        }))
                                        .padding(.trailing, 2)
                                }
                                Divider()
                                VStack {
                                    HStack {
                                        Text("Transition Width").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $aL.tWidth, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal).disabled(!self.aL.isTransition)
                                    HStack {
                                        Text("Transition Depth").font(.headline)
                                        Spacer()
                                    }
                                    FStepper(val: $aL.tDepth, fullStep: true, stepSize: self.aL.increments).frame(height: 42).padding(.horizontal).disabled(!self.aL.isTransition)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        Divider()
                        HStack {
                            Button(action: {helpShown.toggle()}, label: {
                                Image(systemName: "questionmark.circle")
                            })
                            Spacer()
                            Button(action: {aboutShown.toggle()}, label: {
                                Text("About")
                            })
                        }.font(.title).padding(.horizontal, 30)
                        Spacer(minLength: 100)
                    }
                    .frame(width: min(g.size.width, 520), height: g.size.height)
                    .position(x: g.size.width / 2, y: g.size.height / 2)
                    ScrollView {
                        VStack(spacing: 8) {
                            Spacer(minLength: 100)
                            LoadDuctworkView(shown: $loadShown)
                            Spacer(minLength: 100)
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(width: g.size.width)
                    .background(VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)))
                    .position(loadShown ?
                        CGPoint(x: g.size.width / 2, y: g.size.height / 2) :
                        CGPoint(x: g.size.width / 2, y: g.size.height * 2))
                    .animation(.easeInOut, value: loadShown)
                    ScrollView {
                        VStack(spacing: 8) {
                            Spacer(minLength: 50)
                            AboutView(shown: $aboutShown)
                            Spacer(minLength: 100)
                        }
                        .frame(width: g.size.width, height: g.size.height)
                        .background(VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)))
                    }
                    .position(CGPoint(x: g.size.width / 2, y: aboutShown ? g.size.height / 2 : g.size.height * 2))
                    .animation(.easeInOut, value: aboutShown)
                    VStack {
                        Spacer(minLength: 100)
                        HelpView(shown: $helpShown)
                        Spacer(minLength: 100)
                    }
                    .background(VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)))
                    .position(CGPoint(x: g.size.width / 2, y: helpShown ? g.size.height / 2 : g.size.height * 2))
                    .animation(.easeInOut, value: helpShown)
                    
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
