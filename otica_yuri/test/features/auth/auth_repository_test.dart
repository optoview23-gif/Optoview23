// test/features/auth/auth_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:otica_yuri/features/auth/data/auth_repository.dart';

@GenerateMocks([FirebaseAuth, User, UserCredential])
import 'auth_repository_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late AuthRepository repo;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    repo = AuthRepository(mockAuth);
  });

  test('signIn chama FirebaseAuth com email e senha corretos', () async {
    when(mockAuth.signInWithEmailAndPassword(
      email: 'teste@otica.com',
      password: '123456',
    )).thenAnswer((_) async => MockUserCredential());

    await repo.signIn('teste@otica.com', '123456');

    verify(mockAuth.signInWithEmailAndPassword(
      email: 'teste@otica.com',
      password: '123456',
    )).called(1);
  });

  test('signOut chama FirebaseAuth.signOut', () async {
    when(mockAuth.signOut()).thenAnswer((_) async {});
    await repo.signOut();
    verify(mockAuth.signOut()).called(1);
  });
}
