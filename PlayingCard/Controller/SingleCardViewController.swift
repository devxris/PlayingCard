//
//  SingleCardViewController.swift
//  PlayingCard
//
//  Created by Chris Huang on 13/01/2018.
//  Copyright © 2018 Chris Huang. All rights reserved.
//

import UIKit

class SingleCardViewController: UIViewController {
	
	// MARK: Model
	
	var deck = PlayingCardDeck()
	
	// MARK: Storyboard
	
	@IBOutlet weak var playingCardView: PlayingCardView! {
		didSet {
			// add swipe gesture recognizer from code which sync with model
			let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
			swipe.direction = [.left, .right]
			playingCardView.addGestureRecognizer(swipe)
			
			// add pinch gesture recognizer and objc selector in playing card view
			let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(byHandlingGestureRecognizer:)))
			playingCardView.addGestureRecognizer(pinch)
		}
	}
	
	// add tap gesture recognizer from storyboard with target action
	@IBAction func flipCard(_ sender: UITapGestureRecognizer) {
		switch sender.state {
		case .ended :
			playingCardView.isFaceUp = !playingCardView.isFaceUp
		default : break
		}
	}
	
	// MARK: Objc Selectors
	
	@objc func nextCard() {
		if let card = deck.draw() {
			playingCardView.rank = card.rank.order
			playingCardView.suit = card.suit.rawValue
		}
	}
}
