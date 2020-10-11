//
//  CarouselView.swift
//  FieldFab
//
//  Created by Robert Sale on 10/2/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct CarouselView<Content: View>: View {
    @State var current: Int = 0
    var maxIndex: Int
    var views: [Content]

    init(_ views: [Content]) {
        self.views = views
        maxIndex = views.count
    }

    func carouselTab(_ index: Int) -> some View {
        return Circle()
            .fill(index == current ? Color.blue : Color.gray)
            .opacity(index == current ? 0.8 : 0.4)
    }

    //    func renderCarousel() -> some View {
    //
    //    }

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView([Text("Ayyyy")])
    }
}
