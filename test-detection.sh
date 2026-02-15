#!/bin/bash

# 直接测试脚本 - 检查为什么检测失败

echo "========== 测试 V2bX 检测 =========="

# 测试路径
TEST_PATH="/usr/local/V2bX/V2bX"

echo ""
echo "1. 检查文件是否存在:"
ls -lh "$TEST_PATH"
echo ""

echo "2. 检查文件是否可执行:"
if [[ -x "$TEST_PATH" ]]; then
    echo "  ✓ 文件可执行"
else
    echo "  ✗ 文件不可执行"
fi
echo ""

echo "3. 使用 file 命令检测:"
file "$TEST_PATH"
echo ""

echo "4. 测试 grep -q \"ELF\":"
if file "$TEST_PATH" 2>/dev/null | grep -q "ELF"; then
    echo "  ✓ 匹配成功 (ELF)"
else
    echo "  ✗ 匹配失败 (ELF)"
fi
echo ""

echo "5. 测试 grep -qE \"ELF|executable\":"
if file "$TEST_PATH" 2>/dev/null | grep -qE "ELF|executable"; then
    echo "  ✓ 匹配成功 (ELF|executable)"
else
    echo "  ✗ 匹配失败 (ELF|executable)"
fi
echo ""

echo "6. 查看 file 命令的完整输出:"
file "$TEST_PATH" 2>&1
echo ""

echo "7. 测试文件头 (前4字节):"
head -c 4 "$TEST_PATH" | od -An -tx1
if head -c 4 "$TEST_PATH" 2>/dev/null | grep -q $'\x7fELF'; then
    echo "  ✓ ELF 魔数检测成功"
else
    echo "  ✗ ELF 魔数检测失败"
fi
echo ""

echo "8. 测试文件大小:"
SIZE=$(stat -c%s "$TEST_PATH" 2>/dev/null)
echo "  文件大小: $SIZE 字节"
if [[ $SIZE -gt 1048576 ]]; then
    echo "  ✓ 大于 1MB"
else
    echo "  ✗ 小于 1MB"
fi
echo ""

echo "========== 测试完成 =========="
