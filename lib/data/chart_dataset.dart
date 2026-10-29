import '../models/account_models.dart';

/// Structured Institutional Financial Datasets
/// Realistic, visually appealing time-series market curves for 1D, 1W, and 1M.
/// Architected as structured FinancialDataPoint items to allow seamless swapping with live REST/WebSocket feeds.
class LuminaChartData {
  static const List<FinancialDataPoint> oneDay = [
    FinancialDataPoint(timeLabel: '00:00', value: 124630.45, note: 'Midnight Settlement'),
    FinancialDataPoint(timeLabel: '02:00', value: 124685.20),
    FinancialDataPoint(timeLabel: '04:00', value: 124590.10, note: 'Asian Open Liquidity'),
    FinancialDataPoint(timeLabel: '06:00', value: 124520.00),
    FinancialDataPoint(timeLabel: '08:00', value: 124715.50, note: 'London Fix Surge'),
    FinancialDataPoint(timeLabel: '10:00', value: 124940.80),
    FinancialDataPoint(timeLabel: '12:00', value: 124860.30, note: 'Midday Rebalance'),
    FinancialDataPoint(timeLabel: '14:00', value: 125055.00, note: 'US Market Inflow'),
    FinancialDataPoint(timeLabel: '16:00', value: 125225.40),
    FinancialDataPoint(timeLabel: '18:00', value: 125180.70, note: 'L2 Staking Payout'),
    FinancialDataPoint(timeLabel: '20:00', value: 125270.00),
    FinancialDataPoint(timeLabel: '22:00', value: 125310.60, note: 'Intraday High'),
  ];

  static const List<FinancialDataPoint> oneWeek = [
    FinancialDataPoint(timeLabel: 'Mon AM', value: 121890.00, note: 'Week Open'),
    FinancialDataPoint(timeLabel: 'Mon PM', value: 122150.30),
    FinancialDataPoint(timeLabel: 'Tue AM', value: 122080.10, note: 'Consolidation'),
    FinancialDataPoint(timeLabel: 'Tue PM', value: 122420.50),
    FinancialDataPoint(timeLabel: 'Wed AM', value: 122790.00),
    FinancialDataPoint(timeLabel: 'Wed PM', value: 123340.80, note: 'CPI Report Rally'),
    FinancialDataPoint(timeLabel: 'Thu AM', value: 123180.40),
    FinancialDataPoint(timeLabel: 'Thu PM', value: 123850.20, note: 'Arbitrum Distribution'),
    FinancialDataPoint(timeLabel: 'Fri AM', value: 124120.90),
    FinancialDataPoint(timeLabel: 'Fri PM', value: 124480.00, note: 'NYSE Close'),
    FinancialDataPoint(timeLabel: 'Sat', value: 124560.40, note: 'Staking Compounding'),
    FinancialDataPoint(timeLabel: 'Sun', value: 124630.85, note: 'Weekly ATH'),
  ];

  static const List<FinancialDataPoint> oneMonth = [
    FinancialDataPoint(timeLabel: 'Day 01', value: 124630.45, note: 'Month Open'),
    FinancialDataPoint(timeLabel: 'Day 03', value: 124890.20),
    FinancialDataPoint(timeLabel: 'Day 05', value: 124720.00, note: 'Consolidation'),
    FinancialDataPoint(timeLabel: 'Day 08', value: 125140.60),
    FinancialDataPoint(timeLabel: 'Day 10', value: 125580.30, note: 'Sovereign Wire Inflow'),
    FinancialDataPoint(timeLabel: 'Day 12', value: 125390.10),
    FinancialDataPoint(timeLabel: 'Day 15', value: 126020.50, note: 'Mid-Month Yield'),
    FinancialDataPoint(timeLabel: 'Day 18', value: 126450.00),
    FinancialDataPoint(timeLabel: 'Day 20', value: 126820.70, note: 'Treasury Expansion'),
    FinancialDataPoint(timeLabel: 'Day 22', value: 126650.30),
    FinancialDataPoint(timeLabel: 'Day 25', value: 127340.90, note: 'Gold Vault Yield'),
    FinancialDataPoint(timeLabel: 'Day 27', value: 127890.40),
    FinancialDataPoint(timeLabel: 'Day 29', value: 128210.00),
    FinancialDataPoint(timeLabel: 'Day 30', value: 128450.85, note: 'Record Net Worth'),
  ];

  static const List<FinancialDataPoint> oneYear = [
    FinancialDataPoint(timeLabel: 'Q1', value: 104200.00),
    FinancialDataPoint(timeLabel: 'Q2', value: 112500.00),
    FinancialDataPoint(timeLabel: 'Q3', value: 119800.00),
    FinancialDataPoint(timeLabel: 'Q4', value: 128450.85),
  ];

  static const List<FinancialDataPoint> allTime = [
    FinancialDataPoint(timeLabel: '2023', value: 85000.00),
    FinancialDataPoint(timeLabel: '2024', value: 102000.00),
    FinancialDataPoint(timeLabel: '2025', value: 118000.00),
    FinancialDataPoint(timeLabel: '2026', value: 128450.85),
  ];

  static List<FinancialDataPoint> forPeriod(String period) {
    switch (period) {
      case '1D':
        return oneDay;
      case '1W':
        return oneWeek;
      case '1M':
        return oneMonth;
      case '1Y':
        return oneYear;
      case 'ALL':
        return allTime;
      default:
        return oneMonth;
    }
  }

  static List<double> valuesForPeriod(String period) {
    return forPeriod(period).map((p) => p.value).toList();
  }
}
