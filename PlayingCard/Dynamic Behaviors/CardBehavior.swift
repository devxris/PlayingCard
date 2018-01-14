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
	
	// MARK: Private funcs

	private func push(_ item: UIDynamicItem) {
		let push = UIPushBehavior(items: [item], mode: .instantaneous) // better to clean up hereafter since instantaneous mode
		push.angle = (2 * CGFloat.pi).arc4random
		push.magnitude = CGFloat(1.0) + CGFloat(2.0).arc4random
		push.action = { [unowned push, weak self] in self?.removeChildBehavior(push) } // clean up, remove right after push
		addChildBehavior(push) // push behavior needs to know the "item" to push, so addChildBehavior here
	}
	
	// MARK: Funcs
	
	func addItem(_ item: UIDynamicItem) {
		collisionBehavior.addItem(item)
		itemBehavior.addItem(item)
		push(item)
	}
	
	func removeItem(_ item: UIDynamicItem) {
		collisionBehavior.removeItem(item)
		itemBehavior.removeItem(item)
		// since push is instantaneous mode, already removed it right after push
	}
	
	// MARK: Initializers
	
	override init() {
		super.init()
		addChildBehavior(collisionBehavior)
		addChildBehavior(itemBehavior)
		// push behavior needs to know the "item" to push, so not addChildBehavior here
	}
	
	convenience init(animator: UIDynamicAnimator) {
		self.init()
		animator.addBehavior(self) // add self (CardBehavior) to UIDyanmicAnimator
	}
}
