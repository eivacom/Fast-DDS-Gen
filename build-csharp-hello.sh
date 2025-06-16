#!/bin/bash
# Build the C# Hello World project
set -e
cd "$(dirname "$0")/csharp-hello"
dotnet build csharp-hello.csproj 
