import 'package:demarcheur_app/consts/color.dart';
import 'package:demarcheur_app/models/user_model.dart';
import 'package:demarcheur_app/widgets/btn.dart';
import 'package:demarcheur_app/widgets/sub_title.dart';
import 'package:demarcheur_app/widgets/title_widget.dart';
import 'package:demarcheur_app/models/send_message_model.dart';
import 'package:demarcheur_app/services/auth_provider.dart';
import 'package:demarcheur_app/widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
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
  final double _zoomLevel = 1.0;
  final int _currentPage = 1;
  final int _totalPages = 0;

  late PdfViewerController _pdfViewerController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  ConstColors colors = ConstColors();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Initial check for document validity
    if (widget.userCv.document == null || widget.userCv.document!.isEmpty) {
      _isLoading = false;
    }

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
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
        backgroundColor: isError ? colors.error : colors.secondary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  // --- Logic for Actions ---

  void _handleDownload() {
    if (widget.userCv.document != null &&
        widget.userCv.document!.isNotEmpty &&
        widget.userCv.document!.startsWith('http')) {
      Share.share(
        'CV de ${widget.userCv.name}: ${widget.userCv.document}',
        subject: 'Document CV',
      );
    } else {
      _showMessage("Aucun lien de document à partager", isError: true);
    }
  }

  void _handleContact() {
    final authProvider = context.read<AuthProvider>();
    final myId = authProvider.userId;

    if (myId != null) {
      final receiverId = widget.userCv.id;
      if (receiverId != null && receiverId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatWidget(
              pageType: 'CV',
              message: SendMessageModel(
                senderId: myId,
                receiverId: receiverId,
                userName: widget.userCv.name,
                userPhoto: widget.userCv.photo,
                content: '',
                timestamp: DateTime.now(),
              ),
            ),
          ),
        );
        return;
      }
    }

    // Fallback to clipboard if not logged in or no receiverId
    String contactInfo = "";
    if (widget.userCv.phone != null) {
      contactInfo += "Tel: ${widget.userCv.phone}\n";
    }
    if (widget.userCv.email != null) {
      contactInfo += "Email: ${widget.userCv.email}";
    }

    if (contactInfo.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: contactInfo));
      _showMessage("Coordonnées copiées dans le presse-papier !");
    } else {
      _showMessage("Aucune coordonnée disponible", isError: true);
    }
  }

  // --- UI Components ---

  Widget _buildUserInfoCard() {
    final user = widget.userCv;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withOpacity(0.1),
                    width: 3,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(user.photo),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colors.secondary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBadge(
                          HugeIcons.strokeRoundedLocation01,
                          user.location,
                        ),
                        if (user.phone != null)
                          _buildBadge(
                            HugeIcons.strokeRoundedCall02,
                            user.phone!,
                          ),
                        if (user.email != null)
                          _buildBadge(
                            HugeIcons.strokeRoundedMail01,
                            user.email!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(dynamic icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.bgSubmit.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: icon,
            size: 14,
            color: colors.secondary.withOpacity(0.6),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.secondary.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfView() {
    String? docUrl = widget.userCv.document;
    bool hasDoc = docUrl != null && docUrl.isNotEmpty;

    // Fallback PDF for testing if none provided
    if (!hasDoc) {
      // Using a standard sample PDF so the user can "try" the viewer
      docUrl =
          "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";
      hasDoc = true;
    }

    // Logic for relative paths
    String finalUrl = docUrl;
    if (!finalUrl.startsWith('http')) {
      // Assuming it's a relative path from the server root
      finalUrl = "https://demarcheur-backend.onrender.com$finalUrl";
    }

    final isNetwork = finalUrl.startsWith('http');

    return Container(
      height: _isFullscreen ? MediaQuery.of(context).size.height : 500,
      width: double.infinity,
      margin: _isFullscreen
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _isFullscreen
            ? BorderRadius.zero
            : BorderRadius.circular(24),
        boxShadow: _isFullscreen
            ? null
            : [
                BoxShadow(
                  color: colors.secondary.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: _isFullscreen
            ? BorderRadius.zero
            : BorderRadius.circular(24),
        child: Stack(
          children: [
            isNetwork
                ? SfPdfViewer.network(
                    finalUrl,
                    controller: _pdfViewerController,
                    onDocumentLoaded: (_) {
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    onDocumentLoadFailed: (details) {
                      print("PDF LOAD FAILED: ${details.description}");
                      setState(() {
                        _isLoading = false;
                        _hasError = true;
                      });
                      _showMessage("Erreur chargement PDF", isError: true);
                    },
                  )
                : SfPdfViewer.asset(
                    "assets/mypdf.pdf",
                    controller: _pdfViewerController,
                  ),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: SpinKitFadingCircle(color: colors.primary, size: 50.0),
                ),
              ),
            if (_hasError)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        size: 64,
                        color: colors.error.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Impossible d'afficher le document",
                        style: TextStyle(color: colors.secondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "URL: $finalUrl",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isFullscreen)
              Positioned(
                top: 40,
                right: 20,
                child: FloatingActionButton.small(
                  backgroundColor: Colors.white,
                  onPressed: _toggleFullscreen,
                  child: Icon(Icons.close, color: colors.secondary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedFile02,
              size: 48,
              color: colors.secondary.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              msg,
              style: TextStyle(
                color: colors.secondary.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isFullscreen) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.bg,
                foregroundColor: colors.secondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: colors.secondary.withOpacity(0.1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedShare08,
                size: 20,
                color: Colors.black,
              ),
              label: const Text("Partager / DL"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: colors.primary.withOpacity(0.4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedCall02,
                size: 20,
                color: Colors.white,
              ),
              label: const Text(
                "Contacter",
                style: TextStyle(fontWeight: FontWeight.bold),
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
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
      body: _isFullscreen
          ? _buildPdfView()
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar.large(
                  expandedHeight: 180,
                  pinned: true,
                  leading: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      "Détails Candidat",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    centerTitle: true,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          "https://www.shutterstock.com/image-photo/job-search-human-resources-recruitment-260nw-1292578582.jpg",
                          fit: BoxFit.cover,
                        ),
                        Container(color: colors.primary.withOpacity(0.85)),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: _toggleFullscreen,
                      icon: const Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildUserInfoCard(),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildPdfView(),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildActionButtons(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
