//
//  HeaderView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

enum IndexerMutate {
    case inc, dec
}

final class Indexer<T>: ObservableObject {

    @Published var data: [T]
    @Published var index: Int
    //    @Published var previous: Int

    var current: T {
        get { data[index] }
    }

    func mutate(_ dir: IndexerMutate) {
        //        self.previous = self.index
        switch dir {
        case .inc:
            if self.index == self.data.count - 1 { self.index = 0 } else { self.index += 1 }
        case .dec:
            if self.index == 0 { self.index = self.data.count - 1 } else { self.index -= 1 }
        }
    }

    init(_ data: [T]) {
        self.data = data
        self.index = 0
    }
    init(_ data: [T], index i: Int) {
        self.data = data
        self.index = i
    }
}

enum TopBarOptions {
    case fillTopEdge, overlay
}

struct TopBarView<Content: View, TBC: View>: View {
    let content: Content
    let topbarContent: TBC
    var options: Set<TopBarOptions> = []
    @Environment(\.colorScheme) var colorScheme

    init(_ options: TopBarOptions..., @ViewBuilder topbarContent: () -> TBC, @ViewBuilder content: () -> Content) {
        self.content = content()
        for opt in options {
            self.options.insert(opt)
        }
        self.topbarContent = topbarContent()
    }

    init(_ options: Set<TopBarOptions>, @ViewBuilder topbarContent: () -> TBC, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.options = options
        self.topbarContent = topbarContent()
    }

    func renderTopBar(_ g: GeometryProxy) -> AnyView {
        if self.options.contains(.overlay) {
            print(self.options.description)
            return AnyView(
                ZStack(alignment: .top) {
                    self.content
                        .zIndex(1)
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: g.size.width, height: g.size.height)
                    //                        .background(Color.gray)
                    AnyView(
                        HStack {
                            self.topbarContent
                        }
                        .padding(.horizontal)
                        .frame(width: g.size.width, height: 60)
                        .font(.title)
                    )
                    .zIndex(10)
                    .frame(width: g.size.width, height: 90, alignment: .bottom)
                    .background(VisualEffectView(
                        effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)
                    ))
                    .edgesIgnoringSafeArea(self.options.contains(.fillTopEdge) ? .top : .leading)

                }
            )
        } else {
            return AnyView(
                VStack {
                    HStack(alignment: .bottom) {
                        self.topbarContent.font(.title)
                    }
                    .padding(.top, 30)
                    .frame(width: g.size.width, height: 90)
                    .background(AppColors.ControlBG[colorScheme])
                    self.content
                }
                .edgesIgnoringSafeArea(self.options.contains(.fillTopEdge) ? .top : .trailing)
            )
        }
    }

    var body: some View {
        GeometryReader { g in
            renderTopBar(g)
        }
    }
}

struct HeaderView<Content: View>: View {
    var title: String
    var options: Set<TopBarOptions>
    var content: Content

    init(_ title: String, opt: Set<TopBarOptions>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.title = title
        self.options = opt
    }
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.init(title, opt: [], content: content)
    }

    var body: some View {
        TopBarView(options, topbarContent: { Text(title) }, content: {
            self.content
        })
    }
}

struct NextPrevHeaderView<Content: View>: View {
    var action: (IndexerMutate) -> Void
    var title: String
    var options: Set<TopBarOptions> = []
    var content: Content

    init(_ title: String, action: @escaping (IndexerMutate) -> Void, opt: Set<TopBarOptions>, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.action = action
        options = opt
    }
    init(_ title: String, action: @escaping (IndexerMutate) -> Void, @ViewBuilder content: () -> Content) {
        self.init(title, action: action, opt: [], content: content)
    }

    var body: some View {
        TopBarView(.overlay, .fillTopEdge, topbarContent: {
            Button(action: {
                action(.dec)
            }, label: {
                Image(systemName: "arrow.left")
            })
            Spacer()
            Text(title)
            Spacer()
            Button(action: {
                action(.inc)
            }, label: {
                Image(systemName: "arrow.right")
            })
        }) {
            self.content
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        //        let id = Indexer(["Front", "Right", "Back", "Left"])
        return HeaderView("Ayyyy", opt: [.fillTopEdge]) {
            Text("Ayyyyy")
        }.environment(\.colorScheme, .light)
    }
}
