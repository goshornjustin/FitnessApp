/// Sign-in / sign-up page.
///
/// A single page that toggles between sign-in and sign-up modes. Uses
/// `flutter_hooks` for local text controller state and `hooks_riverpod` to
/// read auth providers. The form is hidden once the user is authenticated —
/// the router handles navigation away automatically via `authStateProvider`.
library;

import 'package:fitness_app/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:fitness_app/features/authentication/domain/usecases/sign_up_with_email.dart';
import 'package:fitness_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthPage extends HookConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isSignUp = useState(false);
    
    final authState = ref.watch(authStateProvider);
    final isLoading = ref.watch(authLoadingProvider);
    final authError = ref.watch(authErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isSignUp.value ? 'Sign Up' : 'Sign In'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Auth State Display
            authState.when(
              data: (user) {
                if (user != null) {
                  return Card(
                    color: Colors.green.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 48),
                          const SizedBox(height: 8),
                          Text('Welcome, ${user.name}!'),
                          Text('Email: ${user.email}'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(signOutAsyncProvider);
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Auth Error: $error'),
            ),
            
            const SizedBox(height: 32),
            
            // Show form only if not authenticated
            authState.when(
              data: (user) {
                if (user == null) {
                  return Column(
                    children: [
                      // Email Field
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Field
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      
                      // Error Display
                      if (authError != null)
                        Card(
                          color: Colors.red.shade100,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              authError,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Auth Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            
                            if (email.isEmpty || password.isEmpty) {
                              ref.read(authErrorProvider.notifier).state = 
                                'Please enter both email and password';
                              return;
                            }
                            
                            if (isSignUp.value) {
                              await ref.read(signUpProvider(SignUpParams(
                                email: email,
                                password: password,
                                name: email.split('@')[0], // Simple name from email
                              )));
                            } else {
                              await ref.read(signInProvider(SignInParams(
                                email: email,
                                password: password,
                              )));
                            }
                          },
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : Text(isSignUp.value ? 'Sign Up' : 'Sign In'),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Toggle Sign Up/In
                      TextButton(
                        onPressed: () {
                          isSignUp.value = !isSignUp.value;
                          ref.read(authErrorProvider.notifier).state = null;
                        },
                        child: Text(
                          isSignUp.value
                              ? 'Already have an account? Sign In'
                              : 'Don\'t have an account? Sign Up',
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}