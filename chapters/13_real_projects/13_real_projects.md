# Chapter 13 — Real Projects

> **Goal**: Apply everything learned in real-world projects — E-commerce, Chat, Social Feed, Payments, and CI/CD.

---

## Table of Contents

1. [Project Architecture Blueprint](#1-project-architecture-blueprint)
2. [E-Commerce App](#2-e-commerce-app)
3. [Chat App](#3-chat-app)
4. [Social Feed Scroll](#4-social-feed-scroll)
5. [Payment Integration](#5-payment-integration)
6. [CI/CD Workflows](#6-cicd-workflows)
7. [Production Checklist](#7-production-checklist)
8. [Interview Questions](#8-interview-questions)
9. [Resources](#9-resources)

---

## 1. Project Architecture Blueprint

Every production project should follow this structure:

```
my_app/
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   ├── app_config.dart
│   │   │   ├── theme.dart
│   │   │   └── router.dart
│   │   ├── constants/
│   │   ├── error/
│   │   ├── network/
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── products/
│   │   ├── cart/
│   │   └── profile/
│   ├── shared/
│   │   ├── widgets/
│   │   └── extensions/
│   ├── injection_container.dart
│   └── main.dart
├── test/
├── integration_test/
├── assets/
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

---

## 2. E-Commerce App

### Features
- Product catalog with search & filters
- Product detail with image carousel
- Shopping cart with quantity management
- Checkout with address & payment
- Order history
- User profile

### Key Architecture Decisions

```
┌──────────────────────────────────────────────────┐
│           E-Commerce Architecture                 │
│                                                  │
│  State: Riverpod (products, cart, auth, orders)  │
│  Routing: GoRouter with auth guards              │
│  Network: Dio + Repository pattern               │
│  Storage: Hive (cart cache), Drift (orders)      │
│  Models: Freezed + json_serializable             │
│  DI: Riverpod providers                          │
│  Testing: Unit (domain), Widget (UI), E2E (flows)│
└──────────────────────────────────────────────────┘
```

### Product Listing with Pagination

```dart
// Riverpod AsyncNotifier with pagination
class ProductsNotifier extends AsyncNotifier<ProductsState> {
  int _page = 1;
  bool _hasMore = true;

  @override
  Future<ProductsState> build() async {
    return _fetchProducts(reset: true);
  }

  Future<ProductsState> _fetchProducts({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _hasMore = true;
    }

    final repo = ref.read(productRepositoryProvider);
    final products = await repo.getProducts(page: _page, limit: 20);

    _hasMore = products.length == 20;

    if (reset) {
      return ProductsState(products: products, hasMore: _hasMore);
    } else {
      return ProductsState(
        products: [...state.requireValue.products, ...products],
        hasMore: _hasMore,
      );
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    _page++;
    state = AsyncData(await _fetchProducts());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchProducts(reset: true));
  }
}
```

### Shopping Cart

```dart
class CartNotifier extends Notifier<Cart> {
  @override
  Cart build() => const Cart.empty();

  void addItem(Product product, {int quantity = 1}) {
    state = state.addItem(CartItem(
      productId: product.id,
      name: product.name,
      price: product.price,
      imageUrl: product.imageUrl,
      quantity: quantity,
    ));
  }

  void removeItem(String productId) {
    state = state.removeItem(productId);
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
    } else {
      state = state.updateQuantity(productId, quantity);
    }
  }

  void clear() {
    state = const Cart.empty();
  }
}

final cartProvider = NotifierProvider<CartNotifier, Cart>(CartNotifier.new);

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).total;
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});
```

---

## 3. Chat App

### Technologies

```
┌──────────────────────────────────────────┐
│           Chat App Stack                  │
│                                          │
│  Backend: Firebase / Supabase            │
│  Real-time: WebSocket / Firestore        │
│  Auth: Firebase Auth                     │
│  Storage: Firebase Storage (images)      │
│  Local: Drift (message cache)            │
│  State: Riverpod                         │
│  Push: Firebase Cloud Messaging          │
└──────────────────────────────────────────┘
```

### Message Stream

```dart
class ChatRepository {
  final FirebaseFirestore _firestore;

  Stream<List<Message>> watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(doc))
            .toList());
  }

  Future<void> sendMessage(String chatId, Message message) async {
    final batch = _firestore.batch();

    // Add message
    batch.set(
      _firestore.collection('chats/$chatId/messages').doc(),
      message.toFirestore(),
    );

    // Update chat metadata
    batch.update(
      _firestore.collection('chats').doc(chatId),
      {
        'lastMessage': message.text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount': FieldValue.increment(1),
      },
    );

    await batch.commit();
  }
}
```

### Chat UI

```dart
class ChatPage extends ConsumerWidget {
  final String chatId;
  const ChatPage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(chatId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return MessageBubble(
                    message: msg,
                    isMe: msg.senderId == currentUserId,
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          MessageInput(chatId: chatId),
        ],
      ),
    );
  }
}
```

---

## 4. Social Feed Scroll

### Infinite Scroll with Cached Images

```dart
class FeedPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        ref.read(feedProvider.notifier).loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text('Feed'),
          ),
          feedState.when(
            data: (posts) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= posts.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return PostCard(post: posts[index]);
                },
                childCount: posts.length + (feedState.hasMore ? 1 : 0),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### Post Card with Cached Image

