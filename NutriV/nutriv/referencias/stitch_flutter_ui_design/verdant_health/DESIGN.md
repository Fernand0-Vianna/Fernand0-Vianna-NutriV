# Design System Strategy: The Vitality Curator

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Digital Curator."** 

In an industry often cluttered with complex data and clinical interfaces, this system treats nutrition as an editorial experience. We move beyond the "app-as-a-tool" mentality to "app-as-a-lifestyle-magazine." This is achieved through a high-contrast typographic scale that prioritizes readability, intentional asymmetry in card layouts, and a "breathing" UI that favors negative space over structural lines. The aesthetic is healthy, fresh, and professional, utilizing a botanical green palette to evoke a sense of organic growth and vitality.

## 2. Colors
Our palette is rooted in a lush, verdant spectrum. We avoid sterile blacks and harsh greys in favor of "Deep Botanical" and "Minted Glass."

*   **Primary Core:** `#006A35` (Primary) and `#6BFE9C` (Primary Container). This pairing creates a high-vibrancy focus for action.
*   **The "No-Line" Rule:** To achieve a premium, editorial feel, **1px solid borders are prohibited for sectioning content.** Boundaries must be defined solely through background color shifts. Use `surface-container-low` for large content blocks and `surface` for the main canvas.
*   **Surface Hierarchy & Nesting:** Treat the UI as a series of physical layers. A `surface-container-lowest` card should sit atop a `surface-container-low` section to create a soft, natural lift.
*   **The "Glass & Gradient" Rule:** Use Glassmorphism for floating navigation bars or high-level overlays (e.g., `surface` color at 80% opacity with a 20px backdrop-blur). 
*   **Signature Textures:** For Hero sections or primary CTAs, apply a subtle linear gradient transitioning from `primary` (`#006A35`) to `primary_dim` (`#005C2D`) at a 135-degree angle to add depth and "soul."

## 3. Typography
We utilize a pairing of **Plus Jakarta Sans** for high-impact editorial moments and **Manrope** for functional, friendly data consumption.

*   **Display & Headlines (Plus Jakarta Sans):** These are the "voice" of the brand. Use `display-lg` (3.5rem) for milestone achievements (e.g., "Daily Goal Reached") to create an authoritative, magazine-like feel.
*   **Titles & Body (Manrope):** Chosen for its modern, geometric construction that remains legible at small sizes. `title-md` (1.125rem) should be used for card headers to keep the interface feeling approachable and friendly.
*   **Semantic Scale:** The massive jump between `body-sm` (0.75rem) and `headline-lg` (2rem) is intentional. This "Typographic Tension" is a hallmark of high-end design, signaling clear information hierarchy.

## 4. Elevation & Depth
We eschew traditional material shadows in favor of **Tonal Layering**.

*   **The Layering Principle:** Depth is achieved by stacking surface tiers. A card containing a specific food item uses `surface-container-lowest` (#ffffff) to pop against a `surface-container-low` (#C4FEDD) background.
*   **Ambient Shadows:** If a floating element (like the FAB) requires a shadow, it must be highly diffused: `box-shadow: 0 12px 32px rgba(0, 54, 34, 0.08);`. The shadow uses a tint of `on-surface` (Deep Green) rather than grey, mimicking natural light filtering through foliage.
*   **The "Ghost Border" Fallback:** If a boundary is strictly required for accessibility (e.g., input fields), use the `outline-variant` (#86B89C) at 20% opacity. Never use 100% opaque borders.

## 5. Components

### Buttons
*   **Primary:** High-pill shape (`9999px`). Uses the signature gradient (Primary to Primary Dim). Text is `on-primary` (#CDFFD4) for a soft, low-strain contrast.
*   **Tertiary:** No background or border. Uses `primary` text with an icon. Reserved for "Cancel" or "Skip" actions.

### Data Visualization (The Nutrition Ring)
*   Forgo standard thin lines. Use thick, rounded-cap strokes. 
*   **Depth:** The background "track" of the ring should use `surface-container-high` (#AEF1CC) to suggest a recessed groove in the UI.

### Cards & Lists
*   **Rule:** Forbid divider lines.
*   **Implementation:** Use the `md` (0.75rem) or `lg` (1rem) corner radius. Separate list items using a 12px vertical gap or by alternating between `surface-container-lowest` and `surface-container-low`.
*   **Asymmetry:** In a "Food Entry" card, place the image slightly overlapping the card boundary to break the "boxed-in" feel.

### Input Fields
*   **Style:** Minimalist. Background is `surface-container-lowest`. 
*   **Focus State:** Instead of a heavy border, a 2px "Ghost Border" at 40% opacity appears, and the label shifts to `primary` color.

## 6. Do's and Don'ts

*   **DO:** Use white space as a structural element. If an element feels "stuck," add 8px of padding.
*   **DO:** Use the `tertiary` (#006576) color for secondary data points like "Water Intake" to provide a visual break from the green-heavy palette.
*   **DON'T:** Use pure black (#000000). Use `on-surface` (#003622) for all "black" text to maintain the organic, botanical tone.
*   **DON'T:** Use hard shadows. If you can clearly see where the shadow ends, it's too heavy.
*   **DO:** Ensure all touch targets for chips and buttons are at least 48dp, even if the visual element is smaller, to maintain professional usability standards.