//
//  MultiCardsViewController.swift
//  PlayingCard
//
//  Created by Chris Huang on 14/01/2018.
//  Copyright © 2018 Chris Huang. All rights reserved.
//

import UIKit

class MultiCardsViewController: UIViewController {

	// MARK: Model
	
	private var deck = PlayingCardDeck()
	
	// MARK: Storyboard
	
	@IBOutlet var cardViews: [PlayingCardView]!
	
	// MARK: Properties
	
	private var faceUpCardViews: [PlayingCardView] { // trace how many cards are face up
		return cardViews.filter { $0.isFaceUp && !$0.isHidden }
	}
	
	private var faceUpCardViewMatch: Bool {
		return faceUpCardViews.count == 2
			&& faceUpCardViews[0].rank == faceUpCardViews[1].rank
			&& faceUpCardViews[0].suit == faceUpCardViews[1].suit
	}
	
	// Dynamic animator: create animator <- add behaviors <- add items
	private lazy var animator = UIDynamicAnimator(referenceView: self.view)
	private lazy var collisionBehavior: UICollisionBehavior = {
		let collision = UICollisionBehavior()
		collision.translatesReferenceBoundsIntoBoundary = true
		animator.addBehavior(collision)
		return collision
	}()
	private lazy var itemBehavior: UIDynamicItemBehavior = {
		let item = UIDynamicItemBehavior()
		item.allowsRotation = false
		item.elasticity = 1.0 // not loss or gain energy
		item.resistance = 0.0
		animator.addBehavior(item)
		return item
	}()
	
	// MARK: View Life Cycles
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var cards = [PlayingCard]()
		for _ in 1...((cardViews.count + 1) / 2) {
			let card = deck.draw()!
			cards += [card, card]
		}
		for cardView in cardViews {
			cardView.isFaceUp = false
			let card = cards.remove(at: cards.count.arc4random)
			cardView.rank = card.rank.order
			cardView.suit = card.suit.rawValue
			
			// add tap gesture to flip card
			cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
			
			// add card view to collision and item behaviors
			collisionBehavior.addItem(cardView)
			itemBehavior.addItem(cardView)
			
			// add card view to push behavior ( need to know the object to push )
			let push = UIPushBehavior(items: [cardView], mode: .instantaneous) // better to clean up hereafter since instantaneous mode
			push.angle = (2 * CGFloat.pi).arc4random
			push.magnitude = CGFloat(1.0) + CGFloat(2.0).arc4random
			push.action = { [unowned push] in push.dynamicAnimator?.removeBehavior(push) } // clean up
			animator.addBehavior(push) // push immediately right after behavior added
		}
	}
	
	// MARK: Objc selectors
	
	@objc func flipCard(_ recognizer: UITapGestureRecognizer) {
		switch recognizer.state {
		case .ended :
			if let chosenCardView = recognizer.view as? PlayingCardView {
				// flip card up with UIView.transition(with:, duration:, options: animations:, completion:)
				UIView.transition(with: chosenCardView,
								  duration: 0.6,
								  options: [.transitionFlipFromLeft],
								  animations: { chosenCardView.isFaceUp = !chosenCardView.isFaceUp },
								  completion: { finish in
									if self.faceUpCardViewMatch { // scale up -> scale down -> fade out
										UIViewPropertyAnimator.runningPropertyAnimator( // scale up
											withDuration: 0.6,
											delay: 0,
											options: [],
											animations: {
												self.faceUpCardViews.forEach {
													$0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) }
										    },
											completion: { (position) in // scale down and fade out
												UIViewPropertyAnimator.runningPropertyAnimator(
													withDuration: 0.6,
													delay: 0,
													options: [],
													animations: {
														self.faceUpCardViews.forEach {
															$0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
															$0.alpha = 0
														}
												    },
													completion: { (position) in // clean up to original state
														self.faceUpCardViews.forEach {
															$0.isHidden = true
															$0.alpha = 1
															$0.transform = .identity
														}
													}
												)
											}
										)
									} else if self.faceUpCardViews.count == 2 { // flip card down if 2 cards face up
										self.faceUpCardViews.forEach { cardView in
											UIView.transition(with: cardView,
															  duration: 0.6,
															  options: [.transitionFlipFromLeft],
															  animations: { cardView.isFaceUp = !cardView.isFaceUp }
											)
										}
									}
								  }
				)
			}
		default : break
		}
	}
}

extension CGFloat {
	var arc4random: CGFloat { return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max)) }
}
