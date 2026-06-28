# Payment Gateway — End-to-End Test Plan

Manual test scenarios untuk fitur **strict pay-before-access gating** +
**Manual Bank Transfer** + **Midtrans Snap** + **push notifications** +
**cancel pending subscription**.

Prerequisite:
- Migration `035_payment_gateway_support.sql` & `036_subscription_pending_status.sql` applied.
- Seed `014_seed_bank_accounts_menu.sql` applied.
- At least one active `bank_accounts` row.
- For Midtrans tests: `MIDTRANS_SERVER_KEY` + `MIDTRANS_CLIENT_KEY` set (sandbox).
- FCM credentials file present so push notifications can actually go out.

---

## Scenario 1 — Manual Transfer Happy Path

**Setup:** User `alice@test.com` (client, no existing sub), one active plan
"Premium Monthly" Rp 49.000.

### Steps

1. **Mobile**: alice opens Subscription page → tap "Premium Monthly" → Bottom sheet → tap **"Transfer Bank Manual"**.
2. **Expected**: mobile navigates to `PaymentInstructionPage` showing:
   - Summary card: plan name + amount + status=**pending**
   - Bank card: bank name, account number, holder
   - "Salin Nomor Rekening" button + 5-step instruction list
   - "Upload Bukti Transfer" button
3. **Verify backend**:
   ```sql
   SELECT id, user_id, status FROM subscriptions WHERE user_id = 'alice-id';
   -- status should be 'pending'
   SELECT id, status, payment_type, bank_account_id FROM payment_records WHERE user_id = 'alice-id';
   -- status='pending', payment_type='manual_transfer', bank_account_id NOT NULL
   ```
4. **Mobile**: tap "Upload Bukti Transfer" → pick image → submit.
5. **Expected**: toast "Bukti pembayaran berhasil dikirim", navigate to MyPayments.
6. **Verify backend**:
   ```sql
   SELECT proof_image_url, proof_uploaded_at, status FROM payment_records WHERE id = '...';
   -- proof_image_url NOT NULL, proof_uploaded_at set, status still 'pending'
   ```
7. **Admin web**: open `/payments`, filter "Pending", find alice's row.
8. **Expected**: row shows
   - Type: "Manual" + bank name
   - Proof: "Uploaded" (green badge)
   - Action: "Verify proof"
9. Click "Verify proof" → modal opens → inline proof thumbnail visible → click → fullscreen lightbox works.
10. Click **"Approve & Activate"**.
11. **Expected**:
    - Modal closes, row disappears from "Pending" filter.
    - `payment_records.status = 'completed'`, `paid_at` set.
    - `subscriptions.status = 'active'`, `started_at = NOW()`, `expires_at = NOW() + 1 month`.
    - Alice receives push notification: _"Pembayaran berhasil diverifikasi"_ + in-app notification.
12. **Mobile**: alice pulls-to-refresh subscription page → "MENUNGGU PEMBAYARAN" banner disappears, "Langganan Aktif" card appears.

---

## Scenario 2 — Manual Transfer Rejected

**Setup:** same as Scenario 1 up to step 9 (alice has uploaded proof).

### Steps

1. Admin opens modal → click **"Reject"**.
2. **Expected**:
   - `payment_records.status = 'failed'`, `failed_at` set.
   - `subscriptions.status = 'cancelled'` (extended rejection behavior — see §3).
   - Alice receives push: _"Pembayaran ditolak"_ + in-app notif.
3. **Mobile**: alice refreshes → "MENUNGGU PEMBAYARAN" banner gone → plan cards with "Subscribe" buttons available again.

---

## Scenario 3 — Customer Cancels Pending Subscription

**Setup:** alice just subscribed (Scenario 1, step 1 done) but hasn't uploaded proof yet.

### Steps

1. **Mobile**: alice opens Subscription page → sees "MENUNGGU PEMBAYARAN" banner → taps → MyPaymentsPage → tap three-dot menu / swipe / dedicated "Batalkan Langganan" button.
2. Confirm dialog: "Batalkan langganan Premium Monthly? Kamu bisa subscribe ulang kapan saja."
3. Tap "Ya, Batalkan".
4. **Expected**:
   - `subscriptions.status = 'cancelled'`, `cancelled_at = NOW()`.
   - `payment_records.status = 'failed'` (pending → abandoned).
   - Mobile redirects back to Subscription list, subscribe buttons enabled again.
5. **Verify**: alice can now subscribe to a different plan.

---

## Scenario 4 — Midtrans Happy Path

**Setup:** `MIDTRANS_SERVER_KEY` set (sandbox). alice has no sub.

### Steps

