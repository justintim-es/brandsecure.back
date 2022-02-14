import 'package:mailer/mailer.dart';
import 'package:conduit/conduit.dart';
import 'package:backend_conduit/models/brand.dart';
import 'package:mailer/smtp_server.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:regexed_validator/regexed_validator.dart';
import 'package:random_string/random_string.dart';
class RegisterBrandController extends ResourceController {
  ManagedContext context;
  AuthServer authServer;
  SmtpServer smtpServer;
  String secret;
  RegisterBrandController(this.secret, this.context, this.authServer, this.smtpServer);
  @Operation.post()
  Future<Response> register() async {
    final Map<String, dynamic> body = await request!.body.decode();
    final brandName = body['brandName'] as String;
    final brandNameFreeQuery = Query<Brand>(context)
      ..where((i) => i.brandName).equalTo(brandName);
    final brandNameFree = await brandNameFreeQuery.fetchOne();
    if(brandNameFree != null) {
      return Response.badRequest(body: {
        "error": "brand is already registered"
      });
    }
    final email = body['email'] as String;
    if (!validator.email(email)) {
      return Response.badRequest(body: {
        "error": "invalid e-mail"
      });
    }
    final isEmailFreeQuery = Query<Brand>(context)
      ..where((i) => i.username).equalTo(email);
    final isEmailFree = await isEmailFreeQuery.fetchOne();
    if (isEmailFree != null) {
      return Response.badRequest(body: {
        "error": "email is already in use"
      });
    }
    final password = body['password'] as String;
    if (!validator.password(password)) {
      return Response.badRequest(body: {
        'error': 'password is not strong enough'
      });
    }
    final salt = AuthUtility.generateRandomSalt();
    final brandQuery = Query<Brand>(context)
      ..values.brandName = body['brandName'] as String
      ..values.username = email
      ..values.onboardId = randomAlphaNumeric(500)
      ..values.salt = salt
      ..values.hashedPassword = authServer.hashPassword(password, salt);
    final inserted = await brandQuery.insert();
    final claim = JwtClaim(otherClaims: <String, int>{
      'id': inserted.id!
    });
    final token = issueJwtHS256(claim, secret);
    final message = Message()
      ..from = const Address('info@resalewebsite.io', 'brandssecu.re')
      ..recipients.add(inserted.username!)
      ..subject = "Please confirm your e-mail"
      ..text = "Press on the following link to confirm your e-mail\nhttp://localhost:4200/confirm/$token";
    await send(message, smtpServer);
    return Response.ok("");
  }
  @Operation.get()
  Future<Response> getIsConfirmed() async {
    final brandQuery = Query<Brand>(context)
      ..where((i) => i.id).equalTo(request!.authorization!.ownerID);
    final brand = await brandQuery.fetchOne();
    return Response.ok(brand?.isConfirmed);
  }
  @Operation.post('jwt')
  Future<Response> confirm(@Bind.path('jwt') String jwt) async {
    final claim = verifyJwtHS256Signature(jwt, secret);
    final brandUpdateQuery = Query<Brand>(context)
      ..values.isConfirmed = true
      ..where((i) => i.id).equalTo(claim['id'] as int);
    final brandUpdate = await brandUpdateQuery.updateOne();
    return Response.ok("");
  }
}
