#!/usr/bin/env python3
import subprocess
import sys
import os

os.chdir(r'C:\Users\dell\workspace_itellJ\Desenvolvimento de Aplicações Back-End-Quarkus\MÓDULO 01 - QUARKUS\code-with-quarkus')

print("=" * 60)
print("TESTANDO BUILD DO QUARKUS")
print("=" * 60)

try:
    result = subprocess.run(
        ['mvnw.cmd', 'clean', 'compile', '-q'],
        capture_output=True,
        text=True,
        timeout=300
    )

    print(f"\nCódigo de saída: {result.returncode}")

    if result.stdout:
        print(f"\nSTDOUT:\n{result.stdout}")

    if result.stderr:
        print(f"\nSTDERR:\n{result.stderr}")

    if result.returncode == 0:
        print("\n✅ BUILD COMPILOU COM SUCESSO!")
    else:
        print("\n❌ BUILD FALHOU")
        sys.exit(1)

except Exception as e:
    print(f"Erro ao executar: {e}")
    sys.exit(1)

