<h1 align="center">🛡️ DomainShield </h1>

**DomainShield** is a comprehensive DNS & Email Security Auditor that performs automated security assessments for domain infrastructure. It identifies vulnerabilities in DNS configuration, email authentication, and network services, generating professional security reports.

<p align="center">
<img src="https://github.com/Debajyoti0-0/DomainShield/raw/main/Img/DomainShield.png" alt="DomainShield Tool Logo" width="400">
</p>

## 📋 Features

### 🔍 Security Assessments
- **DNS Infrastructure Analysis**
  - Name server distribution & subnet diversity
  - DNS security extensions (DNSSEC) validation
  - Open resolver testing
  - Name server responsiveness checks

- **Email Security Validation**
  - SPF record configuration & syntax checking
  - DKIM record discovery & validation
  - DMARC policy analysis & reporting
  - Email spoofing vulnerability detection

- **Network Security Scanning**
  - Common service port detection
  - SSL/TLS certificate validation
  - Service exposure analysis
  - Security header verification

### 📊 Professional Reporting
- **HTML Reports** with dark theme and high contrast
- **Detailed Technical Findings** with Proof of Concept
- **Color-coded Severity Levels** (Critical, High, Medium, Low)
- **Actionable Recommendations** for remediation
- **Executive Summary** for quick overview
- **Color-blind friendly** design

## 🚀 Quick Start

### Prerequisites
- Kali Linux or any Linux distribution
- Basic tools: `dig`, `whois`, `nslookup`, `curl`, `openssl`, `nc`

### Easy Installation
```bash
# Clone the repository
git clone https://github.com/Debajyoti0-0/DomainShield.git
cd DomainShield

# Run the installer (automatically installs all dependencies)
chmod +x install.sh
./install.sh
```

The installer will automatically:
- Detect your package manager (apt, yum, dnf, pacman, zypper)
- Install all required tools
- Create a global symlink for easy access

### Manual Installation
If you prefer to install tools manually:

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install -y dnsutils whois curl openssl netcat
```

**CentOS/RHEL/Fedora:**
```bash
sudo yum install -y bind-utils whois curl openssl nc
# or for Fedora:
sudo dnf install -y bind-utils whois curl openssl nc
```

**Arch Linux:**
```bash
sudo pacman -Sy --noconfirm bind-tools whois curl openssl netcat
```

## 📖 Usage

### Basic Usage
```bash
# After installation, use from anywhere:
domainshield example.com

# Or using the direct script:
./DomainShield.sh example.com
```

### Command Line Options
```bash
╔════════════════════════════════════════════════════════════════╗
║                         DomainShield                           ║
║                 DNS & EMAIL SECURITY AUDITOR                   ║
║                  Automated Assessment Tool                     ║
╚════════════════════════════════════════════════════════════════╝

USAGE:
    ./DomainShield.sh [OPTIONS] <domain>

DESCRIPTION:
    Comprehensive automated security assessment for DNS and email infrastructure.
    Performs multiple security checks and generates professional reports.

OPTIONS:
    -h, --help          Show this help message and exit
    -v, --verbose       Enable verbose output during assessment
    -q, --quiet         Suppress non-essential output
    -o, --output DIR    Custom output directory (default: auto-generated)
    -r, --report-only   Generate report from existing data (not implemented)
    --no-html           Generate only text report, no HTML
    --no-network        Skip network port scanning
    --dns-only          Perform only DNS-related checks
    --email-only        Perform only email security checks

EXAMPLES:
    ./DomainShield.sh example.com                    # Full assessment
    ./DomainShield.sh -v example.com                 # Verbose mode
    ./DomainShield.sh -o my_report example.com       # Custom output dir
    ./DomainShield.sh --dns-only example.com         # DNS checks only
    ./DomainShield.sh --email-only example.com       # Email checks only

CHECKS PERFORMED:
    [✓] DNS Infrastructure Security
    [✓] Name Server Distribution & Subnet Diversity
    [✓] Email Authentication (SPF, DKIM, DMARC)
    [✓] SSL/TLS Certificate Validation
    [✓] Network Service Exposure
    [✓] DNS Security Extensions (DNSSEC)
    [✓] Open Resolver Testing

