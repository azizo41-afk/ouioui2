// Supabase Edge Function. Set RESEND_API_KEY and APP_FROM_EMAIL as function secrets.
// Invoke only from a trusted server-side response handler; never expose the Resend key.
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
serve(async (req) => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const { to, invitation, response } = await req.json();
  if (!to || !invitation || !response) return Response.json({ error: 'Missing fields' }, { status: 400 });
  const key = Deno.env.get('RESEND_API_KEY');
  const from = Deno.env.get('APP_FROM_EMAIL');
  if (!key || !from) return Response.json({ error: 'Email service is not configured' }, { status: 503 });
  const accepted = response.status === 'accepted';
  const detail = accepted ? `Invitation acceptée par ${invitation.recipient_name}.` : `${invitation.recipient_name} a décliné ton invitation.`;
  const r = await fetch('https://api.resend.com/emails', {
    method: 'POST', headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ from, to, subject: `Nouvelle réponse : ${invitation.title}`, html: `<div style="font-family:Arial,sans-serif;color:#382f3d"><h2>${detail}</h2><p>${invitation.title}</p><p>${response.message || ''}</p></div>` })
  });
  if (!r.ok) return Response.json({ error: 'Email provider rejected the request' }, { status: 502 });
  return Response.json({ sent: true });
});
