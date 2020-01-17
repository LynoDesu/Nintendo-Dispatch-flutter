import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.topCenter, 
      child: ClipRRect(borderRadius: BorderRadius.circular(6), 
        child: Container(color: Colors.grey, padding: EdgeInsets.all(10),
          child: CircularProgressIndicator()
        )
      ),
    );
  }
}