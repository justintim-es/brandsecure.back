import 'package:conduit/conduit.dart';
import 'package:backend_conduit/models/brand.dart';
class MainController extends ResourceController {
  ManagedContext context;
  MainController(this.context);

  @Operation.get()
  Future<Response> getIsConfirmed() async {
    final brandQuery = Query<Brand>(context)
      ..where((i) => i.id).equalTo(request!.authorization!.ownerID);
    final brand = await brandQuery.fetchOne();
    return Response.ok(brand?.isConfirmed);
  }
}
