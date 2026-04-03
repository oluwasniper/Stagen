import 'package:appwrite/appwrite.dart';

import '../config/app_config.dart';

Client buildAppwriteClient() {
  final configError = AppConfig.appwriteConfigError;
  if (configError != null) {
    throw StateError(configError);
  }

  return Client()
    ..setProject(AppConfig.appwriteProjectId.trim())
    ..setEndpoint(AppConfig.appwriteEndpoint);
}