OUTPUT:
    [📄] full_report.html          - Professional HTML report
    [📄] technical_report.txt      - Detailed technical findings
    [📁] mail_security_audit_<domain>_<timestamp>/  - Report directory

REQUIREMENTS:
    dig, whois, nslookup, curl, openssl, nc (netcat)

EXIT CODES:
    [0] - Success
    [1] - Missing domain or argument error
    [2] - Required tools not installed
    [3] - Assessment failed

NOTE: This tool is for authorized security assessments only.
      Always ensure you have permission to test the target domain.

Author: Debajyoti0-0 | The DomainShield | Version: 1.0
```

### Usage Examples

**Comprehensive Assessment**
```bash
domainshield example.com
```
*Performs full DNS, email, and network security assessment*

**Verbose Mode**
```bash
domainshield -v example.com
```
*Shows detailed progress during assessment*

**Quiet Mode**
```bash
domainshield -q example.com
```
*Shows only the summary report*

**DNS-Only Assessment**
```bash
domainshield --dns-only example.com
```
*Focuses only on DNS infrastructure security*

**Custom Output Directory**
```bash
domainshield -o my_security_report example.com
```
*Saves reports to custom directory*

**Skip Network Scanning**
```bash
domainshield --no-network example.com
```
*Performs assessment without port scanning*

**Text-Only Report**
```bash
domainshield --no-html example.com
```
*Generates only technical text report*

## 🎯 What DomainShield Checks

### DNS Security
- ✅ Name server redundancy & distribution
- ✅ Subnet diversity (single point of failure detection)
- ✅ DNSSEC implementation
- ✅ Open DNS resolvers
- ✅ Name server responsiveness
- ✅ Name server count validation

### Email Security
- ✅ SPF record presence & configuration
- ✅ SPF syntax validation
- ✅ DKIM record discovery
- ✅ DMARC policy enforcement
- ✅ Email spoofing protection
- ✅ Proper email authentication setup
- ✅ DMARC reporting configuration

### Network Security
- ✅ SSL/TLS certificate validity
- ✅ Certificate expiration monitoring
- ✅ Common service exposure (SSH, SMTP, DNS, FTP, etc.)
- ✅ Service accessibility checks
- ✅ Open port detection

## 📊 Sample Reports

Want to see what DomainShield reports look like before running it? Check out the sample reports in the `Sample_Report/` directory:

- **[Sample_Report/full_report.html](https://htmlpreview.github.io/?https://github.com/Debajyoti0-0/DomainShield/blob/main/Sample_Report/full_report.html)** - See a complete assessment report with findings, recommendations, and proof of concept evidence


### Console Summary
```
╔════════════════════════════════════════════════════════════════╗
║                         DomainShield                           ║
║                 DNS & EMAIL SECURITY AUDITOR                   ║
║                  Automated Assessment Tool                     ║
╚════════════════════════════════════════════════════════════════╝

=== ASSESSMENT SUMMARY ===
Critical: 0
High: 4
Medium: 2
Low: 2
Passed: 8
```

### Generated Report Structure
```
mail_security_audit_example.com_2024-01-15_14-30-00/
├── full_report.html          # Professional HTML report
└── technical_report.txt      # Detailed technical findings
```

## 🛠️ Advanced Usage

### Batch Processing
```bash
# Assess multiple domains
for domain in example.com test.org demo.net; do
    domainshield -q $domain
done
```

### Integration with CI/CD
```bash
# Example CI integration
domainshield --quiet example.com
if [ $? -eq 0 ]; then
    echo "Security assessment passed"
else
    echo "Security issues found - check reports"
    exit 1
fi
```

### Custom Assessment Scope
```bash
# Email security only
domainshield --email-only example.com

# DNS infrastructure only  
domainshield --dns-only example.com

