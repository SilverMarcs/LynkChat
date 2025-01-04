//
//  SizeReader.swift
//  BottomInputBarSwiftUI
//
//  Created by Cao, Jiannan on 1/11/24.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
      let next = nextValue()
      value.width += next.width
      value.height += next.height
  }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
          )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

import UIKit
import SwiftUI

class UIBottomBar : UIView {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // var backgroundView: UIView { self }
    var views: Views!
    
    init(barView: UIView, backgroundView: UIView, frame: CGRect = .zero) {
        super.init(frame: frame)
        self.views = Views(barView: barView, backgroundView: backgroundView, superview: self)
    }
    
    var keyboardConstraints: WindowConstrints? {
        didSet {
            oldValue?.uninstall()
            keyboardConstraints?.install()
        }
    }
    
    var superViewConstraints: SuperViewConstraints? {
        didSet {
            oldValue?.uninstall()
            superViewConstraints?.install()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        superViewConstraints = SuperViewConstraints(source: views,  target: views.floatingView)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        keyboardConstraints = WindowConstrints(source: views, target: WindowConstrints.Target(window: window))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        keyboardConstraints?.updateKeyboardDismissPadding()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        views.floatingView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
}

extension UIBottomBar {
    
    struct ViewRepresentable<BottomBar: View, Background: View> : UIViewRepresentable {
        @ViewBuilder
        let bottomBar: BottomBar
        
        @ViewBuilder
        let background :Background
        
        typealias UIViewType = UIBottomBar
        
        func makeUIView(context: Context) -> UIViewType {
            UIBottomBar(
                barView: _UIHostingView(rootView: bottomBar),
                backgroundView: _UIHostingView(rootView: background)
            )
        }
            
        func updateUIView(_ uiView: UIViewType, context: Context) {
            
        }
        
        func sizeThatFits(_ proposal: ProposedViewSize, uiView: Self.UIViewType, context: Self.Context) -> CGSize? {
            uiView.systemLayoutSizeFitting(
                {
                    var size = proposal.replacingUnspecifiedDimensions()
                    size.height = UIView.layoutFittingCompressedSize.height
                    return size
                }(),
                withHorizontalFittingPriority: .defaultHigh,
                verticalFittingPriority: .fittingSizeLevel
            )
        }
     }
}

import UIKit

extension UIBottomBar {
    struct Views {
        
        let barView: UIView
        let backgroundView: UIView
        let floatingView: UIView
         
        init(barView: UIView, backgroundView: UIView, superview: UIView) {

            barView.translatesAutoresizingMaskIntoConstraints = false
            self.barView = barView
            
            //let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundView = backgroundView
            
            let floatingView = UIView()
            //floatingView.layer.borderColor = UIColor.green.cgColor
            //floatingView.layer.borderWidth = 1
            floatingView.translatesAutoresizingMaskIntoConstraints = false
            self.floatingView = floatingView
 
            // superview
            //superview.translatesAutoresizingMaskIntoConstraints = false
            superview.addSubview(floatingView)
            floatingView.addSubview(backgroundView)
            floatingView.addSubview(barView)
        }
    }
}

import SwiftUI

extension View {
    func bottomBar<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        modifier(Modifier(barContent: content))
    }
}

struct Modifier<BarContent : View>: ViewModifier {
    
    @ViewBuilder
    let barContent: BarContent
    
    @State
    private var height: CGFloat?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
                .safeAreaPadding(.bottom, height)
                .ignoresSafeArea(.all, edges: .bottom) // this is for SwiftUI layout interactive dissmissing animation bug
            
            UIBottomBar.ViewRepresentable {
                barContent
            } background: {
                Color.clear.readSize { height = $0.height }
            }
        }
    }
}


import UIKit

protocol Constraints {
    associatedtype Source
    associatedtype Target
    init?(source: Source, target: Target?)
    func install()
    func uninstall()
    
    var constraints: [NSLayoutConstraint] { get }
}

extension Constraints {
    func install() {
        NSLayoutConstraint.activate(constraints)
    }
    
    func uninstall() {
        NSLayoutConstraint.deactivate(constraints)
    }
}

extension UIBottomBar {
    struct SuperViewConstraints : Constraints {
        
        private let source: UIBottomBar.Views
        private let target: UIView
        let constraints: [NSLayoutConstraint]
        
        init?(source: UIBottomBar.Views, target: UIView? = nil) {
            guard let target else { return nil }
            
            let barView = source.barView
            let backgroundView = source.backgroundView
            
            let constraints = [
                backgroundView.topAnchor.constraint(equalTo: target.topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: target.bottomAnchor),
                backgroundView.leadingAnchor.constraint(equalTo: target.leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo:target.trailingAnchor),
                
                barView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
                barView.bottomAnchor.constraint(lessThanOrEqualTo: backgroundView.bottomAnchor),
                barView.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor),
                barView.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor)
            ]
            
            self.source = source
            self.target = target
            self.constraints = constraints
        }
    }
    
    struct WindowConstrints : Constraints {
        
        let source: UIBottomBar.Views
        let target: Target
        
        
        let constraints: [NSLayoutConstraint]
        
        init?(source: UIBottomBar.Views, target: Target?) {
            
            let barView = source.barView
            let backgroundView = source.backgroundView
            
            guard let target else { return nil }
            let window = target.window
            let keyboardLayoutGuide = target.keyboardLayoutGuide
            let safeAreaLayoutGuide = target.safeAreaLayoutGuide
            
            barView.setContentCompressionResistancePriority(.required, for: .horizontal)
            let constraints = [
                // backgroundView == window (without top)
                backgroundView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                
                // hostingView | keyboard (V)
                barView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor),
                
                // Stable horizontal positioning relative to window
                barView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                barView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                
                // hostingView <= safeArea
                barView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor),
                barView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor),
                barView.leadingAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor),
                barView.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor)
            ]
            
            self.source = source
            self.target = target
            self.constraints = constraints
        }
        
        func updateKeyboardDismissPadding() {
            target.keyboardLayoutGuide.keyboardDismissPadding = source.barView.intrinsicContentSize.height
        }
        
        struct Target {
            let window: UIWindow
            let keyboardLayoutGuide: UIKeyboardLayoutGuide
            let safeAreaLayoutGuide: UILayoutGuide
            init?(window: UIWindow?) {
                guard let window, let rootView = window.rootViewController?.view else { return nil }
                self.window = window
                keyboardLayoutGuide = rootView.keyboardLayoutGuide
                safeAreaLayoutGuide = window.safeAreaLayoutGuide
            }
        }
    }
}
