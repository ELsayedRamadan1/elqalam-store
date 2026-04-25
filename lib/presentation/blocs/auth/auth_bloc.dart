import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/usecases/update_profile_usecase.dart';
import '../../../domain/usecases/upload_avatar_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
    required this.uploadAvatarUseCase,
  }) : super(const AuthState()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<GetCurrentUserEvent>(_onGetCurrentUser);
    on<UploadAvatarEvent>(_onUploadAvatar);
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final user = await loginUseCase(event.email, event.password);
      emit(state.copyWith(user: user, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final user =
          await registerUseCase(event.email, event.password, event.name);
      emit(state.copyWith(user: user, isLoading: false));
    } catch (e) {
      debugPrint('Register error: $e');
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await logoutUseCase();
      emit(const AuthState()); // full reset
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onGetCurrentUser(
      GetCurrentUserEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final user = await getCurrentUserUseCase();
      emit(state.copyWith(user: user, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    if (state.user == null) return;

    emit(state.copyWith(isLoading: true, error: null));
    try {
      final user = await updateProfileUseCase.call(
        userId: state.user!.id,
        name: event.name,
        phone: event.phone,
        address: event.address,
        avatarUrl: event.avatarUrl,
      );
      emit(state.copyWith(user: user, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onUploadAvatar(UploadAvatarEvent event, Emitter<AuthState> emit) async {
    if (state.user == null) return;

    emit(state.copyWith(isLoading: true, error: null));
    try {
      // First upload the image to storage
      final avatarUrl = await uploadAvatarUseCase.call(
        userId: state.user!.id,
        imageBytes: event.imageBytes,
        fileName: event.fileName,
      );

      // Then update the profile with the new avatar URL
      final user = await updateProfileUseCase.call(
        userId: state.user!.id,
        avatarUrl: avatarUrl,
      );

      emit(state.copyWith(user: user, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }
}
