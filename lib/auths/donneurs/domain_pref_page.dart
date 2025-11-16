import 'package:demarcheur_app/apps/donneurs/main_screens/dashboard_page.dart';
import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/providers/domain_pref_provider.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

// Import DomainModel
// DomainModel is exported from domain_pref_provider.dart

class DomainPrefPage extends StatefulWidget {
  const DomainPrefPage({super.key});

  @override
  State<DomainPrefPage> createState() => _DomainPrefPageState();
}

class _DomainPrefPageState extends State<DomainPrefPage>
    with SingleTickerProviderStateMixin {
  ConstColors color = ConstColors();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DomainPrefProvider>().initialize().then((_) {
        _animationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildDomainChip({
    required DomainModel domain,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12, right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? color.primary : color.bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? color.primary
                    : color.secondary.withOpacity(0.3),
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 16, color: color.primary),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.bgSubmit,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.secondary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Flexible(
                  child: SubTitle(
                    text: domain.name,
                    fontsize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color.bg : color.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection({
    required String categoryName,
    required List<DomainModel> domains,
    required DomainPrefProvider provider,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: TitleWidget(
              text: categoryName,
              fontSize: 20,
              color: color.secondary,
            ),
          ),
          Wrap(
            children: domains.map((domain) {
              return _buildDomainChip(
                domain: domain,
                isSelected: provider.isSelected(domain.id),
                onTap: () => provider.toggleDomain(domain.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<DomainPrefProvider>(
      builder: (context, provider, child) {
        final hasSelection = provider.hasSelection;
        return Container(
          margin: const EdgeInsets.only(top: 16, bottom: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: hasSelection
                ? LinearGradient(
                    colors: [color.primary, color.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: hasSelection ? null : color.secondary.withOpacity(0.3),
            boxShadow: hasSelection
                ? [
                    BoxShadow(
                      color: color.primary.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: hasSelection
                  ? () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              const DashboardPage(),
                        ),
                      );
                    }
                  : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 56,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TitleWidget(
                      text: hasSelection
                          ? "Continuer"
                          : "Sélectionnez un domaine",
                      fontSize: 18,
                      color: hasSelection
                          ? color.bg
                          : color.secondary.withOpacity(0.6),
                    ),
                    if (hasSelection) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: color.bg,
                        size: 24,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedCountBadge() {
    return Consumer<DomainPrefProvider>(
      builder: (context, provider, child) {
        if (!provider.hasSelection) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.tertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${provider.selectedDomains.length}',
                    style: TextStyle(
                      color: color.bg,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SubTitle(
                text: provider.selectedDomains.length == 1
                    ? 'domaine sélectionné'
                    : 'domaines sélectionnés',
                fontsize: 14,
                fontWeight: FontWeight.w500,
                color: color.secondary,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DomainPrefProvider>(
      builder: (context, provider, child) {
        if (provider.isInitialLoading) {
          return Scaffold(
            backgroundColor: color.bg,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitThreeBounce(color: color.primary, size: 30.0),
                  const SizedBox(height: 24),
                  SubTitle(
                    text: "Chargement...",
                    fontsize: 16,
                    color: color.secondary,
                  ),
                ],
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: color.bg,
            extendBodyBehindAppBar: true,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const Header(isLeading: true),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color.bg,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            // Header Title
                            TitleWidget(
                              text: "Quel poste vous intéresse?",
                              fontSize: 32,
                              color: color.secondary,
                            ),
                            const SizedBox(height: 12),
                            // Subtitle
                            SubTitle(
                              text:
                                  "Sélectionnez un ou plusieurs domaines qui vous intéressent. Nous vous proposerons des offres adaptées à votre profil.",
                              fontsize: 15,
                              fontWeight: FontWeight.w400,
                              color: color.secondary.withOpacity(0.7),
                            ),
                            const SizedBox(height: 24),
                            // Selected count badge
                            _buildSelectedCountBadge(),
                            // Categories and domains
                            ...provider.categories.map((category) {
                              return _buildCategorySection(
                                categoryName: category['name'] as String,
                                domains:
                                    category['domains'] as List<DomainModel>,
                                provider: provider,
                              );
                            }).toList(),
                            // Submit button
                            _buildSubmitButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
