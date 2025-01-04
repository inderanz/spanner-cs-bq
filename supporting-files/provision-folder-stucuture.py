import os

# Directory structure
structure = {
    "payment-system": {
        "README.md": None,
        ".gitignore": None,
        "terraform": {
            "modules": {
                "spanner": {},
                "bigquery": {},
                "dataflow": {},
                "pubsub": {},
                "storage": {},
                "network": {},
                "monitoring": {},
                "kms": {}
            },
            "dev": {
                "main.tf": None,
                "variables.tf": None,
                "outputs.tf": None,
                "backend.tf": None
            },
            "qa": {
                "main.tf": None,
                "variables.tf": None,
                "outputs.tf": None,
                "backend.tf": None
            },
            "production": {
                "main.tf": None,
                "variables.tf": None,
                "outputs.tf": None,
                "backend.tf": None
            }
        },
        "dataflow": {
            "templates": {
                "spanner_to_bigquery_template.py": None,
                "spanner_to_bigquery_template_dev.py": None,
                "spanner_to_bigquery_template_qa.py": None,
                "spanner_to_bigquery_template_prod.py": None
            },
            "pipelines": {
                "dev": {
                    "job_config.json": None,
                    "launch_job.sh": None
                },
                "qa": {
                    "job_config.json": None,
                    "launch_job.sh": None
                },
                "production": {
                    "job_config.json": None,
                    "launch_job.sh": None
                }
            }
        },
        "monitoring": {
            "alert_policies": {
                "latency_alert.tf": None,
                "error_rate_alert.tf": None
            },
            "dashboards": {
                "dataflow_dashboard.json": None,
                "spanner_dashboard.json": None,
                "bigquery_dashboard.json": None
            }
        },
        "scripts": {
            "validate.sh": None,
            "deploy.sh": None,
            "destroy.sh": None
        }
    }
}

def create_structure(base_path, structure):
    for name, content in structure.items():
        path = os.path.join(base_path, name)
        if isinstance(content, dict):
            os.makedirs(path, exist_ok=True)
            create_structure(path, content)
        elif content is None:
            with open(path, 'w') as file:
                file.write("")

# Create the directory structure
base_path = "./"
create_structure(base_path, structure)
