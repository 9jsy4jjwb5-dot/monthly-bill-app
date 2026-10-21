# Monthly Bills — setup guide (free-tier approach)

This is an iPhone-friendly web app prototype. It uses GitHub Pages for hosting and Supabase Auth/Postgres for shared online records. It does not bundle your bill spreadsheet into the public website. The administrator imports it after signing in, so the sheet data is stored in the database.

## Important privacy note
This app is intended for a small trusted group. Require accounts; do not enable anonymous access. Anyone with a standard account can read all shared bill sheets and meal records, and can insert daily meal entries. Only the user ID in `app_admins` can change bill sheets or edit/delete meal records. If the spreadsheet contains sensitive financial details, only invite people you trust because standard users can view the shared bill sheets.

## 1. Create the free database
1. Open https://supabase.com/ and create a project on the free plan. Save the database password somewhere private.
2. Open **SQL Editor**, create a new query, paste all of `supabase.sql`, and run it.
3. Open **Project Settings → API** (or **Connect**) and copy the Project URL and the publishable/anon key. Never put a `service_role` key in this website.
4. In **Authentication → URL Configuration**, add your eventual GitHub Pages URL to the allowed Site URL / Redirect URLs.
5. For a private shared household app, consider turning off open sign-ups after the initial accounts are created. If you disable sign-ups, invite/add accounts through Supabase Auth dashboard.

## 2. Publish the website free
1. Create a GitHub repository, for example `monthly-bill-app`.
2. Upload `index.html`, `manifest.json`, and `icon.svg` to the repository root. Do **not** upload private bill data or any secret/service-role key.
3. In repository **Settings → Pages**, choose deploy from the `main` branch and root folder.
4. Wait for GitHub Pages to publish the URL, usually `https://YOUR-USERNAME.github.io/monthly-bill-app/`.

## 3. Connect and create your administrator account
1. Open the published site on your iPhone in Safari.
2. Enter the Supabase Project URL and public anon/publishable key.
3. Create your own account, then sign in. If email confirmation is enabled, confirm your email first.
4. In Supabase **Authentication → Users**, copy your account's UUID.
5. In SQL Editor, run this, replacing the placeholder with your UUID:

```sql
insert into public.app_admins (user_id)
values ('PASTE-YOUR-AUTH-USER-UUID-HERE')
on conflict (user_id) do nothing;
```

6. Sign out and sign back in. You should see the **Administrator** badge and Admin tab.
7. In **Admin → Import Monthly Bill Excel workbook**, choose the original `Monthly Bill 2026(1).xlsx` file from Files on your iPhone and import it. Review a month, tap a cell to edit, then press **Save changes**.

## 4. Add other users
Create accounts for trusted users (or add/invite them in Supabase Auth if you disable public sign-ups). They sign in to the same URL. Their available actions are limited by database policies to viewing shared data and inserting daily meal entries. They cannot edit monthly sheets or alter existing meal entries. They can choose Vincent or Eileen, date, amount and an optional short note.

## Current prototype limitations
- Excel formulas are imported as displayed values/text from the browser's workbook parser; formula recalculation is not implemented. Verify important totals after import.
- The monthly sheet editor is a basic editable grid, not a full Excel replacement; complex formatting, formulas, merged cells and charts are not preserved.
- This app shares the whole workbook with signed-in users. Do not use this design if meal-entry users must not see bill amounts; that would require a separate, more granular display and data model.
- Free service tiers have quotas and policies may change. The app requires internet access to sync.
