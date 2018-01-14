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
	
	// MARK: Objc selectors
	
	@objc func flipCard(_ recognizer: UITapGestureRecognizer) {
		switch recognizer.state {
		case .ended :
			if let chosenCardView = recognizer.view as? PlayingCardView {
				chosenCardView.isFaceUp = !chosenCardView.isFaceUp
			}
		default : break
		}
	}
}
