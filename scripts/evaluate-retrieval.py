#!/usr/bin/env python3
"""Mide la búsqueda sin conexión, sin escribir en la bóveda de usuario seleccionada."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
PRODUCT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PRODUCT_ROOT))

from claude_obsidian.retrieval_eval import EvaluationError, IndexNotReadyError, run_fixture, run_quality


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vault", help="Bóveda seleccionada y preconstruida; la evaluación es de solo lectura")
    parser.add_argument("--queries", help="Etiquetas JSON locales y explícitas con formato retrieval-queries.v1")
    parser.add_argument("--top", type=int, default=10, help="Profundidad de la clasificación, con una profundidad medida mínima de 10")
    parser.add_argument("--fixture", action="store_true", help="Construye y evalúa el fixture original de fuentes solo dentro de un TemporaryDirectory")
    args = parser.parse_args(argv)
    if args.fixture:
        if args.vault or args.queries or args.top != 10:
            parser.error("--fixture uses its frozen labels and default depth; omit --vault, --queries, and --top")
    elif not args.vault or not args.queries:
        parser.error("provide both --vault and --queries, or use --fixture")
    try:
        report = run_fixture(PRODUCT_ROOT) if args.fixture else run_quality(args.vault, args.queries, PRODUCT_ROOT, args.top)
    except IndexNotReadyError as exc:
        print(f"RETRIEVAL_INDEX_UNAVAILABLE: {exc}", file=sys.stderr)
        return 10
    except EvaluationError as exc:
        print(f"RETRIEVAL_EVALUATION_ERROR: {exc}", file=sys.stderr)
        return 2
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