# Without network scans (firewall friendly)
domainshield --no-network example.com
```

## 📁 Project Structure

```
DomainShield/
├── DomainShield.sh          # Main assessment script
├── install.sh              # Automatic dependency installer
├── Uninstall.sh           # Clean uninstaller
├── Img/
│   ├── DomainShield-Preview.png  # Project logo
│   └── DomainShield.png  # Project logo (not Preview.png)
├── Sample_Report/          # Example reports
│   ├── full_report.html    # Sample HTML report
│   └── DomainShield-Preview.png # Logo preview
├── README.md              # This file
└── reports/              # Generated reports (example)
    └── mail_security_audit_example.com_2024-01-15_14-30-00/
        ├── full_report.html
        └── technical_report.txt
```

## 🎨 Report Features

### HTML Report Includes
- **Professional Dark Theme** with high contrast
- **Color-blind Friendly** headers and indicators
- **Interactive Elements** with hover effects
- **Responsive Design** for all devices
- **Executive Summary** with severity breakdown
- **Technical Details** with proof of concept
- **Actionable Recommendations** for each finding
- **Assessment Methodology** documentation

### Text Report Includes
- **Structured Findings** by severity level
- **Technical Evidence** for each vulnerability
- **Remediation Guidance** with priority levels
- **Raw DNS Records** for manual verification
- **Tool Usage** information

## 🔧 Management

### Installation
```bash
./install.sh
```
*Automatically installs dependencies and creates symlink*

### Uninstallation
```bash
./Uninstall.sh
```
*Removes symlink and optionally uninstalls tools*

### Global Access
After installation, use `domainshield` from any directory:
```bash
domainshield example.com
```

## ⚠️ Legal & Ethical Use

### Authorized Usage Only
- Use only on domains you own or have explicit permission to test
- Obtain proper authorization before conducting security assessments
- Comply with all applicable laws and regulations
- Respect rate limiting and scanning policies

### Educational Purpose
This tool is designed for:
- Security professionals conducting authorized assessments
- System administrators auditing their infrastructure
- Security researchers with proper permissions
- Educational and training purposes
- Personal website security testing

### Responsible Disclosure
If you discover vulnerabilities in third-party systems:
- Follow responsible disclosure practices
- Contact the appropriate security team
- Provide clear reproduction steps
- Allow reasonable time for remediation

## 🤝 Contributing

We welcome contributions from the security community!

### How to Contribute
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Areas for Contribution
- New security checks and validations
- Improved reporting formats
- Additional output formats (JSON, CSV, etc.)
- Enhanced visualization features
- Performance optimizations
- Documentation improvements

### Development Setup
```bash
git clone https://github.com/Debajyoti0-0/DomainShield.git
cd DomainShield
chmod +x DomainShield.sh

# Test your changes
./DomainShield.sh example.com
```

## 📄 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Debajyoti0-0**  
- GitHub: [@Debajyoti0-0](https://github.com/Debajyoti0-0)
- Tool: DomainShield - DNS & Email Security Auditor

## 🙏 Acknowledgments

- Security community for best practices and methodologies
- Open source tools that make this project possible
- Contributors and testers who help improve DomainShield
- Color-blind accessibility guidelines and resources

## 🔗 Related Projects

- [DNSViz](https://dnsviz.net/) - DNS visualization tool
- [MXToolbox](https://mxtoolbox.com/) - Email and DNS diagnostic tools
- [SSL Labs](https://www.ssllabs.com/ssltest/) - SSL/TLS assessment

---

**🔒 Secure Your Domain Infrastructure with DomainShield - Automated DNS & Email Security Auditing**

*"Prevention is better than cure - especially in cybersecurity"*

---

### 📞 Support

If you encounter any issues or have questions:
1. Check the [Issues](https://github.com/Debajyoti0-0/DomainShield/issues) page
2. Create a new issue with detailed information
3. Provide the domain tested and error messages if any

### 🐛 Reporting Bugs

When reporting bugs, please include:
- DomainShield version (run `domainshield --help`)
- Your operating system and version
- The exact command you ran
- Full error output
- Steps to reproduce the issue

---

**⭐ If you find DomainShield useful, please consider giving it a star on GitHub!**





