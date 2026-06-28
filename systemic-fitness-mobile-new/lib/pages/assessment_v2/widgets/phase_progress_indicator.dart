import 'package:flutter/material.dart';

import '../../../ColorCategory.dart';
import '../../../util/sf_typography.dart';

/// Top header untuk semua Phase A/B/C screens.
/// Menampilkan label "PHASE x" + judul + 3 dot indicator (A/B/C).
class PhaseHeader extends StatelessWidget {
  /// 0 = Phase A, 1 = Phase B, 2 = Phase C.
  final int currentPhase;

  /// Sub-progress dalam phase (mis. "Q2 dari 3").
  final String? subProgress;

  /// Judul phase (mis. "Penilaian Kondisi").
  final String title;

  /// Tap handler untuk back button.
  final VoidCallback? onBack;

  const PhaseHeader({
    super.key,
    required this.currentPhase,
    required this.title,
    this.subProgress,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: const BoxDecoration(
        color: kSfDeepNavy,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  visualDensity: VisualDensity.compact,
                ),
              if (onBack != null) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'PHASE ${["A", "B", "C"][currentPhase]}',
                  style: SfTypography.label(
                    fontSize: 11,
                    color: kSfWarmGold,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              if (subProgress != null)
                Text(
                  subProgress!,
                  style: SfTypography.label(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.55),
                    letterSpacing: 1.0,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: SfTypography.headline(
              fontSize: 22,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(3, (i) {
              final active = i == currentPhase;
              final done = i < currentPhase;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: active
                        ? kSfWarmGold
                        : done
                            ? kSfWarmGold.withOpacity(0.55)
                            : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Single-select option card.
/// Tap → emit value lewat onChanged.
class V2SelectCard<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final String label;
  final String? hint;
  final ValueChanged<T> onChanged;

  const V2SelectCard({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? kSfWarmGold.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? kSfWarmGold : kSfCharcoal.withOpacity(0.15),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? kSfWarmGold : kSfCharcoal.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: kSfWarmGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: SfTypography.body(
                      fontSize: 14,
                      color: kSfCharcoal,
                      weight: selected ? FontWeight.w500 : FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      hint!,
                      style: SfTypography.body(
                        fontSize: 12,
                        color: kSfCharcoal.withOpacity(0.55),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multi-select chip-style.
class V2MultiChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const V2MultiChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? kSfWarmGold.withOpacity(0.10) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? kSfWarmGold : kSfCharcoal.withOpacity(0.15),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: selected ? kSfWarmGold : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: selected ? kSfWarmGold : kSfCharcoal.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: SfTypography.body(
                  fontSize: 13.5,
                  color: kSfCharcoal,
                  weight: selected ? FontWeight.w500 : FontWeight.w400,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating CTA bar (Lanjut / Selesai) di bawah screen.
class V2BottomCta extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final String? hint;

  const V2BottomCta({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 12, 20, MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: kSfWarmWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hint != null) ...[
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: SfTypography.body(
                fontSize: 12,
                color: kSfCharcoal.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: loading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: kSfWarmGold,
                disabledBackgroundColor: kSfWarmGold.withOpacity(0.4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white,
                      ),
                    )
                  : Text(label, style: SfTypography.ctaPrimary()),
            ),
          ),
        ],
      ),
    );
  }
}
