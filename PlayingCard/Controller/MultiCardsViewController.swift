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
		}
	}
	
	// MARK: Properties
	
	private var faceUpCardViews: [PlayingCardView] { // trace how many cards are face up
		return cardViews.filter { $0.isFaceUp && !$0.isHidden }
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
									// flip card down if there are 2 cards face up
									if self.faceUpCardViews.count == 2 {
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
