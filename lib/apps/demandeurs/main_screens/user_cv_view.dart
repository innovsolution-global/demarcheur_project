import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/user_model.dart';
import 'package:demarcheur_app/widgets/btn.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class UserCvView extends StatefulWidget {
  final UserModel userCv;
  const UserCvView({super.key, required this.userCv});

  @override
  State<UserCvView> createState() => _UserCvViewState();
}

class _UserCvViewState extends State<UserCvView> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFullscreen = false;
  double _zoomLevel = 1.0;
  int _currentPage = 1;
  int _totalPages = 0;

  late PdfViewerController _pdfViewerController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  ConstColors colors = ConstColors();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();

    // Animation controllers
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
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
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
        backgroundColor: isError ? colors.error : colors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _zoomIn() {
    if (_zoomLevel < 3.0) {
      setState(() {
        _zoomLevel += 0.25;
      });
      _pdfViewerController.zoomLevel = _zoomLevel;
    }
  }

  void _zoomOut() {
    if (_zoomLevel > 0.5) {
      setState(() {
        _zoomLevel -= 0.25;
      });
      _pdfViewerController.zoomLevel = _zoomLevel;
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _pdfViewerController.previousPage();
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _pdfViewerController.nextPage();
    }
  }

  Widget _buildUserInfoCard() {
    final user = widget.userCv;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.secondary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.tertiary, width: 2),
              image: DecorationImage(
                image: NetworkImage(user.photo),
                fit: BoxFit.cover,
                onError: (error, stackTrace) {},
              ),
            ),
            child: user.photo.isEmpty
                ? Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      color: colors.primary,
                      size: 24,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleWidget(
                  text: user.gender == "Masculin"
                      ? "Mr ${user.name}"
                      : "Mme ${user.name}",
                  fontSize: 18,
                ),
                const SizedBox(height: 4),
                SubTitle(
                  text: user.speciality,
                  fontsize: 14,
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedLocation01,
                      color: colors.secondary.withOpacity(0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    SubTitle(
                      text: user.location,
                      fontsize: 12,
                      color: colors.secondary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 16),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedBriefcase01,
                      color: colors.secondary.withOpacity(0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    SubTitle(
                      text: "${user.exp} d'expérience",
                      fontsize: 12,
                      color: colors.secondary.withOpacity(0.7),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: user.status == "Disponible"
                  ? colors.accepted.withOpacity(0.1)
                  : colors.impression.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.status,
              style: TextStyle(
                color: user.status == "Disponible"
                    ? colors.accepted
                    : colors.cour,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfControls() {
    if (_isFullscreen) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.bgSubmit,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.tertiary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page Navigation
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1 ? _previousPage : null,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft02,
                  color: _currentPage > 1
                      ? colors.primary
                      : colors.secondary.withOpacity(0.5),
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$_currentPage / $_totalPages",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentPage < _totalPages ? _nextPage : null,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight02,
                  color: _currentPage < _totalPages
                      ? colors.primary
                      : colors.secondary.withOpacity(0.5),
                  size: 20,
                ),
              ),
            ],
          ),

          // Zoom Controls
          Row(
            children: [
              IconButton(
                onPressed: _zoomLevel > 0.5 ? _zoomOut : null,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedZoomOutArea,
                  color: _zoomLevel > 0.5
                      ? colors.primary
                      : colors.secondary.withOpacity(0.5),
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${(_zoomLevel * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _zoomLevel < 3.0 ? _zoomIn : null,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedZoom,
                  color: _zoomLevel < 3.0
                      ? colors.primary
                      : colors.secondary.withOpacity(0.5),
                  size: 20,
                ),
              ),
            ],
          ),

          // Fullscreen Toggle
          IconButton(
            onPressed: _toggleFullscreen,
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedFullScreen,
              color: colors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (widget.userCv.document == null || widget.userCv.document!.isEmpty) {
      return Container(
        height: 400,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.bgSubmit,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.tertiary),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedFile02,
              color: colors.secondary.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            TitleWidget(
              text: "Aucun CV disponible",
              fontSize: 18,
              color: colors.secondary,
            ),
            const SizedBox(height: 8),
            SubTitle(
              text: "Ce candidat n'a pas encore téléchargé son CV",
              fontsize: 14,
              color: colors.secondary.withOpacity(0.7),
            ),
          ],
        ),
      );
    }

    return Container(
      height: _isFullscreen ? MediaQuery.of(context).size.height : 600,
      margin: _isFullscreen ? EdgeInsets.zero : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: _isFullscreen
            ? BorderRadius.zero
            : BorderRadius.circular(16),
        boxShadow: _isFullscreen
            ? null
            : [
                BoxShadow(
                  color: colors.secondary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: _isFullscreen
            ? BorderRadius.zero
            : BorderRadius.circular(16),
        child: Stack(
          children: [
            SfPdfViewer.asset(
              "assets/mypdf.pdf",
              controller: _pdfViewerController,
              onDocumentLoaded: (details) {
                setState(() {
                  _isLoading = false;
                  _totalPages = details.document.pages.count;
                });
              },
              onDocumentLoadFailed: (details) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                });
                _showMessage("Erreur lors du chargement du CV", isError: true);
              },
              onPageChanged: (details) {
                setState(() {
                  _currentPage = details.newPageNumber;
                });
              },
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: colors.bg.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitFadingCircle(color: colors.primary, size: 50.0),
                      const SizedBox(height: 16),
                      SubTitle(
                        text: "Chargement du CV...",
                        fontsize: 16,
                        color: colors.secondary,
                      ),
                    ],
                  ),
                ),
              ),

            // Error Overlay
            if (_hasError && !_isLoading)
              Container(
                color: colors.bg.withOpacity(0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedAlert01,
                        color: colors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      TitleWidget(
                        text: "Erreur de chargement",
                        fontSize: 18,
                        color: colors.error,
                      ),
                      const SizedBox(height: 8),
                      SubTitle(
                        text: "Impossible de charger le CV",
                        fontsize: 14,
                        color: colors.secondary,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _hasError = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.bg,
                        ),
                        child: Text("Réessayer"),
                      ),
                    ],
                  ),
                ),
              ),

            // Fullscreen Exit Button
            if (_isFullscreen)
              Positioned(
                top: 40,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.secondary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: _toggleFullscreen,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      color: colors.bg,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isFullscreen) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement download functionality
                _showMessage(
                  "Fonctionnalité de téléchargement bientôt disponible",
                );
              },
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDownload01,
                color: colors.primary,
                size: 18,
              ),
              label: Text(
                "Télécharger",
                style: TextStyle(color: colors.primary),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement contact functionality
                _showMessage("Fonctionnalité de contact bientôt disponible");
              },
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedMail01,
                color: colors.bg,
                size: 18,
              ),
              label: Text("Contacter", style: TextStyle(color: colors.bg)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.bg,
      body: _isFullscreen
          ? _buildPdfViewer()
          : CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowTurnBackward,
                      color: colors.bg,
                      size: 24,
                    ),
                  ),
                  backgroundColor: colors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    title: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "CV - ${widget.userCv.name}",
                        style: TextStyle(
                          color: colors.bg,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.primary,
                            colors.primary.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Center(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedFile02,
                            color: colors.bg.withOpacity(0.3),
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // User Info Card
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildUserInfoCard(),
                    ),
                  ),
                ),

                // PDF Controls
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildPdfControls(),
                  ),
                ),

                // PDF Viewer
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildPdfViewer(),
                  ),
                ),

                // Action Buttons
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildActionButtons(),
                  ),
                ),

                // Back Button
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: Btn(
                      texte: "Retour",
                      function: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
