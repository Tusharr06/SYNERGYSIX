import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agro_stick/theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Map<String, dynamic>> historyCards = [
    {'title': 'Today', 'count': 3, 'period': 'daily', 'icon': Icons.today},
    {'title': 'This Week', 'count': 15, 'period': 'weekly', 'icon': Icons.calendar_view_week},
    {'title': 'This Month', 'count': 60, 'period': 'monthly', 'icon': Icons.calendar_month},
  ];

  Map<String, dynamic>? selectedCard;

  Map<String, dynamic> getGraphData(String? period) {
    switch (period) {
      case 'daily':
        return {
          'spots': <FlSpot>[
            FlSpot(0, 0),
            FlSpot(4, 1),
            FlSpot(8, 2),
            FlSpot(12, 1.5),
            FlSpot(16, 3),
            FlSpot(20, 2.5),
          ],
          'xLabels': <String>['12AM', '4AM', '8AM', '12PM', '4PM', '8PM'],
          'yLabel': 'Sprays',
        };
      case 'weekly':
        return {
          'spots': <FlSpot>[
            FlSpot(0, 2),
            FlSpot(1, 3),
            FlSpot(2, 1),
            FlSpot(3, 4),
            FlSpot(4, 2.5),
            FlSpot(5, 3.5),
            FlSpot(6, 1.5),
          ],
          'xLabels': <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          'yLabel': 'Sprays',
        };
      case 'monthly':
        return {
          'spots': <FlSpot>[
            FlSpot(1, 2),
            FlSpot(5, 3),
            FlSpot(10, 1),
            FlSpot(15, 4),
            FlSpot(20, 2.5),
            FlSpot(25, 3.5),
            FlSpot(30, 1.5),
          ],
          'xLabels': <String>['1', '5', '10', '15', '20', '25', '30'],
          'yLabel': 'Sprays',
        };
      default:
        return {
          'spots': <FlSpot>[],
          'xLabels': <String>[],
          'yLabel': 'Sprays',
        };
    }
  }

  List<Map<String, dynamic>> getSprayDetails(String? period, int count) {
    List<Map<String, dynamic>> details = [];
    for (int i = 0; i < (count > 5 ? 5 : count); i++) {
      String time;
      double amount = (i + 1) * 0.5;
      switch (period) {
        case 'daily':
          time = '${(8 + i * 2) % 24}:00 ${8 + i * 2 >= 12 ? 'PM' : 'AM'}';
          break;
        case 'weekly':
          time = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i % 7];
          break;
        case 'monthly':
          time = 'Day ${i * 5 + 1}';
          break;
        default:
          time = 'Unknown';
      }
      details.add({
        'title': 'Spray #${i + 1}',
        'time': time,
        'amount': amount,
      });
    }
    return details;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          'Spray History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              sliver: selectedCard == null
                  ? _buildSummaryView(screenWidth, screenHeight)
                  : _buildDetailView(screenWidth, screenHeight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryView(double screenWidth, double screenHeight) {
    return SliverList(
      delegate: SliverChildListDelegate([
        SizedBox(height: screenHeight * 0.02),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: historyCards.length,
          itemBuilder: (context, index) {
            final card = historyCards[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCard = card;
                });
              },
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        card['icon'] as IconData,
                        color: AppColors.primaryGreen,
                        size: screenWidth * 0.1,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        card['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        '${card['count']} Sprays',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.04,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildDetailView(double screenWidth, double screenHeight) {
    final period = selectedCard?['period'] as String? ?? 'daily';
    final count = selectedCard?['count'] as int? ?? 0;
    final graphData = getGraphData(period);
    final sprayDetails = getSprayDetails(period, count);
    final spots = graphData['spots'] as List<FlSpot>? ?? <FlSpot>[];
    final xLabels = graphData['xLabels'] as List<String>? ?? <String>[];
    final yLabel = graphData['yLabel'] as String? ?? 'Sprays';

    return SliverList(
      delegate: SliverChildListDelegate([
        WillPopScope(
          onWillPop: () async {
            setState(() {
              selectedCard = null;
            });
            return false; // Prevent app from closing
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedCard?['title'] as String? ?? 'Details',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Spray Details',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              ...sprayDetails.map((detail) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                      child: Icon(Icons.water_drop, color: AppColors.primaryGreen, size: 28),
                    ),
                    title: Text(
                      detail['title'] as String,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                    subtitle: Text(
                      'Time: ${detail['time']}\nAmount: ${detail['amount']}L',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Spray Trend',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                height: screenHeight * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: (spots.isNotEmpty ? spots.last.x / (xLabels.length - 1) : 1),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: spots.isNotEmpty ? spots.last.x / (xLabels.length - 1) : 1,
                            getTitlesWidget: (value, meta) {
                              final index = ((value / (spots.isNotEmpty ? spots.last.x / (xLabels.length - 1) : 1)).round());
                              if (index >= 0 && index < xLabels.length) {
                                return Transform.rotate(
                                  angle: -45 * 3.141592653589793 / 180,
                                  child: Text(
                                    xLabels[index],
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.grey[800],
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            yLabel,
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.04,
                              color: Colors.grey[800],
                            ),
                          ),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      minX: spots.isNotEmpty ? spots.first.x : 0,
                      maxX: spots.isNotEmpty ? spots.last.x : 1,
                      minY: 0,
                      maxY: 5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppColors.primaryGreen,
                          barWidth: 4,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                              radius: 5,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: AppColors.primaryGreen,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primaryGreen.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ]),
    );
  }
}