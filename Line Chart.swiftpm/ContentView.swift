import SwiftUI

struct ContentView: View {
	@State var graphData = [CGPoint(x: 0, y: 65054),
									CGPoint(x: 1, y: 61000),
									CGPoint(x: 2, y: 62420),
									CGPoint(x: 3, y: 56030),
									CGPoint(x: 4, y: 57089),
									CGPoint(x: 5, y: 65021),
									CGPoint(x: 6, y: 59060),
									CGPoint(x: 7, y: 67000),
									CGPoint(x: 8, y: 56006),
									CGPoint(x: 9, y: 65070),
									CGPoint(x: 10, y: 54000),
									CGPoint(x: 11, y: 42000),
									CGPoint(x: 12, y: 88000),
									CGPoint(x: 13, y: 49000),
									CGPoint(x: 14, y: 42000),
									CGPoint(x: 15, y: 61000),
									CGPoint(x: 16, y: 67000),
									CGPoint(x: 17, y: 54000),
									CGPoint(x: 18, y: 47000),
									CGPoint(x: 19, y: 42000),
									CGPoint(x: 20, y: 71000),
									CGPoint(x: 21, y: 56000),
									CGPoint(x: 22, y: 81000),
									CGPoint(x: 23, y: 71000),
									CGPoint(x: 24, y: 40000),
									CGPoint(x: 25, y: 49000),
									CGPoint(x: 26, y: 42000),
									CGPoint(x: 27, y: 58000),
									CGPoint(x: 28, y: 66000),
									CGPoint(x: 29, y: 62000),
									CGPoint(x: 30, y: 77000),
									CGPoint(x: 31, y: 52000),
									CGPoint(x: 32, y: 42000),
									CGPoint(x: 33, y: 49000),
									CGPoint(x: 34, y: 58000),
									CGPoint(x: 35, y: 61000),
									CGPoint(x: 36, y: 68000),
									CGPoint(x: 37, y: 43000),
									CGPoint(x: 38, y: 49000),
									CGPoint(x: 39, y: 69000),
									CGPoint(x: 40, y: 81000),
	]

	var body: some View {
		GeometryReader { geometry in
			Group {
				LineChart(data: $graphData)
					.frame(width: geometry.size.width * 0.9, height: geometry.size.height * (UIDevice.current.orientation.isLandscape ? 0.6 : 0.2))
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
	}
}
