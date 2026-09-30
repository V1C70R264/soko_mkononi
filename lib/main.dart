import 'package:e_commerce/core/network/api_client.dart';
import 'package:e_commerce/core/storage/token_storage.dart';
import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:e_commerce/data/datasources/remote/address_remote_datasource.dart';
import 'package:e_commerce/data/datasources/remote/auth_remote_datasource.dart';
import 'package:e_commerce/data/datasources/remote/cart_remote_datasource.dart';
import 'package:e_commerce/data/datasources/remote/favorites_remote_datasource.dart';
import 'package:e_commerce/data/datasources/remote/google_auth_remote_datasource.dart';
import 'package:e_commerce/data/datasources/remote/home_remote_datasource.dart';
import 'package:e_commerce/data/datasources/remote/order_remote_datasource.dart';
import 'package:e_commerce/data/datasources/remote/user_remote_datasource.dart';
import 'package:e_commerce/data/repositories/address_repository_impl.dart';
import 'package:e_commerce/data/repositories/auth_repository_impl.dart';
import 'package:e_commerce/data/repositories/cart_repository_impl.dart';
import 'package:e_commerce/data/repositories/favorites_repository_impl.dart';
import 'package:e_commerce/data/repositories/home_repository_impl.dart';
import 'package:e_commerce/data/repositories/order_repository_impl.dart';
import 'package:e_commerce/data/repositories/user_repository.dart';
import 'package:e_commerce/domain/repositories/auth_repository.dart';
import 'package:e_commerce/domain/usecases/add_to_cart.dart';
import 'package:e_commerce/domain/usecases/auth/signin_with_google.dart';
import 'package:e_commerce/domain/usecases/cancel_order.dart';
import 'package:e_commerce/domain/usecases/clear_cart.dart';
import 'package:e_commerce/domain/usecases/create_address.dart';
import 'package:e_commerce/domain/usecases/create_order.dart';
import 'package:e_commerce/domain/usecases/get_addresses.dart';
import 'package:e_commerce/domain/usecases/get_cart.dart';
import 'package:e_commerce/domain/usecases/get_categories.dart';
import 'package:e_commerce/domain/usecases/get_favorites.dart';
import 'package:e_commerce/domain/usecases/get_orders.dart';
import 'package:e_commerce/domain/usecases/get_products_by_category.dart';
import 'package:e_commerce/domain/usecases/remove_cart_item.dart';
import 'package:e_commerce/domain/usecases/search_products.dart';
import 'package:e_commerce/domain/usecases/set_default_address.dart';
import 'package:e_commerce/domain/usecases/toggle_favorite.dart';
import 'package:e_commerce/domain/usecases/update_cart_item_quantity.dart';
import 'package:e_commerce/domain/usecases/user/get_user_profile.dart';
import 'package:e_commerce/domain/usecases/user/update_profile_details.dart';
import 'package:e_commerce/domain/usecases/user/update_user_profile_image.dart';
import 'package:e_commerce/presentation/bloc/address/address_bloc.dart';
import 'package:e_commerce/presentation/bloc/cart/cart_bloc.dart';
import 'package:e_commerce/presentation/bloc/checkout/checkout_bloc.dart';
import 'package:e_commerce/presentation/bloc/favorites/favorites_bloc.dart';
import 'package:e_commerce/presentation/bloc/home_bloc.dart';
import 'package:e_commerce/presentation/bloc/orders/orders_bloc.dart';
import 'package:e_commerce/presentation/bloc/search/search_bloc.dart';
import 'package:e_commerce/presentation/cubit/auth_cubit.dart';
import 'package:e_commerce/presentation/cubit/profile_cubit.dart';
import 'package:e_commerce/presentation/screens/home_screen.dart';
import 'package:e_commerce/presentation/screens/onboarding_screen.dart';
import 'package:e_commerce/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

late final TokenStorage appTokenStorage;
late final ApiClient appApiClient;
late final AuthRepository appAuthRepository;
late final GetProductsByCategory appGetProductsByCategory;

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

  final homeRemoteDataSource = HomeRemoteDataSourceImpl(apiClient: appApiClient);
  final homeRepository = HomeRepositoryImpl(homeRemoteDataSource);
  final getCategories = GetCategories(homeRepository);
  final getProductsByCategory = GetProductsByCategory(homeRepository);
  appGetProductsByCategory = getProductsByCategory;

  // --- Search feature (reuses homeRepository, no new datasource) ---
  final searchProducts = SearchProducts(homeRepository);

  // --- Cart feature ---
  final cartRemoteDataSource = CartRemoteDataSourceImpl(apiClient: appApiClient);
  final cartRepository = CartRepositoryImpl(cartRemoteDataSource);
  final addToCart = AddToCart(cartRepository);
  final getCart = GetCart(cartRepository);
  final updateCartItemQuantity = UpdateCartItemQuantity(cartRepository);
  final removeCartItem = RemoveCartItem(cartRepository);
  final clearCart = ClearCart(cartRepository);

  // --- Favorites feature ---
  final favoritesRemoteDataSource =
      FavoritesRemoteDataSourceImpl(apiClient: appApiClient);
  final favoritesRepository = FavoritesRepositoryImpl(favoritesRemoteDataSource);
  final getFavorites = GetFavorites(favoritesRepository);
  final toggleFavorite = ToggleFavorite(favoritesRepository);

  // --- Addresses feature ---
  final addressRemoteDataSource =
      AddressRemoteDataSourceImpl(apiClient: appApiClient);
  final addressRepository = AddressRepositoryImpl(addressRemoteDataSource);
  final getAddresses = GetAddresses(addressRepository);
  final createAddress = CreateAddress(addressRepository);
  final setDefaultAddress = SetDefaultAddress(addressRepository);

  // --- Orders feature ---
  final orderRemoteDataSource = OrderRemoteDataSourceImpl(apiClient: appApiClient);
  final orderRepository = OrderRepositoryImpl(orderRemoteDataSource);
  final getOrders = GetOrders(orderRepository);
  final createOrder = CreateOrder(orderRepository);
  final cancelOrder = CancelOrder(orderRepository);

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
        BlocProvider(
          create: (_) => HomeBloc(getCategories, getProductsByCategory),
        ),
        BlocProvider(
          create: (_) => CartBloc(
            addToCart,
            getCart,
            updateCartItemQuantity,
            removeCartItem,
            clearCart,
          ),
        ),
        BlocProvider(
          create: (_) => FavoritesBloc(getFavorites, toggleFavorite),
        ),
        BlocProvider(
          create: (_) => SearchBloc(searchProducts),
        ),
        BlocProvider(
          create: (_) => AddressBloc(getAddresses, createAddress, setDefaultAddress),
        ),
        BlocProvider(
          create: (_) => OrdersBloc(getOrders, cancelOrder),
        ),
        BlocProvider(
          create: (_) => CheckoutBloc(createOrder),
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