# Chapter 06 — Networking & Data: Summary

## Key Takeaways
1. Use **Dio** over `http` for production — supports interceptors, retry, cancellation, file upload.
2. **Repository pattern** abstracts data sources — swap remote for local without UI changes.
3. **freezed** + **json_serializable** = immutable models with generated JSON/copyWith/equality.
4. JWT auth: store tokens in **flutter_secure_storage**, refresh with Dio interceptor.
5. **Certificate pinning** for high-security apps; update app when certs rotate.
6. **Offline-first**: Try network → cache results → fallback to cache on failure.
7. Cancel in-flight requests in `dispose()` using `CancelToken`.
8. Use `--dart-define` for environment-specific config (API URLs, keys).

## Next: [Chapter 07 — Local Storage](../07_local_storage/07_local_storage.md)
