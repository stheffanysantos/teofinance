/// Estado de sincronização de uma entidade entre o cache local (drift) e o
/// Firestore (fonte de verdade) — ver `.claude/docs/DATABASE.md` e
/// `.claude/memory/decisions.md`, decisão 0001.
///
/// Nunca usar flags booleanas espalhadas (`pendingSync`, `isSynced`, etc.)
/// para este conceito — sempre este enum único.
///
/// `pendingDelete` fica sempre no fim: o drift grava o índice do enum.
enum SyncStatus { pendingCreate, pendingUpdate, synced, pendingDelete }
