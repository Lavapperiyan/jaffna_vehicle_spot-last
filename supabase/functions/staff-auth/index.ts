import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { SmtpClient } from "https://deno.land/x/smtp@v0.7.0/mod.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { email, staffId, type } = await req.json()

    // 1. Initialize Supabase Admin Client
    const supabase = createClient(
      Deno.env.get('SB_URL') ?? Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SB_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    )

    // 2. Generate secure link from Supabase Auth
    let actionLink = ''
    let subject = ''
    let emailHtml = ''
    const redirectUrl = Deno.env.get('REDIRECT_URL') ?? 'http://localhost:3000/reset-password'

    if (type === 'invite') {
      const { data, error } = await supabase.auth.admin.generateLink({
        type: 'invite',
        email,
        options: { redirectTo: redirectUrl, data: { staff_id: staffId } }
      })
      if (error) throw error
      actionLink = data.properties.action_link
      subject = `Join Jaffna Vehicle Spot! (Staff: ${staffId})`
      emailHtml = `
        <div style="font-family: sans-serif; padding: 20px; color: #333;">
          <h2 style="color: #2C3545;">Join Jaffna Vehicle Spot</h2>
          <p>Hello,</p>
          <p>You have been invited to join the <b>Jaffna Vehicle Spot</b> management system.</p>
          <div style="background: #f4f4f4; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <p><b>Your Staff ID:</b> ${staffId}</p>
            <p><b>Your Email:</b> ${email}</p>
          </div>
          <p>Please click the button below to set up your password and activate your account:</p>
          <a href="${actionLink}" style="display: inline-block; padding: 12px 24px; background: #E8BC44; color: #2C3545; text-decoration: none; border-radius: 6px; font-weight: bold;">Set Up Password</a>
          <p style="font-size: 12px; color: #666; margin-top: 30px;">If the button doesn't work, copy and paste this link: <br>${actionLink}</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
          <p style="font-size: 12px; color: #999;">Regards, <br><b>Jaffna Vehicle Spot Team</b></p>
        </div>
      `
    } else if (type === 'recovery') {
      const { data, error } = await supabase.auth.admin.generateLink({
        type: 'recovery',
        email,
        options: { redirectTo: redirectUrl }
      })
      if (error) throw error
      actionLink = data.properties.action_link
      subject = 'Password Reset Request'
      emailHtml = `
        <div style="font-family: sans-serif; padding: 20px; color: #333;">
          <h2 style="color: #2C3545;">Reset Your Password</h2>
          <p>Hello,</p>
          <p>We received a request to reset your password for <b>Jaffna Vehicle Spot</b>.</p>
          <p>Click the button below to choose a new password:</p>
          <a href="${actionLink}" style="display: inline-block; padding: 12px 24px; background: #2C3545; color: #E8BC44; text-decoration: none; border-radius: 6px; font-weight: bold;">Reset Password</a>
          <p style="font-size: 12px; color: #666; margin-top: 30px;">If you did not request this, you can safely ignore this email.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
          <p style="font-size: 12px; color: #999;">Regards, <br><b>Jaffna Vehicle Spot Team</b></p>
        </div>
      `
    } else {
      return new Response(JSON.stringify({ error: 'Invalid request type' }), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } })
    }

    // 3. Send Email via Gmail SMTP (using deno_smtp)
    const client = new SmtpClient()
    await client.connectTLS({
      hostname: Deno.env.get('SMTP_HOST') || 'smtp.gmail.com',
      port: Number(Deno.env.get('SMTP_PORT')) || 587,
      username: Deno.env.get('SMTP_USER') || '',
      password: Deno.env.get('SMTP_PASS') || '',
    })

    await client.send({
      from: Deno.env.get('MAIL_FROM') || 'Jaffna Vehicle Spot <...>',
      to: email,
      subject: subject,
      content: emailHtml,
      html: emailHtml,
    })

    await client.close()

    return new Response(
      JSON.stringify({ message: 'Email sent successfully' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  }
})
