import sys
import logging
from os import environ
from argparse import ArgumentParser, Namespace
from databricks.sdk import WorkspaceClient
from databricks.sdk.service.jobs import (
    EnforcePolicyComplianceResponse,
    EnforcePolicyComplianceForJobResponseJobClusterSettingsChange,
    JobCompliance,
)

logging.basicConfig(level=logging.INFO, stream=sys.stdout)
log: logging.Logger = logging.getLogger(__name__)


def get_argment_parser() -> ArgumentParser:
    parser: ArgumentParser = ArgumentParser()
    parser.add_argument("policy_id")
    return parser


def main():
    args: Namespace = get_argment_parser().parse_args()
    client: WorkspaceClient = WorkspaceClient(host=environ["DATABRICKS_HOST"])
    policy_id: str = args.policy_id

    job_compliances: list[JobCompliance] = list(client.policy_compliance_for_jobs.list_compliance(
        policy_id=policy_id,
    ))
    reconciliation_unbounds: list[str] = []

    for job_compliance in job_compliances:
        job_id: int = job_compliance.job_id

        if job_compliance.is_compliant:
            log.debug("Ignoring compliant job %s", job_id)
            continue

        log.info("Attempting compliance enforce on non-compliant job %s", job_id)

        try:
            preview: EnforcePolicyComplianceResponse = client.policy_compliance_for_jobs.enforce_compliance(
                job_id=job_id,
                validate_only=True,
            )

            changset: list[EnforcePolicyComplianceForJobResponseJobClusterSettingsChange] = preview.job_cluster_changes

            if not preview.has_changes or not changset:
                log.warning("Cannot initiate automatic compliance enforcement for job %s; requires manual reconcile", job_id)
                reconciliation_unbounds.append(job_id)
                continue

            for change in preview.job_cluster_changes:
                log.info("Job %s: %s: %s -> %s", job_id, change.field, change.previous_value, change.new_value)

            client.policy_compliance_for_jobs.enforce_compliance(job_id=job_id)

            status: EnforcePolicyComplianceResponse = client.policy_compliance_for_jobs.get_compliance(
                job_id=job_id,
            )

            if not status.is_compliant:
                log.error("Failed to enforce compliance on job %s with violations %s", job_id, status.violations)
                reconciliation_unbounds.append(job_id)
                continue

            log.info("Completing compliance enforce on non-compliant job %s", job_id)
        except Exception:
            log.exception("Failed to enforce compliance on job %s", job_id)

    if reconciliation_unbounds:
        log.error("Failed to enforce compliance on job(s) %s; requires manual reconcile", reconciliation_unbounds)
        sys.exit(1)


if __name__ == "__main__":
    main()
