import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:elqalam/domain/entities/user.dart';
import 'package:elqalam/domain/usecases/login_usecase.dart';
import 'package:elqalam/domain/usecases/register_usecase.dart';
import 'package:elqalam/domain/usecases/logout_usecase.dart';
import 'package:elqalam/domain/usecases/get_current_user_usecase.dart';
import 'package:elqalam/domain/usecases/update_profile_usecase.dart';
import 'package:elqalam/domain/usecases/upload_avatar_usecase.dart';
import 'package:elqalam/presentation/blocs/auth/auth_bloc.dart';
import 'package:elqalam/presentation/blocs/auth/auth_event.dart';
import 'package:elqalam/presentation/blocs/auth/auth_state.dart';

// --- Mocks ---
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}
class MockUploadAvatarUseCase extends Mock implements UploadAvatarUseCase {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockRegisterUseCase registerUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockGetCurrentUserUseCase getCurrentUserUseCase;
  late MockUpdateProfileUseCase updateProfileUseCase;
  late MockUploadAvatarUseCase uploadAvatarUseCase;

  const testUser = User(id: '1', email: 'test@test.com', name: 'Test');

  setUp(() {
    loginUseCase = MockLoginUseCase();
    registerUseCase = MockRegisterUseCase();
    logoutUseCase = MockLogoutUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();
    updateProfileUseCase = MockUpdateProfileUseCase();
    uploadAvatarUseCase = MockUploadAvatarUseCase();
  });

  AuthBloc buildBloc() => AuthBloc(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        updateProfileUseCase: updateProfileUseCase,
        uploadAvatarUseCase: uploadAvatarUseCase,
      );

  group('AuthBloc', () {
    test('initial state is empty AuthState', () {
      expect(buildBloc().state, const AuthState());
    });

    blocTest<AuthBloc, AuthState>(
      'LoginEvent — success emits user',
      build: buildBloc,
      setUp: () {
        when(() => loginUseCase('test@test.com', '123456'))
            .thenAnswer((_) async => testUser);
      },
      act: (bloc) => bloc.add(LoginEvent('test@test.com', '123456')),
      expect: () => [
        const AuthState(isLoading: true),
        const AuthState(user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'LoginEvent — failure emits error',
      build: buildBloc,
      setUp: () {
        when(() => loginUseCase(any(), any()))
            .thenThrow(Exception('Invalid credentials'));
      },
      act: (bloc) => bloc.add(LoginEvent('bad@bad.com', 'wrong')),
      expect: () => [
        const AuthState(isLoading: true),
        isA<AuthState>().having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'LogoutEvent — clears user',
      build: buildBloc,
      seed: () => const AuthState(user: testUser),
      setUp: () {
        when(() => logoutUseCase()).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [
        const AuthState(isLoading: true, user: testUser),
        const AuthState(), // full reset
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'RegisterEvent — success emits user',
      build: buildBloc,
      setUp: () {
        when(() => registerUseCase('new@test.com', 'pass123', 'New'))
            .thenAnswer((_) async => testUser);
      },
      act: (bloc) =>
          bloc.add(RegisterEvent('new@test.com', 'pass123', 'New')),
      expect: () => [
        const AuthState(isLoading: true),
        const AuthState(user: testUser),
      ],
    );
  });
}
