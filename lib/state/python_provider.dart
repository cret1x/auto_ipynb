import 'package:auto_ipynb/core/nb_env.dart';
import 'package:auto_ipynb/util/directory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PythonNotifier extends AsyncNotifier<String> {

  @override
  Future<String> build() async {
    final python = await getPythonExe();
    if (python == null) {
      if (await NbEnv.checkPythonExe("py")) {
        await setPath("py");
        return "py";
      }
      throw Exception("python");
    }
    return python;
  }

  Future<void> setPath(String pythonPath) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("python", pythonPath);
    state = AsyncValue.data(pythonPath);
  }
}

final pythonProvider = AsyncNotifierProvider<PythonNotifier, String>(PythonNotifier.new);