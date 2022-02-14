import 'dart:async';
import 'package:conduit/conduit.dart';   

class Migration3 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("_Brand", "isConfirmed", (c) {c.defaultValue = "false";});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    