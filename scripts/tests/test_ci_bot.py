"""Run with: python3 -m unittest discover -s scripts/tests."""

import contextlib
import copy
import importlib.machinery
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch


SCRIPT = Path(__file__).resolve().parents[1] / "bin" / "ci-bot"
loader = importlib.machinery.SourceFileLoader("ci_bot", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
ci_bot = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = ci_bot
loader.exec_module(ci_bot)


class TokenTestCase(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.token_dir = self.root / "tokens"
        self.token_dir.mkdir()
        self.source = self.token_dir / "old.token"
        self.destination = self.token_dir / "new.token"
        self.source.write_bytes(b"test-token\n")
        self.source.chmod(0o600)
        self.registry = ci_bot.Registry(self.root / "repos.json")
        self.registry.data = {
            "tokens": {str(self.source): {"added_at": "original"}},
            "repos": {
                "owner/repo": {"token_file": str(self.source), "secret_name": "CUSTOM_SECRET"},
                "owner/other": {"token_file": str(self.token_dir / "other.token")},
            },
            "org_secrets": {"owner/CUSTOM_SECRET": {"token_file": str(self.source), "repos": ["repo"]}},
        }
        self.registry.save()
        self.original = copy.deepcopy(self.registry.data)
        services = ci_bot.Services(self.registry.path, None, None, ci_bot.TokenStore())
        services._registry = self.registry
        self.commands = ci_bot.Commands(services)
        self.parser = ci_bot.build_parser(self.commands)
        self.token_dir_patch = patch.object(ci_bot, "DEFAULT_TOKEN_DIR", self.token_dir)
        self.token_dir_patch.start()
        self.addCleanup(self.token_dir_patch.stop)
        registry_patch = patch.object(ci_bot, "DEFAULT_REGISTRY_PATH", self.registry.path)
        registry_patch.start()
        self.addCleanup(registry_patch.stop)

    def assert_unchanged(self):
        self.assertEqual(self.source.read_bytes(), b"test-token\n")
        self.assertEqual(self.registry.data, self.original)
        self.assertEqual(json.loads(self.registry.path.read_text()), self.original)


class TokenRegistryTests(TokenTestCase):
    def test_registering_legacy_entry_removes_redundant_metadata(self):
        self.registry.data["tokens"][str(self.source)].update(path=str(self.source), name="stale-label")
        self.registry.register_token_file(self.source)
        self.registry.save()
        saved = ci_bot.Registry(self.registry.path)
        self.assertEqual(saved.data["tokens"][str(self.source)], {"added_at": "original"})
        self.assertEqual(saved.token_label(str(self.source)), "old")

    def test_listing_selection_and_completion_discover_the_same_tokens(self):
        custom = self.token_dir / "custom.token"
        self.registry.register_token_file(custom)
        org_only = self.token_dir / "org-only.token"
        self.registry.data["org_secrets"]["owner/OTHER"] = {"token_file": str(org_only)}
        self.registry.save()

        output = io.StringIO()
        args = self.parser.parse_args(["token", "list"])
        with contextlib.redirect_stdout(output):
            args.func(args)
        listed_paths = {line.split("\t")[0] for line in output.getvalue().splitlines()}
        choices = self.commands.registered_token_choices()
        self.assertEqual(listed_paths, {str(path) for _, path in choices})
        self.assertEqual(listed_paths, {str(self.source), str(custom), str(org_only), str(self.token_dir / "other.token")})
        self.assertEqual(ci_bot.token_names_for_completion(), ["custom", "old", "org-only", "other"])
        self.assertIn((f"custom ({custom})", custom), choices)
        self.assertIn((f"org-only ({org_only})", org_only), choices)

    def test_selection_adds_default_only_when_not_already_present(self):
        self.assertEqual(len(self.commands.registered_token_choices(str(self.source))), 2)
        choices = self.commands.registered_token_choices(str(self.destination))
        self.assertEqual(len(choices), 3)
        self.assertIn((f"new ({self.destination})", self.destination), choices)

    def test_custom_paths_are_excluded_from_choices_and_completion(self):
        custom = self.root / "external.token"
        self.registry.data["tokens"][str(custom)] = {"name": "external"}
        self.registry.data["repos"]["owner/external"] = {"token_file": str(custom)}
        self.registry.save()
        self.assertNotIn(str(custom), self.registry.token_files())
        self.assertNotIn(custom, [path for _, path in self.commands.registered_token_choices(str(custom))])
        self.assertNotIn("external", ci_bot.token_names_for_completion())

    def test_store_rejects_custom_paths_before_reading_or_writing(self):
        custom = self.root / "external.token"
        custom.write_text("existing-value\n")
        for operation in (
            lambda: self.registry.register_token_file(custom),
            lambda: self.commands.services.tokens.resolve(str(custom)),
            lambda: self.commands.services.tokens.resolve_supplied("new-value", custom),
        ):
            with self.subTest(operation=operation), self.assertRaisesRegex(ci_bot.CIBotError, "Token files must use"):
                operation()
        self.assertEqual(custom.read_text(), "existing-value\n")


class TokenWriteTests(TokenTestCase):
    def test_new_and_replaced_files_have_owner_only_permissions(self):
        self.source.chmod(0o644)
        previous_umask = os.umask(0)
        try:
            for path in (self.destination, self.source):
                with self.subTest(path=path):
                    self.commands.services.tokens.write(path, "replacement")
                    self.assertEqual(path.read_text(), "replacement\n")
                    self.assertEqual(path.stat().st_mode & 0o777, 0o600)
        finally:
            os.umask(previous_umask)

    def test_failed_replace_preserves_existing_token_and_removes_temporary_file(self):
        original_files = set(self.token_dir.iterdir())
        with patch.object(Path, "replace", side_effect=PermissionError("replace denied")):
            with self.assertRaises(PermissionError):
                self.commands.services.tokens.write(self.source, "replacement")
        self.assertEqual(self.source.read_bytes(), b"test-token\n")
        self.assertEqual(set(self.token_dir.iterdir()), original_files)

    def test_failed_first_write_leaves_no_file_or_temporary_file(self):
        original_files = set(self.token_dir.iterdir())
        with patch.object(Path, "replace", side_effect=OSError("replace failed")):
            with self.assertRaises(OSError):
                self.commands.services.tokens.write(self.destination, "replacement")
        self.assertFalse(self.destination.exists())
        self.assertEqual(set(self.token_dir.iterdir()), original_files)


class FileErrorTests(TokenTestCase):
    def test_read_error_returns_failure_with_concise_message(self):
        error = PermissionError(13, "Permission denied", str(self.source))
        output = io.StringIO()
        with patch.object(Path, "read_text", side_effect=error), contextlib.redirect_stderr(output):
            status = ci_bot.main(["token", "show", "old"])
        self.assertEqual(status, 1)
        self.assertIn("File operation failed:", output.getvalue())
        self.assertIn("Permission denied", output.getvalue())
        self.assertNotIn("Traceback", output.getvalue())

    def test_write_error_returns_failure_and_preserves_token(self):
        output = io.StringIO()
        with patch.object(Path, "replace", side_effect=OSError("disk full")), contextlib.redirect_stderr(output):
            status = ci_bot.main(["token", "add", "old", "--token", "replacement"])
        self.assertEqual(status, 1)
        self.assertIn("disk full", output.getvalue())
        self.assertNotIn("Traceback", output.getvalue())
        self.assert_unchanged()


class SecretTokenSelectionTests(TokenTestCase):
    def test_named_token_reads_saved_value_without_prompting_or_writing(self):
        before = self.source.stat()
        with patch("builtins.input") as prompt, patch.object(self.commands.services.tokens, "write") as write:
            result = self.commands.resolve_secret_token("old")
        self.assertEqual(result.value, "test-token")
        self.assertEqual(result.source_path, str(self.source))
        self.assertEqual(self.source.stat().st_mtime_ns, before.st_mtime_ns)
        prompt.assert_not_called()
        write.assert_not_called()
        self.assert_unchanged()

    def test_missing_named_token_is_rejected_without_creating_or_prompting(self):
        with patch("builtins.input") as prompt:
            with self.assertRaisesRegex(ci_bot.CIBotError, "does not exist"):
                self.commands.resolve_secret_token("missing")
        prompt.assert_not_called()
        self.assertFalse((self.token_dir / "missing.token").exists())
        self.assert_unchanged()

    def test_empty_saved_token_is_rejected_without_modifying_it(self):
        self.source.write_text(" ")
        with patch("builtins.input") as prompt:
            with self.assertRaisesRegex(ci_bot.CIBotError, "empty"):
                self.commands.resolve_secret_token("old")
        prompt.assert_not_called()
        self.assertEqual(self.source.read_text(), " ")

    def test_interactive_selection_only_offers_existing_tokens(self):
        with patch.object(ci_bot.sys.stdin, "isatty", return_value=True), patch.object(ci_bot.Prompts, "choice", return_value=0) as select:
            result = self.commands.resolve_secret_token(None, str(self.source))
        select.assert_called_once_with("Select token", [f"old ({self.source})"], 1)
        self.assertEqual(result.source_path, str(self.source))
        self.assert_unchanged()

    def test_no_saved_tokens_fails_without_offering_to_create_one(self):
        self.source.unlink()
        with patch.object(ci_bot.sys.stdin, "isatty", return_value=True), patch("builtins.input") as prompt:
            with self.assertRaisesRegex(ci_bot.CIBotError, "No saved tokens"):
                self.commands.resolve_secret_token(None)
        prompt.assert_not_called()

    def test_noninteractive_selection_reuses_saved_file(self):
        with patch.object(ci_bot.sys.stdin, "isatty", return_value=False):
            result = self.commands.resolve_secret_token(None, str(self.source))
        self.assertEqual(result.value, "test-token")
        self.assertEqual(result.source_path, str(self.source))
        self.assert_unchanged()

    def test_no_selection_does_not_use_environment_or_prompt_for_value(self):
        with patch.object(ci_bot.sys.stdin, "isatty", return_value=False), patch.dict(os.environ, {"CI_BOT_TOKEN": "environment-token"}), patch("builtins.input") as prompt:
            with self.assertRaisesRegex(ci_bot.CIBotError, "Provide a saved token name"):
                self.commands.resolve_secret_token(None)
        prompt.assert_not_called()
        self.assert_unchanged()

    def test_explicit_name_overrides_registered_selection(self):
        self.destination.write_text("different-token\n")
        result = self.commands.resolve_secret_token("new", str(self.source))
        self.assertEqual(result.value, "different-token")
        self.assertEqual(result.source_path, str(self.destination))
        self.assertEqual(self.source.read_bytes(), b"test-token\n")


class InteractiveTokenSelectionTests(TokenTestCase):
    def setUp(self):
        super().setUp()
        self.commands.services.github = Mock()
        self.commands.services.copier = Mock()
        self.registry.data["org_secrets"]["owner/CUSTOM_SECRET"].update(org="owner", secret_name="CUSTOM_SECRET")

    def test_setup_can_add_token_through_shared_add_flow(self):
        args = self.parser.parse_args([
            "setup", "--repo", "owner/repo", "--source", "template", "--template-ref", "main",
            "--secret-name", "CUSTOM_SECRET", "--interactive",
        ])
        with patch.object(ci_bot.sys.stdin, "isatty", return_value=True), patch.object(ci_bot.Shell, "require"), patch.object(ci_bot, "DEFAULT_TOKEN_FILE", self.token_dir / "ci_bot.token"), patch("builtins.input", side_effect=["y", "2", "new", "new-value"]), patch.object(self.commands, "add_token", wraps=self.commands.add_token) as add:
            args.func(args)
        add.assert_called_once_with("new")
        self.assertEqual(self.destination.read_text(), "new-value\n")
        self.assertEqual(self.destination.stat().st_mode & 0o777, 0o600)
        self.assertEqual(set(self.registry.data["tokens"][str(self.destination)]), {"added_at"})
        self.commands.services.github.set_secret.assert_called_once_with("owner/repo", "CUSTOM_SECRET", "new-value")

    def test_other_selectors_only_offer_existing_tokens(self):
        commands = (
            ["token", "show"],
            ["token", "refresh", "--token", "replacement"],
            ["repo", "add", "--repo", "owner/repo", "--source", "template", "--template-ref", "main", "--secret-name", "CUSTOM_SECRET", "--path", "/checkout"],
            ["org", "add", "--org", "owner", "--repos", "repo"],
        )
        for command in commands:
            with self.subTest(command=command), patch.object(ci_bot.sys.stdin, "isatty", return_value=True), patch.object(ci_bot.Prompts, "choice", return_value=0) as select, patch("builtins.input") as prompt:
                args = self.parser.parse_args(command)
                args.func(args)
                options = select.call_args.args[1]
                self.assertEqual(options, [f"old ({self.source})"])
                prompt.assert_not_called()
                self.assertFalse(self.destination.exists())

    def test_other_commands_cannot_create_a_missing_named_token(self):
        commands = (
            ["token", "show", "missing"],
            ["token", "refresh", "missing", "replacement"],
            ["repo", "add", "--repo", "owner/repo", "--token-name", "missing", "--source", "template", "--template-ref", "main", "--secret-name", "CUSTOM_SECRET", "--path", "/checkout"],
            ["org", "add", "--org", "owner", "--repos", "repo", "--token-name", "missing"],
        )
        for command in commands:
            with self.subTest(command=command), patch.object(ci_bot.sys.stdin, "isatty", return_value=True), patch("builtins.input") as prompt:
                args = self.parser.parse_args(command)
                with self.assertRaisesRegex(ci_bot.CIBotError, "Saved token file does not exist"):
                    args.func(args)
                prompt.assert_not_called()
                self.assertFalse((self.token_dir / "missing.token").exists())


class NamedTokenCommandTests(TokenTestCase):
    def test_legacy_token_aliases_are_rejected_without_changes(self):
        for alias in ("set", "save"):
            with self.subTest(alias=alias), contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as failure:
                    ci_bot.main(["token", alias, "old"])
                self.assertEqual(failure.exception.code, 2)
                self.assert_unchanged()

    def test_registry_location_cannot_be_overridden(self):
        with contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit) as failure:
                self.parser.parse_args(["--registry-file", str(self.root / "other.json"), "repo", "list"])
        self.assertEqual(failure.exception.code, 2)
        self.assertNotIn("--registry-file", ci_bot.completion_items(["ci-bot", "--"], 1))

    def test_commands_reject_custom_path_options(self):
        prefixes = (
            ["setup"], ["token", "add", "old"], ["token", "show", "old"],
            ["token", "refresh", "old"], ["token", "rename", "old", "new"],
            ["repo", "add"], ["repo", "token"],
            ["org", "token", "--org", "owner", "--repos", "repo"],
        )
        for prefix in prefixes:
            with self.subTest(command=prefix), contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as failure:
                    self.parser.parse_args([*prefix, "--token-file", str(self.source)])
                self.assertEqual(failure.exception.code, 2)

    def test_add_saves_and_registers_named_file(self):
        args = self.parser.parse_args(["token", "add", "new", "--token", "new-value"])
        args.func(args)
        self.assertEqual(self.destination.read_text(), "new-value\n")
        self.assertEqual(set(self.registry.data["tokens"][str(self.destination)]), {"added_at"})

    def test_setup_and_repo_and_org_commands_use_named_token(self):
        self.commands.services.github = Mock()
        self.commands.services.copier = Mock()
        commands = (
            ["setup", "--repo", "owner/repo"],
            ["repo", "add", "--repo", "owner/repo"],
            ["repo", "token", "--repo", "owner/repo"],
            ["org", "token", "--org", "owner", "--repos", "repo"],
        )
        for command in commands:
            with self.subTest(command=command), patch.object(ci_bot.sys.stdin, "isatty", return_value=False), patch.object(ci_bot.Shell, "require"), patch("builtins.input") as prompt:
                selection = ["--token-name", "old"] if command[0] == "setup" or command[1] == "add" else ["old"]
                args = self.parser.parse_args([*command, *selection])
                args.func(args)
                prompt.assert_not_called()
                self.assertEqual(self.registry.repo("owner/repo").token_file, str(self.source))
        self.commands.services.copier.apply.assert_called_once()
        self.assertEqual(self.commands.services.github.set_secret.call_count, 2)
        self.commands.services.github.set_org_secret.assert_called_once()

    def test_token_name_cannot_be_a_path(self):
        for name in ("../external", "/tmp/external", "nested/name"):
            with self.subTest(name=name), self.assertRaises(ci_bot.CIBotError):
                ci_bot.token_file_for_name(name)


class OrgCommandTests(TokenTestCase):
    def setUp(self):
        super().setUp()
        self.commands.services.github = Mock()
        self.registry.data["org_secrets"]["owner/CUSTOM_SECRET"].update(org="owner", secret_name="CUSTOM_SECRET")
        self.registry.data["repos"]["owner/repo"].update(secret_scope="org", secret_org="owner", path="/checkout/repo")
        self.registry.save()

    def run_org(self, *arguments):
        args = self.parser.parse_args(["org", *arguments])
        with patch.object(ci_bot.sys.stdin, "isatty", return_value=False):
            args.func(args)

    def test_list_shows_registered_organizations_and_secret_details(self):
        self.registry.upsert_org_secret("another", "OTHER", str(self.source), ["first", "second"])
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.run_org("list")
        self.assertEqual(output.getvalue().splitlines(), [
            "another\tsecrets=OTHER\ttokens=old\t2 repo(s)",
            "owner\tsecrets=CUSTOM_SECRET\ttokens=old\t1 repo(s)",
        ])
        self.commands.services.github.assert_not_called()

    def test_list_handles_empty_registry(self):
        self.registry.data = {"repos": {}, "org_secrets": {}, "tokens": {}}
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.run_org("list")
        self.assertEqual(output.getvalue(), "No organizations registered.\n")

    def test_add_registers_org_and_repos_without_updating_github(self):
        self.run_org("add", "--org", "owner", "--repos", "repo,owner/second", "--secret-name", "CUSTOM_SECRET", "--token-name", "old")
        saved = json.loads(self.registry.path.read_text())
        secret = saved["org_secrets"]["owner/CUSTOM_SECRET"]
        self.assertEqual(secret["repos"], ["repo", "second"])
        self.assertEqual(secret["token_file"], str(self.source))
        self.assertEqual(saved["repos"]["owner/second"]["secret_org"], "owner")
        self.assertEqual(saved["repos"]["owner/repo"]["path"], "/checkout/repo")
        self.assertNotIn("last_token_refresh_at", secret)
        self.assertEqual(self.commands.services.github.mock_calls, [])
        self.assertEqual(self.source.read_bytes(), b"test-token\n")

    def test_add_preserves_independent_org_secrets(self):
        self.run_org("add", "--org", "owner", "--repos", "second", "--secret-name", "OTHER", "--token-name", "old")
        self.assertEqual(set(self.registry.data["org_secrets"]), {"owner/CUSTOM_SECRET", "owner/OTHER"})

    def test_add_keeps_all_repos_consistent_when_secret_token_changes(self):
        self.destination.write_text("another-token\n")
        self.run_org("add", "--org", "owner", "--repos", "second", "--secret-name", "CUSTOM_SECRET", "--token-name", "new")
        secret = self.registry.data["org_secrets"]["owner/CUSTOM_SECRET"]
        self.assertEqual(secret["repos"], ["repo", "second"])
        self.assertEqual(secret["token_file"], str(self.destination))
        for repo in ("owner/repo", "owner/second"):
            self.assertEqual(self.registry.repo(repo).token_file, str(self.destination))

    def test_remove_detaches_org_secrets_and_preserves_checkout_settings(self):
        self.registry.upsert_org_secret("another", "OTHER", str(self.source), ["first"])
        self.run_org("remove", "--org", "owner")
        saved = json.loads(self.registry.path.read_text())
        self.assertNotIn("owner/CUSTOM_SECRET", saved["org_secrets"])
        self.assertIn("another/OTHER", saved["org_secrets"])
        repo = saved["repos"]["owner/repo"]
        self.assertEqual(repo["path"], "/checkout/repo")
        for field in ("secret_org", "secret_scope", "token_file", "last_token_refresh_at"):
            self.assertNotIn(field, repo)
        self.assertEqual(saved["repos"]["owner/other"]["token_file"], str(self.token_dir / "other.token"))
        self.assertIn(str(self.source), saved["tokens"])
        self.assertEqual(self.commands.services.github.mock_calls, [])

    def test_remove_handles_legacy_repo_org_association(self):
        self.registry.data["org_secrets"].clear()
        self.registry.data["repos"]["owner/repo"].pop("secret_org")
        self.run_org("remove", "--org", "owner")
        self.assertEqual(self.registry.org_names(), [])
        self.assertNotIn("token_file", self.registry.data["repos"]["owner/repo"])

    def test_remove_rejects_unknown_org_without_changes(self):
        original = copy.deepcopy(self.registry.data)
        with self.assertRaisesRegex(ci_bot.CIBotError, "not registered"):
            self.run_org("remove", "--org", "missing")
        self.assertEqual(self.registry.data, original)

    def test_rename_updates_secret_keys_repo_slugs_and_org_references(self):
        self.registry.upsert_org_secret("owner", "OTHER", str(self.source), ["second"])
        self.run_org("rename", "owner", "renamed")
        saved = json.loads(self.registry.path.read_text())
        self.assertEqual(set(saved["org_secrets"]), {"renamed/CUSTOM_SECRET", "renamed/OTHER"})
        self.assertEqual(saved["org_secrets"]["renamed/CUSTOM_SECRET"]["org"], "renamed")
        self.assertEqual(saved["org_secrets"]["renamed/CUSTOM_SECRET"]["repos"], ["repo"])
        self.assertEqual(set(saved["repos"]), {"renamed/repo", "renamed/other"})
        self.assertEqual(saved["repos"]["renamed/repo"]["secret_org"], "renamed")
        self.assertEqual(saved["repos"]["renamed/repo"]["path"], "/checkout/repo")
        self.assertEqual(self.commands.services.github.mock_calls, [])

    def test_refresh_uses_renamed_org(self):
        self.run_org("rename", "owner", "renamed")
        args = self.parser.parse_args(["token", "refresh", "old", "replacement"])
        args.func(args)
        self.commands.services.github.set_org_secret.assert_called_once_with("renamed", "CUSTOM_SECRET", "replacement", ["repo"], "selected")
        self.commands.services.github.set_secret.assert_not_called()

    def test_rename_preflights_conflicts_before_mutating_registry(self):
        for conflict in ("same", "missing", "organization", "repository"):
            with self.subTest(conflict=conflict):
                original = copy.deepcopy(self.registry.data)
                if conflict == "organization":
                    self.registry.upsert_org_secret("renamed", "OTHER", str(self.source), ["first"])
                elif conflict == "repository":
                    self.registry.data["repos"]["renamed/repo"] = {"secret_scope": "repo"}
                before = copy.deepcopy(self.registry.data)
                old = "missing" if conflict == "missing" else "owner"
                new = "owner" if conflict == "same" else "renamed"
                with self.assertRaises(ci_bot.CIBotError):
                    self.run_org("rename", old, new)
                self.assertEqual(self.registry.data, before)
                self.registry.data = original

    def test_org_completion_includes_management_commands_and_token_names(self):
        completions = ci_bot.completion_items(["ci-bot", "org", ""], 2)
        for command in ("list", "add", "remove", "rename", "token"):
            self.assertIn(command, completions)
        self.assertIn("--token-name", ci_bot.completion_items(["ci-bot", "org", "add", "--"], 3))
        self.assertEqual(ci_bot.completion_items(["ci-bot", "org", "remove", "--"], 3), ["--org"])
        with patch.object(ci_bot, "DEFAULT_REGISTRY_PATH", self.registry.path):
            self.assertEqual(ci_bot.completion_items(["ci-bot", "org", "add", "--token-name", ""], 4), ["old", "other"])

    def test_token_reuses_the_only_registered_secret_and_its_repositories(self):
        self.run_org("token", "old", "--org", "owner")
        self.commands.services.github.set_org_secret.assert_called_once_with("owner", "CUSTOM_SECRET", "test-token", ["repo"])
        self.assertEqual(self.source.read_bytes(), b"test-token\n")

    def test_token_keeps_user_repos_and_other_orgs_separate(self):
        personal = {"secret_scope": "repo", "token_file": str(self.source), "path": "/personal/checkout"}
        self.registry.data["repos"]["personal/repo"] = copy.deepcopy(personal)
        self.registry.register_org_secret("another", "OTHER", str(self.source), ["different"])
        other_secret = copy.deepcopy(self.registry.data["org_secrets"]["another/OTHER"])
        self.run_org("token", "old", "--org", "owner")
        self.commands.services.github.set_org_secret.assert_called_once_with("owner", "CUSTOM_SECRET", "test-token", ["repo"])
        self.commands.services.github.set_secret.assert_not_called()
        self.assertEqual(self.registry.data["repos"]["personal/repo"], personal)
        self.assertEqual(self.registry.data["org_secrets"]["another/OTHER"], other_secret)

    def test_multiple_registered_secrets_require_explicit_selection(self):
        self.registry.register_org_secret("owner", "OTHER", str(self.source), ["second"])
        with self.assertRaisesRegex(ci_bot.CIBotError, "multiple registered secrets"):
            self.run_org("token", "old", "--org", "owner")
        self.assertEqual(self.commands.services.github.mock_calls, [])
        self.run_org("token", "old", "--org", "owner", "--secret-name", "OTHER")
        self.commands.services.github.set_org_secret.assert_called_once_with("owner", "OTHER", "test-token", ["second"])
        self.assertEqual(self.registry.data["org_secrets"]["owner/CUSTOM_SECRET"]["repos"], ["repo"])

    def test_repository_override_replaces_saved_access_and_detaches_removed_repos(self):
        self.registry.data["repos"]["owner/independent"] = {"secret_scope": "repo", "token_file": str(self.source)}
        self.run_org("token", "old", "--org", "owner", "--repos", "second")
        self.commands.services.github.set_org_secret.assert_called_once_with("owner", "CUSTOM_SECRET", "test-token", ["second"])
        saved = json.loads(self.registry.path.read_text())
        self.assertEqual(saved["org_secrets"]["owner/CUSTOM_SECRET"]["repos"], ["second"])
        self.assertEqual(saved["repos"]["owner/repo"]["path"], "/checkout/repo")
        self.assertNotIn("token_file", saved["repos"]["owner/repo"])
        self.assertEqual(saved["repos"]["owner/second"]["secret_scope"], "org")
        self.assertEqual(saved["repos"]["owner/independent"]["secret_scope"], "repo")
        self.assertEqual(saved["repos"]["owner/independent"]["token_file"], str(self.source))
        self.commands.services.github.reset_mock()
        self.run_org("token", "old", "--org", "owner")
        self.commands.services.github.set_org_secret.assert_called_once_with("owner", "CUSTOM_SECRET", "test-token", ["second"])

    def test_missing_registered_repositories_require_an_explicit_list(self):
        original = copy.deepcopy(self.registry.data)
        with self.assertRaisesRegex(ci_bot.CIBotError, "provide --repos"):
            self.run_org("token", "old", "--org", "unregistered")
        self.assertEqual(self.registry.data, original)
        self.assertEqual(self.commands.services.github.mock_calls, [])

    def test_unregistered_org_with_explicit_repos_uses_default_secret_name(self):
        self.run_org("token", "old", "--org", "fresh", "--repos", "first,second")
        self.commands.services.github.set_org_secret.assert_called_once_with("fresh", "CI_BOT_TOKEN", "test-token", ["first", "second"])

    def test_token_can_reuse_registered_token_when_name_is_omitted(self):
        self.run_org("token", "--org", "owner")
        self.commands.services.github.set_org_secret.assert_called_once_with("owner", "CUSTOM_SECRET", "test-token", ["repo"])

    def test_repository_override_rejects_other_owners(self):
        with self.assertRaises(ci_bot.CIBotError):
            self.run_org("token", "old", "--org", "owner", "--repos", "personal/repo")
        self.assertEqual(self.commands.services.github.mock_calls, [])


class RepositoryScopeTests(TokenTestCase):
    def test_setup_and_repo_add_reject_organization_options(self):
        for command in (["setup"], ["repo", "add"]):
            for option in (["--secret-scope", "org"], ["--org", "owner"]):
                with self.subTest(command=command, option=option), contextlib.redirect_stderr(io.StringIO()):
                    with self.assertRaises(SystemExit) as failure:
                        self.parser.parse_args([*command, *option])
                    self.assertEqual(failure.exception.code, 2)

    def test_setup_and_repo_add_completion_omit_organization_options(self):
        for command in (["setup"], ["repo", "add"]):
            with self.subTest(command=command):
                words = ["ci-bot", *command, "--"]
                options = ci_bot.completion_items(words, len(words) - 1)
                self.assertNotIn("--secret-scope", options)
                self.assertNotIn("--org", options)
                self.assertIn("--token-name", options)

    def test_setup_and_repo_add_replace_stale_org_scope_with_repo_scope(self):
        self.commands.services.github = Mock()
        self.commands.services.copier = Mock()
        original_org_secrets = copy.deepcopy(self.registry.data["org_secrets"])
        for command in (["setup"], ["repo", "add"]):
            with self.subTest(command=command):
                self.registry.data["repos"]["owner/repo"].update(secret_scope="org", secret_org="owner")
                self.commands.services.github.reset_mock()
                args = self.parser.parse_args([*command, "--repo", "owner/repo", "--token-name", "old", "--secret-name", "CUSTOM_SECRET"])
                with patch.object(ci_bot.sys.stdin, "isatty", return_value=False), patch.object(ci_bot.Shell, "require"):
                    args.func(args)
                saved = json.loads(self.registry.path.read_text())
                self.assertEqual(saved["repos"]["owner/repo"]["secret_scope"], "repo")
                self.assertNotIn("secret_org", saved["repos"]["owner/repo"])
                self.assertEqual(saved["org_secrets"], original_org_secrets)
                self.commands.services.github.set_org_secret.assert_not_called()
                if command[0] == "setup":
                    self.commands.services.github.set_secret.assert_called_once_with("owner/repo", "CUSTOM_SECRET", "test-token")
                else:
                    self.commands.services.github.set_secret.assert_not_called()


class RepoTokenTests(TokenTestCase):
    def test_repo_token_sets_repo_secret_when_saved_scope_is_org(self):
        self.registry.data["repos"]["owner/repo"].update(secret_scope="org", secret_org="owner")
        original_org_secrets = copy.deepcopy(self.registry.data["org_secrets"])
        self.commands.services.github = Mock()
        args = self.parser.parse_args(["repo", "token", "old", "--repo", "owner/repo"])
        with patch.object(ci_bot.sys.stdin, "isatty", return_value=False):
            args.func(args)
        self.commands.services.github.set_secret.assert_called_once_with("owner/repo", "CUSTOM_SECRET", "test-token")
        self.commands.services.github.set_org_secret.assert_not_called()
        saved = json.loads(self.registry.path.read_text())
        self.assertEqual(saved["repos"]["owner/repo"]["secret_scope"], "repo")
        self.assertNotIn("secret_org", saved["repos"]["owner/repo"])
        self.assertEqual(saved["org_secrets"], original_org_secrets)

    def test_repo_token_rejects_org_options(self):
        for option in (["--secret-scope", "org"], ["--org", "owner"]):
            with self.subTest(option=option), contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as failure:
                    self.parser.parse_args(["repo", "token", "--repo", "owner/repo", *option])
                self.assertEqual(failure.exception.code, 2)

    def test_repo_token_completion_omits_org_options(self):
        options = ci_bot.completion_items(["ci-bot", "repo", "token", "--"], 3)
        self.assertNotIn("--secret-scope", options)
        self.assertNotIn("--org", options)
        self.assertIn("--secret-name", options)
        self.assertNotIn("--token-name", options)
        self.assertNotIn("--token", options)

    def test_repo_and_org_token_apply_saved_value_without_changing_file(self):
        commands = (
            ["repo", "token", "old", "--repo", "owner/repo"],
            ["org", "token", "old", "--org", "owner", "--repos", "repo"],
        )
        for command in commands:
            with self.subTest(command=command):
                self.commands.services.github = Mock()
                before = self.source.stat()
                args = self.parser.parse_args(command)
                with patch.object(ci_bot.sys.stdin, "isatty", return_value=False), patch("builtins.input") as prompt:
                    args.func(args)
                prompt.assert_not_called()
                self.assertEqual(self.source.read_bytes(), b"test-token\n")
                self.assertEqual(self.source.stat().st_mtime_ns, before.st_mtime_ns)
                github = self.commands.services.github
                if command[0] == "repo":
                    github.set_secret.assert_called_once_with("owner/repo", "CUSTOM_SECRET", "test-token")
                else:
                    github.set_org_secret.assert_called_once_with("owner", "CUSTOM_SECRET", "test-token", ["repo"])

    def test_repo_and_org_token_reject_value_and_legacy_name_options(self):
        commands = (["repo", "token"], ["org", "token", "--org", "owner", "--repos", "repo"])
        for command in commands:
            for extra in (["--token", "value"], ["--token-name", "old"], ["old", "new-value"]):
                with self.subTest(command=command, extra=extra), contextlib.redirect_stderr(io.StringIO()):
                    with self.assertRaises(SystemExit) as failure:
                        self.parser.parse_args([*command, *extra])
                    self.assertEqual(failure.exception.code, 2)


class TokenRenameTests(TokenTestCase):
    def rename(self, *arguments):
        args = self.parser.parse_args(["token", "rename", *arguments])
        args.func(args)

    def test_rename_reads_legacy_metadata_and_saves_compact_entry(self):
        self.registry.data["tokens"][str(self.source)].update(path=str(self.source), name="stale-label")
        self.rename("old", "new")
        self.assertEqual(self.registry.data["tokens"], {str(self.destination): {"added_at": "original"}})
        self.assertEqual(ci_bot.Registry(self.registry.path).data["tokens"], self.registry.data["tokens"])

    def test_rename_updates_all_references_and_preserves_metadata(self):
        self.rename("old", "new")
        self.assertFalse(self.source.exists())
        self.assertEqual(self.destination.read_bytes(), b"test-token\n")
        self.assertEqual(self.destination.stat().st_mode & 0o777, 0o600)
        saved = json.loads(self.registry.path.read_text())
        self.assertNotIn(str(self.source), saved["tokens"])
        self.assertEqual(saved["tokens"][str(self.destination)], {
            "added_at": "original",
        })
        self.assertEqual(saved["repos"]["owner/repo"]["token_file"], str(self.destination))
        self.assertEqual(saved["org_secrets"]["owner/CUSTOM_SECRET"]["token_file"], str(self.destination))
        self.assertEqual(saved["repos"]["owner/other"], self.original["repos"]["owner/other"])
        self.assertEqual(saved["repos"]["owner/repo"]["secret_name"], "CUSTOM_SECRET")

    def test_rename_prompts_for_omitted_new_name(self):
        with patch("builtins.input", return_value="new") as prompt:
            self.rename("old")
        prompt.assert_called_once_with("New token name: ")
        self.assertFalse(self.source.exists())
        self.assertEqual(self.destination.read_bytes(), b"test-token\n")
        self.assertEqual(set(self.registry.data["tokens"][str(self.destination)]), {"added_at"})

    def test_rename_rejects_empty_prompted_name(self):
        with patch("builtins.input", return_value=" "):
            with self.assertRaisesRegex(ci_bot.CIBotError, "empty"):
                self.rename("old")
        self.assert_unchanged()

    def test_existing_destination_is_not_overwritten(self):
        self.destination.write_bytes(b"another-token\n")
        with self.assertRaisesRegex(ci_bot.CIBotError, "already exists"):
            self.rename("old", "new")
        self.assert_unchanged()
        self.assertEqual(self.destination.read_bytes(), b"another-token\n")

    def test_dangling_symlink_is_not_overwritten(self):
        self.destination.symlink_to(self.root / "missing")
        with self.assertRaisesRegex(ci_bot.CIBotError, "already exists"):
            self.rename("old", "new")
        self.assert_unchanged()
        self.assertTrue(self.destination.is_symlink())

    def test_registered_destination_without_file_is_rejected(self):
        self.registry.data["repos"]["owner/other"]["token_file"] = str(self.destination)
        with self.assertRaisesRegex(ci_bot.CIBotError, "already registered"):
            self.rename("old", "new")
        self.assertTrue(self.source.exists())
        self.assertFalse(self.destination.exists())

    def test_missing_source_is_rejected(self):
        self.source.unlink()
        with self.assertRaisesRegex(ci_bot.CIBotError, "does not exist"):
            self.rename("old", "new")
        self.assertEqual(self.registry.data, self.original)

    def test_missing_source_is_rejected_before_prompting(self):
        self.source.unlink()
        with patch("builtins.input") as prompt:
            with self.assertRaisesRegex(ci_bot.CIBotError, "does not exist"):
                self.rename("old")
        prompt.assert_not_called()

    def test_store_rename_does_not_prompt(self):
        with patch("builtins.input") as prompt:
            self.commands.services.tokens.rename(self.registry, self.source, "new")
        prompt.assert_not_called()
        self.assertFalse(self.source.exists())
        self.assertEqual(self.destination.read_bytes(), b"test-token\n")
        saved = json.loads(self.registry.path.read_text())
        self.assertEqual(saved["repos"]["owner/repo"]["token_file"], str(self.destination))

    def test_source_referenced_only_by_org_secret_is_supported(self):
        self.registry.data["tokens"].clear()
        self.registry.data["repos"].clear()
        self.rename("old", "new")
        self.assertEqual(self.registry.data["org_secrets"]["owner/CUSTOM_SECRET"]["token_file"], str(self.destination))
        self.assertEqual(set(self.registry.data["tokens"][str(self.destination)]), {"added_at"})

    def test_unregistered_source_is_rejected(self):
        self.registry.data = {"tokens": {}, "repos": {}, "org_secrets": {}}
        with self.assertRaisesRegex(ci_bot.CIBotError, "not registered"):
            self.rename("old", "new")
        self.assertTrue(self.source.exists())
        self.assertFalse(self.destination.exists())

    def test_invalid_name_is_rejected(self):
        with self.assertRaises(ci_bot.CIBotError):
            self.rename("old", "../new")
        self.assert_unchanged()

    def test_failed_registry_replace_restores_file_and_registry(self):
        with patch.object(Path, "replace", side_effect=OSError("save failed")):
            with self.assertRaisesRegex(ci_bot.CIBotError, "save failed"):
                self.rename("old", "new")
        self.assert_unchanged()
        self.assertFalse(self.destination.exists())


class TokenRefreshTests(TokenTestCase):
    def refresh(self, *arguments):
        self.commands.services.tokens = ci_bot.TokenStore()
        self.commands.services.github = Mock()
        self.registry.data["org_secrets"]["owner/CUSTOM_SECRET"].update(org="owner", secret_name="CUSTOM_SECRET")
        args = self.parser.parse_args(["token", "refresh", *arguments])
        args.func(args)
        return self.commands.services.github

    def test_refresh_prompts_directly_and_updates_repo_and_org_secrets(self):
        with patch("builtins.input", return_value="  replacement-token  ") as prompt:
            github = self.refresh("old")
        prompt.assert_called_once_with("Enter CI token: ")
        self.assertEqual(self.source.read_text(), "replacement-token\n")
        github.set_secret.assert_called_once_with("owner/repo", "CUSTOM_SECRET", "replacement-token")
        github.set_org_secret.assert_called_once_with("owner", "CUSTOM_SECRET", "replacement-token", ["repo"], "selected")
        saved = json.loads(self.registry.path.read_text())
        self.assertTrue(saved["repos"]["owner/repo"]["last_token_refresh_at"])
        self.assertTrue(saved["org_secrets"]["owner/CUSTOM_SECRET"]["last_token_refresh_at"])

    def test_refresh_inline_value_skips_prompt(self):
        with patch("builtins.input") as prompt:
            github = self.refresh("old", "--token", "inline-token")
        prompt.assert_not_called()
        self.assertEqual(self.source.read_text(), "inline-token\n")
        github.set_secret.assert_called_once_with("owner/repo", "CUSTOM_SECRET", "inline-token")

    def test_refresh_positional_value_skips_prompt(self):
        with patch("builtins.input") as prompt:
            github = self.refresh("old", "positional-token")
        prompt.assert_not_called()
        self.assertEqual(self.source.read_text(), "positional-token\n")
        github.set_secret.assert_called_once_with("owner/repo", "CUSTOM_SECRET", "positional-token")

    def test_refresh_rejects_conflicting_value_arguments(self):
        with patch("builtins.input") as prompt:
            with self.assertRaisesRegex(ci_bot.CIBotError, "not both"):
                self.refresh("old", "positional-token", "--token", "flag-token")
        prompt.assert_not_called()
        self.assertEqual(self.source.read_bytes(), b"test-token\n")

    def test_refresh_uses_filename_instead_of_stale_label(self):
        self.registry.data["tokens"][str(self.source)]["name"] = "althack"
        with patch("builtins.input", return_value="replacement-token"):
            self.refresh("old")
        self.assertEqual(self.source.read_text(), "replacement-token\n")
        self.assertFalse((self.token_dir / "althack.token").exists())

    def test_refresh_empty_value_preserves_existing_token(self):
        with patch("builtins.input", return_value="  "):
            with self.assertRaisesRegex(ci_bot.CIBotError, "empty"):
                self.refresh("old")
        self.assertEqual(self.source.read_bytes(), b"test-token\n")
        self.commands.services.github.set_secret.assert_not_called()
        self.commands.services.github.set_org_secret.assert_not_called()

    def test_refresh_without_targets_does_not_prompt_or_write(self):
        unassociated = self.token_dir / "unknown.token"
        unassociated.write_text("unassociated-token\n")
        with patch("builtins.input") as prompt:
            with self.assertRaisesRegex(ci_bot.CIBotError, "No registered repos"):
                self.refresh("unknown")
        prompt.assert_not_called()
        self.assertEqual(unassociated.read_text(), "unassociated-token\n")


class TokenShowTests(TokenTestCase):
    def test_show_uses_filename_instead_of_stale_label(self):
        self.registry.data["tokens"][str(self.source)]["name"] = "althack"
        output = io.StringIO()
        args = self.parser.parse_args(["token", "show", "old"])
        with patch("builtins.input") as prompt, contextlib.redirect_stdout(output):
            args.func(args)
        prompt.assert_not_called()
        self.assertEqual(output.getvalue(), "test-token\n")


class TokenCompletionTests(TokenTestCase):
    def test_completion_includes_rename(self):
        self.assertIn("rename", ci_bot.completion_items(["ci-bot", "token", ""], 2))

    def complete(self, *arguments):
        words = ["ci-bot", "token", "rename", *arguments]
        return ci_bot.completion_items(words, len(words) - 1)

    def test_completion_suggests_old_names_only(self):
        self.assertEqual(self.complete(""), ["old", "other"])
        self.assertEqual(self.complete("ol"), ["old", "other"])
        self.assertEqual(self.complete("old", ""), [])

    def test_completion_uses_default_registry(self):
        with patch.object(ci_bot, "DEFAULT_REGISTRY_PATH", self.registry.path):
            self.assertEqual(ci_bot.completion_items(["ci-bot", "token", "rename", ""], 3), ["old", "other"])

    def test_completion_includes_unnamed_referenced_tokens(self):
        self.registry.data["tokens"].clear()
        self.registry.data["org_secrets"]["owner/OTHER"] = {"token_file": str(self.token_dir / "org.token")}
        self.registry.save()
        self.assertEqual(self.complete(""), ["old", "org", "other"])

    def test_completion_handles_missing_or_invalid_registry(self):
        self.registry.path.unlink()
        self.assertEqual(self.complete(""), [])
        self.assertFalse(self.registry.path.exists())
        self.registry.path.write_text("invalid json")
        self.assertEqual(self.complete(""), [])

    def test_all_existing_token_arguments_complete_names(self):
        with patch.object(ci_bot, "DEFAULT_REGISTRY_PATH", self.registry.path):
            for command in ("refresh", "rename", "show"):
                with self.subTest(command=command):
                    words = ["ci-bot", "token", command, ""]
                    self.assertEqual(ci_bot.completion_items(words, 3), ["old", "other"])
                    words = ["ci-bot", "token", command, "old", ""]
                    self.assertEqual(ci_bot.completion_items(words, 4), [])

    def test_refresh_name_completion(self):
        with patch.object(ci_bot, "DEFAULT_REGISTRY_PATH", self.registry.path):
            self.assertEqual(ci_bot.completion_items(["ci-bot", "token", "refresh", ""], 3), ["old", "other"])
            self.assertEqual(ci_bot.completion_items(["ci-bot", "token", "refresh", "ol"], 3), ["old", "other"])
            self.assertEqual(ci_bot.completion_items(["ci-bot", "token", "refresh", "old", ""], 4), [])
            words = ["ci-bot", "token", "refresh", "--token", "value", ""]
            self.assertEqual(ci_bot.completion_items(words, 5), ["old", "other"])

    def test_token_name_option_completes_names(self):
        for command in (["setup"], ["repo", "add"], ["org", "add"]):
            with self.subTest(command=command):
                words = ["ci-bot", *command, "--token-name", ""]
                self.assertEqual(ci_bot.completion_items(words, len(words) - 1), ["old", "other"])

    def test_repo_and_org_token_complete_existing_positional_names(self):
        for command in (["repo", "token"], ["org", "token"]):
            with self.subTest(command=command):
                words = ["ci-bot", *command, ""]
                self.assertEqual(ci_bot.completion_items(words, len(words) - 1), ["old"])
                words = ["ci-bot", *command, "old", ""]
                self.assertEqual(ci_bot.completion_items(words, len(words) - 1), [])


class BashCompletionTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        registry_path = self.root / ".config" / "ci_bot" / "repos.json"
        registry_path.parent.mkdir(parents=True)
        token_dir = self.root / ".config" / "tokens"
        token_dir.mkdir(parents=True)
        self.names = ["alpha", "alpha_ci", "work-bot"]
        for name in self.names:
            (token_dir / f"{name}.token").write_text("saved-value\n")
        registry_path.write_text(json.dumps({
            "tokens": {str(token_dir / f"{name}.token"): {"added_at": "original"} for name in self.names},
        }))
        self.environment = {
            **os.environ, "HOME": str(self.root), "CI_BOT_TEST_PYTHON": sys.executable,
            "CI_BOT_TEST_SCRIPT": str(SCRIPT),
        }
        self.environment.pop("_CI_BOT_COMPLETE", None)

    def complete(self, *arguments):
        script = r'''
ci-bot() { "$CI_BOT_TEST_PYTHON" "$CI_BOT_TEST_SCRIPT" "$@"; }
eval "$(_CI_BOT_COMPLETE=bash_source ci-bot)"
COMP_WORDS=("$@")
COMP_CWORD=$((${#COMP_WORDS[@]} - 1))
_ci_bot_completion
if ((${#COMPREPLY[@]})); then printf '%s\0' "${COMPREPLY[@]}"; fi
'''
        result = subprocess.run(
            ["bash", "--noprofile", "--norc", "-c", script, "completion-test", "ci-bot", *arguments],
            env=self.environment, check=True, capture_output=True,
        )
        self.assertEqual(result.stderr, b"")
        return [item.decode() for item in result.stdout.split(b"\0") if item]

    def test_saved_token_names_and_prefixes_complete(self):
        for command in (["token", "show"], ["token", "refresh"], ["token", "rename"], ["repo", "token"], ["org", "token"]):
            with self.subTest(command=command):
                self.assertEqual(self.complete(*command, ""), self.names)
                self.assertEqual(self.complete(*command, "alpha"), ["alpha", "alpha_ci"])
                self.assertEqual(self.complete(*command, "alpha", ""), [])

    def test_token_name_option_and_command_options_complete(self):
        self.assertEqual(self.complete("setup", "--token-name", "alpha"), ["alpha", "alpha_ci"])
        self.assertEqual(self.complete("token", "refresh", "alpha", "--t"), ["--token"])

if __name__ == "__main__":
    unittest.main()
