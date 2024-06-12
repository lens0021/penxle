import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:ferry_flutter/ferry_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:glyph/components/button.dart';
import 'package:glyph/components/heading.dart';
import 'package:glyph/components/svg_image.dart';
import 'package:glyph/components/svg_icon.dart';
import 'package:glyph/context/loader.dart';
import 'package:glyph/ferry/extension.dart';
import 'package:glyph/graphql/__generated__/login_screen_authorize_single_sign_on_token_mutation.req.gql.dart';
import 'package:glyph/graphql/__generated__/login_screen_query.req.gql.dart';
import 'package:glyph/graphql/__generated__/schema.schema.gql.dart';
import 'package:glyph/providers/auth.dart';
import 'package:glyph/providers/ferry.dart';
import 'package:glyph/routers/app.gr.dart';
import 'package:glyph/themes/colors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:transparent_image/transparent_image.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      '58678861052-lf5sv4oggv0ieiuitk9vnh6c6nmq2e4m.apps.googleusercontent.com',
  serverClientId:
      '58678861052-afsh5183jqgh7n1cv0gp5drctvdkfb1t.apps.googleusercontent.com',
);

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 10),
    );

    _animationController.addListener(() {
      if (_animationController.status == AnimationStatus.completed) {
        final client = ref.read(ferryProvider);
        client.requestController.add(GLoginScreen_QueryReq());
      }
    });

    _animationController.repeat();

    _alignmentAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(ferryProvider);

    return Operation(
      client: client,
      operationRequest: GLoginScreen_QueryReq(),
      builder: (context, response, error) {
        return Scaffold(
          appBar: const Heading(
            backgroundColor: Colors.transparent,
            bottomBorder: false,
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              const SizedBox.expand(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: BrandColors.gray_900),
                ),
              ),
              if (response?.data != null)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return UnconstrainedBox(
                        constrainedAxis: Axis.vertical,
                        clipBehavior: Clip.hardEdge,
                        alignment: _alignmentAnimation.value,
                        child: Row(
                          children: response!.data!.featuredImages
                              .map(
                                (image) => FadeInImage(
                                  placeholder: MemoryImage(kTransparentImage),
                                  image: NetworkImage(image.url),
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  fadeInDuration:
                                      const Duration(milliseconds: 150),
                                  color: Colors.black.withOpacity(0.4),
                                  colorBlendMode: BlendMode.srcATop,
                                ),
                              )
                              .toList(),
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgImage('logos/full',
                                height: 38, color: BrandColors.gray_0),
                            Gap(8),
                            Text(
                              '창작자를 위한 콘텐츠 플랫폼\n글리프에 오신 것을 환영해요!',
                              style: TextStyle(
                                  fontSize: 16, color: BrandColors.gray_0),
                            ),
                          ],
                        ),
                      ),
                      Button(
                        style: const ButtonStyle(
                          foregroundColor:
                              WidgetStatePropertyAll(BrandColors.gray_900),
                          backgroundColor:
                              WidgetStatePropertyAll(BrandColors.gray_0),
                          minimumSize:
                              WidgetStatePropertyAll(Size.fromHeight(48)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgImage('icons/google', width: 18, height: 18),
                            Gap(10),
                            Text('구글로 시작하기', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        onPressed: () async {
                          await _googleSignIn.signOut();
                          final authResult = await _googleSignIn.signIn();
                          if (authResult == null) {
                            return;
                          }

                          if (!context.mounted) {
                            return;
                          }

                          await context.loader.run(() async {
                            final req =
                                GLoginScreen_AuthorizeSingleSignOnToken_MutationReq(
                              (b) => b
                                ..vars.input.provider =
                                    GUserSingleSignOnProvider.GOOGLE
                                ..vars.input.token = authResult.serverAuthCode,
                            );

                            final resp = await client.req(req);

                            await ref
                                .read(authProvider.notifier)
                                .setAccessToken(
                                  resp.authorizeSingleSignOnToken.token,
                                );
                          });
                        },
                      ),
                      const Gap(11),
                      Button(
                        style: const ButtonStyle(
                          foregroundColor:
                              WidgetStatePropertyAll(BrandColors.gray_900),
                          backgroundColor:
                              WidgetStatePropertyAll(BrandColors.gray_0),
                          minimumSize:
                              WidgetStatePropertyAll(Size.fromHeight(48)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgImage('icons/naver', width: 16, height: 16),
                            Gap(10),
                            Text('네이버로 시작하기', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        onPressed: () async {
                          await FlutterNaverLogin.logOut();
                          await FlutterNaverLogin.logIn();
                          final token =
                              await FlutterNaverLogin.currentAccessToken;

                          if (!token.isValid()) {
                            return;
                          }

                          if (!context.mounted) {
                            return;
                          }

                          await context.loader.run(() async {
                            final req =
                                GLoginScreen_AuthorizeSingleSignOnToken_MutationReq(
                              (b) => b
                                ..vars.input.provider =
                                    GUserSingleSignOnProvider.NAVER
                                ..vars.input.token = token.accessToken,
                            );

                            final resp = await client.req(req);
                            await ref
                                .read(authProvider.notifier)
                                .setAccessToken(
                                  resp.authorizeSingleSignOnToken.token,
                                );
                          });
                        },
                      ),
                      if (Platform.isIOS) ...[
                        const Gap(11),
                        Button(
                          style: const ButtonStyle(
                            foregroundColor:
                                WidgetStatePropertyAll(BrandColors.gray_900),
                            backgroundColor:
                                WidgetStatePropertyAll(BrandColors.gray_0),
                            minimumSize:
                                WidgetStatePropertyAll(Size.fromHeight(48)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgImage('icons/apple', width: 16, height: 16),
                              Gap(10),
                              Text('애플로 시작하기', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          onPressed: () async {
                            try {
                              final credential =
                                  await SignInWithApple.getAppleIDCredential(
                                scopes: [
                                  AppleIDAuthorizationScopes.email,
                                  AppleIDAuthorizationScopes.fullName,
                                ],
                              );

                              await context.loader.run(() async {
                                final req =
                                    GLoginScreen_AuthorizeSingleSignOnToken_MutationReq(
                                  (b) => b
                                    ..vars.input.provider =
                                        GUserSingleSignOnProvider.APPLE
                                    ..vars.input.token =
                                        credential.authorizationCode,
                                );

                                final resp = await client.req(req);
                                await ref
                                    .read(authProvider.notifier)
                                    .setAccessToken(
                                      resp.authorizeSingleSignOnToken.token,
                                    );
                              });
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                      ],
                      const Gap(11),
                      Button(
                        style: const ButtonStyle(
                          foregroundColor:
                              WidgetStatePropertyAll(BrandColors.gray_900),
                          backgroundColor:
                              WidgetStatePropertyAll(BrandColors.gray_0),
                          minimumSize:
                              WidgetStatePropertyAll(Size.fromHeight(48)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgIcon('mail', size: 20),
                            Gap(10),
                            Text(
                              '이메일로 시작하기',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        onPressed: () {
                          context.router.push(const LoginWithEmailRoute());
                        },
                      ),
                      const Gap(32),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
