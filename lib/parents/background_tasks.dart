import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'noti_service.dart';

final notiService = NotiService();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background task started: $task");

    if (task == "checkVaccination") {
      await notiService.initNotification();
      print("Checking vaccination dates...");

      final childId = inputData?['childId'];
      if (childId == null) return Future.value(false);

      try {
        // Fetch child data
        final childResponse =
        await http.get(Uri.parse('http://10.0.2.2:8000/api/child/$childId'));
        if (childResponse.statusCode != 200) return Future.value(false);

        final childData = json.decode(childResponse.body);
        final childName = childData['name'];
        final childDOB = DateTime.parse(childData['date_of_birth']);

        // Fetch vaccination status
        final nextPeriodResponse = await http.get(
          Uri.parse(
              'http://10.0.2.2:8000/api/child/$childId/vaccinations/status'),
        );
        if (nextPeriodResponse.statusCode != 200) return Future.value(false);

        final nextPeriodList =
        json.decode(nextPeriodResponse.body) as List<dynamic>;
        final notCompleted =
        nextPeriodList.where((item) => item['status'] == false).toList();

        if (notCompleted.isEmpty) return Future.value(true);

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
        final missingNames = notCompleted.map<String>((item) => item['name'] as String).toList();

        if (daysUntil > 0 && daysUntil <= 7) {
          await notiService.showMissingVaccination(
            childName: childName,
            missingNames: missingNames,
            id: childId,
          );
        } else {
          await notiService.showMissingVaccination(
            childName: childName,
            missingNames: missingNames,
            id: childId,
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
