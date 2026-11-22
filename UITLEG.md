# Hoe je agenda-app tot stand kwam: de volledige uitleg

*Opgesteld op 22 november 2026. Alle tijden zijn Belgische/Nederlandse tijd.*

> **Hoe dit document gemaakt is.** Na `/clear` zie ik ons eerdere gesprek niet meer. Ik heb alles
> gereconstrueerd uit wat wel bewaard is: de volledige geschiedenis op GitHub (elke commit, branch en
> pull request, met tijdstip), de bestanden zelf en de installatie-instructies voor Supabase.
> Wat **zeker** is, staat gewoon vermeld. Wat ik **afleid**, bijvoorbeeld handelingen die jij zelf in
> Supabase of op GitHub deed, staat aangegeven met *(afgeleid)*.

---

## Deel 1 — Begrippen

Eerst de woorden die steeds terugkomen.

| Begrip | Wat het is |
|---|---|
| **Claude Code (cloud)** | De versie van Claude waarmee je nu praat. Ik draai in een tijdelijke computer in de cloud (een "container"). Daarin staat een kopie van je project en ik kan er bestanden aanmaken, aanpassen en naar GitHub sturen. De container wordt na een tijd opgeruimd, dus alles wat bewaard moet blijven, moet naar GitHub. |
| **GitHub** | Een website waar code bewaard wordt, met de volledige geschiedenis van elke wijziging. |
| **Repository (repo)** | Een projectmap op GitHub. Die van jou heet **`JornBage/claude-bestanden`** en is **openbaar** (iedereen kan de code bekijken). |
| **Commit** | Een opgeslagen momentopname van een wijziging, met een beschrijving en een tijdstip. |
| **Branch** | Een aparte "werklijn" naast de hoofdversie. Je kunt er wijzigingen op maken zonder de hoofdversie aan te raken. |
| **`main`** | De hoofdbranch. Dit is de versie die live staat. |
| **Pull request (PR)** | Een voorstel op GitHub om een branch samen te voegen met `main`. Je kunt het bekijken en dan op "Merge" klikken. |
| **Merge** | Een branch samenvoegen met een andere, meestal met `main`. |
| **Push** | Commits vanuit de cloudcomputer naar GitHub sturen. |
| **GitHub Pages** | Een gratis functie van GitHub die de bestanden uit je repo als website online zet. Zo is je agenda bereikbaar in de browser. |
| **Supabase** | Een online dienst met een database en een inlogsysteem. Je agenda bewaart er je gegevens, zodat ze op al je toestellen hetzelfde zijn, en het verstuurt er meldingen vanuit. |
| **localStorage** | Een opslagplaats in je browser, op je toestel zelf. De agenda bewaart daar altijd een eigen kopie, ook zonder internet. |
| **PWA** | "Progressive Web App": een website die je als app op je telefoon kunt installeren (met eigen icoon, en ze werkt ook offline). |
| **Service worker** | Een klein script (`sw.js`) dat op de achtergrond in je browser draait. Het zorgt dat de app offline werkt en dat meldingen binnenkomen. |
| **Web Push** | De techniek waarmee een server een melding naar je telefoon kan sturen, ook als de app dicht is. |
| **Edge Function** | Een stukje code dat op de servers van Supabase draait (hier: de functie die meldingen verstuurt). |

---

## Deel 2 — Het tijdsverloop, stap voor stap

### Vóór zaterdag 21 november, 10:26 — het begin

- Het eerste ontwerp van de agenda (`Agenda.html`, 539 regels) bestond al voordat de repo werd
  aangemaakt. *(afgeleid: vermoedelijk gemaakt in een gewone Claude-chat en daarna gedownload)*
  Het bevatte al een kalender met maand-, week- en dagweergave en een zijbalk met to-do's.

### Zaterdag 21 november — dag 1

**Op GitHub, door jou:**

