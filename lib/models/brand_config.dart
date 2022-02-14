import 'package:backend_conduit/backend_conduit.dart';
class BrandConfig extends Configuration {
	BrandConfig(String fileName): super.fromFile(File(fileName));
	String? dbuser;
	String? password;
	String? host;
	int? port;
	String? dbname;
	String? secret;
	String? smtpHost;
	int? smtpPort;
	String? smtpUser ;
	String? smtpPassword;
}
