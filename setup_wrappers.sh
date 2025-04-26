#!/bin/sh

mkdir -p bin

for tool in "./toolchain-$2/bin"/*; do
  base=$(basename "$tool")
  cat > "./bin/$base" <<EOF
#!/bin/sh
exec "\$(dirname "\$0")/../toolchain-$2/bin/$base" --sysroot="\$(dirname "\$0")/../sysroot/arch-$1" "\$@"
EOF
  chmod +x "./bin/$base"
done
