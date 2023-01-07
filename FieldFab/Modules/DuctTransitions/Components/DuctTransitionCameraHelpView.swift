//
//  Camera Help View.swift
//  FieldFab
//
//  Created by Robert Sale on 9/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
#if DEBUG
@_exported import HotSwiftUI
#endif

extension DuctTransition {
    struct CameraHelpView: View {
        //    var g: GeometryProxy
        //    @Binding var visible: Bool
        @Environment(\.colorScheme) var colorScheme
        
        func rImage(_ i: String) -> Image {
            if colorScheme == .dark {
                return Image("\(i) Inverted")
            } else {
                return Image(i)
            }
        }
        
        var body: some View {
            ScrollView {
                VStack(alignment: .center, spacing: 24.0) {
                    HStack(alignment: .center) {
                        rImage("Drag")
                        Spacer()
                        Text("Drag finger to rotate camera around the ductwork").multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24.0)
                    .padding(.top, 24.0)
                    Divider().background(Color.white)
                    HStack(alignment: .center) {
                        rImage("Rotate")
                        Spacer()
                        Text("Rotate with two fingers to roll the camera").multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24.0)
                    Divider().background(Color.white)
                    HStack(alignment: .center) {
                        rImage("Drag")
                        Spacer()
                        Text("Pinch and spread fingers to zoom").multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24.0)
                    Divider().background(Color.white)
                    HStack(alignment: .center) {
                        VStack {
                            rImage("HScroll")
                            rImage("VScroll")
                        }
                        Spacer()
                        Text("Scroll with two fingers to adjust camera position").multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24.0)
                    Text("Press and hold on one of the duct faces to make one of the sides flat.").multilineTextAlignment(.center)
                }
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .zIndex(2.0)
            }
            #if DEBUG
            .eraseToAnyView()
            #endif
        }
        #if DEBUG
        @ObservedObject var iO = injectionObserver
        #endif
    }
}

extension DuctTransition {
    struct ARCameraHelpView: View {
        @Environment(\.colorScheme) var colorScheme
        
        func rImage(_ i: String) -> Image {
            if colorScheme == .dark {
                return Image("\(i) Inverted")
            } else {
                return Image(i)
            }
        }
        
        var body: some View {
            ScrollView {
                VStack(alignment: .center, spacing: 24.0) {
                    HStack(alignment: .center) {
                        rImage("Drag")
                        Spacer()
                        Text("Drag finger move ductwork around the area. Translation mode XZ moves the duct horizontally, while Y mode moves the duct vertically.").multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    }
                    .padding(.horizontal, 24.0)
                    .padding(.top, 24.0)
                    Divider().background(Color.white)
                    HStack(alignment: .center) {
                        rImage("Rotate")
                        Spacer()
                        Text("Rotate with two fingers to rotate the ductwork").multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24.0)
                    Text("Press and hold on one of the duct faces to make one of the sides flat.").multilineTextAlignment(.center)
                }
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .zIndex(2.0)
            }
#if DEBUG
            .eraseToAnyView()
#endif
        }
#if DEBUG
        @ObservedObject var iO = injectionObserver
#endif
    }
}
