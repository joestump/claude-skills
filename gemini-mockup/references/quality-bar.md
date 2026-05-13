# Quality-bar prompt fragment

Universal Layer 4 — the "good rendering" floor. Concatenate at the END of
every mockup prompt, after the screen-specific description.

These instructions don't change per project. They set the photorealism +
production-quality bar that distinguishes a usable mockup from a wireframe.

---

Render the UI with **production-quality polish**: clean, modern,
finished-product appearance. NOT a wireframe. NOT a sketch. NOT a Figma
preview with empty bounding boxes.

- **Visual hierarchy:** clear font-size variation between page titles, section
  headings, body text, and metadata. Use ~3-4 distinct sizes.
- **Whitespace:** generous and consistent. Sections separated by at least
  16-24px of vertical space. Cards have meaningful internal padding.
- **Realistic sample data:** real-looking names, dates, message subjects,
  email addresses, numbers. Never lorem ipsum. Never `username@example.com`
  unless the project's own examples use that. Use names that fit the
  project's deployment context (e.g., a family deployment uses family-style
  names; an enterprise deployment uses business-style ones). 4-8 sample rows
  in a list/table is usually right — enough to suggest the pattern, not so
  many that the eye glazes.
- **Status and state:** show realistic states (online indicators, sync
  progress bars, recent timestamps, unread counts). The mockup should look
  like a screenshot of a system in actual use, not an empty just-installed
  one.
- **Iconography:** every icon should be sharp, consistent with the project's
  declared icon set (e.g., Heroicons outlined or solid, Lucide, Phosphor),
  the same stroke weight throughout, the same fill style.
- **Typography weight:** use weight (regular vs medium vs semibold) to
  reinforce hierarchy. Don't make everything semibold "for emphasis" — that
  flattens the design.
- **Photorealistic rendering quality:** crisp anti-aliased text, smooth
  rounded corners, subtle shadows that read as soft drop-shadow not as harsh
  outlines, no jagged edges, no compression artifacts.

Do not add unrequested elements: no random charts, no fake graphs, no
pretend AI assistant chat bubbles, no extra buttons that aren't described.
Show only what the description specifies, rendered well.
