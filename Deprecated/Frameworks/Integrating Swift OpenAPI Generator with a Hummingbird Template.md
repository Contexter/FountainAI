# Integrating Apple’s Swift OpenAPI Generator with a Hummingbird Template

Below is a step-by-step guide showing how to **add OpenAPI-driven endpoints** to your **Hummingbird** application, using the **exact** file structure produced by the official template. Specifically:

- **`App.swift`** contains your main struct (conforming to `AsyncParsableCommand`) with command-line argument options (`hostname`, `port`, `logLevel`).  
- **`Application+build.swift`** defines the actual `buildApplication(_:)` function that assembles a Hummingbird `Application`, plus `buildRouter()` to register routes.

By following these steps, you’ll keep the original **Hello!** route, while also serving routes defined in **`openapi.yaml`** using Apple’s Swift OpenAPI Generator.

---

## 1) Existing Template Code

Your **`App.swift`** (main entry) might look like this (already provided by the template):

```swift
import ArgumentParser
import Hummingbird
import Logging

@main
struct AppCommand: AsyncParsableCommand, AppArguments {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    @Option(name: .shortAndLong)
    var logLevel: Logger.Level?

    func run() async throws {
        let app = try await buildApplication(self)
        try await app.runService()
    }
}

/// Extend `Logger.Level` so it can be used as an argument
#if hasFeature(RetroactiveAttribute)
    extension Logger.Level: @retroactive ExpressibleByArgument {}
#else
    extension Logger.Level: ExpressibleByArgument {}
#endif
```

Meanwhile, **`Application+build.swift`** handles application setup:

```swift
import Hummingbird
import Logging

/// Application arguments protocol. We use a protocol so we can call
/// `buildApplication` inside Tests as well as in the App executable. 
public protocol AppArguments {
    var hostname: String { get }
    var port: Int { get }
    var logLevel: Logger.Level? { get }
}

// Request context used by application
typealias AppRequestContext = BasicRequestContext

/// Build application
public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let environment = Environment()
    let logger = {
        var logger = Logger(label: "GhActionsProxy")
        logger.logLevel =
            arguments.logLevel ??
            environment.get("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ??
            .info
        return logger
    }()

    let router = buildRouter()
    let app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "GhActionsProxy"
        ),
        logger: logger
    )
    return app
}

/// Build router
func buildRouter() -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    // Add middleware
    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.info)
    }

    // Original “Hello!” endpoint
    router.get("/") { _, _ in
        return "Hello!"
    }

    // We'll add OpenAPI routing code here
    return router
}
```

Currently, **GET “/”** returns **“Hello!”**.

---

## 2) Add OpenAPI Dependencies

In your **`Package.swift`**, add:

1. **Apple’s Swift OpenAPI Generator** (for generating server stubs)
2. **swift-openapi-hummingbird** (to integrate those stubs with Hummingbird)

For example:

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "GhActionsProxy",  // or whatever your project is named
    platforms: [.macOS(.v12)],
    dependencies: [
        // Already used by the template
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),

        // NEW: OpenAPI Generator
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "0.2.0"),

        // NEW: Hummingbird + OpenAPI bridging
        .package(url: "https://github.com/swift-server/swift-openapi-hummingbird.git", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "GhActionsProxy",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),

                // NEW: Apple’s OpenAPI Generator + runtime
                .product(name: "SwiftOpenAPIGenerator", package: "swift-openapi-generator"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-generator"),

                // NEW: Hummingbird bridging for OpenAPI
                .product(name: "OpenAPIHummingbird", package: "swift-openapi-hummingbird"),
            ]
        )
    ]
)
```

---

## 3) Create an OpenAPI Spec (`openapi.yaml`)

Place **`openapi.yaml`** in the same folder as `Application+build.swift`, usually `Sources/GhActionsProxy/`. For example:

```yaml
openapi: 3.0.0
info:
  title: "Demo API"
  version: "1.0.0"

paths:
  /hello:
    get:
      operationId: getHello
      responses:
        '200':
          description: "Returns a friendly greeting"
          content:
            text/plain:
              schema:
                type: string
```

This declares a `GET /hello` endpoint returning a plain-text string.

---

## 4) Generate Server Code

From your **package root** (where `Package.swift` is), run:

```bash
swift package \
  plugin \
  --allow-writing-to-directory ./Sources/GhActionsProxy/Generated \
  --product SwiftOpenAPIGenerator \
  generate-server-interface \
  --input ./Sources/GhActionsProxy/openapi.yaml \
  --output ./Sources/GhActionsProxy/Generated
```

You should now have generated files in `Sources/GhActionsProxy/Generated/`, including a protocol like `MyAPIProtocol` with a `getHello(...)` method.

---

## 5) Implement the Generated Protocol

Create **`MyServerImplementation.swift`** in `Sources/GhActionsProxy/`:

```swift
import Foundation
import OpenAPIRuntime

// If Swift can't find your protocol automatically, try importing your module:
// import GhActionsProxy

struct MyServerImplementation: MyAPIProtocol {
    func getHello(context: ServerRequestContext) async throws -> String {
        // You can return any message
        return "Hello from Swift + Hummingbird + OpenAPI!"
    }
}
```

If your spec had multiple endpoints, you’d see more functions to implement.

---

## 6) Register the OpenAPI Routes

Open **`Application+build.swift`** again, locate **`buildRouter()`**, and **add** the bridging code:

```swift
import Hummingbird
import Logging
import OpenAPIRuntime      // NEW
import OpenAPIHummingbird  // NEW

public func buildRouter() -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    // Middleware
    router.addMiddleware {
        LogRequestsMiddleware(.info)
    }

    // Existing route
    router.get("/") { _, _ in
        return "Hello!"
    }

    // NEW CODE for OpenAPI
    let serverImplementation = MyServerImplementation()
    let transport = HummingbirdOpenAPIServerTransport(implementation: serverImplementation)
    do {
        try transport.registerHandlers(on: router)
    } catch {
        router.get("/_openapi_error") { _, _ in
            "Error registering OpenAPI routes: \(error)"
        }
    }

    return router
}
```

- `MyServerImplementation` is where we wrote `getHello`.  
- `HummingbirdOpenAPIServerTransport` automatically configures routes like `/hello` based on your `openapi.yaml`.

---

## 7) Build & Test

Run:

```bash
swift build
swift run
```

1. **`GET /`** should still respond with **“Hello!”**  
2. **`GET /hello`** is now mapped to `MyServerImplementation.getHello(...)`, returning your custom message.

---

## 8) (Optional) Serve Your Spec File

If you’d like to expose **`openapi.yaml`** via an endpoint (e.g., `/openapi.yaml`):

```swift
router.get("/openapi.yaml") { _, _ in
    let path = "Sources/GhActionsProxy/openapi.yaml"
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    return String(data: data, encoding: .utf8) ?? "File not found"
}
```

---

## Conclusion

1. **Add** OpenAPI dependencies to `Package.swift`.  
2. **Place** `openapi.yaml` alongside `Application+build.swift`.  
3. **Generate** server stubs with `swift-openapi-generator`.  
4. **Implement** the generated protocol in `MyServerImplementation`.  
5. **Insert** bridging code in `buildRouter()` using `HummingbirdOpenAPIServerTransport`.  
6. **Build & Run** to serve both the original “Hello!” route and any new endpoints defined in your OpenAPI spec.

By doing so, you keep the official Hummingbird template structure intact, while adding fully OpenAPI-compliant endpoints.