1. Mobile: subscribe → pick **"Midtrans (Otomatis)"**.
2. **Expected**: navigate to `PaymentInstructionPage` with **"Bayar Sekarang"** button (no bank info).
3. Tap → `MidtransPaymentPage` → auto-launches external browser with `snap_redirect_url`.
4. In browser: pick payment method → use sandbox credentials (see Midtrans docs) → complete payment.
5. **Expected backend (from webhook)**:
   - `payment_records.status = 'completed'`, `gateway_status = 'settlement'`, `gateway_response` contains raw payload.
   - `subscriptions.status = 'active'`, `started_at = NOW()`, `expires_at = NOW() + 1 month`.
   - Alice receives push notification.
6. **Mobile**: alice back to app → MyPayments pull-to-refresh → status LUNAS.

### Test webhook manually via `curl`

```bash
# Compute signature:
ORDER_ID="FC-<payment-id>"
STATUS_CODE="200"
GROSS_AMOUNT="49000.00"
SERVER_KEY="<your-sandbox-key>"
SIGNATURE=$(echo -n "${ORDER_ID}${STATUS_CODE}${GROSS_AMOUNT}${SERVER_KEY}" | sha512sum | awk '{print $1}')

# Send a fake Midtrans notification:
curl -X POST http://localhost:8080/api/payments/midtrans/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "transaction_time":"2024-01-01 12:00:00",
    "transaction_status":"settlement",
    "transaction_id":"txn-xyz",
    "status_message":"midtrans payment notification",
    "status_code":"200",
    "signature_key":"'${SIGNATURE}'",
    "payment_type":"bank_transfer",
    "order_id":"'${ORDER_ID}'",
    "merchant_id":"M123",
    "gross_amount":"49000.00",
    "fraud_status":"accept",
    "currency":"IDR"
  }'
```

Expected: HTTP 200, payment status flipped to completed, subscription activated.

---

## Scenario 5 — Midtrans Signature Rejection

Same as Scenario 4 but send a webhook with a `signature_key` that wasn't computed
from the real server key.

**Expected:** backend returns HTTP 401, payment row unchanged. Log line
`[Midtrans.Webhook] invalid signature`.

Covered by automated tests in `midtrans_service_test.go`:
- `TestMidtrans_VerifySignature_Invalid`
- `TestMidtrans_VerifySignature_WrongServerKey`

---

## Scenario 6 — Duplicate Subscribe Blocked

**Setup:** alice has a pending sub (from Scenario 1 step 1, pre-upload).

### Steps

1. alice tries to subscribe to a different plan.
2. **Expected**: backend returns HTTP 409 Conflict with message
   _"Kamu sudah memiliki langganan aktif. Batalkan terlebih dahulu untuk beralih plan."_
   (Same error used for active subs — strict gating blocks both.)
3. Mobile surfaces the toast.
4. alice cancels the pending sub (Scenario 3) → now subscribe works.

---

## Scenario 7 — Pending→Active Avoids Double Duration (Regression)

**Setup:** Plan has `duration_months = 1`. alice subscribes, sub created with
status='pending', `started_at = NOW()`, `expires_at = NOW() + 1 month`
(placeholder written by `CreateSubscription`).

### Steps

1. Admin approves payment immediately.
2. **Verify** `expires_at`:
   ```sql
   SELECT started_at, expires_at, EXTRACT(EPOCH FROM (expires_at - started_at))/86400 AS days
   FROM subscriptions WHERE id = '...';
   ```
3. **Expected**: `days ≈ 30` (one month), **NOT** `60` (two months).
4. **Regression note:** the old activate SQL did `expires_at = GREATEST(expires_at, NOW()) + interval`,
   which would add another month on top of the placeholder — doubling the
   duration. Migration 036 + updated `activate` SQL fixes this by resetting
   `expires_at = NOW() + interval` when the sub was pending.

---

## Automated Test Coverage

Currently covered by `go test ./internal/service/ -run TestMidtrans`:

- `TestMapTransactionStatus` — all 10 Midtrans status values map correctly
- `TestMidtrans_IsConfigured` — env gating
- `TestMidtrans_VerifySignature_Valid` / `Invalid` / `WrongServerKey` / `NotConfigured`
- `TestMidtrans_CreateSnapTransaction_HappyPath` / `NotConfigured` / `GatewayError`

NOT automated (require DB or a running backend):
- Repository transaction correctness (ActivatePendingSubscription, ApplyMidtransNotification)
- Subscribe → payment_instruction → upload_proof round trip
- Push notification delivery (requires FCM stub)

These are covered by the manual scenarios above.

---

## Smoke Command

One-liner to run all automated payment-related tests:

```bash
cd systemic-fitness-api
go test ./internal/service/ -run "TestMidtrans|TestMapTransactionStatus" -v
```
