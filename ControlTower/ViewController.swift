//
//  ViewController.swift
//  ControlTower
//
//  Created by Ivan Kazakov on 07/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
				
		let flight = Flight(type: DomesticAirlineType.American)
		
		let lendingInstructions = flight.requestLandingInstructions()
		
		print("Runway: \(lendingInstructions.runway), Terminal: \(lendingInstructions.terminal.terminal), Gate: \(lendingInstructions.terminal.gate)")
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

