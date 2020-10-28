//
//  TapWithLocation.swift
//  FieldFab
//
//  Created by Robert Sale on 10/25/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import UIKit

public extension View {
  func onTapWithLocation(coordinateSpace: CoordinateSpace = .local, _ tapHandler: @escaping (CGPoint) -> Void) -> some View {
    modifier(TapLocationViewModifier(tapHandler: tapHandler, coordinateSpace: coordinateSpace))
  }
}

fileprivate struct TapLocationViewModifier: ViewModifier {
  let tapHandler: (CGPoint) -> Void
  let coordinateSpace: CoordinateSpace

  func body(content: Content) -> some View {
    content.overlay(
      TapLocationBackground(tapHandler: tapHandler, coordinateSpace: coordinateSpace)
    )
  }
}

fileprivate struct TapLocationBackground: UIViewRepresentable {
  var tapHandler: (CGPoint) -> Void
  let coordinateSpace: CoordinateSpace

  func makeUIView(context: UIViewRepresentableContext<TapLocationBackground>) -> UIView {
    let v = UIView(frame: .zero)
    let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
    v.addGestureRecognizer(gesture)
    return v
  }

  class Coordinator: NSObject {
    var tapHandler: (CGPoint) -> Void
    let coordinateSpace: CoordinateSpace

    init(handler: @escaping ((CGPoint) -> Void), coordinateSpace: CoordinateSpace) {
      self.tapHandler = handler
      self.coordinateSpace = coordinateSpace
    }

    @objc func tapped(gesture: UITapGestureRecognizer) {
      let point = coordinateSpace == .local
        ? gesture.location(in: gesture.view)
        : gesture.location(in: nil)
      tapHandler(point)
    }
  }

  func makeCoordinator() -> TapLocationBackground.Coordinator {
    Coordinator(handler: tapHandler, coordinateSpace: coordinateSpace)
  }

  func updateUIView(_: UIView, context _: UIViewRepresentableContext<TapLocationBackground>) {
    /* nothing */
  }
}
