import "package:volticar_app/features/game/models/destination_model.dart";
import "package:volticar_app/features/game/services/destination_fetch_service.dart";

class DestinationFetchRepository {
  final DestinationFetchService _destinationFetchService =
      DestinationFetchService();

  Future<List<Destination>> fetchDestinations() async {
    final destinations = await _destinationFetchService.fetchDestinations();
    return destinations;
  }
}
