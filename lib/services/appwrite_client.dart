import 'package:appwrite/appwrite.dart';

import '../config/app_config.dart';

final Client client = Client()
  ..setProject(AppConfig.appwriteProjectId)
  ..setEndpoint(AppConfig.appwriteEndpoint);
