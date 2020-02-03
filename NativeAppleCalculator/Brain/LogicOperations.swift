//
//  LogicOperations.swift
//  NativeAppleCalculator
//
//  Created by Igor Shelginskiy on 2/3/20.
//  Copyright © 2020 Igor Shelginskiy. All rights reserved.
//

import Foundation

final class LogicOperations
{

	private var accumulator = 0.0
	private var previousAccumulator = 0.0
	private var previousPriority = Int.max
	private var pending: [PendingBinaryOperationInfo] = []
	private var previousOperation: PendingBinaryOperationInfo?
	var result: Double {
		return accumulator
	}

	private enum Operation
	{
		case unaryOperation((Double) -> Double)
		case binaryOperation((Double, Double) -> Double, Int)
		case percentOperation((Double) -> Double, (Double, Double) -> Double)
		case equals
		case clear
	}
	//Сохраняем в структуру инфу по отложенной операции: первого оператора и саму функцию
	private struct PendingBinaryOperationInfo
	{
		var function: ((Double, Double) -> Double)
		var firstOperand: Double
	}

	private var operations: [String: Operation] = [
		"⁺∕₋": Operation.unaryOperation{ -$0 },
		"×": Operation.binaryOperation({ $0 * $1 }, 1),
		"+": Operation.binaryOperation({ $0 + $1 }, 0),
		"-": Operation.binaryOperation({ $0 - $1 }, 0),
		"÷": Operation.binaryOperation({ $0 / $1 }, 1),
		"=": Operation.equals,
		"%": Operation.percentOperation({ $0 / 100 }, { $0 * $1 / 100 }),
		"C": Operation.clear
	]

	//Устанавливаем начальное значение
	func setOperand(operand: Double) {
		accumulator = operand
	}
	//Выполняем пришедшую операцию, либо откладываем если операция с двумя операндами
	func performOperation(symbol: String, getBothOperandsForBinaryOperation: Bool = true) {
		if let operation = operations[symbol] {
			switch operation {
			case .unaryOperation(let function):
				accumulator = function(accumulator)
				previousAccumulator = accumulator
			case .binaryOperation(let function, let priority):
				if getBothOperandsForBinaryOperation {
					if pending.count > 0 {
						if previousPriority > priority {
							executePendingOperations()
						}
						else if previousPriority == priority {
							executeLastPendingOperation()
						}
					}
					pending.append(PendingBinaryOperationInfo(function: function,
															  firstOperand: accumulator))
					previousPriority = priority
					previousAccumulator = accumulator
				}
				else {
					updateLastPendingOperation(symbol: symbol)
				}
			case .percentOperation(let oneDigitPercent, let twoDigitPercent):
				if pending.count > 0 {
					accumulator = twoDigitPercent(accumulator, previousAccumulator)
				}
				else {
					accumulator = oneDigitPercent(accumulator)
				}
				previousAccumulator = accumulator
			case .equals:
				if pending.count > 0 {
					if let function = pending.last?.function {
						previousOperation = PendingBinaryOperationInfo(function: function, firstOperand: accumulator)
					}
					executePendingOperations()
				}
				else if let operation = previousOperation {
					accumulator = operation.function(accumulator, operation.firstOperand)
				}
				previousAccumulator = accumulator
			case .clear:
				clear()
			}
		}
	}
	func clear() {
		accumulator = 0.0
		previousAccumulator = 0.0
		pending = []
		previousOperation = nil
	}
	//Выполняем все отложенные операции из массива
	private func executePendingOperations() {
		while pending.count > 0 {
			executeLastPendingOperation()
		}
	}
	//Выполним последнюю отложенную операцию
	private func executeLastPendingOperation() {
		let operation = pending.removeLast()
		accumulator = operation.function(operation.firstOperand, accumulator)
	}
	//Обновляем операцию в последней отложенной при множественном нажатии
	private func updateLastPendingOperation(symbol: String) {
		guard let operation = operations[symbol] else { return }
		if pending.isEmpty == false {
			switch operation {
			case .binaryOperation(let function, _):
				pending[pending.count - 1].function = function
			default:
				break
			}
		}
	}
}
