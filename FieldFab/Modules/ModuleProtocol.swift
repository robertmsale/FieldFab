//
//  ModuleProtocol.swift
//  FieldFab
//
//  Created by Robert Sale on 12/29/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import SwiftUI

enum ModuleLoadMethod {
    case development, production
}
protocol ModularView: View {
    associatedtype Module = View
    associatedtype Args
    static var loadMethod: ModuleLoadMethod { get }
    static func loadModule(_ args: Args) -> Module
}

#if DEBUG
struct ModuleProtocolPreviews: PreviewProvider {
    struct ModuleChildTest: View {
        var body: some View {
            Text("Ayyyyy")
        }
    }
    static var previews: some View {
        ModuleChildTest()
    }
}
#endif
