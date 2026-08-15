# Development notes

The final implementation provides:

- a compact overflow grid for application-owned tray items;
- drag-and-drop between the visible panel tray and popup;
- persistent ordering of tray items;
- persistent ordering of built-in Plasma applets;
- exact popup-to-panel placement using target item identity rather than
  unstable numeric indices;
- a dedicated private MIME type for tray drags to avoid generic panel text-drop
  behavior.

The final release intentionally keeps some drop-target calculations duplicated
in separate QML scopes. A structural audit found these could theoretically be
consolidated, but doing so would couple different QML ownership/geometry
contexts and risk regressions. The tested implementation therefore favors
stability over cosmetic deduplication.
