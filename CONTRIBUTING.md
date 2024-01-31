# Contributing to AWS ARC EKS

Thank you for considering contributing to AWS ARC EKS! We appreciate your time and effort.
To ensure a smooth collaboration, please take a moment to review the following guidelines.

## How to Contribute

1. Fork the repository to your own GitHub account.
2. Clone the repository to your local machine.
   ```bash
   git clone https://github.com/<your_organization>/<your_terraform_module>.git
   ```
3. Create a new branch for your feature / bugfix.
   ```bash
   git checkout -b feature/branch_name
   ```
4. Make your changes and commit them.
   ```bash
   git commit -m "Your descriptive commit message"
   ```
5. Push to your forked repository.
   ```bash
   git push origin feature/branch_name
   ```
6. Open a pull request in the original repository with a clear title and description.
   If your pull request addresses an issue, please reference the issue number in the pull request description.

## Code Style

Please follow the Terraform language conventions and formatting guidelines. Consider using an editor with Terraform support or a linter to ensure adherence to the style.

## Testing

!!! This section is a work-in-progress, as we are starting to adopt testing using Terratest. !!!

Before submitting a pull request, ensure that your changes pass all tests. If applicable, add new tests to cover your changes.

## Documentation

Keep the module documentation up-to-date. If you add new features or change existing functionality, update the [README](README.md) and any relevant documentation files.

## Security and Compliance Checks

GitHub Actions are in place to perform security and compliance checks. Please make sure your changes pass these checks before submitting a pull request.

## Licensing

By contributing, you agree that your contributions will be licensed under the project's [LICENSE](LICENSE).
