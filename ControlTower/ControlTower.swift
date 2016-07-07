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

extension Airline {
	
	var descendSpeed: Knots {
		
		return type.descendSpeed
	}
	
	func requestLandingInstructions() -> LandingInstructions {
		return ControlTower().landingInstructions(self)
	}
}

protocol AirlineType: Flying {
	
}

struct LandingInstructions {
	
	let runway: ControlTower.Runway
	let terminal: (terminal: ControlTower.Terminal, gate: Int?)
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

extension DomesticAirlineType {
	
	var descendSpeed: Knots {
		
		return 100
	}
}

extension InternationalAirlineType {
	
	var descendSpeed: Knots {
		
		return 130
	}
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
		
		case A
		case B
		case C
		case International
		case Private
		
		static func terminalFor(airline: Airline) -> (terminal: Terminal, gate: Int?) {
			
			func availableGateForTerminal(terminal: Terminal) -> (terminal: Terminal, gate: Int?) {
				
				var gate: Int?
				
				if var gates = GateManager.sharedInstance.gatesModel[terminal] {
					
					gate = GateManager.sharedInstance.getAvailableGate(within: &gates)
				}
				
				return (terminal, gate)
			}
			
			var terminal: Terminal
			
			switch airline.type {
				
				case is DomesticAirlineType:
					
					let domesticAL = airline.type as! DomesticAirlineType
					
					switch domesticAL {
						
						case .American:
							
							terminal = .A
						
						case .Delta:
							
							terminal = .B
						case .United:
							
							terminal = .C
					}
				
				case is InternationalAirlineType:
					
					terminal = .International
				
				default:
					
					terminal = .Private
			}
			
			return availableGateForTerminal(terminal)
		}
	}
	
	class GateManager {
		
		static let sharedInstance = GateManager()
		
		private init() {}
		
		enum GateStatus: String {
			case occupied
			case vacant
		}
		
		var gatesModel: [Terminal: [GateStatus: [Int]]] = [
		
			.A: [.occupied: [1,2,3,4,5,6,7,8], .vacant: [9,10,11,12]],
			.B: [.occupied: [1], .vacant: [2,3,4,5,6,7,8]],
			.C: [.occupied: [1,2,3,4], .vacant: [5,6,7,8,9,10]],
			.International: [.occupied: [1,2,3], .vacant: [4,5,6]],
			.Private: [.occupied: [1], .vacant: [2,3]]
		]
		
//		var gatesForTerminalA: [GateStatus: [Int]] = [.occupied: [1,2,3,4,5,6,7,8], .vacant: [9,10,11,12]]
//		var gatesForTerminalB: [GateStatus: [Int]] = [.occupied: [1], .vacant: [2,3,4,5,6,7,8]]
//		var gatesForTerminalC: [GateStatus: [Int]] = [.occupied: [1,2,3,4], .vacant: [5,6,7,8,9,10]]
//		var gatesForInternationalTerminal: [GateStatus: [Int]] = [.occupied: [1,2,3], .vacant: [4,5,6]]
//		var gatesForPrivateHangars: [GateStatus: [Int]] = [.occupied: [1], .vacant: [2,3]]
		
		func updateStatusFor(gate: Int, inout inTerminalGates gates: [GateStatus: [Int]], targetStatus: GateStatus) {
			
			var sourceGates: [Int]?
			var targetGates: [Int]?
			
			targetGates = gates[targetStatus]
			
			func transferGate(number gateNumber: Int, inout from sourceGates: [Int]?, inout to targetGates: [Int]?, targetStatus: GateStatus, inout within gatePool: [GateStatus: [Int]]) {
				
				if targetGates == nil {
					
					gatePool.updateValue([gateNumber], forKey: targetStatus)
					
				} else {
					
					targetGates?.append(gateNumber)
				}
				
				if let index = sourceGates?.indexOf(gateNumber) {
					
					sourceGates?.removeAtIndex(index)
				}
			}
			
			switch targetStatus {
				
				case .occupied:
					
					sourceGates = gates[.vacant]
				
				
				case .vacant:
					
					sourceGates = gates[.occupied]
			}
			
			transferGate(number: gate, from: &sourceGates, to: &targetGates, targetStatus: targetStatus, within: &gates)
		}
		
		func getAvailableGate(inout within gates: [GateStatus: [Int]]) -> Int? {
			
			guard let gate = gates[.vacant]?.first else {
				
				return nil
			}
			
			//Pasan updates gate status here, but it is a wrong place for it, IMHO
			//updateStatusFor(gate, inTerminalGates: &gates, targetStatus: .occupied)
			return gate
		}
		
		
	}
	
	func landingInstructions(airline: Airline) -> LandingInstructions {
		
		let runway = Runway.suitableRunwayFor(airline.descendSpeed)
		let terminal = Terminal.terminalFor(airline)
		
		return LandingInstructions(runway: runway, terminal: terminal)
	}
}

struct Flight: Airline {
	
	let type: AirlineType
}