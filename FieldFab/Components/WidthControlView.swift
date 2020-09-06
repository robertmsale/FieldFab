//
//  WidthControlView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/6/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct WidthControlView: View {
    @EnvironmentObject var aL: AppLogic
    
    var body: some View {
        TextField("derp", value: $aL.depth, formatter: numFmt())
    }
}

struct WidthControlView_Previews: PreviewProvider {
    static var previews: some View {
        let aL = AppLogic()
        return WidthControlView().environmentObject(aL)
    }
}
