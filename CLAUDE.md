# Mijn Agenda

Persoonlijke agenda-app (afspraken, to-do's, dagdoelen, meldingen) in het Nederlands.
Gehost via GitHub Pages: `index.html` stuurt door naar `Agenda.html`.

## Bestanden
- `Agenda.html` — de hele app in één bestand (HTML + CSS + JavaScript, geen build-stap, geen frameworks).
  Secties zijn gemarkeerd met `/* ... */`-commentaar (Data, Cloud sync, Quick add, Voice input, Notifications, ...).
- `sw.js` — service worker (offline gebruik); `manifest.json` + `icon-*.png` — installeerbare app (PWA).
- `supabase-setup.sql` — tabel `agenda_data`: één rij per gebruiker met de hele agenda als JSON.
- `supabase-reminders.sql` — tabellen `push_subs` en `reminders`, plus pg_cron-taak die elke minuut de Edge Function aanroept.
- `supabase/functions/send-reminders/index.ts` — Edge Function die meldingen en alarmen (web push) verstuurt.
- `meldingen-installatie.md` — staat alleen lokaal en bevat geheime sleutels. Nooit committen (staat in `.git/info/exclude`).

## Werking in het kort
- Data wordt lokaal (localStorage) bewaard en, na inloggen, gesynchroniseerd met Supabase.
- De invoerbalk ("quick add") en spraakinvoer begrijpen Nederlandse zinnen, bv.
  `voeg 'voetbaltraining' toe op 23 november van 19u30-21u`, ook herhalingen (elke maandag, elke werkdag),
  aanpassen, verwijderen (ook voor weekdagen of een periode van een reeks), meldingen en alarmen.
- Afspraken met "werk" in de titel worden zwart weergegeven.
- Ongedaan maken: tot 50 stappen (Ctrl+Z).

## Afspraken voor wijzigingen
- Alle teksten in de app zijn in het Nederlands; code, variabelen en commentaar in het Engels.
- Verhoog bij elke release `APP_VERSION` in `Agenda.html`: open pagina's zien dan de nieuwe versie en herladen zichzelf.
  Pas bij gewijzigde shell-bestanden ook `CACHE` in `sw.js` aan.
- Werk per wijziging op een eigen branch en merge daarna naar `main` (de live versie).
- Geen geheime sleutels (VAPID private key, CRON_SECRET, service role key) in de repository zetten.
  De publieke Supabase URL en anon key in `Agenda.html` mogen wel.
- Antwoord de gebruiker in het Nederlands.
