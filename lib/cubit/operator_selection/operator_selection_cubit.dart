import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:venturiautospurghi/models/account.dart';
import 'package:venturiautospurghi/models/event.dart';
import 'package:venturiautospurghi/plugins/dispatcher/platform_loader.dart';
import 'package:venturiautospurghi/repositories/cloud_firestore_service.dart';
import 'package:venturiautospurghi/utils/global_constants.dart';

part 'operator_selection_state.dart';

class OperatorSelectionCubit extends Cubit<OperatorSelectionState> {
  final CloudFirestoreService _databaseRepository;
  final Event _event;
  final bool isTriState;

  OperatorSelectionCubit(this._databaseRepository, this._event, this.isTriState)
      : assert(_databaseRepository != null),
        super(LoadingOperators()){
      getOperators();
  }

  bool onTap(Account operator) {
    if(Constants.debug) print("${operator.name} ${operator.surname} selected");
    ReadyOperators state = (this.state as ReadyOperators);
    Map<String,int> selectionListUpdated = new Map.from(state.selectionList);
    if(selectionListUpdated.containsKey(operator.id)) {
      if(selectionListUpdated[operator.id] == 2) state.primaryOperatorSelected = false;
      int newValue = (selectionListUpdated[operator.id]+1) % ((isTriState && !state.primaryOperatorSelected)? 3 : 2);
      if(newValue == 2) state.primaryOperatorSelected = true;
      selectionListUpdated[operator.id] = newValue;
      emit(new ReadyOperators.updateSelection(state, selectionListUpdated));
    }
  }

  void getOperators() async {
    List<Account> operators = await _databaseRepository.getOperatorsFree(_event.id??"", _event.start, _event.end);
    emit(new ReadyOperators(operators,event:_event));
  }

  void saveSelectionToEvent(){
    ReadyOperators state = (this.state as ReadyOperators);
    List<Account> tempOperators = state.operators;
    List<Account> subOperators = List();
    state.selectionList.forEach((key, value) {
      Account tempAccount = tempOperators.firstWhere((account) => account.id == key);
      if(value == 1) subOperators.add(tempAccount);
      else if(value == 2) _event.operator = tempAccount;
      tempOperators.remove(tempAccount);
    });
    _event.suboperators = subOperators;
  }

  bool validateAndSave() {
    if(!isTriState || (state as ReadyOperators).primaryOperatorSelected) {
      saveSelectionToEvent();
      return true;
    } else {
      PlatformUtils.notifyErrorMessage("Seleziona l'operatore principale, tappando due volte");
      return false;
    }
  }

  Event getEvent() => _event;
}