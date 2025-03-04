//
//  ReflectionAPI.swift
//  FieldFab
//
//  Created by Robert Sale on 12/30/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import SwiftUI
import StringFix

//#if DEBUG
//class ReflectionStruct {
//    var reflection1: String { "a" }
//}
//extension ReflectionStruct {
//    var reflection2: String { "b" }
//}
//
//struct ReflectionAPI: View {
//    var testString: String {
//        let mirror = Mirror(reflecting: ReflectionStruct())
//        var retval = ""
//        for child in mirror.children {
//            retval += child.label ?? ""
//        }
//        return retval
//    }
//    
//    var body: some View {
//        Text(testString)
//        .enableInjection()
//    }
//
//    #if DEBUG
//    @ObserveInjection var forceRedraw
//    #endif
//}
//
//struct ReflectionAPI_Previews: PreviewProvider {
//    static var previews: some View {
//        ReflectionAPI()
//    }
//}
//#endif
