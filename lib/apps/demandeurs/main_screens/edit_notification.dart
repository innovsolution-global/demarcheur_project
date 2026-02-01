import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/widgets/header_page.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class EditNotification extends StatefulWidget {
  const EditNotification({super.key});

  @override
  State<EditNotification> createState() => _EditNotificationState();
}

class _EditNotificationState extends State<EditNotification>
    with TickerProviderStateMixin {
  ConstColors colors = ConstColors();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Notification settings
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  // Job-related notifications
  bool _newApplications = true;
  bool _applicationUpdates = true;
  bool _interviewReminders = true;
  bool _jobMatches = true;

  // Marketing notifications
  bool _promotionalEmails = false;
  bool _weeklyDigest = true;
  bool _platformUpdates = true;

  // Sound and vibration
  String _selectedSound = 'Default';
  bool _vibration = true;
  bool _doNotDisturb = false;

  // Quiet hours
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);

  final List<String> _soundOptions = [
    'Default',
    'Chime',
    'Bell',
    'Ding',
    'None',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
              color: colors.bg,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.bg,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colors.accepted,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _quietHoursStart : _quietHoursEnd,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primary,
              secondary: colors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
      _showMessage(
        isStartTime ? 'Heure de début mise à jour' : 'Heure de fin mise à jour',
      );
    }
  }

  Widget _buildSectionHeader(String title, List<List<dynamic>> icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: HugeIcon(icon: icon, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          TitleWidget(text: title, fontSize: 18, color: colors.secondary),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    List<List<dynamic>>? icon,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.tertiary.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: icon != null
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? colors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HugeIcon(
                  icon: icon,
                  color: iconColor ?? colors.primary,
                  size: 20,
                ),
              )
            : null,
        title: TitleWidget(text: title, fontSize: 16, color: colors.secondary),
        subtitle: SubTitle(
          text: subtitle,
          fontsize: 13,
          color: colors.secondary.withOpacity(0.7),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: colors.primary,
          activeTrackColor: colors.primary.withOpacity(0.3),
          inactiveThumbColor: colors.secondary.withOpacity(0.5),
          inactiveTrackColor: colors.tertiary,
        ),
      ),
    );
  }

  Widget _buildSoundSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.tertiary.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedVolumeHigh,
            color: colors.primary,
            size: 20,
          ),
        ),
        title: TitleWidget(
          text: 'Son de notification',
          fontSize: 16,
          color: colors.secondary,
        ),
        subtitle: SubTitle(
          text: _selectedSound,
          fontsize: 13,
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
        trailing: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowRight02,
          color: colors.secondary.withOpacity(0.5),
          size: 16,
        ),
        onTap: () {
          _showSoundSelection();
        },
      ),
    );
  }

  void _showSoundSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.tertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              TitleWidget(text: 'Sélectionner le son', fontSize: 18),
              const SizedBox(height: 20),
              ..._soundOptions.map((sound) {
                final isSelected = _selectedSound == sound;
                return ListTile(
                  title: Text(sound),
                  trailing: isSelected
                      ? HugeIcon(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                          color: colors.primary,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedSound = sound;
                    });
                    Navigator.pop(context);
                    _showMessage('Son de notification mis à jour');
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuietHoursTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.tertiary.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.cour.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedMoon02,
                color: colors.cour,
                size: 20,
              ),
            ),
            title: TitleWidget(
              text: 'Mode silencieux',
              fontSize: 16,
              color: colors.secondary,
            ),
            subtitle: SubTitle(
              text: _doNotDisturb
                  ? 'Activé de ${_quietHoursStart.format(context)} à ${_quietHoursEnd.format(context)}'
                  : 'Désactivé',
              fontsize: 13,
              color: _doNotDisturb
                  ? colors.cour
                  : colors.secondary.withOpacity(0.7),
              fontWeight: _doNotDisturb ? FontWeight.w600 : FontWeight.normal,
            ),
            trailing: Switch(
              value: _doNotDisturb,
              onChanged: (value) {
                setState(() {
                  _doNotDisturb = value;
                });
                _showMessage(
                  value
                      ? 'Mode silencieux activé'
                      : 'Mode silencieux désactivé',
                );
              },
              activeThumbColor: colors.cour,
              activeTrackColor: colors.cour.withOpacity(0.3),
            ),
          ),
          if (_doNotDisturb) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.bgSubmit,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.tertiary),
                        ),
                        child: Column(
                          children: [
                            SubTitle(
                              text: 'Début',
                              fontsize: 12,
                              color: colors.secondary.withOpacity(0.7),
                            ),
                            const SizedBox(height: 4),
                            TitleWidget(
                              text: _quietHoursStart.format(context),
                              fontSize: 16,
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.bgSubmit,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.tertiary),
                        ),
                        child: Column(
                          children: [
                            SubTitle(
                              text: 'Fin',
                              fontsize: 12,
                              color: colors.secondary.withOpacity(0.7),
                            ),
                            const SizedBox(height: 4),
                            TitleWidget(
                              text: _quietHoursEnd.format(context),
                              fontSize: 16,
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _showMessage('Notification de test envoyée !');
        },
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedHotelBell,
          color: colors.bg,
          size: 18,
        ),
        label: Text(
          'Tester les notifications',
          style: TextStyle(
            color: colors.bg,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bgSubmit,
      body: CustomScrollView(
        slivers: [
          Header(auto: true),

          // Header Section
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleWidget(
                      text: 'Paramètres de notification',
                      fontSize: 24,
                      color: colors.secondary,
                    ),
                    const SizedBox(height: 4),
                    SubTitle(
                      text: 'Personnalisez vos préférences de notification',
                      fontsize: 16,
                      color: colors.secondary.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main notification methods
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildSectionHeader(
                      'Méthodes de notification',
                      HugeIcons.strokeRoundedNotification03,
                    ),
                    _buildNotificationTile(
                      title: 'Notifications push',
                      subtitle: 'Recevez des notifications sur votre appareil',
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                        _showMessage(
                          value
                              ? 'Notifications push activées'
                              : 'Notifications push désactivées',
                        );
                      },
                      icon: HugeIcons.strokeRoundedSmartPhone01,
                      iconColor: colors.primary,
                    ),
                    _buildNotificationTile(
                      title: 'Notifications email',
                      subtitle: 'Recevez des emails de notification',
                      value: _emailNotifications,
                      onChanged: (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                        _showMessage(
                          value
                              ? 'Notifications email activées'
                              : 'Notifications email désactivées',
                        );
                      },
                      icon: HugeIcons.strokeRoundedMail01,
                      iconColor: colors.cour,
                    ),
                    _buildNotificationTile(
                      title: 'Notifications SMS',
                      subtitle:
                          'Recevez des SMS pour les événements importants',
                      value: _smsNotifications,
                      onChanged: (value) {
                        setState(() {
                          _smsNotifications = value;
                        });
                        _showMessage(
                          value
                              ? 'Notifications SMS activées'
                              : 'Notifications SMS désactivées',
                        );
                      },
                      icon: HugeIcons.strokeRoundedMessage01,
                      iconColor: colors.accepted,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Job-related notifications
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildSectionHeader(
                      'Candidatures et emplois',
                      HugeIcons.strokeRoundedBriefcase01,
                    ),
                    _buildNotificationTile(
                      title: 'Nouvelles candidatures',
                      subtitle:
                          'Soyez alerté des nouvelles candidatures reçues',
                      value: _newApplications,
                      onChanged: (value) {
                        setState(() {
                          _newApplications = value;
                        });
                      },
                      icon: HugeIcons.strokeRoundedUserAdd01,
                    ),
                    _buildNotificationTile(
                      title: 'Mises à jour candidatures',
                      subtitle: 'Changements de statut des candidatures',
                      value: _applicationUpdates,
                      onChanged: (value) {
                        setState(() {
                          _applicationUpdates = value;
                        });
                      },
                      icon: HugeIcons.strokeRoundedRefresh,
                    ),
                    _buildNotificationTile(
                      title: 'Rappels d\'entretiens',
                      subtitle: 'Rappels avant vos entretiens programmés',
                      value: _interviewReminders,
                      onChanged: (value) {
                        setState(() {
                          _interviewReminders = value;
                        });
                      },
                      icon: HugeIcons.strokeRoundedCalendar03,
                    ),
                    _buildNotificationTile(
                      title: 'Correspondances d\'emplois',
                      subtitle: 'Nouveaux emplois correspondant à votre profil',
                      value: _jobMatches,
                      onChanged: (value) {
                        setState(() {
                          _jobMatches = value;
                        });
                      },
                      icon: HugeIcons.strokeRoundedTarget03,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Marketing notifications
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildSectionHeader(
                      'Marketing et mises à jour',
                      HugeIcons.strokeRoundedMegaphone01,
                    ),
                    _buildNotificationTile(
                      title: 'Emails promotionnels',
                      subtitle: 'Offres spéciales et promotions',
                      value: _promotionalEmails,
                      onChanged: (value) {
                        setState(() {
                          _promotionalEmails = value;
                        });
                      },
                      icon: HugeIcons.strokeRoundedTag01,
                    ),
                    _buildNotificationTile(
                      title: 'Résumé hebdomadaire',
                      subtitle: 'Résumé de vos activités de la semaine',
                      value: _weeklyDigest,
                      onChanged: (value) {
                        setState(() {
                          _weeklyDigest = value;
                        });
                      },
                      icon: HugeIcons.strokeRoundedCalendarAdd01,
                    ),
                    _buildNotificationTile(
                      title: 'Mises à jour de la plateforme',
                      subtitle: 'Nouvelles fonctionnalités et améliorations',
                      value: _platformUpdates,
                      onChanged: (value) {
                        setState(() {
                          _platformUpdates = value;
                        });
                      },
                      icon: HugeIcons.strokeRoundedInformationCircle,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sound and behavior settings
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildSectionHeader(
                      'Son et comportement',
                      HugeIcons.strokeRoundedSettings02,
                    ),
                    _buildSoundSelector(),
                    _buildNotificationTile(
                      title: 'Vibration',
                      subtitle: 'Vibrer lors de la réception de notifications',
                      value: _vibration,
                      onChanged: (value) {
                        setState(() {
                          _vibration = value;
                        });
                      },
                      icon: HugeIcons.strokeRoundedViber,
                    ),
                    _buildQuietHoursTile(),
                  ],
                ),
              ),
            ),
          ),

          // Test button
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildTestNotificationButton(),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
