//
//  UIView+Constraints.swift
//
//  Copyright © 2019 Go Go Encode.
//  MIT License · http://choosealicense.com/licenses/mit/
//

import UIKit

extension UIView {
    
    @discardableResult
    func fill(view: UIView, space: UIEdgeInsets = .zero) -> (top: NSLayoutConstraint, leading: NSLayoutConstraint, bottom: NSLayoutConstraint, trailling: NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            topAnchor.constraint(equalTo: view.topAnchor, constant: space.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: space.left),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -space.bottom),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -space.right),
        ]
        NSLayoutConstraint.activate(constraints)
        return (constraints[0], constraints[1], constraints[2], constraints[3])
    }
    
    @discardableResult
    func fillSuperView(space: UIEdgeInsets = .zero) -> (top: NSLayoutConstraint, leading: NSLayoutConstraint, bottom: NSLayoutConstraint, trailling: NSLayoutConstraint)? {
        guard let view = superview else { return nil }
        return fill(view: view, space: space)
    }
    
    /// Leading
    @discardableResult
    func leading(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: offset)
        NSLayoutConstraint.activate([constraint])
        
        return constraint
    }
    
    @discardableResult
    func leadingToSuperView(offset: CGFloat = 0) -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return leading(view: view, offset: offset)
    }
    
    @discardableResult
    func leadingToSafe(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: offset)
        NSLayoutConstraint.activate([constraint])
        
        return constraint
    }
    
    @discardableResult
    func leadingToSuperViewSafe(offset: CGFloat = 0) -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return leadingToSafe(view: view, offset: offset)
    }
    
    /// Trailing
    @discardableResult
    func trailing(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: offset)
        NSLayoutConstraint.activate([constraint])
        
        return constraint
    }
    
    @discardableResult
    func trailingToSuperView(offset: CGFloat = 0) -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return trailing(view: view, offset: offset)
    }
    
    @discardableResult
    func trailingToSafe(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: offset)
        NSLayoutConstraint.activate([constraint])
        
        return constraint
    }
    
    @discardableResult
    func trailingToSuperViewSafe(offset: CGFloat = 0) -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return trailingToSafe(view: view, offset: offset)
    }
    
    /// Top
    @discardableResult
    func top(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(equalTo: view.topAnchor, constant: offset)
        NSLayoutConstraint.activate([constraint])
        
        return constraint
    }
    
    @discardableResult
    func topToSuperView(offset: CGFloat = 0) -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return top(view: view, offset: offset)
    }
    
    @discardableResult
    func topToSafe(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: offset)
        NSLayoutConstraint.activate([constraint])
        
        return constraint
    }
    
    @discardableResult
    func topToSuperViewSafe(offset: CGFloat = 0) -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return topToSafe(view: view, offset: offset)
    }
    
    /// Bottom
    @discardableResult
    func bottom(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: offset)
        NSLayoutConstraint.activate([constraint])
        
        return constraint
    }
    
    @discardableResult
    func bottomToSuperView(offset: CGFloat = 0) -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return bottom(view: view, offset: offset)
    }
    
    @discardableResult
    func bottomToSafe(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: offset)
        NSLayoutConstraint.activate([constraint])
        
        return constraint
    }
    
    @discardableResult
    func bottomToSuperViewSafe(offset: CGFloat = 0) -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return bottomToSafe(view: view, offset: offset)
    }
    
    /// Size
    @discardableResult
    func height(_ value: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalToConstant: value)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func height(_ view: UIView, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: multiplier)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func heightToSuperView(multiplier: CGFloat) -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return height(view, multiplier: multiplier)
    }
    
    @discardableResult
    func width(_ value: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalToConstant: value)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func width(_ view: UIView, multiplier: CGFloat = 1) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func widthToSuperView(multiplier: CGFloat) -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return width(view, multiplier: multiplier)
    }
    
    @discardableResult
    func square() -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalTo: widthAnchor)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func square(value: CGFloat) -> (aspect: NSLayoutConstraint, height: NSLayoutConstraint) {
        let constraints = [
            square(),
            height(value)
        ]
        return (constraints[0], constraints[1])
    }
    
    /// Vertical spacing
    @discardableResult
    func vertical(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(equalTo: view.bottomAnchor, constant: offset)
        constraint.isActive = true
        return constraint
    }
    
    /// Horizontal spacing
    @discardableResult
    func horizontal(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: offset)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func horizontalTrailing(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: offset)
        constraint.isActive = true
        return constraint
    }
    
    /// Center
    @discardableResult
    func center(view: UIView) -> (x: NSLayoutConstraint, y: NSLayoutConstraint) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        return (constraints[0], constraints[1])
    }
    
    @discardableResult
    func centerSuperView() -> (x: NSLayoutConstraint, y: NSLayoutConstraint)? {
        guard let view = superview else { return nil }
        return center(view: view)
    }
    
    @discardableResult
    func centerX(view: UIView) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerXAnchor.constraint(equalTo: view.centerXAnchor)
        NSLayoutConstraint.activate([constraint])
        return constraint
    }
    
    @discardableResult
    func centerY(view: UIView) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerYAnchor.constraint(equalTo: view.centerYAnchor)
        NSLayoutConstraint.activate([constraint])
        return constraint
    }
    
    @discardableResult
    func centerXToSuperView() -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return centerX(view: view)
    }
    
    @discardableResult
    func centerYToSuperView() -> NSLayoutConstraint? {
        guard let view = superview else { return nil }
        return centerY(view: view)
    }
}

