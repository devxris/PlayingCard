//
//  ViewController.swift
//  PlayingCard
//
//  Created by Chris Huang on 13/01/2018.
//  Copyright © 2018 Chris Huang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var deck = PlayingCardDeck()

	override func viewDidLoad() {
		super.viewDidLoad()
		for _ in 1...10 { if let card = deck.draw() { print("\(card)") } }
	}
}