```dart
class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(post.author.avatarUrl),
            ),
            title: Text(post.author.name),
            subtitle: Text(timeAgo(post.createdAt)),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),

          // Image
          if (post.imageUrl != null)
            CachedNetworkImage(
              imageUrl: post.imageUrl!,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              memCacheWidth: MediaQuery.of(context).size.width.toInt(),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(post.content),
          ),

          // Actions
          Row(
            children: [
              IconButton(
                icon: Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? Colors.red : null,
                ),
                onPressed: () {},
              ),
              Text('${post.likeCount}'),
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: () {},
              ),
              Text('${post.commentCount}'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 5. Payment Integration

### Stripe

```yaml
dependencies:
  flutter_stripe: ^11.0.0
```

```dart
class PaymentService {
  final Dio _dio;

  PaymentService(this._dio);

  Future<void> makePayment({
    required int amount,
    required String currency,
  }) async {
    // 1. Create PaymentIntent on server
    final response = await _dio.post('/create-payment-intent', data: {
      'amount': amount,
      'currency': currency,
    });

    final clientSecret = response.data['clientSecret'];

    // 2. Initialize payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'My Store',
        style: ThemeMode.system,
      ),
    );

    // 3. Present payment sheet
    await Stripe.instance.presentPaymentSheet();
    // Payment successful if no exception thrown
  }
}
```

### In-App Purchase

```yaml
dependencies:
  in_app_purchase: ^3.2.0
```

```dart
class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  void init() {
    _subscription = _iap.purchaseStream.listen(_handlePurchase);
  }

  Future<List<ProductDetails>> getProducts() async {
    final available = await _iap.isAvailable();
    if (!available) return [];

    const ids = {'premium_monthly', 'premium_yearly'};
    final response = await _iap.queryProductDetails(ids);
    return response.productDetails;
  }

  Future<void> buy(ProductDetails product) async {
    final params = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: params);
  }

  void _handlePurchase(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Verify on server
        _verifyPurchase(purchase);
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void dispose() => _subscription.cancel();
}
```

---

## 6. CI/CD Workflows

### GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0'
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: flutter analyze --fatal-infos

  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0'
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info

  build-android:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0'
      - run: flutter pub get
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: build/app/outputs/bundle/release/

  build-ios:
    runs-on: macos-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.0'
      - run: flutter pub get
      - run: flutter build ipa --release --no-codesign
```

### Codemagic

```yaml
# codemagic.yaml
workflows:
  flutter-workflow:
    name: Flutter Build
    max_build_duration: 30
    environment:
      flutter: 3.29.0
      xcode: latest
    scripts:
      - name: Get packages
        script: flutter pub get
      - name: Analyze
        script: flutter analyze
      - name: Test
        script: flutter test
      - name: Build Android
        script: flutter build appbundle --release
      - name: Build iOS
        script: flutter build ipa --release
    artifacts:
      - build/app/outputs/**/*.aab
      - build/ios/ipa/*.ipa
    publishing:
      google_play:
        credentials: $GOOGLE_PLAY_CREDENTIALS
        track: internal
      app_store_connect:
        api_key: $APP_STORE_API_KEY
```

---

## 7. Production Checklist

```
Pre-Release Checklist:

□ Performance
  □ Profile mode testing — no jank
  □ App size analysis and optimization
  □ Memory leak check in DevTools

□ Security
  □ API keys in --dart-define, not in code
  □ Certificate pinning for sensitive APIs
  □ Tokens in flutter_secure_storage
  □ Obfuscated release build
  □ ProGuard rules for Android

□ Quality
  □ > 80% test coverage
  □ All golden tests passing
  □ E2E test for critical flows
  □ Error reporting (Sentry, Crashlytics)
  □ Analytics tracking (Firebase, Mixpanel)

□ UX
  □ Loading states for all async operations
  □ Error states with retry buttons
  □ Empty states for lists
  □ Offline mode graceful degradation
  □ Accessibility labels

□ DevOps
  □ CI/CD pipeline passing
  □ Automated version bumping
  □ Changelog maintained
  □ App Store / Play Store screenshots updated
```

---

## 8. Interview Questions

### Q1: How would you architect an e-commerce Flutter app?
**A**: Clean Architecture with feature-first structure. Features: auth, products, cart, checkout, orders. State: Riverpod. Routing: GoRouter with auth guards. Networking: Dio + repository pattern. Local: Hive for cart cache, secure storage for tokens. Models: Freezed. Testing: Unit for domain, widget for UI, E2E for checkout flow.

### Q2: How do you implement real-time chat?
**A**: WebSocket or Firebase Firestore for real-time messages. Local database (Drift) for offline caching. Stream-based architecture — UI subscribes to message stream. Push notifications via FCM for background messages. Implement message queuing for poor connectivity.

### Q3: What CI/CD tools work best with Flutter?
**A**: GitHub Actions (free, flexible), Codemagic (Flutter-specialized, easier iOS signing), Bitrise, and Fastlane. Pipeline: Analyze → Test → Build → Deploy. Use `flutter analyze`, `flutter test --coverage`, and `flutter build` in sequence.

---

## 9. Resources

- [Flutter Stripe](https://pub.dev/packages/flutter_stripe)
- [In-App Purchase](https://pub.dev/packages/in_app_purchase)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Codemagic Flutter CI/CD](https://codemagic.io/)
- [GitHub Actions for Flutter](https://github.com/marketplace/actions/flutter-action)

---

[← Previous: Architecture](../12_architecture_patterns/12_architecture_patterns.md) | [Next: Advanced Topics →](../14_advanced_topics/14_advanced_topics.md) | [Back to README](../../README.md)
