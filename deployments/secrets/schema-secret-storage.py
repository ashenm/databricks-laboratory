#!/usr/bin/env python3
import json
import os
import sys
from argparse import ArgumentParser, Namespace
from databricks.sdk import WorkspaceClient
from urllib.parse import quote


def configure(client: WorkspaceClient, schema: str, connection_name: str) -> None:
    payload: dict = {
        "secret_storage": {
            "connection_name": connection_name,
            "storage_type": "STORAGE_TYPE_EXTERNAL",
        }
    }
    client.api_client.do(method="PATCH", path=f"/api/2.1/unity-catalog/schemas/{quote(schema, safe='')}", body=payload)


def delete(client: WorkspaceClient, schema: str):
    payload: dict = {"secret_storage": {}}
    client.api_client.do(method="PATCH", path=f"/api/2.1/unity-catalog/schemas/{quote(schema, safe='')}", body=payload)


def get_argument_parser() -> ArgumentParser():
    parser: ArgumentParser = ArgumentParser()
    parser.add_argument("action", choices=["create", "update", "delete"])
    parser.add_argument("--schema", required=True, action="store")
    parser.add_argument("--connection-name", action="store")
    return parser


def main():
    args: Namespace = get_argument_parser().parse_args()
    client: WorkspaceClient = WorkspaceClient(host=os.environ["DATABRICKS_HOST"].rstrip("/"))
    if args.action in ("create", "update"):
        configure(client=client, schema=args.schema, connection_name=args.connection_name)
        return
    delete(client=client, schema=args.schema)


if __name__ == "__main__":
    main()
