import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyForecast {
  final DateTime date;
  final double? minTempC;
  final double? maxTempC;
  final double? precipitationMm;
  final int? weatherCode;

  DailyForecast({
    required this.date,
    this.minTempC,
    this.maxTempC,
    this.precipitationMm,
    this.weatherCode,
  });
}

class WeatherService {
  // Open-Meteo free API: no key required
  static Future<List<DailyForecast>> fetch7DayForecast({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=auto',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch weather: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;
    final times = List<String>.from(daily['time'] as List);
    final tMax = List<double>.from((daily['temperature_2m_max'] as List).map((e) => (e as num).toDouble()));
    final tMin = List<double>.from((daily['temperature_2m_min'] as List).map((e) => (e as num).toDouble()));
    final precip = List<double>.from((daily['precipitation_sum'] as List).map((e) => (e as num).toDouble()));
    final wCode = List<int>.from((daily['weathercode'] as List).map((e) => (e as num).toInt()));

    final List<DailyForecast> out = [];
    for (int i = 0; i < times.length && i < 7; i++) {
      out.add(DailyForecast(
        date: DateTime.parse(times[i]),
        minTempC: tMin[i],
        maxTempC: tMax[i],
        precipitationMm: precip[i],
        weatherCode: wCode[i],
      ));
    }
    return out;
  }

  // Simple WMO weather code -> emoji/icon hint
  static String codeToEmoji(int? code) {
    if (code == null) return '❓';
    if (code == 0) return '☀️'; // clear
    if ([1,2,3].contains(code)) return '⛅'; // partly cloudy
    if ([45,48].contains(code)) return '🌫️'; // fog
    if ([51,53,55,61,63,65].contains(code)) return '🌧️'; // rain
    if ([66,67,80,81,82].contains(code)) return '🌦️'; // showers
    if ([71,73,75,77,85,86].contains(code)) return '❄️'; // snow
    if ([95,96,99].contains(code)) return '⛈️'; // thunderstorm
    return '🌡️';
  }
}


