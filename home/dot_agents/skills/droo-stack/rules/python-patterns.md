---
title: Python Modern Patterns
impact: MEDIUM
impactDescription: readable, type-safe, idiomatic Python
tags: python, type-hints, async, comprehensions, dataclass
---

# Python Modern Patterns

## Type Hints on All Function Signatures

Every function must have parameter and return type annotations. Use `|` union syntax (3.10+).

### Incorrect

```python
def fetch_user(user_id, include_posts=False):
    result = db.query(User, user_id)
    if result is None:
        return None
    if include_posts:
        result.posts = db.query_posts(user_id)
    return result
```

### Correct

```python
def fetch_user(user_id: int, *, include_posts: bool = False) -> User | None:
    result = db.query(User, user_id)
    if result is None:
        return None
    if include_posts:
        result.posts = db.query_posts(user_id)
    return result
```

## Comprehensions Over map/filter

Comprehensions are more Pythonic and readable than `map()`/`filter()` with lambdas.

### Incorrect

```python
def process_orders(orders):
    # Nested map/filter is hard to read
    active_totals = list(
        map(
            lambda o: {"id": o["id"], "total": o["quantity"] * o["price"]},
            filter(lambda o: o["status"] == "active", orders),
        )
    )
    # map with lambda for simple transforms
    names = list(map(lambda u: u.name.lower(), users))
    return active_totals, names
```

### Correct

```python
def process_orders(orders: list[dict]) -> tuple[list[dict], list[str]]:
    active_totals = [
        {"id": o["id"], "total": o["quantity"] * o["price"]}
        for o in orders
        if o["status"] == "active"
    ]
    names = [u.name.lower() for u in users]
    return active_totals, names
```

## dataclass vs Pydantic: When to Use Each

Use `dataclass` for internal value objects. Use Pydantic when data crosses a trust boundary (API, file, user input).

### Incorrect

```python
from pydantic import BaseModel


# Overkill: Pydantic for a simple internal coordinate
class Point(BaseModel):
    x: float
    y: float

    def distance_to(self, other: "Point") -> float:
        return ((self.x - other.x) ** 2 + (self.y - other.y) ** 2) ** 0.5


# Dangerous: raw dict for external API response
def parse_webhook(payload: dict) -> dict:
    return {
        "event": payload["event"],
        "timestamp": payload["ts"],
        "data": payload.get("data", {}),
    }
```

### Correct

```python
from dataclasses import dataclass

from pydantic import BaseModel, Field


# dataclass for internal domain objects -- no validation overhead
@dataclass(frozen=True)
class Point:
    x: float
    y: float

    def distance_to(self, other: "Point") -> float:
        return ((self.x - other.x) ** 2 + (self.y - other.y) ** 2) ** 0.5


# Pydantic for untrusted external data -- validates and coerces
class WebhookEvent(BaseModel):
    event: str
    timestamp: int = Field(alias="ts")
    data: dict = Field(default_factory=dict)


def parse_webhook(payload: dict) -> WebhookEvent:
    return WebhookEvent.model_validate(payload)
```

## async/await Patterns

Use `asyncio.gather` for concurrent I/O. Never block the event loop with sync calls.

### Incorrect

```python
import asyncio
import requests  # sync library in async code


async def fetch_all_profiles(user_ids: list[int]):
    results = []
    for uid in user_ids:
        # Sequential AND blocking -- defeats the purpose of async
        resp = requests.get(f"https://api.example.com/users/{uid}")
        results.append(resp.json())
    return results
```

### Correct

```python
import asyncio

import aiohttp


async def fetch_all_profiles(user_ids: list[int]) -> list[dict]:
    async with aiohttp.ClientSession() as session:
        tasks = [_fetch_profile(session, uid) for uid in user_ids]
        return await asyncio.gather(*tasks)


async def _fetch_profile(session: aiohttp.ClientSession, user_id: int) -> dict:
    async with session.get(f"https://api.example.com/users/{user_id}") as resp:
        resp.raise_for_status()
        return await resp.json()
```

## Context Managers for Resource Cleanup

Use `with` statements or write custom context managers. Never rely on manual close() calls.

### Incorrect

```python
def export_report(records: list[dict], output_path: str) -> None:
    db = Database.connect("postgres://localhost/reports")
    f = open(output_path, "w")
    try:
        for record in db.query("SELECT * FROM summary"):
            f.write(format_row(record))
    except Exception:
        f.close()
        db.close()
        raise
    f.close()
    db.close()
```

### Correct

```python
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator


@contextmanager
def database_connection(dsn: str) -> Iterator[Database]:
    db = Database.connect(dsn)
    try:
        yield db
    finally:
        db.close()


def export_report(records: list[dict], output_path: Path) -> None:
    with (
        database_connection("postgres://localhost/reports") as db,
        output_path.open("w") as f,
    ):
        for record in db.query("SELECT * FROM summary"):
            f.write(format_row(record))
```
