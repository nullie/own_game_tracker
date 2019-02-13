import "dart:convert";
import "dart:io";
import "package:path_provider/path_provider.dart";

class ParticipantsStorage {
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/participants.json");
  }

  Future<List<Participant>> load() async {
    final file = await _getLocalFile();
    if(await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> data = jsonDecode(contents);
      final List<Participant> participants = data.map(
        (entry) => Participant(entry['name'], entry['score'])
      ).toList();
      return participants;
    } else {
      return _getDefaultParticipants();
    }
  }
  Future<void> save(final List<Participant> participants) async {
    final data = participants.map((participant) => {
      'name': participant.name,
      'score': participant.score,
    }).toList();
    final contents = jsonEncode(data);
    final file = await _getLocalFile();
    await file.writeAsString(contents, mode: FileMode.writeOnly, flush: true);
  }
  List<Participant> _getDefaultParticipants() {
    return List.generate(8, (index) => Participant("Игрок $index", 0));
  }
}

class Participant {
  String name;
  int score;
  Participant(this.name, this.score);
}
