#!/usr/bin/env python3
"""Construye o puntúa, sin conexión, el paquete congelado de aceptación de prompts de Query y Save."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
PRODUCT_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PRODUCT_ROOT))

from claude_obsidian.prompt_eval import (
    PromptEvaluationError,
    evaluate_response,
    generate_packet,
)


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser(
        "packet", help="Imprime un paquete vinculado a las fuentes actuales de Query y Save"
    )

    evaluate_parser = subparsers.add_parser(
        "evaluate", help="Evalúa una respuesta proporcionada sin ejecutar ningún proveedor"
    )
    evaluate_parser.add_argument("response", help="Archivo JSON estricto con formato prompt-response.v1")
    evaluate_parser.add_argument(
        "--packet",
        help="JSON prompt-packet.v1 generado antes; las fuentes actuales se vuelven a comprobar",
    )
    args = parser.parse_args(argv)
    try:
        if args.command == "packet":
            result = generate_packet(PRODUCT_ROOT)
        else:
            packet = args.packet or generate_packet(PRODUCT_ROOT)
            result = evaluate_response(
                packet, args.response, product_root=PRODUCT_ROOT
            )
    except PromptEvaluationError as exc:
        print(f"PROMPT_EVALUATION_ERROR: {exc}", file=sys.stderr)
        return 2
    print(json.dumps(result, ensure_ascii=False, indent=2))
    if args.command == "evaluate" and not result["summary"]["passed"]:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
