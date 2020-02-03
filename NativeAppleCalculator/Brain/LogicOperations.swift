//
//  LogicOperations.swift
//  NativeAppleCalculator
//
//  Created by Igor Shelginskiy on 2/3/20.
//  Copyright © 2020 Igor Shelginskiy. All rights reserved.
//

import Foundation

struct LogicOperations
{
	private var currentContainer: Double?
	private var pendingContainer = Double()
	var result: Double? {
		return currentContainer
	}

	private enum Operation
	{
		case unaryOperation((Double) -> Double)
		case binaryOperation((Double, Double) -> Double)
		case percentOperation((Double) -> Double, (Double, Double) -> Double)
		case equals
	}

	private var operations: [String: Operation] = [
		"⁺∕₋": Operation.unaryOperation{ -$0 },
		"×": Operation.binaryOperation(*),
		"+": Operation.binaryOperation(+),
		"-": Operation.binaryOperation(-),
		"÷": Operation.binaryOperation(/),
		"=": Operation.equals,
		"%": Operation.percentOperation({ $0 / 100 }, { $0 / 100 * $1 }),
	]

	mutating func performOperation(_ symbol: String) {
		if let operation = operations[symbol] {
			switch operation {
			case .unaryOperation(let function):
				if let result = currentContainer {
					currentContainer = function(result)
					performPendingContainer()
				}
			case .binaryOperation(let function):
				performPendingBinaryOperation()
				if let result = currentContainer {
					pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: result)
				}
				performPendingContainer()
			case .percentOperation(let oneDigitPercent, let twoDigitPercent):
				if let result = currentContainer{
					if result > 0 {
						pendingBinaryOperation = PendingBinaryOperation(function: twoDigitPercent, firstOperand: pendingContainer)
					}
					else {
						currentContainer = oneDigitPercent(result)
					}
				}
				performPendingContainer()
			case .equals:
				performPendingBinaryOperation()
				performPendingContainer()
			}
		}
	}

	private mutating func performPendingBinaryOperation() {
		if let pendOper = pendingBinaryOperation, let accum = currentContainer {
			currentContainer = pendOper.perform(with: accum)
			performPendingContainer()
			pendingBinaryOperation = nil
		}
	}

	private var pendingBinaryOperation: PendingBinaryOperation?

	private struct PendingBinaryOperation
	{
		let function: (Double, Double) -> Double
		let firstOperand: Double

		func perform(with seconOperand: Double) -> Double {
			return function(firstOperand, seconOperand)
		}
	}
	mutating func setDigit(_ operand: Double) {
		currentContainer = operand
	}
	mutating func performPendingContainer() {
		if let result = currentContainer {
			pendingContainer = result
		}
	}
	mutating func null() {
		currentContainer = nil
		pendingBinaryOperation = nil
		pendingContainer = Double()
	}
}
