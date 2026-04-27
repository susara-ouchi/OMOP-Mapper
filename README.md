# Concept Mapper — Setup Guide

A free, mobile-friendly web app for filling in OMOP concept mappings.
Hosted on GitHub Pages + Supabase (both free tiers).

---

## Architecture

```
GitHub Pages          Supabase (free tier)
┌─────────────┐       ┌─────────────────────┐
│  index.html │ ────► │  source_fields table │
│  (static)   │ ◄──── │  mappings table      │
└─────────────┘  REST │  (PostgreSQL)        │
                 API  └─────────────────────┘
```

No server required. The browser calls Supabase directly.

---

## Step 1 — Create a Supabase project

1. Go to https://supabase.com and sign up (free)
2. Click **New project**, give it a name, choose a region, set a password
3. Wait ~2 minutes for it to spin up

---

## Step 2 — Create your tables

1. In Supabase dashboard → **SQL Editor** → **New query**
2. Paste the entire contents of `schema.sql`
3. Click **Run** — you should see "Success"

---

## Step 3 — Get your API credentials

1. In Supabase dashboard → **Project Settings** → **API**
2. Copy:
   - **Project URL** (looks like `https://abcdefgh.supabase.co`)
   - **anon / public** key (long JWT string)

---

## Step 4 — Configure index.html

Open `index.html` and replace the two placeholders near the top of the `<script>`:

```js
const SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';   // ← replace
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY';                    // ← replace
```

---

## Step 5 — Upload your source fields CSV

Your CSV must have these columns (column names are case-sensitive):

```
source_field,details
AdmissionID,Admission number of patient
BirthWeight,Birth weight of child
...
```

To upload:
1. Supabase dashboard → **Table Editor** → `source_fields` table
2. Click **Insert** → **Import data from CSV**
3. Upload your CSV

Or paste rows directly in SQL Editor:
```sql
insert into source_fields (source_field, details) values
  ('AdmissionID', 'Admission number of patient'),
  ('BirthWeight', 'Birth weight of child');
```

---

## Step 6 — Deploy to GitHub Pages

1. Create a new **GitHub repository** (can be private or public)
2. Upload `index.html` to the repo root
3. Go to **Settings** → **Pages**
4. Under **Source**, select **Deploy from a branch** → `main` → `/ (root)`
5. Click **Save**
6. Your app will be live at:
   `https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/`

(Takes ~1 minute to go live after first deploy)

---

## How it works

| Feature | Detail |
|---|---|
| Users | Type their username on login — no password needed |
| Mappings | Saved per-user in the `mappings` table (username + source_field_id) |
| Re-entry | Users can return and continue where they left off |
| Admin view | Run `select * from mapping_progress;` in Supabase SQL editor to see progress |

---

## Exporting results

In Supabase SQL Editor, run:

```sql
select
  sf.id,
  sf.source_field,
  sf.details,
  m.username,
  m.domain_id,
  m.name,
  m.concept_id,
  m.vocab,
  m.updated_at
from source_fields sf
left join mappings m on m.source_field_id = sf.id
order by sf.id, m.username;
```

Then click **Download CSV** to export the full populated table.

---

## Limits (free tiers)

| Service | Free limit | Your expected usage |
|---|---|---|
| GitHub Pages | Unlimited static hosting | ✓ Well within |
| Supabase DB | 500 MB storage | ✓ Tiny (KBs) |
| Supabase bandwidth | 2 GB/month | ✓ Way under |
| Supabase API requests | 500k/month | ✓ Fine for non-concurrent use |

**Cost: $0.00**
