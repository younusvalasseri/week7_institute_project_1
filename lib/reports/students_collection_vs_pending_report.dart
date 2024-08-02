import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/account_transaction.dart';
import 'package:intl/intl.dart';
import 'package:week7_institute_project_1/custom_date_range_picker.dart';

class StudentsCollectionVsPendingReport extends StatefulWidget {
  const StudentsCollectionVsPendingReport({super.key});

  @override
  State<StudentsCollectionVsPendingReport> createState() =>
      _StudentsCollectionVsPendingReportState();
}

class _StudentsCollectionVsPendingReportState
    extends State<StudentsCollectionVsPendingReport> {
  DateTimeRange? _selectedDateRange;
  Future<List<ChartData>>? _chartDataFuture;

  @override
  void initState() {
    super.initState();
    _chartDataFuture = _prepareChartData();
  }

  void _pickDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (BuildContext context) {
        return CustomDateRangePicker(initialDateRange: _selectedDateRange);
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _chartDataFuture = _prepareChartData();
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
      _chartDataFuture = _prepareChartData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Collection Chart'),
      ),
      body: Column(
        children: [
          _buildDateFilter(),
          Expanded(
            child: FutureBuilder<List<ChartData>>(
              future: _chartDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                } else {
                  return SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      dateFormat: DateFormat.yMMMM(),
                      intervalType: DateTimeIntervalType.months,
                    ),
                    series: <ChartSeries>[
                      LineSeries<ChartData, DateTime>(
                        name: 'Student Fee Collection',
                        dataSource: snapshot.data!,
                        xValueMapper: (ChartData data, _) => data.date,
                        yValueMapper: (ChartData data, _) => data.amount,
                        dataLabelSettings: const DataLabelSettings(
                            isVisible: true), // Enable data labels
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () => _pickDateRange(context),
            child: const Text('Select Date Range'),
          ),
          if (_selectedDateRange != null)
            Column(
              children: [
                Text(
                  '${DateFormat('dd/MMM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MMM/yyyy').format(_selectedDateRange!.end)}',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearDateRange,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<List<ChartData>> _prepareChartData() async {
    final box = await Hive.openBox<AccountTransaction>('transactions');
    final transactions = box.values.where((transaction) =>
        transaction.category == 'Incomes' &&
        transaction.mainCategory == 'Student Fee');

    final Map<DateTime, double> data = {};

    for (var transaction in transactions) {
      final entryDate = transaction.entryDate;
      if (_selectedDateRange != null &&
          (entryDate.isBefore(_selectedDateRange!.start) ||
              entryDate.isAfter(_selectedDateRange!.end))) {
        continue;
      }

      final month = DateTime(entryDate.year, entryDate.month);
      if (data.containsKey(month)) {
        data[month] = data[month]! + transaction.amount;
      } else {
        data[month] = transaction.amount;
      }
    }

    final List<ChartData> chartData =
        data.entries.map((entry) => ChartData(entry.key, entry.value)).toList();

    return chartData;
  }
}

class ChartData {
  final DateTime date;
  final double amount;

  ChartData(this.date, this.amount);
}
