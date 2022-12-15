//
//  LineChart.swift
//  Line Chart
//
//  Created by Eduard Caziuc on 11.12.2022.
//

import SwiftUI

struct LineChart: View {
	// MARK: - Public Properties
	
	@Binding var data: [CGPoint]
	@State var showIndicator: Bool
	var lineWidth: Double
	var pointMarkSize: Double
	var numberOfGridlines: Int
	var axisBaseValue: Double?
	
	// MARK: - Private Properties
	
	@State private var currentYLabel: Double = 0
	@State private var pointMarkReached: Double = 0
	@State private var isDragging: Bool = false
	@State private var animationProgress: CGFloat = 0
	@State private var dragGestureXLocation: Double = .zero
	private var hapticGenerator: UIImpactFeedbackGenerator = .init(style: .light)
	private var lineColor: Color = .gray
	private var yLegendOffset: CGFloat = -13
	private var maxY: Double = 0
	private var minY: Double = 0
	private var maxX: Double = 0
	private var minX: Double = 0
	private var xAxis: Double = 0
	private var yAxis: Double = 0
	private var yLabels: [Double] { data.map { $0.y } }
	private var xLabels: [Double] { data.map { $0.x } }
	
	// MARK: - Initialization
	
	init(data: Binding<[CGPoint]>, showIndicator: Bool = true, lineWidth: Double = 3.2, pointMarkSize: Double = 6, numberOfGridlines: Int = 4, axisBaseValue: Double? = .zero) {
		_data = data
		self.showIndicator = showIndicator
		self.lineWidth = lineWidth
		self.pointMarkSize = pointMarkSize
		self.numberOfGridlines = numberOfGridlines
		self.axisBaseValue = axisBaseValue
		setupChart()
	}
	
