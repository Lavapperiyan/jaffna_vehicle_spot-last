import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:developer' as developer;

class EmailService {
  // CONFIGURATION: User needs to fill these in
  static const String _senderEmail = 'nfplantationsk@gmail.com'; 
  static const String _appPassword = 'vnxuuctoletvnbaa'; // Gmail App Password

  static Future<bool> sendCredentialsEmail({
    required String recipientEmail,
    required String staffName,
    required String staffId,
    required String password,
  }) async {
    // Check if configured (optional safety)
    if (_senderEmail == 'YOUR_GMAIL@gmail.com' || _appPassword == 'YOUR_APP_PASSWORD') {
      developer.log('EmailService: SMTP Credentials not configured. Skipping email send.');
      return false;
    }

    final smtpServer = gmail(_senderEmail, _appPassword);

    final message = Message()
      ..from = Address(_senderEmail, 'Jaffna Vehicle Spot Admin')
      ..recipients.add(recipientEmail)
      ..subject = 'Your Staff Account Credentials - Jaffna Vehicle Spot'
      ..html = """
        <div style="font-family: sans-serif; padding: 20px; color: #333;">
          <h2 style="color: #2C3545;">Welcome to Jaffna Vehicle Spot!</h2>
          <p>Hello <strong>$staffName</strong>,</p>
          <p>Your staff account has been successfully created. You can now log in to the application using the following credentials:</p>
          <div style="background-color: #F8FAFC; padding: 15px; border-radius: 8px; border: 1px solid #E2E8F0;">
            <p style="margin: 5px 0;"><strong>Login Email:</strong> <span style="color: #2C3545; font-weight: bold;">$recipientEmail</span></p>
            <p style="margin: 5px 0;"><strong>Staff ID:</strong> $staffId</p>
            <p style="margin: 5px 0;"><strong>Initial Password:</strong> <span style="color: #E8BC44; font-weight: bold;">$password</span></p>
          </div>
          <p style="margin-top: 20px;"><strong>Important:</strong> Please use the <b>Login Email</b> above to sign in to the app.</p>
          <p style="margin-top: 10px;">Please change your password after your first login for security reasons.</p>
          <p>Best regards,<br>The Administration Team</p>
          <hr style="border: 0; border-top: 1px solid #EEE; margin: 20px 0;">
          <small style="color: #64748B;">This is an automated message. Please do not reply directly to this email.</small>
        </div>
      """;

    try {
      final sendReport = await send(message, smtpServer);
      developer.log('Message sent: $sendReport');
      return true;
    } on MailerException catch (e) {
      developer.log('Message not sent. \n$e');
      for (var p in e.problems) {
        developer.log('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    } catch (e) {
      developer.log('EmailService Error: $e');
      return false;
    }
  }
}
