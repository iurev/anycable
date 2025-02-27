# Configuration

AnyCable uses [`anyway_config`](https://github.com/palkan/anyway_config) gem for configuration; thus it is possible to set configuration parameters through environment vars, `config/anycable.yml` file or `secrets.yml` when using Rails.

You can also pass configuration variables to CLI as options, e.g.:

```sh
$ bundle exec anycable --rpc-host 0.0.0.0:50120 \
                       --redis-channel my_redis_channel \
                       --log-level debug
```

**NOTE:** CLI options take precedence over parameters from other sources (files, env).

## Primary settings

Here is the list of the most commonly used configuration parameters and the way you can provide them:

- in Ruby code using parameter name (e.g. `AnyCable.config.rpc_host = "127.0.0.0:42421"`)
- in `config/anycable.yml`\* or `secrets.yml` using the parameter name
- through environment variable
- through a CLI option.

**rpc_host** (`ANYCABLE_RPC_HOST`, `--rpc-host`)

Local address to run gRPC server on (default: `"[::]:50051"`, deprecated, will be changed to `"127.0.0.1:50051"` in future versions).

**broadcast_adapter** (`ANYCABLE_BROADCAST_ADAPTER`, `--broadcast-adapter`)

[Broadcast adapter](./broadcast_adapters.md) to use. Available options out-of-the-box: `redis` (default), `nats`, `http`.

**nats_servers** (`ANYCABLE_NATS_SERVERS`, `--nats-servers`)

A comma-separated list of NATS server addresses (default: `"nats://localhost:4222"`).

**nats_channel** (`ANYCABLE_NATS_CHANNEL`, `--redis-channel`)

NATS pus/sub channel for broadcasting (default: `"__anycable__"`).

**redis_url** (`REDIS_URL`, `ANYCABLE_REDIS_URL`, `--redis-url`)

Redis URL for pub/sub (default: `"redis://localhost:6379/5"`).

**redis_channel** (`ANYCABLE_REDIS_CHANNEL`, `--redis-channel`)

Redis channel for broadcasting (default: `"__anycable__"`). When using the `redisx` adapter, it's used as a name of the Redis stream.

**redis_tls_verify** (`ANYCABLE_REDIS_TLS_VERIFY`, `--redis-tls-verify`)

Whether to validate Redis server TLS certificate if `rediss://` protocol is used (default: `false`).

**redis_tls_client_cert_path** (`ANYCABLE_REDIS_TLS_CLIENT_CERT_PATH`, `--redis-tls-client_cert-path`)

Path to file with client TLS certificate in PEM format if Redis server requires client authentication.

**redis_tls_client_key_path** (`ANYCABLE_REDIS_TLS_CLIENT_KEY_PATH`, `--redis-tls-client_key-path`)

Path to file with private key for client TLS certificate if Redis server requires client authentication.

**log_level** (`ANYCABLE_LOG_LEVEL`, `--log-level`)

Logging level (default: `"info"`).

**log_file** (`ANYCABLE_LOG_FILE`, `--log-file`)

Path to the log file. By default AnyCable logs to STDOUT.

**debug** (`ANYCABLE_DEBUG`, `--debug`)

Shortcut to turn on verbose logging ("debug" log level and gRPC logging on).

For the complete list of configuration parameters see [`config.rb`](https://github.com/anycable/anycable/blob/master/lib/anycable/config.rb) file.

\* You can change the default YML config location path by settings `ANYCABLE_CONF` env variable.

## Presets

AnyCable comes with a few built-in configuration presets for particular deployments environments, such as Fly. The presets are detected and activated automatically

To disable automatic presets activation, provide `ANYCABLE_PRESETS=none` environment variable (or pass the corresponding option to the CLI: `bundle exec anycable --presets=none`).

**NOTE:** Presets do not override explicitly provided configuration values.

### Preset: fly

Automatically activated if all of the following environment variables are defined: `FLY_APP_NAME`, `FLY_REGION`, `FLY_ALLOC_ID`.

The preset provide the following defaults:

- `rpc_host`: "0.0.0.0:50051"

If the `ANYCABLE_FLY_WS_APP_NAME` env variable is provided, the following defaults are configured as well:

- `nats_servers`: `"nats://<FLY_REGION>.<ANYCABLE_FLY_WS_APP_NAME>.internal:4222"`
- `http_broadcast_url`: `"http://<FLY_REGION>.<ANYCABLE_FLY_WS_APP_NAME>.internal:8090/_broadcast"`

## Concurrency settings

AnyCable gRPC server maintains a pool of worker threads to execute commands. We rely on the `grpc` gem [default pool size](https://github.com/grpc/grpc/blob/80e834abab5dff45e16e9a1e3b98f20eae5f91ad/src/ruby/lib/grpc/generic/rpc_server.rb#L163), which is equal to **30**.

You can configure the pool size via `rpc_pool_size` parameter (or `ANYCABLE_RPC_POOL_SIZE` env var).

Increasing pool size makes sense if you have a lot of IO operations in your channels (DB, HTTP, etc.).

**NOTE**: Make sure the gRPC pool size is aligned with concurrency limits you have in your application, such as database pool size.

**IMPORTANT**: AnyCable-Go concurrency limit must correlate to the RPC server pool size (read more in [AnyCable-Go Configuration](../anycable-go/configuration.md#concurrency-settings)).

### Redis connections

Redis broadcast adapter uses a single connection to Redis.