	var body: some View {
		GeometryReader { geometry in
			HStack(spacing: 4) {
				
				VStack(alignment: .trailing, spacing: yLegendOffset) {
					ForEach(0...numberOfGridlines, id: \.self) { gridNumber in
						Text("$\(yLegendLabel(for: gridNumber), specifier: "%.0f")").offset(x: 0, y: yLegendPosition(for: gridNumber, geometrySize: geometry.size))
							.foregroundColor(.gray)
							.font(.caption2)
					}
				}
				
				GeometryReader { geometry in
					ZStack {
						LinearGradient(gradient: Gradient(colors: [lineColor.opacity(0.6), lineColor.opacity(0.3), lineColor.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
							.clipShape(lineMark(in: geometry, closedPath: true))
							.opacity(animationProgress == 1 ? 1 : 0)
						
						lineMark(in: geometry)
							.trim(from: 0, to: animationProgress)
							.stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
							.overlay {
								if pointMarkSize > 0 {
									pointMarks(in: geometry)
										.fill(lineColor)
										.opacity(animationProgress == 1 ? 1 : 0)
								}
							}
						
						if showIndicator { positionIndicator(in: geometry) }
					}
				}
				.background {
					ForEach((0...numberOfGridlines), id: \.self) { gridNumber in
						gridlines(at: yLegendLabel(for: gridNumber), in: geometry.size)
							.trim(from: 0, to: animationProgress)
							.stroke(.gray, style: StrokeStyle(lineWidth: gridNumber == numberOfGridlines ? 2 : 0.6, lineCap: .square, dash: [2, gridNumber == numberOfGridlines ? 0 : 2])
							)
							.clipped()
					}
				}
			}
			.background {
				chartAxis(in: geometry.size)
					.trim(from: 0, to: animationProgress)
					.stroke(.gray, lineWidth: 1)
			}
		}
		.onAppear { withAnimation(.easeIn(duration: 2).delay(0.3)) { animationProgress = 1 } }
	}
}

// MARK: - Subviews

private extension LineChart {
	func lineMark(in geometry: GeometryProxy, closedPath: Bool = false) -> some Shape {
		Path { path in
			for (index, value) in data.enumerated() {
				let xPosition = CGFloat((value.x - minX) / xAxis) * geometry.size.width
				let yPosition = (1 - CGFloat((value.y - minY) / yAxis)) * geometry.size.height
				if index == 0 { path.move(to: CGPoint(x: xPosition, y: yPosition)) }
				//else { path.move(to: CGPoint(x: xPosition, y: geometry.size.height)) } // For bar graph style.
				path.addLine(to: CGPoint(x: xPosition, y: yPosition))
			}
			
			if closedPath {
				path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
				path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
				path.closeSubpath()
			}
		}
	}
	
	func pointMarks(in geometry: GeometryProxy) -> Path {
		Path { path in
			for (_, value) in data.enumerated() {
				let xPosition = CGFloat((value.x - minX) / xAxis) * geometry.size.width
				let yPosition = (1 - CGFloat((value.y - minY) / yAxis)) * geometry.size.height
				path.addEllipse(in: CGRect(x: xPosition - (pointMarkSize / 2), y: yPosition - (pointMarkSize / 2), width: pointMarkSize, height: pointMarkSize))
				path.move(to: CGPoint(x: xPosition, y: yPosition))
			}
		}
	}
	
	@ViewBuilder
	func positionIndicator(in geometry: GeometryProxy) -> some View {
		let boxHeight: CGFloat = 60
		let boxOffset = max(0, min(geometry.size.width - boxHeight, dragGestureXLocation - boxHeight / 2))
		
		Group {
			GroupBox {
				Text("$\(currentYLabel, specifier: "%.0f")")
					.font(.headline)
			}
			.frame(height: boxHeight)
			.position(x:(boxOffset) + boxHeight / 2, y: -(boxHeight / 2))
			
			Rectangle()
				.fill(.indigo)
				.frame(width: 2, height: geometry.size.height)
				.position(x: dragGestureXLocation, y: geometry.size.height / 2)
			
			Circle()
				.frame(width: 12, height: 12)
				.position(x: dragGestureXLocation, y: getYPosition(forXPosition: dragGestureXLocation, in: geometry.size))
		}
		.opacity(isDragging ? 1 : 0)
		.contentShape(Rectangle())
		
		.gesture(
			DragGesture(minimumDistance: 0)
				.onChanged { value in
					isDragging = true
					
					if((value.location.x < geometry.size.width) && (value.location.x > 0)) {
						dragGestureXLocation = value.location.x
					}
				}
				.onEnded { _ in
					withAnimation { isDragging = false }
				}
		)
		.onChange(of: pointMarkReached) { value in
			guard let firstValue = data.first?.y, value != firstValue else { return }
			hapticGenerator.impactOccurred()
		}
	}
	
	func gridlines(at height: CGFloat, in geometrySize: CGSize) -> Path {
		Path { path in
			path.move(to: CGPoint(x: 0, y: (height - minY) * stepHeight(geometrySize: geometrySize)))
			path.addLine(to: CGPoint(x: geometrySize.width, y: (height - minY) * stepHeight(geometrySize: geometrySize)))
		}
	}
	
	func chartAxis(in geometrySize: CGSize) -> Path {
		Path { path in
			path.move(to: CGPoint(x: geometrySize.width, y: 0))
			path.addLine(to: CGPoint(x: geometrySize.width, y: geometrySize.height))
		}
	}
}

// MARK: - Private Methods

private extension LineChart {
	// MARK: -  Position Indicator Methods
	
	mutating func setupChart() {
		if !$data.wrappedValue.isEmpty {
			// If axisBaseValue is not set, the minY value will be the lowest value in the data array.
			minY = axisBaseValue == nil ? yLabels.min() ?? .zero : axisBaseValue ?? .zero
			maxY = yLabels.max() ?? 0
			minX = xLabels.min() ?? 0
			maxX = xLabels.max() ?? 0
			
			// Sets the color of the line mark to green if the data is in an upwards trend or to red if it's in a downwards trend.
			if data.count > 1 {
				let deltaY = data[data.count - 1].y - data[data.count - 2].y
				if (deltaY >= 0) {
					lineColor = Color.green
				} else if (deltaY < 0) {
					lineColor = .red
				}
			} else {
				lineColor = .gray
			}
			xAxis = maxX - minX
			yAxis = maxY - minY
		}
	}
	
	func yLabel(forXPosition xPosition: Double, in geometrySize: CGSize) -> Double {
		let xLabel = xLabel(forXPosition: xPosition, in: geometrySize)
		var result = Double(0)
		
		for index in 1..<data.count {
			let lowerBound = data[index - 1].x
			let upperBound = data[index].x
			
			if ((xLabel <= upperBound) && (xLabel >= lowerBound)) {
				let interpolationFraction = (upperBound - lowerBound) / (xLabel - lowerBound)
				result = data[index - 1].y + (data[index].y - data[index - 1].y) / interpolationFraction
				
				//Set currentYLabel value for position indicator.
				DispatchQueue.main.async {
					if round(xLabel) == data[0].x {
						currentYLabel = data[0].y
					} else if round(xLabel) == round(data[Int(upperBound)].x) {
						currentYLabel = data[index].y
					}
					pointMarkReached = data[index].y
				}
			}
		}
		return result
	}
	
	func xLabel(forXPosition xPosition: Double, in geometrySize: CGSize) -> Double {
		return ((xAxis * xPosition) / geometrySize.width) + minX
	}
	
	func getYPosition(forXPosition xPosition: Double, in geometrySize: CGSize) -> Double {
		let yLabel = yLabel(forXPosition: xPosition, in: geometrySize)
		return (1 - CGFloat((yLabel - minY) / yAxis)) * geometrySize.height
	}
	
	// MARK: -  Legend Methods
	
	func yLegendLabels() -> [Double]? {
		let step = Double(maxY - minY) / Double(numberOfGridlines)
		var yLegendLabels: [Double] = []
		for index in 0...numberOfGridlines {
			yLegendLabels += [minY + step * Double(index)]
		}
		return yLegendLabels
	}
	
	func yLegendLabel(for gridNumber: Int) -> CGFloat{
		guard let legendLabels = yLegendLabels() else { return 0 }
		return CGFloat(legendLabels[gridNumber])
	}
	
	func yLegendPosition(for gridNumber: Int, geometrySize: CGSize) -> CGFloat {
		guard let legend = yLegendLabels() else { return 0 }
		return (geometrySize.height - ((CGFloat(legend[gridNumber]) - minY) * stepHeight(geometrySize: geometrySize))) - (geometrySize.height / 2)
	}
	
	func stepHeight(geometrySize: CGSize) -> CGFloat {
		return geometrySize.height / yAxis
	}
}
