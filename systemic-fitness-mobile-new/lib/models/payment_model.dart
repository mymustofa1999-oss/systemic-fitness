class PaymentPlan {
  String? id;
  String? name;
  String? description;
  double? price;
  String? currency;
  int? durationMonths;
  List<String>? features;
  int? maxClients;
  bool? isActive;

  PaymentPlan({
    this.id,
    this.name,
    this.description,
    this.price,
    this.currency,
    this.durationMonths,
    this.features,
    this.maxClients,
    this.isActive,
  });

  factory PaymentPlan.fromJson(Map<String, dynamic> json) => PaymentPlan(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    price: (json['price'] as num?)?.toDouble(),
    currency: json['currency'],
    durationMonths: json['duration_months'],
    features: (json['features'] as List?)?.cast<String>(),
    maxClients: json['max_clients'],
    isActive: json['is_active'],
  );
}

class Subscription {
  String? id;
  String? userId;
  String? planId;
  String? planName;
  String? status;
  String? startedAt;
  String? expiresAt;
  String? paymentMethod;

  Subscription({
    this.id,
    this.userId,
    this.planId,
    this.planName,
    this.status,
    this.startedAt,
    this.expiresAt,
    this.paymentMethod,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'],
    userId: json['user_id'],
    planId: json['plan_id'],
    planName: json['plan_name'],
    status: json['status'],
    startedAt: json['started_at'],
    expiresAt: json['expires_at'],
    paymentMethod: json['payment_method'],
  );
}

// ─── Client Subscription Models ─────────────────────────────────

class ClientPlan {
  String? id;
  String? name;
  String? description;
  String? tier;
  String? billingPeriod;
  double? price;
  double? originalPrice;
  String? currency;
  int? durationMonths;
  int? discountPct;
  List<String>? features;
  bool? isPopular;
  int? sortOrder;

  ClientPlan({
    this.id,
    this.name,
    this.description,
    this.tier,
    this.billingPeriod,
    this.price,
    this.originalPrice,
    this.currency,
    this.durationMonths,
    this.discountPct,
    this.features,
    this.isPopular,
    this.sortOrder,
  });

  factory ClientPlan.fromJson(Map<String, dynamic> json) => ClientPlan(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    tier: json['tier'],
    billingPeriod: json['billing_period'],
    price: (json['price'] as num?)?.toDouble(),
    originalPrice: (json['original_price'] as num?)?.toDouble(),
    currency: json['currency'],
    durationMonths: json['duration_months'],
    discountPct: json['discount_pct'],
    features: (json['features'] as List?)?.cast<String>(),
    isPopular: json['is_popular'],
    sortOrder: json['sort_order'],
  );
}

class PlanGroup {
  String? tier;
  ClientPlan? monthly;
  ClientPlan? annual;

  PlanGroup({this.tier, this.monthly, this.annual});

  factory PlanGroup.fromJson(Map<String, dynamic> json) => PlanGroup(
    tier: json['tier'],
    monthly: json['monthly'] != null ? ClientPlan.fromJson(json['monthly']) : null,
    annual: json['annual'] != null ? ClientPlan.fromJson(json['annual']) : null,
  );
}

class ClientSubscription {
  String? id;
  String? planId;
  String? planName;
  String? tier;
  String? billingPeriod;
  String? status;
  String? startedAt;
  String? expiresAt;
  String? cancelledAt;
  String? paymentMethod;
  String? createdAt;

  ClientSubscription({
    this.id,
    this.planId,
    this.planName,
    this.tier,
    this.billingPeriod,
    this.status,
    this.startedAt,
    this.expiresAt,
    this.cancelledAt,
    this.paymentMethod,
    this.createdAt,
  });

  factory ClientSubscription.fromJson(Map<String, dynamic> json) =>
      ClientSubscription(
        id: json['id'],
        planId: json['plan_id'],
        planName: json['plan_name'],
        tier: json['tier'],
        billingPeriod: json['billing_period'],
        status: json['status'],
        startedAt: json['started_at'],
        expiresAt: json['expires_at'],
        cancelledAt: json['cancelled_at'],
        paymentMethod: json['payment_method'],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_id': planId,
        'plan_name': planName,
        'tier': tier,
        'billing_period': billingPeriod,
        'status': status,
        'started_at': startedAt,
        'expires_at': expiresAt,
        'cancelled_at': cancelledAt,
        'payment_method': paymentMethod,
        'created_at': createdAt,
      };
}

class MySubscriptionResult {
  bool hasSubscription;
  ClientSubscription? subscription;
  int? daysRemaining;

