# MovieMatch


## Generate proto

protoc --dart_out=grpc:lib/generated -Iprotos protos/moviematch.proto

## Getting Started

Clone and start server: https://github.com/MatiasHiltunen/moviematch_server

- After server is running, you can start the app, for example with flutter run

- Project assumes that you are using android emulator and has included the emulator localhost proxy to /lib/providers/moviematch.dart: 10.0.2.2. If you are not using Android emulator, replace that with localhost

