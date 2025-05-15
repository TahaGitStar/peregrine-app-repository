import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/models/support_request.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/utils/date_formatter.dart';

class SupportRequestDetailsScreen extends StatefulWidget {
  static const String routeName = '/support-request-details';
  
  final SupportRequest request;
  
  const SupportRequestDetailsScreen({
    super.key,
    required this.request,
  });

  @override
  State<SupportRequestDetailsScreen> createState() => _SupportRequestDetailsScreenState();
}

class _SupportRequestDetailsScreenState extends State<SupportRequestDetailsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _replyController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Message> _messages;
  late RequestStatus _currentStatus;
  
  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.request.messages);
    _currentStatus = widget.request.status;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _replyController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _sendReply() {
    if (_replyController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(
        Message(
          id: 'MSG-${_messages.length + 1}',
          content: _replyController.text.trim(),
          timestamp: DateTime.now(),
          isFromClient: false,
        ),
      );
      _replyController.clear();
    });
  }
  
  void _markAsResolved() {
    setState(() {
      _currentStatus = RequestStatus.resolved;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تحديث حالة الطلب إلى "تم الحل"',
          style: GoogleFonts.cairo(),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'تفاصيل الطلب',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: AppTheme.primary.withOpacity(0.4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_currentStatus != RequestStatus.resolved)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(LucideIcons.checkCircle, color: Colors.white),
                onPressed: _markAsResolved,
                tooltip: 'تحديد كمحلول',
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Request Info Card
            _buildRequestInfoCard(),
            
            // Messages List
            Expanded(
              child: _buildMessagesList(),
            ),
            
            // Reply Section
            _buildReplySection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRequestInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.request.title,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _currentStatus.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _currentStatus.color,
                    width: 1,
                  ),
                ),
                child: Text(
                  _currentStatus.arabicLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _currentStatus.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                LucideIcons.user,
                size: 16,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'العميل: ${widget.request.clientName}',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                LucideIcons.tag,
                size: 16,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'رقم الطلب: ${widget.request.id}',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppTheme.accent,
                ),
              ),
              const Spacer(),
              Text(
                'منذ ${DateFormatter.getTimeAgo(widget.request.createdAt)}',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _messages.length,
      reverse: false,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }
  
  Widget _buildMessageBubble(Message message) {
    final isFromClient = message.isFromClient;
    
    return Align(
      alignment: isFromClient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isFromClient ? AppTheme.accent.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isFromClient ? const Radius.circular(20) : const Radius.circular(0),
            bottomRight: isFromClient ? const Radius.circular(0) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: isFromClient 
                  ? AppTheme.accent.withOpacity(0.1) 
                  : AppTheme.primary.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: isFromClient ? AppTheme.accent : AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatDateTime(message.timestamp),
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReplySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'اكتب ردك هنا...',
                hintStyle: GoogleFonts.cairo(color: Colors.grey),
                filled: true,
                fillColor: AppTheme.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              style: GoogleFonts.cairo(),
              maxLines: 3,
              minLines: 1,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(30),
            elevation: 4,
            shadowColor: AppTheme.primary.withOpacity(0.3),
            child: InkWell(
              onTap: _sendReply,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.all(14),
                child: const Icon(
                  LucideIcons.send,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}