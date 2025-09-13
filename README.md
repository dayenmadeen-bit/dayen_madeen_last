# dayen_madeen

A Flutter application for business owners and employees to manage customers, debts, and payments.

## QA checklist (device testing)

1. Registration & email verification
   - Create owner: email required; verification link; unique ID generated post verification.
   - Change email in settings: redirects to email verification; prevents saving until verified; offline blocked.
2. Offline behavior
   - Disconnect network: all mutating actions show offline notice; read-only stays available; re-connect re-enables actions.
3. Employee permissions
   - Presets viewer/accountant/manager: tabs, FABs, contextual menus appear/disappear accordingly.
   - Unauthorized attempts show unified permission notice.
4. Announcements
   - Banner rotates every 10s on owner/employee/customer/registration screens.
   - Seed button (admins only) works; Firestore rules block non-admin writes.
5. Notifications
   - Debt create/update and payment create show notifications; SERVICE_NOT_AVAILABLE handled safely.
6. UI/UX
   - No overflows; notification badge stable; visual identity preserved.
7. Evidence
   - Capture screenshots for each scenario with timestamps and app version.
This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
