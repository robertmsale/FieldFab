//
//  TabPicker.swift
//  FieldFab
//
//  Created by Robert Sale on 12/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct TabTypePicker: View {
    typealias TTNL = DuctTab.TabTypeAndNil
    var face: WorkShopView.Face
    var edge: DuctTab.Edge
    @Binding var data: DuctTab?
    var pickerText: String {
        if data == nil { return "None" }
        return data!.type.text
    }
    var body: some View {
        HStack {
            Text("Type")
            Spacer()
            Picker(pickerText, selection: Binding<TTNL>(get: {
                if data == nil { return .none }
                switch data!.type {
                    case .slock: return .slock
                    case .drive: return .drive
                    case .straight: return .straight
                    case .tapered: return .tapered
                    case .foldin: return .foldin
                    case .foldout: return .foldout
                }
            }, set: {v in
                func checker(val: inout DuctTab?, to: DuctTab.TType) {
                    if val == nil { val = DuctTab(length: .inch, type: to) }
                    else { val!.type = to }
                }
                switch v {
                    case .none: data = nil
                    case .slock: checker(val: &data, to: .slock)
                    case .drive: checker(val: &data, to: .drive)
                    case .foldin: checker(val: &data, to: .foldin)
                    case .foldout: checker(val: &data, to: .foldout)
                    case .straight: checker(val: &data, to: .straight)
                    case .tapered: checker(val: &data, to: .tapered)
                }
            })) {
                Text(TTNL.none.rawValue).tag(TTNL.none)
                if edge != .left && edge != .right {
                    Text(TTNL.straight.rawValue).tag(TTNL.straight)
                    Text(TTNL.tapered.rawValue).tag(TTNL.tapered)
                }
                Text(TTNL.slock.rawValue).tag(TTNL.slock)
                if edge != .left && edge != .right {
                    Text(TTNL.drive.rawValue).tag(TTNL.drive)
                }
                Text(TTNL.foldin.rawValue).tag(TTNL.foldin)
                if edge != .left && edge != .right {
                    Text(TTNL.foldout.rawValue).tag(TTNL.foldout)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 160, height: 30)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}

struct TabLengthPicker: View {
    typealias TLNL = DuctTab.TabLengthAndNil
    var face: WorkShopView.Face
    var edge: DuctTab.Edge
    @Binding var data: DuctTab?
    var pickerText: String {
        if data == nil { return "None" }
        return data!.length.text
    }
    var body: some View {
        HStack {
            Text("Length")
            Spacer()
            Picker(pickerText, selection: Binding<TLNL>(get: {
                if data == nil { return .none }
                switch data!.length {
                    case .inch: return .inch
                    case .half: return .half
                    case .threeeighth: return .threeeighth
                }
            }, set: {v in
                func checker(val: inout DuctTab?, to: DuctTab.Length) {
                    if val == nil { val = DuctTab(length: to, type: edge == .left || edge == .right ? .slock : .straight) }
                    else { val!.length = to }
                }
                switch v {
                    case .none: data = nil
                    case .inch: checker(val: &data, to: .inch)
                    case .half: checker(val: &data, to: .half)
                    case .threeeighth: checker(val: &data, to: .threeeighth)
                        
                }
            }), content: {
                Text("None").tag(TLNL.none)
                Text("Inch").tag(TLNL.inch)
                Text("Half Inch").tag(TLNL.half)
                Text("Three Eighths").tag(TLNL.threeeighth)
            })
            .pickerStyle(WheelPickerStyle())
            .frame(width: 160, height: 30)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}

struct TabPicker_Previews: PreviewProvider {
    static var previews: some View {
//        TabPicker()
        Text("Ayyyy")
    }
}
