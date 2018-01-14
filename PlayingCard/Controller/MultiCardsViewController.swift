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
	private lazy var cardBehavior = CardBehavior(animator: self.animator)
	
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
			
			// add card view to cardBehavior ( included collistion, item, and push behaviors )
			cardBehavior.addItem(cardView)
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
