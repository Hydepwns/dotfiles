---
title: Python CLI and Data Patterns
impact: HIGH
impactDescription: type-safe CLIs, validated data, modern paths
tags: python, typer, pydantic, pathlib, pytest
---

# Python CLI and Data Patterns

## Typer CLI Scaffolding

Use Typer for CLI applications with type-annotated commands, not argparse or click.

### Incorrect

```python
import argparse

def main():
    parser = argparse.ArgumentParser(description="Deploy service")
    parser.add_argument("--env", type=str, required=True)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("service", type=str)
    args = parser.parse_args()

    if args.env not in ("staging", "production"):
        parser.error("env must be staging or production")

    deploy(args.service, args.env, args.dry_run)
```

### Correct

```python
from enum import Enum
from typing import Annotated

import typer

app = typer.Typer(help="Service deployment tool")


class Environment(str, Enum):
    staging = "staging"
    production = "production"


@app.command()
def deploy(
    service: Annotated[str, typer.Argument(help="Service name to deploy")],
    env: Annotated[Environment, typer.Option(help="Target environment")],
    dry_run: Annotated[bool, typer.Option("--dry-run", help="Preview without applying")] = False,
) -> None:
    """Deploy a service to the target environment."""
    if dry_run:
        typer.echo(f"Would deploy {service} to {env.value}")
        raise typer.Exit()
    _run_deploy(service, env)


if __name__ == "__main__":
    app()
```

## Pydantic Models for Config Validation

Use Pydantic for any config or external data. Never trust raw dicts from YAML/JSON.

### Incorrect

```python
import json

def load_config(path):
    with open(path) as f:
        config = json.load(f)
    # Hope these keys exist and are the right types
    host = config["database"]["host"]
    port = config["database"]["port"]
    max_connections = config.get("database", {}).get("max_connections", 10)
    return host, port, max_connections
```

### Correct

```python
from pathlib import Path

from pydantic import BaseModel, Field


class DatabaseConfig(BaseModel):
    host: str
    port: int = Field(ge=1, le=65535)
    max_connections: int = Field(default=10, ge=1, le=1000)


class AppConfig(BaseModel):
    database: DatabaseConfig
    debug: bool = False


def load_config(path: Path) -> AppConfig:
    return AppConfig.model_validate_json(path.read_text())
```

## pathlib Over os.path

Use `Path` objects and `/` operator. Never use `os.path.join` or string concatenation.

### Incorrect

```python
import os

def find_config():
    home = os.path.expanduser("~")
    config_dir = os.path.join(home, ".config", "myapp")
    config_file = os.path.join(config_dir, "config.toml")

    if not os.path.isdir(config_dir):
        os.makedirs(config_dir)

    if os.path.isfile(config_file):
        with open(config_file, "r") as f:
            return f.read()
    return None
```

### Correct

```python
from pathlib import Path


def find_config() -> str | None:
    config_dir = Path.home() / ".config" / "myapp"
    config_file = config_dir / "config.toml"

    config_dir.mkdir(parents=True, exist_ok=True)

    if config_file.is_file():
        return config_file.read_text()
    return None
```

## pytest Fixtures Over setup/teardown

Use fixtures for test dependencies. Never use unittest-style setUp/tearDown.

### Incorrect

```python
import unittest
import tempfile
import os

class TestConfigLoader(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.config_path = os.path.join(self.tmpdir, "config.toml")
        with open(self.config_path, "w") as f:
            f.write('[database]\nhost = "localhost"\nport = 5432\n')

    def tearDown(self):
        os.remove(self.config_path)
        os.rmdir(self.tmpdir)

    def test_loads_config(self):
        config = load_config(self.config_path)
        self.assertEqual(config.database.host, "localhost")
```

### Correct

```python
from pathlib import Path

import pytest


@pytest.fixture
def config_file(tmp_path: Path) -> Path:
    path = tmp_path / "config.toml"
    path.write_text('[database]\nhost = "localhost"\nport = 5432\n')
    return path


def test_loads_valid_config(config_file: Path) -> None:
    config = load_config(config_file)
    assert config.database.host == "localhost"
    assert config.database.port == 5432


def test_rejects_invalid_port(tmp_path: Path) -> None:
    bad_config = tmp_path / "config.toml"
    bad_config.write_text('[database]\nhost = "localhost"\nport = -1\n')
    with pytest.raises(ValidationError):
        load_config(bad_config)
```
