import '../models/plant.dart';

class PlantSchedule {
  final DateTime? indoor;
  final DateTime? sow;
  final DateTime? harvest;
  const PlantSchedule({this.indoor, this.sow, this.harvest});
}

class PlantTask {
  final DateTime date;
  final String type; // indoor | sow | harvest | indoorFall | sowFall | harvestFall
  final Plant plant;
  final String label;
  final String icon;
  const PlantTask({required this.date, required this.type, required this.plant, required this.label, required this.icon});
}

class ScheduleService {
  static ({DateTime? lastFrost, DateTime? firstFallFrost}) computeZoneKeyDates(String zone, {DateTime? today}) {
    final z = usdaZones[zone];
    today ??= DateTime.now();
    if (z == null) return (lastFrost: null, firstFallFrost: null);
    var year = today.year;
    var lastFrost = DateTime(year, z.month, z.day);
    if (lastFrost.isBefore(today)) {
      lastFrost = DateTime(year + 1, z.month, z.day);
    }
    DateTime? firstFallFrost;
    if (z.firstMonth != null && z.firstDay != null) {
      firstFallFrost = DateTime(lastFrost.year, z.firstMonth!, z.firstDay!);
    }
    return (lastFrost: lastFrost, firstFallFrost: firstFallFrost);
  }

  static PlantSchedule computeSpringSchedule(Plant plant, String zone) {
    final anchors = computeZoneKeyDates(zone);
    final lastFrost = anchors.lastFrost;
    if (lastFrost == null) return const PlantSchedule();
    final sow = lastFrost.add(Duration(days: plant.plantAfterFrostDays));
    DateTime? indoor;
    if (plant.startIndoorsWeeks > 0) {
      indoor = sow.subtract(Duration(days: plant.startIndoorsWeeks * 7));
    }
    DateTime? harvest;
    if (plant.harvestWeeks > 0) {
      harvest = sow.add(Duration(days: plant.harvestWeeks * 7));
    }
    return PlantSchedule(indoor: indoor, sow: sow, harvest: harvest);
  }

  static PlantSchedule computeFallSchedule(Plant plant, String zone) {
    if (!plant.supportsFall) return const PlantSchedule();
    final anchors = computeZoneKeyDates(zone);
    final fallFrost = anchors.firstFallFrost;
    if (fallFrost == null) return const PlantSchedule();
    final sow = fallFrost.subtract(Duration(days: plant.fallPlantBeforeFrostDays));
    DateTime? indoor;
    if (plant.fallStartIndoorsWeeks > 0) {
      indoor = sow.subtract(Duration(days: plant.fallStartIndoorsWeeks * 7));
    }
    DateTime? harvest;
    if (plant.harvestWeeks > 0) {
      harvest = sow.add(Duration(days: plant.harvestWeeks * 7));
    }
    return PlantSchedule(indoor: indoor, sow: sow, harvest: harvest);
  }

  static List<PlantTask> makePlantTasks(Plant plant, String zone) {
    final tasks = <PlantTask>[];
    final spring = computeSpringSchedule(plant, zone);
    if (spring.indoor != null) {
      tasks.add(PlantTask(date: spring.indoor!, type: 'indoor', plant: plant, label: 'Start ${plant.name} indoors', icon: '🌱'));
    }
    if (spring.sow != null) {
      final label = spring.indoor != null ? 'Transplant ${plant.name}' : 'Sow ${plant.name}';
      final icon = spring.indoor != null ? '🌿' : '🌱';
      tasks.add(PlantTask(date: spring.sow!, type: 'sow', plant: plant, label: label, icon: icon));
    }
    if (spring.harvest != null) {
      tasks.add(PlantTask(date: spring.harvest!, type: 'harvest', plant: plant, label: 'Harvest ${plant.name}', icon: '🎉'));
    }
    final fall = computeFallSchedule(plant, zone);
    if (fall.indoor != null) {
      tasks.add(PlantTask(date: fall.indoor!, type: 'indoorFall', plant: plant, label: 'Start ${plant.name} indoors (fall)', icon: '🌱'));
    }
    if (fall.sow != null) {
      final label = fall.indoor != null ? 'Transplant ${plant.name} (fall)' : 'Sow ${plant.name} (fall)';
      final icon = fall.indoor != null ? '🌿' : '🌱';
      tasks.add(PlantTask(date: fall.sow!, type: 'sowFall', plant: plant, label: label, icon: icon));
    }
    if (fall.harvest != null) {
      tasks.add(PlantTask(date: fall.harvest!, type: 'harvestFall', plant: plant, label: 'Harvest ${plant.name} (fall)', icon: '🎉'));
    }
    tasks.sort((a, b) => a.date.compareTo(b.date));
    return tasks;
  }
}
