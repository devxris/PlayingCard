//
//  CardBehavior.swift
//  PlayingCard
//
//  Created by Chris Huang on 14/01/2018.
//  Copyright © 2018 Chris Huang. All rights reserved.
//

import UIKit

// Dynamic animator: create animator <- subclass UIDynamicBehavior <- add child behaviors <- add items
// UIDynamicBehavior (a collection of behaviors): create a UIDynamicBehavior subclass <- add child behavior

class CardBehavior: UIDynamicBehavior {
	
	// MARK: Properties

	private lazy var collisionBehavior: UICollisionBehavior = {
		let collision = UICollisionBehavior()
		collision.translatesReferenceBoundsIntoBoundary = true
		return collision
	}()
	private lazy var itemBehavior: UIDynamicItemBehavior = {
		let item = UIDynamicItemBehavior()
		item.allowsRotation = false
		item.elasticity = 1.0 // not loss or gain energy
		item.resistance = 0.0
		return item
	}()
	lazy var gravityBehavior: UIGravityBehavior = {
		let gravity = UIGravityBehavior()
		gravity.magnitude = 0.0 // no gravity until turn accelerometer on
		return gravity
	}()
	
	// MARK: Private funcs

	private func push(_ item: UIDynamicItem) {
		let push = UIPushBehavior(items: [item], mode: .instantaneous) // better to clean up hereafter since instantaneous mode
		// push towards the center
		if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
			let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
			switch (item.center.x, item.center.y) {
			case let (x, y) where x < center.x && y < center.y:
				push.angle = (CGFloat.pi/2).arc4random
			case let (x, y) where x > center.x && y < center.y:
				push.angle = CGFloat.pi-(CGFloat.pi/2).arc4random
			case let (x, y) where x < center.x && y > center.y:
				push.angle = (-CGFloat.pi/2).arc4random
			case let (x, y) where x > center.x && y > center.y:
				push.angle = CGFloat.pi+(CGFloat.pi/2).arc4random
			default:
				push.angle = (CGFloat.pi*2).arc4random
			}
		}
		push.magnitude = CGFloat(1.0) + CGFloat(2.0).arc4random
		push.action = { [unowned push, weak self] in self?.removeChildBehavior(push) } // clean up, remove right after push
		addChildBehavior(push) // push behavior needs to know the "item" to push, so addChildBehavior here
	}
	
	// MARK: Funcs
	
	func addItem(_ item: UIDynamicItem) {
		collisionBehavior.addItem(item)
		itemBehavior.addItem(item)
		gravityBehavior.addItem(item)
		push(item)
	}
	
	func removeItem(_ item: UIDynamicItem) {
		collisionBehavior.removeItem(item)
		itemBehavior.removeItem(item)
		gravityBehavior.removeItem(item)
		// since push is instantaneous mode, already removed it right after push
	}
	
	// MARK: Initializers
	
	override init() {
		super.init()
		addChildBehavior(collisionBehavior)
		addChildBehavior(itemBehavior)
		addChildBehavior(gravityBehavior)
		// push behavior needs to know the "item" to push, so not addChildBehavior here
	}
	
	convenience init(animator: UIDynamicAnimator) {
		self.init()
		animator.addBehavior(self) // add self (CardBehavior) to UIDyanmicAnimator
	}
}
