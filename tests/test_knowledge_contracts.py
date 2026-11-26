#!/usr/bin/env python3
"""Static contracts for skill routing, trust, and methodology templates."""

from __future__ import annotations

import json
import re
import shutil
import sys
import tempfile
import unittest
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from claude_obsidian.lint_engine import lint_vault
from claude_obsidian.page_schema import PAGE_TYPES
from claude_obsidian.transaction import BUNDLE_SCHEMA, inspect_bundle


def _frontmatter(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    parts = text.split("---", 2)
    if len(parts) != 3:
        raise AssertionError(f"missing frontmatter: {path}")
    return parts[1]


def _description(path: Path) -> str:
    match = re.search(r"(?m)^description:\s*(.+)$", _frontmatter(path))
    if not match:
        raise AssertionError(f"missing one-line description: {path}")
    return match.group(1).strip().strip('"').casefold()


class KnowledgeContractTests(unittest.TestCase):
    def test_canvas_catalog_declared_by_skill_is_accepted_with_a_board(self) -> None:
        skill = (ROOT / "skills/canvas/SKILL.md").read_text(encoding="utf-8")
        catalogs = set(re.findall(r"`(wiki/canvases/[^`]+\.md)`", skill))
        self.assertEqual(1, len(catalogs))
        catalog = catalogs.pop()
        board = "wiki/canvases/research.canvas"
        writes = [
            {"path": board, "mode": "create", "content": '{"nodes":[],"edges":[]}'},
            {"path": catalog, "mode": "create", "content": "# Canvases\n\n[[research.canvas]]\n"},
        ]
        with tempfile.TemporaryDirectory() as directory:
            vault = Path(directory) / "vault"
            vault.mkdir()
            plan = inspect_bundle(vault, {
                "schema": BUNDLE_SCHEMA,
                "operation_id": "skill-canvas-catalog",
                "operation_type": "canvas",
                "expected_hashes": {write["path"]: None for write in writes},
                "writes": writes,
            })
            self.assertTrue(plan["valid"])
            self.assertEqual([board, catalog], plan["changed_paths"])
            self.assertEqual([], list(vault.iterdir()))

    def test_persistent_content_has_an_explicit_trust_boundary(self) -> None:
        security = (ROOT / "SECURITY.md").read_text(encoding="utf-8").casefold()
        self.assertIn("jerarquía de confianza del contenido", security)
        self.assertIn("contenido no confiable", security)

        consumers = (
            "skills/save/SKILL.md",
            "skills/wiki-ingest/SKILL.md",
            "skills/autoresearch/SKILL.md",
            "skills/wiki-query/SKILL.md",
            "agents/wiki-ingest.md",
        )
        for relative in consumers:
            text = (ROOT / relative).read_text(encoding="utf-8").casefold()
            self.assertIn("no confiable", text, relative)
            self.assertIn("incrustad", text, relative)

    def test_ambiguous_skill_routes_are_narrowed(self) -> None:
        descriptions = {
            name: _description(ROOT / "skills" / name / "SKILL.md")
            for name in (
                "save",
                "wiki-ingest",
                "wiki-query",
                "obsidian-markdown",
                "think",
                "wiki-mode",
                "wiki-lint",
            )
        }
        self.assertNotIn("add this to the wiki", descriptions["save"])
        self.assertNotIn("add this to the wiki", descriptions["wiki-ingest"])
        self.assertNotIn("agrega esto a la wiki", descriptions["save"])
        self.assertNotIn("añade esto a la wiki", descriptions["save"])
        self.assertNotIn("agrega esto a la wiki", descriptions["wiki-ingest"])
        self.assertNotIn("añade esto a la wiki", descriptions["wiki-ingest"])
        self.assertIn("contenido específico de la conversación", descriptions["save"])
        self.assertIn("material de origen", descriptions["wiki-ingest"])
        self.assertIn("explícitamente acotada a la bóveda", descriptions["wiki-query"])
        self.assertIn("no para markdown general", descriptions["obsidian-markdown"])
        self.assertIn(
            "no una revisión de salud determinista de la bóveda", descriptions["think"]
        )
        self.assertIn("no guarda contenido", descriptions["wiki-mode"])
        self.assertIn(
            "no razona en sentido amplio ni repara", descriptions["wiki-lint"]
        )

    def test_methodology_templates_include_required_page_properties(self) -> None:
        required = {"type", "methodology_role", "title", "status", "created", "updated", "tags"}
        templates = sorted((ROOT / "skills/wiki-mode/templates").glob("*/*.md"))
        self.assertEqual(6, len(templates))
        for template in templates:
            frontmatter = _frontmatter(template)
            keys = {
                line.split(":", 1)[0]
                for line in frontmatter.splitlines()
                if line and not line[0].isspace() and ":" in line
            }
            self.assertTrue(required.issubset(keys), f"{template}: {required - keys}")
            page_type = re.search(r"(?m)^type:\s*(\S+)", frontmatter)
            self.assertIsNotNone(page_type, str(template))
            self.assertIn(page_type.group(1), PAGE_TYPES, str(template))
            self.assertIn("created: {{date}}", frontmatter, str(template))
            self.assertIn("updated: {{date}}", frontmatter, str(template))
            self.assertNotRegex(frontmatter, r"(?m)^\w+:\s*\[\]\s*$")

    def test_reference_and_navigation_policies_are_routed(self) -> None:
        wiki_skill = (ROOT / "skills/wiki/SKILL.md").read_text(encoding="utf-8")
        for name in (
            "css-snippets.md",
            "frontmatter.md",
            "git-setup.md",
            "mcp-setup.md",
            "plugins.md",
            "rest-api.md",
        ):
            self.assertIn(f"references/{name}", wiki_skill)

        ingest = (ROOT / "skills/wiki-ingest/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("filtro de valor de compilación", ingest)
        self.assertIn("fuera de la bóveda seleccionada", ingest)
        self.assertIn("índice de metodología activo o MOC", ingest)
        schema = (ROOT / "WIKI.md").read_text(encoding="utf-8")
        self.assertIn("catálogo activo o MOC", schema)

    def test_capability_scopes_match_skill_boundaries(self) -> None:
        document = json.loads(
            (ROOT / "config/capabilities.json").read_text(encoding="utf-8")
        )
        capabilities = {item["id"]: item for item in document["capabilities"]}

        bases = capabilities["obsidian-bases"]
        self.assertNotIn("vault:**/*.base", bases["read_scope"])
        self.assertEqual(
            {"vault:wiki/*.base", "vault:wiki/**/*.base"},
            {item["pattern"] for item in bases["write_scope"]},
        )
        self.assertIn("vault:inbox/**", capabilities["wiki-ingest"]["read_scope"])
        self.assertIn("vault:**", capabilities["canvas"]["read_scope"])
        self.assertNotIn("vault:_attachments/**", capabilities["canvas"]["read_scope"])
        query_reason = capabilities["wiki-query"]["verification_reason"].casefold()
        self.assertIn("read-only", query_reason)
        self.assertNotIn("answer filing", query_reason)

        self.assertEqual(
            {
                "vault:.claude-obsidian.json",
                "vault:.gitignore",
                "vault:.obsidian/app.json",
                "vault:.obsidian/appearance.json",
                "vault:.obsidian/graph.json",
                "vault:.obsidian/snippets/vault-colors.css",
                "vault:.raw/.manifest.json",
                "vault:.vault-meta/address-counter.txt",
                "vault:.vault-meta/legacy-pages.txt",
                "vault:.vault-meta/tiling-thresholds.json",
                "vault:inbox/.gitkeep",
                "vault:wiki/hot.md",
                "vault:wiki/index.md",
                "vault:wiki/log.md",
                "vault:wiki/meta/ledgers/claim-ledger.json",
                "vault:wiki/meta/ledgers/source-ledger.json",
                "vault:wiki/overview.md",
            },
            {item["pattern"] for item in capabilities["wiki"]["write_scope"]},
        )

    def test_marketplace_uninstall_uses_the_declared_name(self) -> None:
        marketplace = json.loads(
            (ROOT / "config/public-marketplace.json").read_text(encoding="utf-8")
        )
        guide = (ROOT / "docs/install-guide.md").read_text(encoding="utf-8")
        self.assertIn(
            f"claude plugin marketplace remove {marketplace['name']}",
            guide,
        )
        self.assertNotIn("marketplace remove AgriciDaniel/claude-obsidian", guide)
        self.assertNotIn("marketplace remove dpratoo/segundo-cerebro", guide)

    def test_release_excludes_host_only_root_claude_context(self) -> None:
        allowlist = json.loads(
            (ROOT / "config/release-allowlist.json").read_text(encoding="utf-8")
        )
        self.assertNotIn("CLAUDE.md", allowlist["include_files"])
        is_release_artifact = (ROOT / ".claude-plugin/marketplace.json").is_file()
        self.assertEqual(not is_release_artifact, (ROOT / "CLAUDE.md").is_file())

    def test_agents_resolve_helpers_and_return_bounded_packets(self) -> None:
        lint_agent = (ROOT / "agents/wiki-lint.md").read_text(encoding="utf-8")
        self.assertIn('CORE="$PRODUCT_ROOT/scripts/claude-obsidian.py"', lint_agent)
        self.assertNotIn("python3 scripts/claude-obsidian.py", lint_agent)

        ingest_agent = (ROOT / "agents/wiki-ingest.md").read_text(encoding="utf-8")
        self.assertRegex(ingest_agent, r"(?m)^maxTurns:\s*60$")
        self.assertIn("status: complete | partial", ingest_agent)
        self.assertIn("truncado en silencio", ingest_agent)
        self.assertIn("Agrupa el trabajo independiente de descubrimiento", ingest_agent)

    def test_canvas_discloses_render_time_network_egress(self) -> None:
        skill = (ROOT / "skills/canvas/SKILL.md").read_text(encoding="utf-8")
        reference = (ROOT / "skills/canvas/references/canvas-spec.md").read_text(
            encoding="utf-8"
        )
        self.assertIn("salida de red al renderizar", skill)
        self.assertIn("Abrirlo o renderizarlo en", reference)
        self.assertIn("Obsidian puede contactar", reference)
        self.assertRegex(
            reference, r"16\s+caracteres\s+hexadecimales\s+en\s+minúsculas"
        )
        self.assertIn(
            "no prescribe una longitud ni un conjunto de caracteres", reference
        )
        self.assertIn(
            "nodo de archivo puede incluir el campo opcional `color`", reference
        )

    def test_bases_date_arithmetic_keeps_unresolved_candidates_explicit(self) -> None:
        skill = (ROOT / "skills/obsidian-bases/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("/ 86400000", skill)
        self.assertIn("Ninguna observación en la aplicación nativa", skill)
        self.assertIn("no una garantía de compatibilidad", skill)

    def test_defuddle_does_not_overstate_configured_runner_evidence(self) -> None:
        skill = (ROOT / "skills/defuddle/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("Nunca cambies la etiqueta `configured` por `verified`", skill)
        self.assertIn("ejecutable manual", skill)
        self.assertNotIn("verified executable", skill)
        self.assertNotIn("ejecutable verificado", skill)

    def test_numeric_only_tag_advice_uses_semantic_values(self) -> None:
        for relative in (
            "skills/obsidian-markdown/SKILL.md",
            "skills/wiki/references/frontmatter.md",
        ):
            text = (ROOT / relative).read_text(encoding="utf-8")
            self.assertIn("etiqueta solo numérica", text, relative)
            self.assertIn('year/2026', text, relative)
            self.assertNotIn('- "2026"', text, relative)

    def test_forward_evaluation_corpus_is_complete_and_lint_clean(self) -> None:
        corpus = json.loads(
            (ROOT / "tests/fixtures/forward/scenarios.json").read_text(encoding="utf-8")
        )
        self.assertEqual("claude-obsidian.forward-evaluations.v1", corpus["schema"])
        scenarios = {item["skill"]: item for item in corpus["scenarios"]}
        self.assertEqual({"save", "wiki-ingest", "wiki-query"}, set(scenarios))
        for scenario in scenarios.values():
            self.assertIn("hostile_quote_not_executed", scenario["invariants"])
            self.assertTrue(scenario["prompt"].strip())

        contract = json.loads(
            (ROOT / "config/product-contract.json").read_text(encoding="utf-8")
        )
        gates = {item["id"]: item for item in contract["release_gates"]}
        self.assertTrue(gates["core-workflow-forward-tests"]["required"])

        with tempfile.TemporaryDirectory() as directory:
            vault = Path(directory) / "vault"
            shutil.copytree(ROOT / "examples/sample-vault", vault)
            shutil.copy2(
                ROOT / "tests/fixtures/forward/query-evidence.md",
                vault / "wiki/sources/Aster batch policy.md",
            )
            shutil.copy2(
                ROOT / "tests/fixtures/forward/query-index.md",
                vault / "wiki/index.md",
            )
            report = lint_vault(vault, as_of=date(2026, 7, 12))
            self.assertEqual(0, report["summary"]["issues_found"], report)


if __name__ == "__main__":
    unittest.main()