  MySubscriptionResult({
    this.hasSubscription = false,
    this.subscription,
    this.daysRemaining,
  });

  factory MySubscriptionResult.fromJson(Map<String, dynamic> json) =>
      MySubscriptionResult(
        hasSubscription: json['has_subscription'] ?? false,
        subscription: json['subscription'] != null
            ? ClientSubscription.fromJson(json['subscription'])
            : null,
        daysRemaining: json['days_remaining'],
      );
}

// ─── Payment Records & Gateway Models ───────────────────────────

/// Mirrors backend `repository.ClientPaymentRecord`. One row per
/// payment attempt for a subscription. Status flow:
///   pending → completed | failed | refunded
class ClientPaymentRecord {
  String? id;
  String? subscriptionId;
  double? amount;
  String? currency;
  String? status; // pending | completed | failed | refunded
  String? paymentMethod;
  String? paymentType; // manual_transfer | midtrans_snap
  String? bankAccountId;
  String? proofImageUrl;
  String? proofUploadedAt;
  String? snapToken;
  String? snapRedirectUrl;
  String? gatewayStatus;
  String? externalId;
  String? paidAt;
  String? createdAt;

  ClientPaymentRecord({
    this.id,
    this.subscriptionId,
    this.amount,
    this.currency,
    this.status,
    this.paymentMethod,
    this.paymentType,
    this.bankAccountId,
    this.proofImageUrl,
    this.proofUploadedAt,
    this.snapToken,
    this.snapRedirectUrl,
    this.gatewayStatus,
    this.externalId,
    this.paidAt,
    this.createdAt,
  });

  factory ClientPaymentRecord.fromJson(Map<String, dynamic> json) =>
      ClientPaymentRecord(
        id: json['id'],
        subscriptionId: json['subscription_id'],
        amount: (json['amount'] as num?)?.toDouble(),
        currency: json['currency'],
        status: json['status'],
        paymentMethod: json['payment_method'],
        paymentType: json['payment_type'],
        bankAccountId: json['bank_account_id'],
        proofImageUrl: json['proof_image_url'],
        proofUploadedAt: json['proof_uploaded_at'],
        snapToken: json['snap_token'],
        snapRedirectUrl: json['snap_redirect_url'],
        gatewayStatus: json['gateway_status'],
        externalId: json['external_id'],
        paidAt: json['paid_at'],
        createdAt: json['created_at'],
      );

  bool get hasProof => proofImageUrl != null && proofImageUrl!.isNotEmpty;
}

/// Bank account destinations for manual transfer (admin-managed).
class BankAccount {
  String? id;
  String? bankName;
  String? accountNumber;
  String? accountHolder;
  String? branch;
  String? notes;
  bool? isActive;

  BankAccount({
    this.id,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
    this.branch,
    this.notes,
    this.isActive,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) => BankAccount(
        id: json['id'],
        bankName: json['bank_name'],
        accountNumber: json['account_number'],
        accountHolder: json['account_holder'],
        branch: json['branch'],
        notes: json['notes'],
        isActive: json['is_active'],
      );
}

/// Returned by POST /subscription/subscribe. Fields populated depend
/// on the requested payment_type:
///   - manual_transfer  → bankAccount + payment
///   - midtrans_snap    → snapToken + snapRedirectUrl + payment
class SubscribeResult {
  ClientSubscription? subscription;
  ClientPaymentRecord? payment;
  BankAccount? bankAccount;
  String? snapToken;
  String? snapRedirectUrl;

  SubscribeResult({
    this.subscription,
    this.payment,
    this.bankAccount,
    this.snapToken,
    this.snapRedirectUrl,
  });

  factory SubscribeResult.fromJson(Map<String, dynamic> json) => SubscribeResult(
        subscription: json['subscription'] != null
            ? ClientSubscription.fromJson(
                Map<String, dynamic>.from(json['subscription']))
            : null,
        payment: json['payment'] != null
            ? ClientPaymentRecord.fromJson(
                Map<String, dynamic>.from(json['payment']))
            : null,
        bankAccount: json['bank_account'] != null
            ? BankAccount.fromJson(
                Map<String, dynamic>.from(json['bank_account']))
            : null,
        snapToken: json['snap_token'],
        snapRedirectUrl: json['snap_redirect_url'],
      );
}
