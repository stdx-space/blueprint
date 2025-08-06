# Blueprint

Infrastructure-as-Code repository for building cloud images and managing reusable Terraform modules with an integrated private module registry.

## Overview

This repository provides a comprehensive infrastructure automation toolkit that includes:

- **Packer configurations** for building customized VM images (AMIs) and systemd-sysext overlay images
- **Terraform modules** (33+ preconfigured modules) that encapsulate common infrastructure patterns
- **Private module registry** powered by Cloudflare Workers for versioned module distribution
- **CI/CD pipelines** for automated building, validation, and publishing

## Repository Structure

```
blueprint/
├── imgfab/                 # Image fabrication with Packer
│   ├── ami/               # VM/AMI image builds
│   │   ├── build.pkr.hcl
│   │   ├── sources.pkr.hcl
│   │   └── templates/     # OS-specific configs (preseed, kickstart, etc.)
│   └── sysext/            # Systemd-sysext overlay images
│       ├── build.pkr.hcl
│       └── templates/     # Service unit files
├── modules/               # Terraform modules (33+ modules)
│   ├── alma/             # AlmaLinux OS configuration
│   ├── debian/           # Debian OS configuration
│   ├── flatcar/          # Flatcar Container Linux configuration
│   ├── consul/           # HashiCorp Consul service mesh
│   ├── nomad/            # HashiCorp Nomad orchestrator
│   ├── vault/            # HashiCorp Vault secrets management
│   ├── nomad-*/          # Nomad job modules (Redis, PostgreSQL, MinIO, etc.)
│   └── ...               # Additional infrastructure modules
├── registry/              # Terraform module registry
│   ├── src/              # TypeScript source code
│   ├── test/             # Vitest test suite
│   └── package.json      # Node.js dependencies
└── .github/workflows/     # GitHub Actions CI/CD
    ├── modules.yml       # Module publishing pipeline
    ├── registry.yml      # Registry deployment
    ├── ami.yml          # AMI building
    └── sysext.yml       # Sysext building
```

## Getting Started

### Prerequisites

- **Terraform** >= 1.0 for module development
- **Packer** >= 1.8 for image building
- **Node.js** >= 18 for registry development
- **Git** for version control

### Module Development

1. **Using existing modules:**
   ```hcl
   module "debian_config" {
     source = "github.com/narwhl/blueprint//modules/debian"
     # or from registry: "registry.narwhl.workers.dev/narwhl/blueprint/debian"

     # Module-specific variables
   }
   ```

2. **Creating new modules:**
   ```bash
   cd modules/
   mkdir my-module
   cd my-module

   # Create standard module files
   touch main.tf variables.tf outputs.tf terraform.tf README.md

   # Initialize and validate
   terraform init
   terraform fmt
   terraform validate
   ```

3. **Module structure conventions:**
   - `main.tf` - Core resource definitions
   - `variables.tf` - Input variable declarations
   - `outputs.tf` - Output value exports
   - `terraform.tf` - Provider requirements
   - `templates/` - Configuration file templates (`.tftpl`)
   - `README.md` - Module documentation

### Image Building

1. **Building AMIs:**
   ```bash
   cd imgfab/ami
   packer init .
   packer build .
   ```

2. **Building systemd-sysext images:**
   ```bash
   cd imgfab/sysext
   packer build .
   ```

### Registry Development

1. **Local development:**
   ```bash
   cd registry
   npm ci                    # Install dependencies
   npm run dev              # Start local dev server
   npm test                 # Run test suite
   ```

2. **Deployment:**
   ```bash
   npm run deploy           # Build for production (dry-run)
   terraform apply          # Deploy to Cloudflare Workers
   ```

## Module Categories

### Platform Modules
- `debian/`, `alma/`, `flatcar/` - OS-specific configurations with cloud-init/ignition
- `proxmox/`, `vsphere/` - Virtualization platform integrations
- `nvidia/` - GPU driver and container toolkit setup

### Service Infrastructure
- `consul/`, `nomad/`, `vault/` - HashiCorp stack components
- `consul-template/` - Dynamic configuration management
- `tailscale/` - Zero-trust networking

### Nomad Job Modules
Preconfigured Nomad job specifications for common services:
- `nomad-redis/`, `nomad-valkey/` - In-memory data stores
- `nomad-postgres/`, `nomad-spilo/` - PostgreSQL databases
- `nomad-minio/` - Object storage
- `nomad-ingress/` - Load balancing and routing
- `nomad-forgejo/`, `nomad-mastodon/`, `nomad-vaultwarden/` - Applications

### Security & PKI
- `certificates/` - TLS certificate generation
- `pki/` - Public key infrastructure
- `vault-cf-access/` - Vault with Cloudflare Access integration

## CI/CD Workflows

### Automated Module Publishing
The `modules.yml` workflow automatically:
1. Detects changed modules on push
2. Validates Terraform formatting and syntax
3. Publishes to the private registry (on manual trigger)

### Registry Deployment
The `registry.yml` workflow:
1. Builds the TypeScript application
2. Runs Terraform plan/apply for Cloudflare Workers
3. Deploys on push to main branch

### Image Building
- `ami.yml` - Builds and uploads AMI images to R2 storage
- `sysext.yml` - Creates systemd-sysext overlay images

## Development Guidelines

### Before Submitting Changes

1. **For Terraform modules:**
   ```bash
   terraform fmt -check     # Ensure proper formatting
   terraform init           # Initialize providers
   terraform validate       # Validate configuration
   ```

2. **For registry code:**
   ```bash
   npm test                 # Run test suite
   npm run build           # Verify build succeeds
   ```

3. **For Packer templates:**
   ```bash
   packer fmt .            # Format HCL files
   packer validate .       # Validate configuration
   ```

### Best Practices

- Follow existing module patterns and naming conventions
- Document module inputs/outputs in README files
- Use semantic versioning for module releases
- Test modules in isolation before integration
- Keep sensitive data in Vault or environment variables
- Use `.tftpl` extension for Terraform template files

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-module`)
3. Make changes following the guidelines above
4. Ensure all validations pass
5. Submit a pull request with clear description

## Support

For issues or questions, please open an issue in the GitHub repository
