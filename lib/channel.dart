import 'package:backend_conduit/backend_conduit.dart';
import 'package:backend_conduit/models/brand_config.dart';
import 'package:conduit/managed_auth.dart';
import 'package:backend_conduit/models/brand.dart';
import 'package:backend_conduit/controllers/register_brand_controller.dart';
import 'package:mailer/smtp_server.dart';
import 'package:backend_conduit/controllers/main_controller.dart';
import 'package:backend_conduit/controllers/home_controller.dart';
/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://conduit.io/docs/http/channel/.
class BackendConduitChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  ManagedContext? context;
  AuthServer? authServer;
  SmtpServer? smtpServer;
  BrandConfig? config;
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
      config = BrandConfig(options!.configurationFilePath!);
      final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
      final presistanceStore = PostgreSQLPersistentStore.fromConnectionInfo(config!.dbuser, config!.password, config!.host, config!.port, config!.dbname);
      context = ManagedContext(dataModel, presistanceStore);
      final authStorage = ManagedAuthDelegate<Brand>(context);
      authServer = AuthServer(authStorage);
      smtpServer = SmtpServer(config!.smtpHost!, port: config!.smtpPort!, username: config!.smtpUser, password: config!.smtpPassword);
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://conduit.io/docs/http/request_controller/
    router.route('/auth/token').link(() => AuthController(authServer));
    router.route('/register-brand/[:jwt]').link(() => RegisterBrandController(config!.secret!, context!, authServer!, smtpServer!));
    router.route('/main')
    .link(() => Authorizer.bearer(authServer!))
    ?.link(() => MainController(context!));
    router.route('/home')
    .link(() => Authorizer.bearer(authServer!))
    ?.link(() => HomeController(context!));
    return router;
  }
}
