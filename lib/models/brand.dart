import 'package:conduit/conduit.dart';
import 'package:conduit/managed_auth.dart';
class Brand extends ManagedObject<_Brand> implements _Brand, ManagedAuthResourceOwner<_Brand> {}

class _Brand extends ResourceOwnerTableDefinition {
  @Column(unique: true)
  String? brandName;
  @Column(defaultValue: 'false')
  bool? isConfirmed;
  @Column(defaultValue: 'false')
  bool? isBoarded;
  @Column(unique: true)
  String? stripeAccountId;
  @Column(nullable: true)
  String? onboardId;

}
