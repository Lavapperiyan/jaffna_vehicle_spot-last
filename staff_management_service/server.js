const express = require('express');
const cors = require('cors');
const nodemailer = require('nodemailer');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// 1. Supabase Admin Client (using Service Role Key for Admin privileges)
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

// 2. Nodemailer Transporter (Gmail SMTP)
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: false, // true for 465, false for other ports (587)
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

// Verify SMTP Connection
transporter.verify((error, success) => {
  if (error) {
    console.error('SMTP Connection Error:', error);
  } else {
    console.log('SMTP Server is ready to send emails');
  }
});

// --- HELPER: Send Branded Email ---
async function sendBrandedEmail({ to, subject, html }) {
  const mailOptions = {
    from: process.env.MAIL_FROM,
    to,
    subject,
    html
  };
  return transporter.sendMail(mailOptions);
}

// --- API: Invite Staff (Admin) ---
app.post('/api/auth/invite-staff', async (req, res) => {
  const { email, staffId } = req.body;

  if (!email || !staffId) {
    return res.status(400).json({ error: 'Email and Staff ID are required' });
  }

  try {
    // 1. Generate a secure invitation/signup link from Supabase
    // Using 'signup' type here since we want the user to set their password
    const { data, error } = await supabase.auth.admin.generateLink({
      type: 'invite',
      email: email,
      options: { 
        redirectTo: process.env.REDIRECT_URL,
        data: { staff_id: staffId } // Optional: associate staffId with the auth metadata
      }
    });

    if (error) throw error;

    const signupLink = data.properties.action_link;

    // 2. Send the branded email
    const emailHtml = `
      <div style="font-family: sans-serif; padding: 20px; color: #333;">
        <h2 style="color: #2C3545;">Join Jaffna Vehicle Spot</h2>
        <p>Hello,</p>
        <p>You have been invited to join the <b>Jaffna Vehicle Spot</b> management system.</p>
        <div style="background: #f4f4f4; padding: 15px; border-radius: 8px; margin: 20px 0;">
          <p><b>Your Staff ID:</b> ${staffId}</p>
          <p><b>Your Email:</b> ${email}</p>
        </div>
        <p>Please click the button below to set up your password and activate your account:</p>
        <a href="${signupLink}" style="display: inline-block; padding: 12px 24px; background: #E8BC44; color: #2C3545; text-decoration: none; border-radius: 6px; font-weight: bold;">Set Up Password</a>
        <p style="font-size: 12px; color: #666; margin-top: 30px;">If the button doesn't work, copy and paste this link: <br>${signupLink}</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        <p style="font-size: 12px; color: #999;">Regards, <br><b>Jaffna Vehicle Spot Team</b></p>
      </div>
    `;

    await sendBrandedEmail({
      to: email,
      subject: `Welcome to Jaffna Vehicle Spot! (Staff: ${staffId})`,
      html: emailHtml
    });

    res.json({ message: 'Invitation email sent successfully' });
  } catch (error) {
    console.error('Invite Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// --- API: Forgot Password (User) ---
app.post('/api/auth/forgot-password', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ error: 'Email is required' });
  }

  try {
    // 1. Generate recovery link
    const { data, error } = await supabase.auth.admin.generateLink({
      type: 'recovery',
      email: email,
      options: { redirectTo: process.env.REDIRECT_URL }
    });

    if (error) throw error;

    const resetLink = data.properties.action_link;

    // 2. Send the branded reset email
    const emailHtml = `
      <div style="font-family: sans-serif; padding: 20px; color: #333;">
        <h2 style="color: #2C3545;">Reset Your Password</h2>
        <p>Hello,</p>
        <p>We received a request to reset your password for <b>Jaffna Vehicle Spot</b>.</p>
        <p>Click the button below to choose a new password:</p>
        <a href="${resetLink}" style="display: inline-block; padding: 12px 24px; background: #2C3545; color: #E8BC44; text-decoration: none; border-radius: 6px; font-weight: bold;">Reset Password</a>
        <p style="font-size: 12px; color: #666; margin-top: 30px;">If you did not request this, you can safely ignore this email.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
        <p style="font-size: 12px; color: #999;">Regards, <br><b>Jaffna Vehicle Spot Team</b></p>
      </div>
    `;

    await sendBrandedEmail({
      to: email,
      subject: 'Password Reset Request',
      html: emailHtml
    });

    res.json({ message: 'Password reset link sent to your email' });
  } catch (error) {
    console.error('Reset Error:', error);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3004;
app.listen(PORT, () => {
  console.log(`Staff Management Service running on port ${PORT}`);
});
