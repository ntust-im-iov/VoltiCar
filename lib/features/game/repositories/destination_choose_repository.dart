import "package:volticar_app/features/game/models/destination_choose_model.dart";
import "package:volticar_app/features/game/services/destination_choose_service.dart";

class DestinationChooseRepository {
  final DestinationChooseService _destinationChooseService =
      DestinationChooseService();

  Future<DestinationChooseModel> chooseDestination(String destinationId) async {
    final result =
        await _destinationChooseService.chooseDestination(destinationId);
    return result;
  }
}
