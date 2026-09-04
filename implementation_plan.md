# Refactor Training Card Movement Addition

## Goal
Refactor the Training Card page to use a single flexible "+ Tambah Gerakan" button instead of specific Upper/Lower/Core buttons. The movement selection must strictly mirror the movements configured in the Training Module (dl_menu_items) for the client's gender and level.

## Proposed Changes

### systemic-fitness-web/src/app/(dashboard)/clients/[id]/training-card/page.tsx
#### [MODIFY] page.tsx
- **UI Rewrite**: Replace the "+ Tambah Upper", "+ Tambah Lower", and "+ Tambah Core" buttons with a single "+ Tambah Gerakan" button.
- **Strict Movement Source Filtering**: 
  - Ensure cdData (Cool Down) is correctly included when building the menuCategoryMap.
  - Refactor the movementOptions memo to strictly rely on menuCategoryMap.has(m.id). Since menuCategoryMap is populated directly from the useDLMenuItems API (which already filters strictly by the client's level and effectiveGender), this ensures that ONLY movements configured in the Training Module for that specific level/gender combination can be selected.
  - Remove the legacy regex fallback (if mLevel !== -1) logic that allowed arbitrary movements from the master list.
- **Persistence Fix & Dropdown Flexibility**:
  - Remove the // Filter by bodyPart block inside the MovementSelect component.
  - Why? Because with a single "+ Tambah Gerakan" button, a user can pick any movement (Upper, Lower, Core, etc.). If an item is saved to the backend with body_part: "core", reloading the page would lock the dropdown to *only* Core movements, preventing the user from editing/swapping it with an Upper movement later. Removing this UI restriction fixes the persistence edit bug while preserving the backend's validBodyPart payload requirements.

## Verification Plan
1. npm run build and npx tsc --noEmit in the frontend to ensure no type errors.
2. Verify visually that only one button appears.
3. Add a movement, save the training card, and reload the page to ensure the movement (and all fields like Pattern, BPM) persists correctly.
4. Verify that when editing a saved movement, the dropdown shows all available movements, not just those matching its saved body_part.
