import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/core/storage/token_storage.dart';
import 'package:e_commerce/data/datasources/remote/auth_remote_datasource.dart';
import 'package:e_commerce/data/datasources/remote/google_auth_remote_datasource.dart';
import 'package:e_commerce/data/datasources/remote/user_remote_datasource.dart';
import 'package:e_commerce/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce/data/repositories/user_repository.dart';
import 'package:e_commerce/domain/repositories/auth_repository.dart';
import 'package:e_commerce/domain/usecases/auth/signin_with_google.dart';
import 'package:e_commerce/domain/usecases/user/get_user_profile.dart';
import 'package:e_commerce/domain/usecases/user/update_profile_details.dart';
import 'package:e_commerce/domain/usecases/user/update_user_profile_image.dart';
import 'package:e_commerce/presentation/cubit/auth_cubit.dart';
import 'package:e_commerce/presentation/cubit/profile_cubit.dart';
import 'package:e_commerce/presentation/screens/home_screen.dart';
import 'package:e_commerce/presentation/screens/onboarding_screen.dart';
import 'package:e_commerce/presentation/screens/splash_screen.dart';
import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

late final TokenStorage appTokenStorage;
late final ApiClient appApiClient;
late final AuthRepository appAuthRepository;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  appTokenStorage = TokenStorage();
  appApiClient = ApiClient(storage: appTokenStorage);
  final authRemote = AuthRemoteDatasource(
    apiClient: appApiClient,
    tokenStorage: appTokenStorage,
  );
  final googleAuth = GoogleAuthService(authRemote);
  final userRemote = UserRemoteDatasourceImpl(apiClient: appApiClient);
  appAuthRepository = AuthRepositoryImpl(
    authRemote: authRemote,
    googleAuth: googleAuth,
    userRemote: userRemote,
    tokenStorage: appTokenStorage,
  );

  final signInWithGoogle = SignInWithGoogle(appAuthRepository);

  final userRepository = UserRepositoryImpl(userRemote);
  final getUserProfile = GetUserProfile(userRepository);
  final updateUserProfileImage = UpdateUserProfileImage(userRepository);
  final updateProfileDetails = UpdateProfileDetails(userRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(signInWithGoogle),
        ),
        BlocProvider(
          create: (_) => ProfileCubit(
            getUserProfile,
            updateUserProfileImage,
            updateProfileDetails,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soko Mkononi',
      theme: AppTheme.light,
      home: FutureBuilder<bool>(
        future: appTokenStorage.isLoggedIn(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (authSnapshot.hasData && authSnapshot.data == true) {
            return const HomeScreen();
          }
          return const OnboardingScreen();
        },
      ),
    );
  }
}