// MARK: - Derived functions
extension UIView {
    
    @discardableResult
    func fillTop(_ view: UIView, insets: UIEdgeInsets = .zero) -> (top: NSLayoutConstraint, leading: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        let topConstraint = top(view: view, offset: insets.top)
        let leadingConstraint = leading(view: view, offset: insets.left)
        let trailingConstraint = trailing(view: view, offset: -insets.right)
        return (topConstraint, leadingConstraint, trailingConstraint)
    }
    
    @discardableResult
    func fillTopOfSuperView(insets: UIEdgeInsets = .zero) -> (top: NSLayoutConstraint, leading: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        guard let view = superview else { fatalError("There is no super view") }
        return fillTop(view, insets: insets)
    }
    
    @discardableResult
    func fillBottom(_ view: UIView, insets: UIEdgeInsets = .zero) -> (leading: NSLayoutConstraint, bottom: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        let leadingConstraint = leading(view: view, offset: insets.left)
        let bottomConstraint = bottom(view: view, offset: -insets.bottom)
        let trailingConstraint = trailing(view: view, offset: -insets.right)
        return (leadingConstraint, bottomConstraint, trailingConstraint)
    }
    
    @discardableResult
    func fillBottomOfSuperView(insets: UIEdgeInsets = .zero) -> (leading: NSLayoutConstraint, bottom: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        guard let view = superview else { fatalError("There is no super view") }
        return fillBottom(view, insets: insets)
    }
    
    @discardableResult
    func fillLeading(_ view: UIView, insets: UIEdgeInsets = .zero) -> (top: NSLayoutConstraint, leading: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        let topConstraint = top(view: view, offset: insets.top)
        let leadingConstraint = leading(view: view, offset: insets.left)
        let bottomConstraint = bottom(view: view, offset: -insets.bottom)
        return (topConstraint, leadingConstraint, bottomConstraint)
    }
    
    @discardableResult
    func fillLeadingOfSuperView(insets: UIEdgeInsets = .zero) -> (top: NSLayoutConstraint, leading: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        guard let view = superview else { fatalError("There is no super view") }
        return fillLeading(view, insets: insets)
    }
    
    @discardableResult
    func fillTrailing(_ view: UIView, insets: UIEdgeInsets = .zero) -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        let topConstraint = top(view: view, offset: insets.top)
        let bottomConstraint = bottom(view: view, offset: -insets.bottom)
        let trailingConstraint = trailing(view: view, offset: -insets.right)
        return (topConstraint, bottomConstraint, trailingConstraint)
    }
    
    @discardableResult
    func fillTrailingOfSuperView(insets: UIEdgeInsets = .zero) -> (top: NSLayoutConstraint, bottom: NSLayoutConstraint, trailing: NSLayoutConstraint) {
        guard let view = superview else { fatalError("There is no super view") }
        return fillTrailing(view, insets: insets)
    }
}

extension UIView {
    func wrap() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        centerSuperView()
        return view
    }
}

extension NSLayoutConstraint {
    
    func with(_ priority: UILayoutPriority) {
        self.priority = priority
    }
}

extension UILayoutPriority {
    static var p_999 = UILayoutPriority(999)
}
