//
//  ControlTower.swift
//  ControlTower
//
//  Created by Ivan Kazakov on 07/07/16.
//  Copyright © 2016 Antevis. All rights reserved.
//

typealias Knots = Int

//MARK: protocols

protocol Flying {
	
	var descendSpeed: Knots { get }
}

protocol Landing {
	
	func requestLandingInstructions() -> LandingInstructions
}

protocol Airline: Flying, Landing {
	
	var type: AirlineType { get }
}

protocol AirlineType {
	
}

struct LandingInstructions {
	
	let runway: ControlTower.Runway
}

//MARK: AirlineType

enum DomesticAirlineType: AirlineType {
	
	case Delta
	case American
	case United
}

enum InternationalAirlineType: AirlineType {
	
	case Aeroflot
	case SmallPlanet
	case Lufthansa
	case KLM
}

//MARK: Control Tower

final class ControlTower {
	
	enum Runway {
		
		case R22L
		case L31R
		case M52J
		case B19E
		
		//TODO: this is obviously poor approach. Can be implemented through enum cases with associated values, and should return an optional array of suitable runways
		static func suitableRunwayFor(speed: Knots) -> Runway {
			
			switch speed {
			case 0..<91: return .R22L
			case 91...120: return .L31R
			case 121...140: return .M52J
			case 141...165: return .B19E
			default: return .B19E
			}
		}
	}
	
	enum Terminal {
		
		case A(Int?)
		case B(Int?)
		case C(Int?)
		case International(Int?)
		case Private(Int?)
		
		static func terminalFor(airline: Airline) -> Terminal {
			
			switch airline.type {
				
				case is DomesticAirlineType:
					
					let domesticAL = airline.type as! DomesticAirlineType
					
					switch domesticAL {
						
						case .American: return .A(nil)
						case .Delta: return .B(nil)
						case .United: return .C(nil)
					}
				
				case is InternationalAirlineType: return .International(nil)
				
				default: return .Private(nil)
				
			}
		}
	}
	
	class GateManager {
		
		enum GateStatus {
			case occupied
			case vacant
		}
		
		var gatesForTerminalA: [String: [Int]] = ["occupied": [1,2,3,4,5,6,7,8], "vacant": [9,10,11,12]]
		var gatesForTerminalB: [String: [Int]] = ["occupied": [1], "vacant": [2,3,4,5,6,7,8]]
		var gatesForTerminalC: [String: [Int]] = ["occupied": [1,2,3,4], "vacant": [5,6,7,8,9,10]]
		var gatesForInternationalTerminal: [String: [Int]] = ["occupied": [1,2,3], "vacant": [4,5,6]]
		var gatesForPrivateHangars: [String: [Int]] = ["occupied": [1], "vacant": [2,3]]
		
		func updateStatusFor(gate: Int, inout inTerminalGates gates: [String: [Int]], newStatus: GateStatus) {
			
			var occupiedGates = gates["occupied"]
			var vacantGates = gates["vacant"]
			
			switch newStatus {
				
				case .occupied:
				
					transferGate(number: gate, from: &vacantGates, to: &occupiedGates, targetName: "occupied", within: &gates)
				
				case .vacant:
					
					transferGate(number: gate, from: &occupiedGates, to: &vacantGates, targetName: "vacant", within: &gates)
			}
		}
		
		func transferGate(number gateNumber: Int, inout from sourceGates: [Int]?, inout to targetGates: [Int]?, targetName: String, inout within gatePool: [String: [Int]]) {
			
			if targetGates == nil {
				
				gatePool.updateValue([gateNumber], forKey: targetName)
			} else {
				
				targetGates?.append(gateNumber)
			}
			
			if let index = sourceGates?.indexOf(gateNumber) {
				
				sourceGates?.removeAtIndex(index)
			}
		}
		
	}
	
	func land(airline: Airline) -> LandingInstructions {
		
		let runway = Runway.suitableRunwayFor(airline.descendSpeed)
		
		return LandingInstructions(runway: runway)
	}
}