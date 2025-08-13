import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'noti_service.dart';

final notiService = NotiService();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background task started");
    if (task == "checkVaccination") {
      await notiService.initNotification();
      print("Checking vaccination dates...");

      final childId = inputData?['childId'];
      if (childId == null) return Future.value(false);

      try {
        // Fetch child data (no setState)
        final childResponse = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/child/$childId'),
        );

        if (childResponse.statusCode != 200) return Future.value(false);

        final childData = json.decode(childResponse.body);
        final childName = childData['name'];
        final childDOB = DateTime.parse(childData['date_of_birth']);

        // Fetch next period
        final nextPeriodResponse = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/child/$childId/vaccinations/nextStatus'),
        );

        if (nextPeriodResponse.statusCode != 200) return Future.value(false);

        final nextPeriodList = json.decode(nextPeriodResponse.body) as List<dynamic>;
        final notCompleted = nextPeriodList.where((item) => item['status'] == false).toList();

        if (notCompleted.isEmpty) return Future.value(true);

        // Calculate days until next period
        final now = DateTime.now();
        final nextPeriodDate = DateTime(
          now.year,
          childDOB.month,
          childDOB.day,
        );

        var adjustedNextPeriod = nextPeriodDate;
        if (adjustedNextPeriod.isBefore(now)) {
          adjustedNextPeriod = DateTime(
            now.year + 1,
            childDOB.month,
            childDOB.day,
          );
        }

        final daysUntil = adjustedNextPeriod.difference(now).inDays;

        // Show notification if exactly 7 days left
        if (daysUntil > 0 && daysUntil <= 7) {
          final missingNames = notCompleted.map((item) => item['name']).join(', ');
          await notiService.showNotification(
            id: childId,
            title: "Upcoming Vaccination",
            body: "$missingNames is due for $childName in $daysUntil day${daysUntil > 1 ? 's' : ''}.",
          );
        }
      } catch (e) {
        print("Error in background task: $e");
        return Future.value(false);
      }
    }

    return Future.value(true);
  });
}
