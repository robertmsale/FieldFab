//
//  DuctTransitionAirflowDataHelpView.swift
//  FieldFab
//
//  Created by Robert Sale on 10/4/24.
//  Copyright © 2024 Robert Sale. All rights reserved.
//

import SwiftUI

extension DuctTransition {
    struct AirflowDataHelpView: View {
        
        var crossL1: some Shape {
            return Path { p in
                p.move(to: CGPoint(x: 80, y: 0))
                p.addLine(to: CGPoint(x: 80, y: 180))
            }.stroke(lineWidth: 1.0)
        }
        
        var crossL2: some Shape {
            return Path { p in
                p.move(to: CGPoint(x: 0, y: 90))
                p.addLine(to: CGPoint(x: 180, y: 90))
            }.stroke(lineWidth: 1.0)
        }
        
        var crossL3: some Shape {
            return Path { p in
                p.move(to: CGPoint(x: 100, y: 20))
                p.addLine(to: CGPoint(x: 100, y: 200))
            }.stroke(lineWidth: 1.0)
        }
        
        var crossL4: some Shape {
            return Path { p in
                p.move(to: CGPoint(x: 20, y: 105))
                p.addLine(to: CGPoint(x: 200, y: 105))
            }.stroke(lineWidth: 1.0)
        }
        
        var prologue: some View {
            Group { // Prologue
                Text("You have 2 inputs:")
                VStack(alignment: .leading) {
                    Text("> Expected CFM")
                    Text("> Expected External Static Pressure")
                }
                Spacer().frame(height:24)
                Text("Duct fittings are typically rated by their equivalent length to tell you pressure loss across the fitting. These equivalent length values are based on empirical data and extensive lab testing to ensure their accuracy. These equivalent lengths can be found on ductulators or inside ACCA Manual D.")
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer().frame(height:24)
                Text("Because we are creating custom transitions, FieldFab relies on a generalized formula for calculating K Factor based on the following conditions:")
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                Spacer().frame(height:24)
            }
        }
        
        var horizontalRule: some View {
            VStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 1)
            }.padding(.vertical, 5)
        }
        
        var centerline: some View {
            Group { // Centerline
                horizontalRule
                HStack {
                    Spacer()
                    VStack(alignment: .center) {
                        Text("1. The centerline offset of the duct")
                        GeometryReader { p in
                            crossL1.stroke(Color.red)
                            crossL2.stroke(Color.red)
                            crossL3.stroke(Color.blue)
                            crossL4.stroke(Color.blue)
                        }.frame(width: 200, height: 200)
                    }
                    Spacer()
                }
                Text("As you add more offset to the X and Y axis, the air has to change direction which affects the K Factor. To put it into perspective, if there is no offset, the air stream in the center of the transition will experience little to no turbulence.")
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer().frame(height:24)
            }
        }
        
        var vergence: some View {
            Group { // vergence
                horizontalRule
                HStack {
                    Spacer()
                    VStack {
                        Text("2. Convergence or Divergence")
                        GeometryReader { p in
                            Rectangle()
                                .stroke(lineWidth: 1.0)
                                .stroke(Color.blue)
                            Rectangle()
                                .stroke(lineWidth: 1.0)
                                .stroke(Color.red)
                                .frame(width: 130, height: 110)
                                .offset(x: 35, y: 45)
                        }.frame(width: 200, height: 200)
                    }
                    Spacer()
                }
                Text("If the outlet of the duct is smaller in area than the inlet, this is considered convergent. Velocity pressure increases across the outlet and K Factor increases much more as a result. If the outlet is larger than the inlet, we have a divergent transition piece. Velocity pressure decreases at the outlet and K factor increases at a much lower rate. If the area of both the inlet and the outlet are the same, then velocity pressure does not change and neither does K Factor.")
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer().frame(height: 24)
                Text("For perspective, consider the scenario where you have a divergent transition piece with a slight offset. The center of the air stream will move along a curve from the inlet to the outlet. In this case there will be some turbulence from that change in direction. If the transition is convergent, the increase in velocity at the outlet will apply more turbulence to the center of the air stream which in turn multiplies the turbulent forces at the center of the outlet.")
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                horizontalRule
                Spacer().frame(height: 24)
            }
        }
        
        var epilogue: some View {
            Group { // Epilogue
                Text("Taking both of these facts about our transition piece into consideration we can create a relatively accurate approximation of how much pressure loss in \"wc will occur across the transition. Results may vary in the field!")
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
        }
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("Airflow Data Help").font(.title)
                    Spacer()
                    
                }.padding(.horizontal, 24)
                ScrollView {
                    VStack(alignment: .leading) {
                        prologue
                        centerline
                        vergence
                        epilogue
                    }
                    .padding(.all, 24)
                }
            }
            .enableInjection()
        }

        @ObserveInjection var forceRedraw
    }
}

#Preview {
    DuctTransition.AirflowDataHelpView()
}