| Tijd | Wat gebeurde er |
|---|---|
| 10:26 | Je maakt de repository **`claude-bestanden`** aan op GitHub. |
| 10:28 | Je uploadt `Agenda.html` en een `README.md` via de knop "Add files via upload". |
| 10:42 | Je past `README.md` aan. |

**Daarna begint het werk met Claude Code.** Werkwijze op dag 1: voor elke wijziging maakte ik een
eigen **branch**, en daarna een **pull request**, die jij op GitHub samenvoegde met `main`
("Merge pull request"). Dat gebeurde 20 keer.

| Tijd | Branch / PR | Wat er veranderde |
|---|---|---|
| 10:44 | `english-code-cleanup` | De code (commentaar, namen, kleuren) wordt naar het Engels vertaald, de teksten op het scherm blijven Nederlands. De README wordt verwijderd. Oude, Nederlandse opgeslagen gegevens worden automatisch omgezet. |
| 10:49 | PR #1 | Eerste pull request. Die werd **gesloten zonder samenvoegen**, omdat jij intussen de README had aangepast en dat botste ("conflict"). |
| 10:54 | PR #2 | Het conflict wordt opgelost (README blijft verwijderd) en jij voegt dit samen. |
| 11:09 | `supabase-sync` | **Inloggen en synchronisatie met Supabase** toegevoegd. Nieuw bestand: `supabase-setup.sql`. |
| 11:10 | `supabase-sync` | Het adres van jouw Supabase-project wordt ingevuld. |
| 11:24 | PR #3 | Samengevoegd. |
| 11:27–11:35 | PR #4 | Bij inloggen worden nu de echte foutmeldingen getoond. *(afgeleid: het inloggen lukte eerst niet en we moesten zien waarom)* |
| 11:37 | `add-index`, PR #5 | Nieuw bestand `index.html`: dat stuurt bezoekers automatisch door naar `Agenda.html`. Nodig voor **GitHub Pages**, dat altijd `index.html` opent. *(afgeleid: rond dit moment zette je GitHub Pages aan in de instellingen van de repo)* |
| 12:23 | `quick-add`, PR #6 | De **invoerbalk** die Nederlandse zinnen begrijpt, bv. *voeg 'voetbaltraining' toe op 23 november van 19u30-21u*. |
| 12:32 | `weekday-repeat`, PR #7 | Afspraken **herhalen op gekozen weekdagen** (vinkjes ma t/m zo, met einddatum). |
| 12:34 | `quick-repeat`, PR #8 | De invoerbalk begrijpt herhalingen: *elke maandag*, *elke werkdag*, *dagelijks*. |
| 12:40 | `quick-robust`, PR #9 | Meer manieren van formuleren worden begrepen, en er staat nu een **versienummer** in beeld. |
| 12:42 | `undo`, PR #10 | Knop **Ongedaan maken** (tot 50 stappen, ook met Ctrl+Z). |
| 12:45 | `black-work`, PR #11 | Afspraken met **"werk"** in de titel worden altijd **zwart**. |
| 12:53 | `quick-modify`, PR #12 | Via de balk bestaande afspraken **aanpassen**, en een kleur kiezen per type. |
| 12:58 | `quick-delete`, PR #13 | Via de balk afspraken **verwijderen**. Dubbele afspraken worden samengevoegd bij aanpassen. |
| 13:01 | `scoped-modify`, PR #14 | Aanpassen voor **alleen de genoemde weekdagen** van een reeks. |
| 13:03 | `auto-update`, PR #15 | **Automatisch bijwerken**: een open agenda merkt dat er een nieuwere versie online staat en herlaadt zichzelf. |
| 13:11 | `date-scope`, PR #16 | Eén dag, bepaalde weekdagen of een **periode** van een reeks verwijderen of aanpassen. |
| 13:23 | `pwa`, PR #17 | **Installeerbare app (PWA)**: nieuwe bestanden `manifest.json`, `sw.js` en de icoontjes `icon-180/192/512.png` en `icon-maskable-512.png`. Werkt ook offline. |
| 13:31 | `day-overview`, PR #18 | Op smalle schermen (telefoon) een **dagoverzicht onder de kalender**. Tikken op een dag in de maand selecteert die dag. |
| 13:37 | `todo-deadlines`, PR #19 | To-do's via de invoerbalk, **herhalende to-do's** (dagelijks of op weekdagen) en **deadlines** zichtbaar in de kalender. |
| 13:45 | `voice-input`, PR #20 | **Spraakinvoer**: microfoonknop. Wat je zegt verschijnt in de balk, zodat je het kunt nakijken voor je het toevoegt. |

