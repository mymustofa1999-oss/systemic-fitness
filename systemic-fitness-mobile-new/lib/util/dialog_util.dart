import 'package:flutter/material.dart';
import 'package:workout/util/loading_dialog.dart';

class DialogUtil{
  BuildContext? context;

  bool isOpen = false;

  BuildContext? dialogContext;


  DialogUtil(BuildContext context){
    this.context = context;
  }





  showLoadingDialog(){
    isOpen = true;
    showDialog(
        context: context!,
        builder: (BuildContext context) {
          dialogContext= context;
          return LoadingDialog();
        }).then((value) => isOpen = false);

  }


  dismissLoadingDialog(){
    if(isOpen){
      isOpen = false;
      Navigator.pop(dialogContext!);
    }
  }



}