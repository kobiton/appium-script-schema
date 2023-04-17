# appium-script-schema
The schema to communicate between ita-background-services and appium-script-generator

### Requirements

- Node.js 14+
- Yarn 1.22.4

### Compiling

- `yarn install`: Install modules for compiling protocol buffer code.
- `yarn compile [/absolute/path/to/output/dir]`: Compile .proto files to target dir. Default is `./dist`.
- The compiled js code requires `google-protobuf` module. Make sure, you add it as **production dependency** on the upstream repo (the one using compiled js code).
