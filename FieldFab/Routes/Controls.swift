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
    
    var body: some View {
        VStack(spacing: 8.0) {
            Text("Settings").font(.title)
            Divider()
            VStack() {
                HStack(alignment: .center, spacing: 10.0) {
                    Text("Width:")
                    Spacer()
                    NumberFieldView(binding: $aL.width)
                    Button(action: {self.aL.mutate(x: -1, f: .width)}, label: {
                        Image(systemName: "arrow.left")
                    })
                    Button(action: {self.aL.mutate(x: 1, f: .width)}, label: {
                        Image(systemName: "arrow.right")
                    })
                }
                HStack(alignment: .center, spacing: 10.0) {
                    Text("Depth:")
                    Spacer()
                    NumberFieldView(binding: $aL.depth)
                    Button(action: {self.aL.mutate(x: -1, f: .depth)}, label: {
                        Image(systemName: "arrow.left")
                    })
                    Button(action: {self.aL.mutate(x: 1, f: .depth)}, label: {
                        Image(systemName: "arrow.right")
                    })
                }
                HStack(alignment: .center, spacing: 10.0) {
                    Text("Length:")
                    Spacer()
                    NumberFieldView(binding: $aL.length)
                    Button(action: {self.aL.mutate(x: -1, f: .length)}, label: {
                        Image(systemName: "arrow.left")
                    })
                    Button(action: {self.aL.mutate(x: 1, f: .length)}, label: {
                        Image(systemName: "arrow.right")
                    })
                }
                HStack(alignment: .center, spacing: 10.0) {
                    Text("Offset X:")
                    Spacer()
                    NumberFieldView(binding: $aL.offsetX)
                    Button(action: {self.aL.mutate(x: -1, f: .offsetX)}, label: {
                        Image(systemName: "arrow.left")
                    })
                    Button(action: {self.aL.mutate(x: 1, f: .offsetX)}, label: {
                        Image(systemName: "arrow.right")
                    })
                }
                HStack(alignment: .center, spacing: 10.0) {
                    Text("Offset Y:")
                    Spacer()
                    NumberFieldView(binding: $aL.offsetY)
                    Button(action: {self.aL.mutate(x: -1, f: .offsetY)}, label: {
                        Image(systemName: "arrow.left")
                    })
                    Button(action: {self.aL.mutate(x: 1, f: .offsetY)}, label: {
                        Image(systemName: "arrow.right")
                    })
                }
                Divider()
            }
            VStack() {
                Toggle("Transition?", isOn: $aL.isTransition)
                if $aL.isTransition.wrappedValue {
                    HStack(alignment: .center, spacing: 10.0) {
                        Text("tWidth:")
                        Spacer()
                        NumberFieldView(binding: $aL.tWidth)
                        Button(action: {self.aL.mutate(x: -1, f: .tWidth)}, label: {
                            Image(systemName: "arrow.left")
                        })
                        Button(action: {self.aL.mutate(x: 1, f: .tWidth)}, label: {
                            Image(systemName: "arrow.right")
                        })
                    }
                    HStack(alignment: .center, spacing: 10.0) {
                        Text("tDepth:")
                        Spacer()
                        NumberFieldView(binding: $aL.tDepth)
                        Button(action: {self.aL.mutate(x: -1, f: .tDepth)}, label: {
                            Image(systemName: "arrow.left")
                        })
                        Button(action: {self.aL.mutate(x: 1, f: .tDepth)}, label: {
                            Image(systemName: "arrow.right")
                        })
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20.0)
    }
}

struct Controls_Previews: PreviewProvider {
    static var previews: some View {
        Controls()
    }
}
