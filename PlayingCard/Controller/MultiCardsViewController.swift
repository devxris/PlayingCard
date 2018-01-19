//
//  MultiCardsViewController.swift
//  PlayingCard
//
//  Created by Chris Huang on 14/01/2018.
//  Copyright © 2018 Chris Huang. All rights reserved.
//

import UIKit
import CoreMotion

class MultiCardsViewController: UIViewController {

	// MARK: Model
	
	private var deck = PlayingCardDeck()
	
	// MARK: Storyboard
	
	@IBOutlet var cardViews: [PlayingCardView]!
	
	// MARK: Properties
	
	private var faceUpCardViews: [PlayingCardView] { // trace how many cards are face up
		return cardViews.filter { $0.isFaceUp
			&& !$0.isHidden
			&& $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
			&& $0.alpha == 1 }
	}
	
	private var faceUpCardViewMatch: Bool {
		return faceUpCardViews.count == 2
			&& faceUpCardViews[0].rank == faceUpCardViews[1].rank
			&& faceUpCardViews[0].suit == faceUpCardViews[1].suit
	}
	
	private var lastChosenCardView: PlayingCardView?
	
	// Dynamic animator: create animator <- add behaviors <- add items
	private lazy var animator = UIDynamicAnimator(referenceView: self.view)
	private lazy var cardBehavior = CardBehavior(animator: self.animator)
	
	// MARK: ViewController Life Cycles
	
	// turn accelerometer on when view appears
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// get a shared motion manager and check availibility of accelerometer
		if CMMotionManager.shared.isAccelerometerAvailable {
			// configure the update interval
			CMMotionManager.shared.accelerometerUpdateInterval = 1/10
			// turn on gravity effect
			cardBehavior.gravityBehavior.magnitude = 1.0
			// register a closure with accelerometer and get back accelerometer data
			CMMotionManager.shared.startAccelerometerUpdates(to: .main) { (data, error) in
				if var x = data?.acceleration.x, var y = data?.acceleration.y {
					/* Be aware of hardware and view are in different coordinate systems and auto rotation */
					switch UIDevice.current.orientation {
					case .portrait : y *= -1
					case .portraitUpsideDown : break
					case .landscapeRight : swap(&x, &y)
					case .landscapeLeft : swap(&x, &y); y *= -1
					default : x = 0; y = 0
					}
					self.cardBehavior.gravityBehavior.gravityDirection = CGVector(dx: x, dy: -y)
				}
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		cardBehavior.gravityBehavior.magnitude = 0 // stop gravity
		CMMotionManager.shared.stopAccelerometerUpdates() // stop accelerometer
	}
	
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
			if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
				
				// track down the last chosen card view
				lastChosenCardView = chosenCardView
				
				// stop card behavior and add back if 2 face up cards not matched or flip one chosen card back
				cardBehavior.removeItem(chosenCardView)
				
				// flip card up with UIView.transition(with:, duration:, options: animations:, completion:)
				UIView.transition(with: chosenCardView,
								  duration: 0.6,
								  options: [.transitionFlipFromLeft],
								  animations: { chosenCardView.isFaceUp = !chosenCardView.isFaceUp },
								  completion: { finish in
									let cardsToAnimate = self.faceUpCardViews // trace down the original two chosen cards
									if self.faceUpCardViewMatch { // scale up -> scale down -> fade out
										UIViewPropertyAnimator.runningPropertyAnimator( // scale up
											withDuration: 0.6,
											delay: 0,
											options: [],
											animations: {
												cardsToAnimate.forEach {
													$0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) }
										    },
											completion: { (position) in // scale down and fade out
												UIViewPropertyAnimator.runningPropertyAnimator(
													withDuration: 0.75,
													delay: 0,
													options: [],
													animations: {
														cardsToAnimate.forEach {
															$0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
															$0.alpha = 0
														}
												    },
													completion: { (position) in // clean up to original state
														cardsToAnimate.forEach {
															$0.isHidden = true
															$0.alpha = 1
															$0.transform = .identity
														}
													}
												)
											}
										)
									} else if self.faceUpCardViews.count == 2 { // flip card down if 2 cards face up
										if chosenCardView == self.lastChosenCardView { // let 2nd card control the animation
											cardsToAnimate.forEach { cardView in
												UIView.transition(with: cardView,
																  duration: 0.6,
																  options: [.transitionFlipFromLeft],
																  animations: { cardView.isFaceUp = false },
																  completion: { finish in self.cardBehavior.addItem(cardView) } // add behavior back
												)
											}
										}
									} else {
										if !chosenCardView.isFaceUp {
											self.cardBehavior.addItem(chosenCardView) // add behavior back
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
