import 'package:dynamic_form_bi/data/models/states/states_model.dart';
import 'package:dynamic_form_bi/data/models/states/style_states_model.dart';

enum StatesEnum { base, error, success, focused,disabled,loading }

class ReusedWidget {
  static StyleStatesModel? getStateStyle(StatesModel? states, StatesEnum state) {
    switch (state) {
      case StatesEnum.base:
        return states?.base;
      case StatesEnum.error:
        return states?.error;
      case StatesEnum.success:
        return states?.success;
      case StatesEnum.focused:
        return states?.focused;
        //disabled, loading
      default:
        return null;
    }
  }
}
