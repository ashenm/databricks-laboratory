import logging
from typing import TypedDict
from enum import Enum
import yamale
import sys
from termcolor import colored
from pathlib import Path
from databricks.sdk.service.marketplace import (
    ConsumerTerms,
    GetListingResponse,
    InstallationDetail,
)
from databricks.sdk.service.catalog import Privilege, PermissionsChange, SecurableType
from yamale.schema import Schema
from argparse import ArgumentParser, Namespace
from databricks.sdk import WorkspaceClient


DATABRICKS_MARKETPLACE_DEFAULT_PERMISSIONS: list[PermissionsChange] = [
    PermissionsChange(add=[Privilege.MANAGE], principal="one-env-laboratory-sudoers"),
]
DATABRICKS_MARKETPLACE_CONSUMER_TERMS: ConsumerTerms = ConsumerTerms(version="2023-01")

DIFF_PREVIEW_TEXT_PREFIX: str = colored(text="will be", color="dark_grey")
DIFF_PREVIEW_TEXT_CREATE_PREFIX: str = colored(text="+", color="green")
DIFF_PREVIEW_TEXT_CREATE: str = " ".join([DIFF_PREVIEW_TEXT_PREFIX, colored(text="created", color="green")])
DIFF_PREVIEW_TEXT_DESTROY_PREFIX: str = colored(text="-", color="red")
DIFF_PREVIEW_TEXT_DESTROY: str = " ".join([DIFF_PREVIEW_TEXT_PREFIX, colored(text="destroyed", color="red")])


class Stage(Enum):
    Plan = "plan"
    Apply = "apply"


class Subscription(TypedDict):
    listing_id: str


Subscriptions = dict[str, Subscription]


def get_argument_parser() -> ArgumentParser:
    parser: ArgumentParser = ArgumentParser()
    parser.add_argument(
        "--stage",
        dest="stage",
        action="store",
        choices=[stage.value for stage in Stage],
    )
    parser.add_argument(dest="config", action="store")
    return parser


def get_configuration(filepath: str) -> Subscriptions:
    schema: Schema = yamale.make_schema(path=Path(__file__).resolve().parent.joinpath("schema.yaml"))
    data: list[tuple[dict, str]] = yamale.make_data(path=filepath)
    yamale.validate(schema=schema, data=data)
    return data[0][0]["subscriptions"] if data[0][0]["subscriptions"] else {}


def canonicalize_installations(
    installations: list[InstallationDetail],
) -> Subscriptions:
    subscriptions: Subscriptions = {}
    for installation in installations:
        catalog_name: str = installation.catalog_name.strip()
        subscriptions[catalog_name] = {"listing_id": installation.listing_id, "id": installation.id}
    return subscriptions


def diff(current: Subscriptions, existing: Subscriptions) -> tuple[Subscriptions, Subscriptions]:
    creations: Subscriptions = {key: value for key, value in current.items() if key not in existing}
    deletions: Subscriptions = {key: value for key, value in existing.items() if key not in current}
    return (creations, deletions)


def preview(creations: Subscriptions, deletions: Subscriptions) -> None:
    if not creations and not deletions:
        print(colored(text="No changes. Databricks Marketplace subscriptions are up-to-date.", color="green"))
        return

    for catalog_name, subscription in creations.items():
        print()
        print("\t", "#", catalog_name, DIFF_PREVIEW_TEXT_CREATE)
        print("\t\t", DIFF_PREVIEW_TEXT_CREATE_PREFIX, "listing_id", subscription["listing_id"])
        print()

    for catalog_name, subscription in deletions.items():
        print()
        print("\t", "#", catalog_name, DIFF_PREVIEW_TEXT_DESTROY)
        print("\t\t", DIFF_PREVIEW_TEXT_DESTROY_PREFIX, "listing_id", subscription["listing_id"])
        print()


def main() -> None:
    args: Namespace = get_argument_parser().parse_args()
    logging.info(msg="Attempting subscription config loading")
    subscriptions: Subscriptions = get_configuration(filepath=Path(args.config).resolve().as_posix())

    logging.info(msg="Attempting Databricks client initialization")
    client: WorkspaceClient = WorkspaceClient()

    logging.info(msg="Attempting existing subscriptions listing")
    installations: Subscriptions = canonicalize_installations(installations=list(client.consumer_installations.list()))

    logging.info(msg="Attempting Databricks Marketplace installation diff")
    (creations, deletions) = diff(current=subscriptions, existing=installations)

    preview(creations=creations, deletions=deletions)

    if args.stage != Stage.Apply.value:
        logging.debug(msg="Attempting early exit due to non-apply run stage")
        return

    for key, creation in creations.items():
        consumer_listing: GetListingResponse = client.consumer_listings.get(id=creation["listing_id"])
        client.consumer_installations.create(
            catalog_name=key,
            listing_id=creation["listing_id"],
            share_name=consumer_listing.listing.summary.share.name,
            accepted_consumer_terms=DATABRICKS_MARKETPLACE_CONSUMER_TERMS,
        )
        client.grants.update(
            securable_type=SecurableType.CATALOG.value,
            full_name=key,
            changes=DATABRICKS_MARKETPLACE_DEFAULT_PERMISSIONS,
        )

    for key, deletion in deletions.items():
        client.consumer_installations.delete(
            installation_id=deletion["id"],
            listing_id=deletion["listing_id"],
        )


if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.INFO)
    main()
