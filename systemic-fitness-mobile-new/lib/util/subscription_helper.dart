import 'package:workout/models/payment_model.dart';

/// Returns true if the user has an active **paid** subscription.
/// Free plans (tier null/empty/"free") are treated as not paid.
///
/// This is a UX helper only — the backend remains the source of truth and
/// will reject API calls with HTTP 403 if the gate is bypassed.
bool isPaidActive(MySubscriptionResult? sub) {
  if (sub == null || !sub.hasSubscription) return false;
  final s = sub.subscription;
  if (s == null) return false;
  if ((s.status ?? '').toLowerCase() != 'active') return false;
  final tier = (s.tier ?? '').toLowerCase();
  return tier.isNotEmpty && tier != 'free' && tier != 'sf_free';
}
