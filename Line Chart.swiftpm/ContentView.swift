import SwiftUI

struct ContentView: View {
   @State var chartData: [Double] = [65054, 61000, 62420, 56030, 57089, 65021, 59060, 67000, 56006, 65070, 54000, 42000, 88000, 49000, 42000, 61000, 67000, 54000, 47000, 42000, 71000, 56000, 81000, 71000, 40000, 49000, 42000, 58000, 66000, 62000, 77000, 52000, 42000, 49000, 58000, 61000, 68000, 43000, 49000, 69000, 81000]
   @State var presentGraphSheet: Bool = false
   
   var body: some View {
      GeometryReader { geometry in
         VStack {
            lineGraph
               .frame(width: geometry.size.width * 0.9, height: geometry.size.height * (UIDevice.current.orientation.isLandscape ? 0.6 : 0.2))
         }
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         
         .onTapGesture {
            presentGraphSheet = true
         }
         
         .popover(isPresented: $presentGraphSheet) {
            GeometryReader { geometry in
               VStack(spacing: 30) {
                  detailLineGraph
                     .frame(width: geometry.size.width * 0.9, height: geometry.size.height * (UIDevice.current.orientation.isLandscape ? 0.6 : 0.2))
                     .accessibilityElement()
                     .accessibilityIdentifier("InvestmentsLineGph")
                     .accessibilityLabel("Investments Line Graph")
                  
                  Button {
                     chartData.append(chartData.randomElement() ?? 20000)
                  } label: {
                     Text("Add Value")
                  }
                  .buttonStyle(.borderedProminent)
                  
               }
               .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
         }
      }
      
   }
   
   @ViewBuilder
   var lineGraph: some View {
      LineChart(data: LineChart.createPointMarks(with: chartData))
   }
   
   @ViewBuilder
   var detailLineGraph: some View {
      LineChart(data: LineChart.createPointMarks(with: chartData), enablePositionIndicator: true, lineMarkWidth: 3.2, pointMarkSize: 8, numberOfGridlines: 4, dashedGridlines: true)
   }
}

struct ContentView2: View {
    var graphData: [CGPoint] = []
    
    init() {
        var expensePointMarks: [CGPoint] = []
        for expense in Expense.allExpenses {
            expensePointMarks.append(CGPoint(x: Double(expense.xValue), y: expense.expense))
        }
        graphData = expensePointMarks
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                LineChart(data: graphData)
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * (UIDevice.current.orientation.isLandscape ? 0.6 : 0.2))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct Expense {
    enum Month: Int {
        case jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec
    }
    
    let month: Month
    let expense: Double
    
    var quarter: Int {
        switch month {
        case .jan, .feb, .mar:
            return 1
        case .apr, .may, .jun:
            return 2
        case .jul, .aug, .sep:
            return 3
        default:
            return 4
            
        }
    }
    
    var xValue: Double {Double(month.rawValue) }
    
    static var allExpenses: [Expense] {
        [
            Expense(month: .jan, expense: 3500),
            Expense(month: .feb, expense: 5000),
            Expense(month: .mar, expense: 5500),
            Expense(month: .apr, expense: 5100),
            Expense(month: .may, expense: 4200),
            Expense(month: .jun, expense: 7500),
            Expense(month: .jul, expense: 1250),
            Expense(month: .aug, expense: 9000),
            Expense(month: .sep, expense: 5750),
            Expense(month: .oct, expense: 6000),
            Expense(month: .nov, expense: 2100),
            Expense(month: .dec, expense: 6000)
            
        ]
    }
}
