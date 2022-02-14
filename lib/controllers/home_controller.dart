import 'package:conduit/conduit.dart';
import 'package:backend_conduit/models/brand.dart';
import 'package:dio/dio.dart' as dischio;
import 'package:random_string/random_string.dart';
class HomeController extends ResourceController {
  ManagedContext context;
  HomeController(this.context);
  @Operation.get()
  Future<Response> isBoarded() async {
    final brandQuery = Query<Brand>(context)
      ..where((i) => i.id).equalTo(request!.authorization!.ownerID);
    final brand = await brandQuery.fetchOne();
    return Response.ok(brand!.isBoarded!);
  }
  @Operation.post()
  Future<Response> onboard() async {
    final brandQuery = Query<Brand>(context)
      ..where((i) => i.id).equalTo(request!.authorization!.ownerID);
      final brand = await brandQuery.fetchOne();
    final response = await dischio.Dio().get('http://localhost:3000/api/onboard/onboard-link/' + brand!.onboardId!);
    final brandUpdateQuery = Query<Brand>(context)
      ..values.stripeAccountId = response.data['id'] as String
      ..where((i) => i.id).equalTo(request!.authorization!.ownerID);
    final brandUpdate = await brandUpdateQuery.updateOne();
    return Response.ok(response.data['link']);
  }
}