**In Supabase, door jou, op dag 1** *(afgeleid uit de code en `supabase-setup.sql`)*:
1. Een account aangemaakt op supabase.com en een **project** aangemaakt
   (projectcode `xvuqcmmxarvkpcetztno`).
2. In de **SQL Editor** de inhoud van `supabase-setup.sql` geplakt en uitgevoerd. Dat maakte:
   - de tabel **`agenda_data`**: één rij per gebruiker, met de hele agenda (afspraken, to-do's, doelen) erin;
   - **beveiligingsregels** (Row Level Security): elke gebruiker kan alleen zijn eigen rij zien en wijzigen.
3. Een **gebruiker met e-mail en wachtwoord** aangemaakt. De app kan alleen inloggen, niet zelf
   registreren, dus dit gebeurde in Supabase onder *Authentication → Users*.
4. Het **projectadres** (URL) en de **publieke sleutel** (`sb_publishable_…`) doorgegeven. Die
   staan nu in `Agenda.html`. Die publieke sleutel mag openbaar zijn: de beveiligingsregels
   bepalen wat iemand ermee kan.

### Zondag 22 november — dag 2

De werkwijze veranderde: er werden geen pull requests meer gemaakt. Ik werkte verder op de branch
`voice-input` en voegde elke wijziging **zelf** samen met `main` en pushte die meteen naar GitHub
("Merge branch 'voice-input'"). Zo stond elke verbetering binnen een minuut live.

| Tijd | Wat er veranderde |
|---|---|
| 11:58 | **Herhalende doelen** (dagelijks, om de 2 dagen, wekelijks) met een vinkje per dag en een **focus-ster**. |
| 12:02 | Doelen **"zelf kiezen"** per dag (*ook morgen* / *niet vandaag*), en een dag overslaan bij geplande doelen. |
| 12:09 | De sectie heet voortaan **"Dagelijkse doelen"**. |
| 12:16 | **Meldingen en alarmen** via Web Push. Nieuwe bestanden: `supabase-reminders.sql` en `supabase/functions/send-reminders/index.ts`. `sw.js` kan nu meldingen tonen. |
| 13:09 | Kleine aanpassing aan de Edge Function, omdat die anders **niet wilde installeren** via het Supabase-dashboard. *(afgeleid: je kreeg een fout bij het deployen)* |
| 13:15 | Aanvulling in `supabase-reminders.sql`: expliciete **rechten op de tabellen**. *(afgeleid: het SQL-script gaf een rechtenprobleem)* |
| 13:40 | Via de balk of spraak een **melding** of **alarm** instellen: minuten, uren of dagen vooraf, bij de start, of op een tijdstip. |
| 13:47 | **15 kleuren** (ook geel) voor afspraken en to-do's. De app toont nu **waarom** meldingen mislukken. |
| 13:53 | Overgeslagen of niet gekozen doelen komen in een ingeklapt vak **"Niet vandaag"**. |
| 14:01 | Meldingen: een gewijzigd tijdstip telt als nieuwe melding, net verstreken tijden worden nog aanvaard, en alarmen van verwijderde afspraken stoppen. |
| 14:07 | **Wisknop (×)** in de invoerbalk. |
| — | Je gebruikte `/clear` om met een lege context verder te gaan en besloot de agenda-app even te laten rusten. |
| 14:14 | **`CLAUDE.md`** toegevoegd: een projectbriefje dat elke nieuwe Claude-chat automatisch inleest (branch `claude-md`, samengevoegd met `main`). |

**In Supabase, door jou, op dag 2** *(uit `meldingen-installatie.md`)*:
1. **SQL Editor**: het meldingen-script uitgevoerd. Dat maakte:
   - tabel **`push_subs`**: welke telefoons/browsers meldingen mogen ontvangen;
   - tabel **`reminders`**: alle meldingen en alarmen van de komende 30 dagen;
   - functie **`replace_reminders`**: de app vervangt hiermee in één keer alle nog niet verstuurde meldingen;
   - functie **`ack_reminder`**: voor de knop "Stop" op een alarm;
   - een **geplande taak (pg_cron)** die **elke minuut** de Edge Function aanroept.
2. **Edge Functions → Secrets**: drie geheimen toegevoegd: `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`
   en `CRON_SECRET`.
3. **Edge Functions → Deploy a new function → Via Editor**: de functie **`send-reminders`**
   aangemaakt met de code uit de repo, en **"Verify JWT" uitgezet** (de functie controleert in
   plaats daarvan het `CRON_SECRET`).
4. **Op je telefoon**: de agenda geopend, ingelogd, op het **belletje** getikt en meldingen toegestaan.

---

## Deel 3 — Hoe alles samenwerkt

```
 Jouw telefoon / computer                 GitHub                        Supabase
 ┌───────────────────────┐        ┌──────────────────────┐      ┌───────────────────────────┐
 │ Browser of             │◀──────│ GitHub Pages          │      │ Inloggen (Auth)           │
 │ geïnstalleerde app     │ laadt │ zet Agenda.html,      │      │                           │
 │                        │ de app│ sw.js, icoontjes      │      │ Tabel agenda_data         │
 │ localStorage:          │       │ online                │      │  (je hele agenda)         │
 │  eigen kopie agenda    │◀─────────────────────────────────────▶│                           │
 │                        │  synchroniseren na inloggen  │      │ Tabel reminders           │
 │ sw.js (service worker) │       └──────────────────────┘      │ Tabel push_subs           │
 │  offline + meldingen   │                                     │                           │
 │                        │◀────────── Web Push ─────────────────│ Edge Function             │
 └───────────────────────┘                                     │  send-reminders           │
                                                               │  ▲ elke minuut aangeroepen│
                                                               │  │ door pg_cron            │
                                                               └───────────────────────────┘
```

1. **De app openen**: je browser haalt `Agenda.html` op van **GitHub Pages**.
2. **Gegevens**: alles wat je invoert, gaat eerst naar **localStorage** op je toestel. Ben je
   ingelogd, dan stuurt de app het kort daarna naar de tabel **`agenda_data`** in Supabase. Op een
   ander toestel haalt de app het daar weer op.
3. **Meldingen**: de app zet alle meldingen van de komende 30 dagen in de tabel **`reminders`**.
   Elke minuut roept **pg_cron** de functie **`send-reminders`** aan. Die kijkt wat er nu moet
   afgaan en stuurt een **Web Push** naar elke telefoon in **`push_subs`**. De service worker op je
   telefoon toont de melding. Een **alarm** herhaalt zich elke minuut (maximaal 10 keer) tot je op
   **Stop** tikt.
4. **Updates**: verandert er iets aan de app, dan verhoog ik `APP_VERSION`. Een open agenda merkt
   dat en herlaadt zichzelf.

---

## Deel 4 — Wat staat waar?

### Op GitHub — repository `JornBage/claude-bestanden` (openbaar)

| Bestand | Wat het is |
|---|---|
| `Agenda.html` | **De hele app** in één bestand (ongeveer 1600 regels): opmaak, uiterlijk en alle logica. |
| `index.html` | Doorverwijzing naar `Agenda.html`, voor GitHub Pages. |
| `manifest.json` | Naam, kleuren en icoontjes van de installeerbare app. |
| `icon-180.png`, `icon-192.png`, `icon-512.png`, `icon-maskable-512.png` | App-icoontjes in verschillende formaten. |
| `sw.js` | Service worker: offline werken en meldingen tonen. |
| `supabase-setup.sql` | Het script voor de tabel `agenda_data` (al uitgevoerd in Supabase). |
| `supabase-reminders.sql` | Het script voor meldingen (al uitgevoerd). In deze versie staat `<CRON_SECRET>` als lege plek in plaats van het echte geheim. |
| `supabase/functions/send-reminders/index.ts` | De code van de Edge Function (de echte versie draait in Supabase). |
| `CLAUDE.md` | Projectbriefje voor nieuwe Claude-chats. |
| `UITLEG.md` | Dit document (op branch `uitleg`). |

- **Branches**: `main` is de live versie. Daarnaast staan er nog ongeveer 20 oude branches
  (`quick-add`, `pwa`, `voice-input`, …). Die zijn allemaal al in `main` verwerkt. Ze kunnen blijven
  staan of opgeruimd worden, ze doen niets.
- **Website**: via GitHub Pages, normaal op **https://jornbage.github.io/claude-bestanden/**.
- **Geschiedenis**: op GitHub onder *Commits* (63 stuks) en *Pull requests* (20, waarvan 19 samengevoegd).

### In Supabase — project `xvuqcmmxarvkpcetztno`

| Onderdeel | Waar in het dashboard |
|---|---|
| Je gebruikersaccount | Authentication → Users |
| Tabellen `agenda_data`, `push_subs`, `reminders` | Table Editor |
| Functies `replace_reminders`, `ack_reminder` | Database → Functions |
| Geplande taak `send-reminders` (elke minuut) | Integrations → Cron (of Database → Cron Jobs) |
| Edge Function `send-reminders` | Edge Functions |
| Geheimen `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `CRON_SECRET` | Edge Functions → Secrets |

### Op je toestellen

- **localStorage** van de browser: een kopie van je agenda en je weergave-instellingen
  (bv. maand of week, zijbalk open of dicht).
- **Cache van de service worker**: de app-bestanden, voor offline gebruik.
- **Meldingsabonnement** van je telefoon (dat staat ook in `push_subs`).

### Alleen in de cloudcomputer van Claude (tijdelijk!)

- **`meldingen-installatie.md`**: de installatie-instructies **met de echte geheime sleutels**.
  Staat bewust niet op GitHub. **Dit bestand verdwijnt** als deze cloudomgeving wordt opgeruimd.
  Bewaar de inhoud dus zelf op een veilige plek (bv. een wachtwoordmanager).

### In Claude

- De **gesprekken** zelf staan in je lijst met Claude Code-sessies. Na `/clear` weet de chat de
  inhoud niet meer, maar de bestanden op GitHub blijven gewoon bestaan.

---

## Deel 5 — Wat de app nu allemaal kan (overzicht)

- Kalender met **maand-, week- en dagweergave**, rode lijn op het huidige tijdstip.
- **Afspraken** met 15 kleuren. "Werk"-afspraken worden zwart.
- **Herhalende afspraken** op gekozen weekdagen, met einddatum.
- **To-do's**: eenmalig, herhalend (dagelijks of op weekdagen) of met **deadline** in de kalender.
- **Dagelijkse doelen**: dagelijks, om de 2 dagen, wekelijks, of zelf kiezen. Met focus-ster en een
  vak "Niet vandaag".
- **Invoerbalk** die Nederlandse zinnen begrijpt: toevoegen, aanpassen, verwijderen (ook voor een
  deel van een reeks), herhalingen, meldingen en alarmen. Met **wisknop**.
- **Spraakinvoer** (microfoonknop, in Chrome).
- **Ongedaan maken** (50 stappen, Ctrl+Z).
- **Inloggen** en **synchronisatie** tussen toestellen via Supabase.
- **Meldingen en alarmen** op je telefoon, ook als de app dicht is.
- **Installeerbaar als app** en **werkt offline**.
- **Werkt zichzelf automatisch bij** als er een nieuwe versie online staat.
- Op smalle schermen een **dagoverzicht** onder de kalender.
