#!/bin/bash

#
# Compile protocol buffer code. Usage: bash scripts/compile.sh /absolute/path/to/out/dir
#

# Interrupt on error for addressing earlier
set -e

# To help consumer repos easier for compiling, we auto install dependencies so that
# they (consumer repos) can just call one command "yarn compile" to get the
# generated source code
yarn install --frozen-lockfile --non-interactive

outDir="$1"

gRPCLib="${2-grpc}"

rootDir=`dirname $(dirname $0)`

if [ -z "$outDir" ]; then
  outDir=`pwd`/dist
fi

# Make sure the output directory is clean before compiling.
if [ -d "$outDir" ]; then
  rm -rf $outDir
fi

mkdir $outDir &>/dev/null || true

sourceDir=$rootDir/src

executeGenCmd() {
 $rootDir/.protoc-cache/protoc/bin/protoc \
    --proto_path=$sourceDir \
    $sourceDir/*.proto "$@"
}

echo "Generating code for Node.js..."
executeGenCmd \
  --js_out=import_style=commonjs,binary:$outDir

if [ "$gRPCLib" == "grpc-js" ]; then
  # Compile gRPC to nodejs which will includes "@grpc/grpc-js" lib instead of "grpc" into compiled files
  # See why we use "@grpc/grpc-js" here https://kobiton.atlassian.net/browse/KOB-9515
  echo "Generating code for Node.js gRPC using grpc-js..."
  executeGenCmd \
    --grpc_out=grpc_js:$outDir \
    --plugin=protoc-gen-grpc=`which grpc_tools_node_protoc_plugin`
else
  # Compile gRPC to nodejs which will includes "gprc" lib into compiled files
  echo "Generating code for Node.js gRPC using grpc-node..."
  executeGenCmd \
    --grpc_out=$outDir \
    --plugin=protoc-gen-grpc=`which grpc_tools_node_protoc_plugin`
fi

echo "Copy all *.js files..."
node ./node_modules/copy/bin/cli.js "$sourceDir/**/*.js" $outDir
