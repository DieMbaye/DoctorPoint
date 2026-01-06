import 'package:flutter/material.dart';
import '../auth/auth_choice_screen.dart';
import '../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int index = 0;

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/images/onboard1.png',
      'title': 'Des milliers de médecins',
      'desc':
          'Accédez instantanément à des milliers de médecins et contactez-les facilement.'
    },
    {
      'image': 'assets/images/onboard2.png',
      'title': 'Discussion en direct',
      'desc':
          'Discutez avec votre médecin par message ou appel pour un meilleur suivi.'
    },
    {
      'image': 'assets/images/onboard3.png',
      'title': 'Prendre rendez-vous',
      'desc':
          'Prenez rendez-vous et échangez avec votre médecin en toute simplicité.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => index = i),
              itemBuilder: (_, i) {
                return Column(
                  children: [
                    const SizedBox(height: 60),

                    Image.asset(
                      pages[i]['image']!,
                      height: 280,
                      fit: BoxFit.cover,
                    ),

                    const SizedBox(height: 30),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            pages[i]['title']!,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            pages[i]['desc']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 20),

                          // DOTS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              pages.length,
                              (d) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: index == d ? 14 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: index == d
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // BOUTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (index == pages.length - 1) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AuthChoiceScreen(),
                                    ),
                                  );
                                } else {
                                  _controller.nextPage(
                                    duration:
                                        const Duration(milliseconds: 400),
                                    curve: Curves.ease,
                                  );
                                }
                              },
                              child: Text(
                                index == pages.length - 1
                                    ? 'Commencer'
                                    : 'Suivant',
                              ),
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AuthChoiceScreen(),
                                ),
                              );
                            },
                            child: const Text('Passer'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
