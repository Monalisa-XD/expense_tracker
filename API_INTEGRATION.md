# Local-First Synchronization & API Integration Architecture

This document describes the offline-first API synchronization patterns integrated into the codebase.

## 1. System Architecture

The database/repository access strategy follows a local-first design pattern:

```
        ┌───────────────┐
        │   Flutter UI  │
        └───────┬───────┘
                ↓
        ┌───────────────┐
        │   Riverpod    │
        └───────┬───────┘
                ↓
        ┌───────────────┐
        │   UseCases    │
        └───────┬───────┘
                ↓
        ┌───────────────┐
        │  Repository   │
        └───────┬───────┘
           ┌────┴────┐
           ↓         ↓
      Local DB    Remote API
           ↓         ↓
           └────┬────┘
                ↓
          Sync Engine
                ↓
          Sync Queue
```

1. **Presentation / UI**: Renders content immediately using values loaded from local storage.
2. **Local DB (SharedPreferences)**: Operates as the single source of truth for immediate rendering.
3. **Sync Queue**: Stores pending creates, updates, and deletes as discrete operations (`SyncQueueItem`) when remote writes fail or the device is offline.
4. **Sync Engine**: Replays queued tasks when connection becomes online or when manually triggered by "Sync Now".

---

## 2. API Error Mapping

Raw HTTP network faults are mapped into high-level, structured exceptions in `api_exception.dart`:

- `NetworkException` (0)
- `UnauthorizedException` (401)
- `ForbiddenException` (403)
- `NotFoundException` (404)
- `ValidationException` (422)
- `ServerException` (500)
- `TimeoutException` (408)

---

## 3. Conflict Resolution

When local changes and remote server changes conflict (e.g. both copies were updated while offline), the Sync Engine applies **Last-Write-Wins (LWW)** conflict resolution based on compare checks of the entity's `updatedAt` / `createdAt` timestamp attributes.
