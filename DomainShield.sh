#!/bin/bash

# DomainShield
# Comprehensive DNS & Email Security Auditor
# Author: Debajyoti0-0
# Github: https://github.com/Debajyoti0-0
# Usage: ./DomainShield.sh domain.com

# Function to display help
show_help() {
    clear
    cat << 'EOF'

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
EOF
}

# Colors for output (for the main script)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to clean domain input
clean_domain() {
    local domain="$1"
    
    # Remove protocol prefixes
    domain=$(echo "$domain" | sed -E 's|^https?://||')
    domain=$(echo "$domain" | sed -E 's|^ftp://||')
    domain=$(echo "$domain" | sed -E 's|^sftp://||')
    domain=$(echo "$domain" | sed -E 's|^ldap://||')
    domain=$(echo "$domain" | sed -E 's|^ldaps://||')
    
    # Remove www prefix
    domain=$(echo "$domain" | sed -E 's|^www\.||')
    
    # Remove path and query parameters
    domain=$(echo "$domain" | sed -E 's|/.*$||')
    domain=$(echo "$domain" | sed -E 's|\?.*$||')
    
    # Remove port numbers
    domain=$(echo "$domain" | sed -E 's|:[0-9]+$||')
    
    # Convert to lowercase
    domain=$(echo "$domain" | tr '[:upper:]' '[:lower:]')
    
    echo "$domain"
}

# Function to validate domain format
validate_domain() {
    local domain="$1"
    
    # Check for common typos or incomplete commands
    if [[ "$domain" =~ ^h$|^he$|^hel$|^help$ ]]; then
        echo -e "${YELLOW}Did you mean '--help'? Use './DomainShield.sh --help' for usage information.${NC}"
        return 1
    fi
    
    # Check for single character domains (very unlikely to be valid)
    if [ ${#domain} -lt 2 ]; then
        echo -e "${RED}Error: '$domain' is too short to be a valid domain.${NC}"
        echo -e "${YELLOW}Use './DomainShield.sh --help' for usage information.${NC}"
        return 1
    fi
    
    # Check for very short domains (less than 3 chars) - warn but allow
    if [ ${#domain} -lt 3 ]; then
        echo -e "${YELLOW}Warning: '$domain' is very short. This might not be a valid domain.${NC}"
        echo -e "${YELLOW}If this is a mistake, use './DomainShield.sh --help' for proper usage.${NC}"
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    # Basic domain format validation
    if echo "$domain" | grep -Eq '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'; then
        return 0
    else
        echo -e "${RED}Error: '$domain' is not a valid domain format.${NC}"
        echo -e "${YELLOW}Please provide a valid domain name (e.g., example.com)${NC}"
        return 1
    fi
}

# Function to detect common typos
detect_typos() {
    local arg="$1"
    
    case "$arg" in
        "h"|"he"|"hel"|"help")
            echo -e "${YELLOW}Did you mean '--help'? Use './DomainShield.sh --help' for usage information.${NC}"
            return 0
            ;;
        "-H"|"-HE"|"-HELP")
            echo -e "${YELLOW}Did you mean '--help'? Use './DomainShield.sh --help' for usage information.${NC}"
            return 0
            ;;
        "v"|"ve"|"ver"|"verb"|"verbo"|"verbos"|"verbose")
            echo -e "${YELLOW}Did you mean '--verbose'? Use './DomainShield.sh --verbose domain.com'${NC}"
            return 0
            ;;
        "q"|"qu"|"qui"|"quie"|"quiet")
            echo -e "${YELLOW}Did you mean '--quiet'? Use './DomainShield.sh --quiet domain.com'${NC}"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Initialize variables
DOMAIN=""
VERBOSE=false
QUIET=false
CUSTOM_OUTPUT_DIR=""
NO_HTML=false
NO_NETWORK=false
DNS_ONLY=false
EMAIL_ONLY=false
REPORT_ONLY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -o|--output)
            CUSTOM_OUTPUT_DIR="$2"
            shift 2
            ;;
        -r|--report-only)
            REPORT_ONLY=true
            shift
            ;;
        --no-html)
            NO_HTML=true
            shift
            ;;
        --no-network)
            NO_NETWORK=true
            shift
            ;;
        --dns-only)
            DNS_ONLY=true
            shift
            ;;
        --email-only)
            EMAIL_ONLY=true
            shift
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}"
            echo -e "${YELLOW}Use -h or --help for usage information.${NC}"
            exit 1
            ;;
        *)
            # First, check for common typos
            if detect_typos "$1"; then
                exit 1
            fi
            
            # Clean and validate the domain
            RAW_DOMAIN="$1"
            CLEANED_DOMAIN=$(clean_domain "$RAW_DOMAIN")
            
            if validate_domain "$CLEANED_DOMAIN"; then
                DOMAIN="$CLEANED_DOMAIN"
            else
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if domain is provided
if [ -z "$DOMAIN" ]; then
    clear
    cat << 'EOF'

╔════════════════════════════════════════════════════════════════╗
║                         DomainShield                           ║
║                 DNS & EMAIL SECURITY AUDITOR                   ║
║                  Automated Assessment Tool                     ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${RED}Error: No domain specified${NC}"
    echo ""
    echo -e "${YELLOW}Usage: ./DomainShield.sh [OPTIONS] <domain>${NC}"
    echo -e "${YELLOW}Use ./DomainShield.sh --help for full usage information.${NC}"
    exit 1
fi

# Show cleaned domain if it was modified
if [ "$RAW_DOMAIN" != "$DOMAIN" ] && [ "$QUIET" = false ]; then
    echo -e "${YELLOW}[INFO]${NC} Cleaned domain input: $RAW_DOMAIN → $DOMAIN"
fi

# Initialize other variables
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
if [ -n "$CUSTOM_OUTPUT_DIR" ]; then
    REPORT_DIR="$CUSTOM_OUTPUT_DIR"
else
    REPORT_DIR="mail_security_audit_${DOMAIN}_${TIMESTAMP}"
fi
HTML_REPORT="${REPORT_DIR}/full_report.html"

# Create report directory
mkdir -p "$REPORT_DIR"

# Function to log messages
log() {
    if [ "$QUIET" = false ]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[VERBOSE]${NC} $1"
    fi
}

warn() {
    if [ "$QUIET" = false ]; then
        echo -e "${YELLOW}[WARN]${NC} $1"
    fi
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    if [ "$QUIET" = false ]; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    fi
}

# Function to check command availability
check_command() {
    if ! command -v $1 &> /dev/null; then
        error "$1 is not installed. Please install it."
        case $1 in
            "dig")
                echo "On Ubuntu/Debian: sudo apt install dnsutils"
                echo "On CentOS/RHEL: sudo yum install bind-utils"
                ;;
            "whois")
                echo "On Ubuntu/Debian: sudo apt install whois"
                echo "On CentOS/RHEL: sudo yum install whois"
                ;;
            "nc")
                echo "On Ubuntu/Debian: sudo apt install netcat"
                echo "On CentOS/RHEL: sudo yum install nc"
                ;;
            "openssl")
                echo "Usually pre-installed. If not:"
                echo "On Ubuntu/Debian: sudo apt install openssl"
                echo "On CentOS/RHEL: sudo yum install openssl"
                ;;
        esac
        exit 2
    fi
}

# Display assessment configuration
show_config() {
    if [ "$QUIET" = false ]; then
        clear
        echo -e "${CYAN}"
        echo "╔══════════════════════════════════════════════════════════╗"
        echo "║                   ASSESSMENT CONFIG                      ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        echo -e "${YELLOW}Domain:${NC} $DOMAIN"
        echo -e "${YELLOW}Output Directory:${NC} $REPORT_DIR"
        echo -e "${YELLOW}Mode:${NC} $(
            if [ "$DNS_ONLY" = true ]; then echo "DNS Only"
            elif [ "$EMAIL_ONLY" = true ]; then echo "Email Only"
            elif [ "$NO_NETWORK" = true ]; then echo "No Network Scanning"
            else echo "Full Assessment"
            fi
        )"
        echo -e "${YELLOW}Reports:${NC} $([ "$NO_HTML" = true ] && echo "Text Only" || echo "HTML + Text")"
        echo -e "${YELLOW}Verbose:${NC} $([ "$VERBOSE" = true ] && echo "Yes" || echo "No")"
        echo ""
    fi
}

# Initialize findings arrays with POC support
declare -a CRITICAL_FINDINGS=()
declare -a HIGH_FINDINGS=()
declare -a MEDIUM_FINDINGS=()
declare -a LOW_FINDINGS=()
declare -a PASSED_CHECKS=()

# Function to add findings with POC
add_finding() {
    local severity="$1"
    local message="$2"
    local recommendation="$3"
    local poc="$4"
    
    case $severity in
        "CRITICAL")
            CRITICAL_FINDINGS+=("$message|$recommendation|$poc")
            ;;
        "HIGH")
            HIGH_FINDINGS+=("$message|$recommendation|$poc")
            ;;
        "MEDIUM")
            MEDIUM_FINDINGS+=("$message|$recommendation|$poc")
            ;;
        "LOW")
            LOW_FINDINGS+=("$message|$recommendation|$poc")
            ;;
        "PASS")
            PASSED_CHECKS+=("$message")
            ;;
    esac
}

# Main assessment functions
assess_dns_infrastructure() {
    log "Assessing DNS infrastructure..."
    
    # Get name servers
    NS_LIST=$(dig NS $DOMAIN +short)
    if [ -z "$NS_LIST" ]; then
        add_finding "CRITICAL" "No name servers found for domain" \
            "Configure proper name servers with your domain registrar" \
            "Command: dig NS $DOMAIN returned no results"
        return
    fi
    
    declare -a NS_IPS=()
    declare -a SUBNETS=()
    
    # Analyze each name server
    for ns in $NS_LIST; do
        ip=$(dig A $ns +short | head -1)
        if [ -n "$ip" ]; then
            NS_IPS+=("$ip")
            subnet=$(echo $ip | cut -d. -f1-3)
            SUBNETS+=("$subnet")
            
            # Check if name server is responsive
            if dig @$ip $DOMAIN SOA +short > /dev/null 2>&1; then
                add_finding "PASS" "Name server $ns ($ip) is responsive"
            else
                add_finding "HIGH" "Name server $ns ($ip) is not responsive" \
                    "Check name server configuration and connectivity" \
                    "Command: dig @$ip $DOMAIN SOA +short failed"
            fi
        fi
    done
    
    # Check subnet diversity
    unique_subnets=$(printf '%s\n' "${SUBNETS[@]}" | sort -u | wc -l)
    if [ $unique_subnets -eq 1 ] && [ ${#NS_IPS[@]} -gt 1 ]; then
        local subnet_poc="Name server IPs: ${NS_IPS[*]} all belong to subnet ${SUBNETS[0]}.0/24"
        add_finding "CRITICAL" "All name servers are on the same subnet" \
            "Distribute name servers across different geographic locations and network subnets" \
            "$subnet_poc"
    elif [ $unique_subnets -lt ${#NS_IPS[@]} ]; then
        local subnet_poc="Name server subnets found: $(printf '%s ' "${SUBNETS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
        add_finding "HIGH" "Some name servers share the same subnet" \
            "Ensure name servers are on different network infrastructure" \
            "$subnet_poc"
    else
        add_finding "PASS" "Name servers are properly distributed across multiple subnets"
    fi
    
    # Check number of name servers
    if [ ${#NS_IPS[@]} -lt 2 ]; then
        add_finding "CRITICAL" "Only one name server configured" \
            "Configure at least 2-4 name servers for redundancy" \
            "Found only ${#NS_IPS[@]} name server(s): ${NS_LIST}"
    fi
}

assess_dns_security() {
    log "Assessing DNS security features..."
    
    # Check for DNSSEC
    if dig $DOMAIN DNSKEY +short | grep -q "257"; then
        add_finding "PASS" "DNSSEC is properly configured"
    else
        add_finding "MEDIUM" "DNSSEC is not configured" \
            "Implement DNSSEC to prevent DNS spoofing and cache poisoning" \
            "Command: dig $DOMAIN DNSKEY +short | grep '257' returned no results"
    fi
    
    # Check for open DNS resolvers
    for ns in $(dig NS $DOMAIN +short); do
        ip=$(dig A $ns +short | head -1)
        # Basic check if it responds to recursive queries
        if dig @$ip google.com A +short > /dev/null 2>&1; then
            add_finding "HIGH" "Name server $ns may be an open resolver" \
                "Configure name servers to only answer for authorized domains" \
                "Name server $ip responded to recursive query for google.com"
        fi
    done
}

assess_email_security() {
    log "Assessing email security (SPF, DKIM, DMARC)..."
    
    # SPF Check
    spf_record=$(dig TXT $DOMAIN +short | grep "v=spf1")
    if [ -n "$spf_record" ]; then
        # Check SPF syntax using online API
        if curl -s "https://dmarcian.com/spf-survey/$DOMAIN" | grep -q "valid" 2>/dev/null; then
            add_finding "PASS" "SPF record is properly configured"
        else
            add_finding "MEDIUM" "SPF record may have syntax issues" \
                "Validate SPF record syntax and mechanisms" \
                "SPF Record: $spf_record"
        fi
        
        # Check for overly permissive SPF
        if echo "$spf_record" | grep -q "\+all"; then
            add_finding "CRITICAL" "SPF record uses +all (allow all)" \
                "Change SPF to ~all (soft fail) or -all (hard fail)" \
                "Vulnerable SPF Record: $spf_record"
        fi
    else
        add_finding "HIGH" "No SPF record found" \
            "Implement SPF record to prevent email spoofing" \
            "Command: dig TXT $DOMAIN +short | grep 'v=spf1' returned no results"
    fi
    
    # DMARC Check
    dmarc_record=$(dig TXT _dmarc.$DOMAIN +short)
    if [ -n "$dmarc_record" ]; then
        if echo "$dmarc_record" | grep -q "v=DMARC1"; then
            # Check DMARC policy
            if echo "$dmarc_record" | grep -q "p=reject"; then
                add_finding "PASS" "DMARC is configured with reject policy (strongest)"
            elif echo "$dmarc_record" | grep -q "p=quarantine"; then
                add_finding "MEDIUM" "DMARC is configured with quarantine policy" \
                    "Consider upgrading to p=reject for maximum protection" \
                    "Current DMARC policy: $dmarc_record"
            elif echo "$dmarc_record" | grep -q "p=none"; then
                add_finding "HIGH" "DMARC is configured with none policy (monitoring only)" \
                    "Upgrade to p=quarantine or p=reject" \
                    "Current DMARC policy: $dmarc_record"
            fi
            
            # Check for reporting
            if echo "$dmarc_record" | grep -q "rua="; then
                add_finding "PASS" "DMARC reporting is configured"
            else
                add_finding "LOW" "DMARC reporting not configured" \
                    "Add rua tag to receive DMARC aggregate reports" \
                    "DMARC record without reporting: $dmarc_record"
            fi
        fi
    else
        add_finding "HIGH" "No DMARC record found" \
            "Implement DMARC policy starting with p=none and monitoring" \
            "Command: dig TXT _dmarc.$DOMAIN +short returned no results"
    fi
    
    # DKIM Check (try common selectors)
    common_selectors=("default" "dkim" "selector1" "selector2" "google" "mail" "k1" "domainkey")
    dkim_found=false
    dkim_poc="Checked selectors: "
    
    for selector in "${common_selectors[@]}"; do
        dkim_record=$(dig TXT ${selector}._domainkey.$DOMAIN +short)
        dkim_poc+="$selector: "
        if [ -n "$dkim_record" ] && echo "$dkim_record" | grep -q "v=DKIM1"; then
            dkim_found=true
            dkim_poc+="FOUND "
            add_finding "PASS" "DKIM record found for selector '$selector'"
            break
        else
            dkim_poc+="NOT_FOUND "
        fi
    done
    
    if [ "$dkim_found" = false ]; then
        add_finding "HIGH" "No DKIM record found for common selectors" \
            "Configure DKIM with your email provider and publish DNS record" \
            "$dkim_poc"
    fi
}

assess_network_security() {
    log "Assessing network security..."
    
    # Get web server IP
    web_ip=$(dig A $DOMAIN +short | head -1)
    
    if [ -n "$web_ip" ]; then
        # Check for common services
        for port in 21 22 23 25 53 80 443 3389; do
            timeout 2 nc -z $web_ip $port > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                local poc="Port $port is open on $web_ip (service: $(get_service_name $port))"
                case $port in
                    22) add_finding "LOW" "SSH service detected on port $port" \
                           "Ensure SSH is properly secured with key authentication" "$poc" ;;
                    25) add_finding "MEDIUM" "SMTP service detected on port $port" \
                           "Ensure proper email server configuration" "$poc" ;;
                    53) add_finding "HIGH" "DNS service detected on port $port" \
                           "Verify if this should be publicly accessible" "$poc" ;;
                    23) add_finding "CRITICAL" "Telnet service detected on port $port" \
                           "Immediately disable telnet and use SSH" "$poc" ;;
                    *) add_finding "LOW" "Service detected on port $port" \
                           "Verify this service needs to be publicly accessible" "$poc" ;;
                esac
            fi
        done
    fi
}

# Helper function to get service name
get_service_name() {
    case $1 in
        21) echo "FTP" ;;
        22) echo "SSH" ;;
        23) echo "Telnet" ;;
        25) echo "SMTP" ;;
        53) echo "DNS" ;;
        80) echo "HTTP" ;;
        443) echo "HTTPS" ;;
        3389) echo "RDP" ;;
        *) echo "Unknown" ;;
    esac
}

assess_ssl_tls() {
    log "Assessing SSL/TLS configuration..."
    
    # Simple SSL check
    if curl -s -I "https://$DOMAIN" --connect-timeout 10 > /dev/null 2>&1; then
        add_finding "PASS" "HTTPS is properly configured and accessible"
        
        # Check certificate expiration
        cert_info=$(echo | openssl s_client -connect $DOMAIN:443 -servername $DOMAIN 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)
        if [ -n "$cert_info" ]; then
            not_after=$(echo "$cert_info" | grep notAfter | cut -d= -f2)
            exp_date=$(date -d "$not_after" +%s 2>/dev/null || date -j -f "%b %d %T %Y %Z" "$not_after" +%s 2>/dev/null)
            current_date=$(date +%s)
            if [ -n "$exp_date" ]; then
                days_until_exp=$(( (exp_date - current_date) / 86400 ))
                
                if [ $days_until_exp -lt 30 ]; then
                    add_finding "HIGH" "SSL certificate expires in $days_until_exp days" \
                        "Renew SSL certificate immediately" \
                        "Certificate expires on: $not_after"
                elif [ $days_until_exp -lt 60 ]; then
                    add_finding "MEDIUM" "SSL certificate expires in $days_until_exp days" \
                        "Plan certificate renewal" \
                        "Certificate expires on: $not_after"
                else
                    add_finding "PASS" "SSL certificate is valid for $days_until_exp days"
                fi
            fi
        fi
    else
        add_finding "HIGH" "HTTPS is not properly configured or accessible" \
            "Configure SSL/TLS certificate for the domain" \
            "Command: curl -I https://$DOMAIN failed"
    fi
}

generate_html_report() {
    log "Generating comprehensive HTML report..."
    
    local temp_html=$(mktemp)

    # Copy logo to report directory to ensure it's always accessible
    if [ -f "Img/DomainShield-Preview.png" ]; then
        cp "Img/DomainShield-Preview.png" "$REPORT_DIR/"
        log "Logo copied to report directory"
    elif [ -f "./DomainShield-Preview.png" ]; then
        cp "./DomainShield-Preview.png" "$REPORT_DIR/"
        log "Logo copied to report directory"
    else
        warn "Logo file not found. Using fallback emoji."
    fi

    cat > "$temp_html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Assessment Report - $DOMAIN</title>
    <link rel="icon" type="image/png" href="DomainShield-Preview.png">

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap');

        body {
            margin: 0;
            padding: 0;
            background: #0c0f17;
            font-family: 'Poppins', sans-serif;
            color: #e8eef5;
            line-height: 1.6;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        /* Header Styles */
        .header {
            padding: 50px 20px;
            background: linear-gradient(135deg, #0d1b2a, #1f3b58);
            border-bottom: 2px solid rgba(255,255,255,0.1);
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
            margin-bottom: 30px;
        }

        .header-content {
            max-width: 900px;
            margin: auto;
            text-align: center;
        }

        .brand-section {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 25px;
            margin-bottom: 25px;
        }

        .shield-icon {
            width: 100px;  /* Increased from 80px */
            height: 100px; /* Increased from 80px */
            filter: drop-shadow(2px 2px 6px rgba(0,0,0,0.4));
            transition: transform 0.3s ease;
            object-fit: contain;
    }

        .shield-icon:hover { 
            transform: scale(1.1); 
            filter: drop-shadow(2px 2px 8px rgba(0,0,0,0.6));
        }

        .fallback-icon {
            font-size: 5em; /* Increased from 4em */
            filter: drop-shadow(2px 2px 6px rgba(0,0,0,0.4));
            transition: transform 0.3s ease;
        }

        .fallback-icon:hover {
            transform: scale(1.1);
        }

        .brand-text h1 {
            font-size: 2.6em;
            margin: 0;
            color: #fff;
            font-weight: 600;
            letter-spacing: 1px;
        }

        .brand-text h2 {
            font-size: 1.25em;
            margin: 5px 0 0;
            color: #dce2e8;
            font-weight: 300;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 22px;
            margin-top: 35px;
        }

        .info-item {
            padding: 18px;
            background: rgba(255,255,255,0.08);
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,0.15);
            backdrop-filter: blur(6px);
            transition: transform 0.25s ease, background 0.25s ease;
        }

        .info-item:hover {
            transform: translateY(-5px);
            background: rgba(255,255,255,0.14);
        }

        .info-label {
            display: block;
            font-size: 0.8em;
            color: #aab7c4;
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .info-value {
            display: block;
            font-size: 1.15em;
            color: #fff;
            font-weight: 500;
        }

        /* Content Section Styles */
        .content-section {
            background: #1a1f2e;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
            border: 1px solid #2a3142;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }

        .section-title {
            color: #fff;
            font-size: 1.5em;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #3498db;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Summary Styles */
        .summary {
            background: linear-gradient(135deg, #2c3e50, #34495e);
            color: #fff;
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 30px;
            border: 1px solid #4a5f7a;
        }

        .summary h3 {
            color: #fff;
            margin-top: 0;
            font-size: 1.4em;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .summary p {
            margin: 12px 0;
            font-size: 1.1em;
            color: #ecf0f1;
        }

        .summary strong {
            color: #fff;
            font-weight: 600;
        }

        /* Finding Styles */
        .critical { 
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white; 
            padding: 20px; 
            margin: 15px 0; 
            border-radius: 8px;
            border-left: 5px solid #ff6b6b;
            box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
        }

        .high { 
            background: linear-gradient(135deg, #e67e22, #d35400);
            color: white; 
            padding: 20px; 
            margin: 15px 0; 
            border-radius: 8px;
            border-left: 5px solid #ffa502;
            box-shadow: 0 4px 12px rgba(230, 126, 34, 0.3);
        }

        .medium { 
            background: linear-gradient(135deg, #f39c12, #e67e22);
            color: white; 
            padding: 20px; 
            margin: 15px 0; 
            border-radius: 8px;
            border-left: 5px solid #ffc312;
            box-shadow: 0 4px 12px rgba(243, 156, 18, 0.3);
        }

        .low { 
            background: linear-gradient(135deg, #3498db, #2980b9);
            color: white; 
            padding: 20px; 
            margin: 15px 0; 
            border-radius: 8px;
            border-left: 5px solid #48dbfb;
            box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
        }

        .pass { 
            background: linear-gradient(135deg, #27ae60, #229954);
            color: white; 
            padding: 20px; 
            margin: 15px 0; 
            border-radius: 8px;
            border-left: 5px solid #2ecc71;
            box-shadow: 0 4px 12px rgba(39, 174, 96, 0.3);
        }

        .finding-item strong {
            font-size: 1.1em;
            display: block;
            margin-bottom: 10px;
        }

        /* FIXED: Better contrast for Recommendation and POC headers */
        .recommendation { 
            background: rgba(255, 255, 255, 0.15); 
            padding: 15px; 
            margin: 12px 0; 
            border-radius: 6px; 
            color: #fff; 
            border-left: 4px solid #f1c40f;
        }

        .recommendation-header {
            font-weight: bold;
            color: #FFD700; /* Bright gold for high contrast */
            margin-bottom: 8px;
            display: block;
            font-size: 1.05em;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: rgba(0, 0, 0, 0.3);
            padding: 4px 8px;
            border-radius: 4px;
            border: 1px solid #FFD700;
        }

        .poc { 
            background: rgba(255, 255, 255, 0.1); 
            padding: 15px; 
            margin: 12px 0; 
            border-radius: 6px; 
            border-left: 4px solid #3498db; 
            font-family: 'Courier New', monospace; 
            font-size: 0.9em; 
            color: #e8eef5;
            word-wrap: break-word;
        }

        .poc-header {
            font-weight: bold;
            color: #00FFFF; /* Bright cyan for high contrast */
            margin-bottom: 8px;
            display: block;
            font-size: 1.05em;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            background: rgba(0, 0, 0, 0.3);
            padding: 4px 8px;
            border-radius: 4px;
            border: 1px solid #00FFFF;
        }

        /* Technical Details Styles */
        .technical-details {
            background: #1a1f2e;
            color: #e8eef5;
        }

        .technical-details h4 {
            color: #3498db;
            margin: 20px 0 10px 0;
            font-size: 1.1em;
        }

        .technical-details pre {
            background: #0c0f17;
            padding: 15px;
            border-radius: 6px;
            border: 1px solid #2a3142;
            color: #aab7c4;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
            overflow-x: auto;
            margin: 10px 0;
        }

        .technical-details ul {
            color: #e8eef5;
            padding-left: 20px;
        }

        .technical-details li {
            margin: 8px 0;
            color: #e8eef5;
        }

        /* Footer Styles */
        footer {
            margin-top: 40px; 
            padding: 25px; 
            background: linear-gradient(135deg, #2c3e50, #34495e);
            color: #ecf0f1; 
            border-radius: 8px;
            text-align: center;
            border: 1px solid #4a5f7a;
        }

        footer p {
            margin: 5px 0;
            color: #ecf0f1;
        }

        footer strong {
            color: #fff;
        }

        /* General Text Styles */
        h3 {
            color: #fff;
            font-size: 1.4em;
            margin: 30px 0 15px 0;
            padding-bottom: 8px;
            border-bottom: 2px solid #3498db;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        h4 {
            color: #3498db;
            margin: 20px 0 10px 0;
        }

        p {
            color: #e8eef5;
            margin: 10px 0;
        }

        /* No Findings Message */
        .no-findings {
            text-align: center;
            color: #aab7c4;
            font-style: italic;
            padding: 20px;
            background: rgba(255,255,255,0.05);
            border-radius: 8px;
            margin: 15px 0;
        }
    </style>
</head>

<body>
    <div class="header">
        <div class="header-content">
            <div class="brand-section">
EOF

    # Check if logo exists in report directory and use appropriate HTML
    if [ -f "$REPORT_DIR/DomainShield-Preview.png" ]; then
        cat >> "$temp_html" << EOF
                <img src="DomainShield-Preview.png" alt="DomainShield Logo" class="shield-icon">
EOF
    else
        cat >> "$temp_html" << EOF
                <div class="fallback-icon">🛡️</div>
EOF
    fi

    cat >> "$temp_html" << EOF
                <div class="brand-text">
                    <h1>DomainShield</h1>
                    <h2>Security Assessment Report</h2>
                </div>
            </div>

            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">Target Domain</span>
                    <span class="info-value">$DOMAIN</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Report Date</span>
                    <span class="info-value">$(date)</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Assessment Type</span>
                    <span class="info-value">DNS & Email Security</span>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <!-- Executive Summary -->
        <div class="summary">
            <h3>📊 Executive Summary</h3>
            <p><strong>Critical Findings:</strong> ${#CRITICAL_FINDINGS[@]}</p>
            <p><strong>High Findings:</strong> ${#HIGH_FINDINGS[@]}</p>
            <p><strong>Medium Findings:</strong> ${#MEDIUM_FINDINGS[@]}</p>
            <p><strong>Low Findings:</strong> ${#LOW_FINDINGS[@]}</p>
            <p><strong>Passed Checks:</strong> ${#PASSED_CHECKS[@]}</p>
        </div>
EOF

    # Critical Findings
    cat >> "$temp_html" << EOF
        <div class="content-section">
            <h3>🚨 Critical Severity Findings</h3>
EOF

    if [ ${#CRITICAL_FINDINGS[@]} -eq 0 ]; then
        cat >> "$temp_html" << EOF
            <div class="no-findings">No critical findings. Good job!</div>
EOF
    else
        for finding in "${CRITICAL_FINDINGS[@]}"; do
            IFS='|' read -r message recommendation poc <<< "$finding"
            cat >> "$temp_html" << EOF
            <div class="critical finding-item">
                <strong>❌ $message</strong>
                <div class="recommendation">
                    <span class="recommendation-header">Recommendation</span>
                    $recommendation
                </div>
                <div class="poc">
                    <span class="poc-header">Proof of Concept</span>
                    $poc
                </div>
            </div>
EOF
        done
    fi

    cat >> "$temp_html" << EOF
        </div>
EOF

    # High Findings
    cat >> "$temp_html" << EOF
        <div class="content-section">
            <h3>⚠️ High Severity Findings</h3>
EOF

    if [ ${#HIGH_FINDINGS[@]} -eq 0 ]; then
        cat >> "$temp_html" << EOF
            <div class="no-findings">No high severity findings.</div>
EOF
    else
        for finding in "${HIGH_FINDINGS[@]}"; do
            IFS='|' read -r message recommendation poc <<< "$finding"
            cat >> "$temp_html" << EOF
            <div class="high finding-item">
                <strong>⚠️ $message</strong>
                <div class="recommendation">
                    <span class="recommendation-header">Recommendation</span>
                    $recommendation
                </div>
                <div class="poc">
                    <span class="poc-header">Proof of Concept</span>
                    $poc
                </div>
            </div>
EOF
        done
    fi

    cat >> "$temp_html" << EOF
        </div>
EOF

    # Medium Findings
    cat >> "$temp_html" << EOF
        <div class="content-section">
            <h3>🔸 Medium Severity Findings</h3>
EOF

    if [ ${#MEDIUM_FINDINGS[@]} -eq 0 ]; then
        cat >> "$temp_html" << EOF
            <div class="no-findings">No medium severity findings.</div>
EOF
    else
        for finding in "${MEDIUM_FINDINGS[@]}"; do
            IFS='|' read -r message recommendation poc <<< "$finding"
            cat >> "$temp_html" << EOF
            <div class="medium finding-item">
                <strong>🔸 $message</strong>
                <div class="recommendation">
                    <span class="recommendation-header">Recommendation</span>
                    $recommendation
                </div>
                <div class="poc">
                    <span class="poc-header">Proof of Concept</span>
                    $poc
                </div>
            </div>
EOF
        done
    fi

    cat >> "$temp_html" << EOF
        </div>
EOF

    # Low Findings
    cat >> "$temp_html" << EOF
        <div class="content-section">
            <h3>ℹ️ Low Severity Findings</h3>
EOF

    if [ ${#LOW_FINDINGS[@]} -eq 0 ]; then
        cat >> "$temp_html" << EOF
            <div class="no-findings">No low severity findings.</div>
EOF
    else
        for finding in "${LOW_FINDINGS[@]}"; do
            IFS='|' read -r message recommendation poc <<< "$finding"
            cat >> "$temp_html" << EOF
            <div class="low finding-item">
                <strong>ℹ️ $message</strong>
                <div class="recommendation">
                    <span class="recommendation-header">Recommendation</span>
                    $recommendation
                </div>
                <div class="poc">
                    <span class="poc-header">Proof of Concept</span>
                    $poc
                </div>
            </div>
EOF
        done
    fi

    cat >> "$temp_html" << EOF
        </div>
EOF

    # Passed Checks
    cat >> "$temp_html" << EOF
        <div class="content-section">
            <h3>✅ Passed Security Checks</h3>
EOF

    if [ ${#PASSED_CHECKS[@]} -eq 0 ]; then
        cat >> "$temp_html" << EOF
            <div class="no-findings">No security checks passed.</div>
EOF
    else
        for finding in "${PASSED_CHECKS[@]}"; do
            cat >> "$temp_html" << EOF
            <div class="pass finding-item">
                <strong>✅ $finding</strong>
            </div>
EOF
        done
    fi

    cat >> "$temp_html" << EOF
        </div>
EOF

    # Technical Details
    cat >> "$temp_html" << EOF
        <div class="content-section technical-details">
            <h3>🔧 Technical Details</h3>
            
            <h4>Name Servers:</h4>
            <pre>$(dig NS $DOMAIN +short 2>/dev/null)</pre>
            
            <h4>SPF Record:</h4>
            <pre>$(dig TXT $DOMAIN +short | grep "spf" 2>/dev/null)</pre>
            
            <h4>DMARC Record:</h4>
            <pre>$(dig TXT _dmarc.$DOMAIN +short 2>/dev/null)</pre>
            
            <h4>IP Addresses:</h4>
            <pre>$(for ns in $(dig NS $DOMAIN +short 2>/dev/null); do 
                ip=$(dig A $ns +short 2>/dev/null | head -1)
                echo "$ns: $ip"
            done)</pre>
        </div>

        <div class="content-section technical-details">
            <h3>📋 Assessment Methodology</h3>
            
            <h4>Security Checks Performed:</h4>
            <ul>
                <li>DNS Infrastructure Analysis</li>
                <li>Email Security (SPF/DKIM/DMARC) Validation</li>
                <li>Network Service Discovery</li>
                <li>SSL/TLS Configuration Check</li>
                <li>DNS Security Extensions (DNSSEC)</li>
                <li>Open Resolver Testing</li>
                <li>Name Server Distribution Analysis</li>
            </ul>
            
            <h4>Tools Used:</h4>
            <ul>
                <li>dig (DNS analysis)</li>
                <li>nslookup</li>
                <li>whois</li>
                <li>curl</li>
                <li>OpenSSL</li>
                <li>netcat</li>
            </ul>
        </div>

        <footer>
            <p><strong>Confidential Report</strong> - For authorized personnel only</p>
            <p>Generated by DomainShield - Automated Mail Security Auditor v1.0</p>
        </footer>
    </div>
</body>
</html>
EOF

    # Move temporary file to final location
    mv "$temp_html" "$HTML_REPORT"
    success "HTML report generated: $HTML_REPORT"
}

generate_text_report() {
    local text_report="${REPORT_DIR}/technical_report.txt"
    
    cat > "$text_report" << EOF
MAIL SECURITY ASSESSMENT REPORT
===============================

Domain: $DOMAIN
Date: $(date)
Generated by: DomainShield - Automated Mail Security Auditor

EXECUTIVE SUMMARY
=================
Critical Findings: ${#CRITICAL_FINDINGS[@]}
High Findings: ${#HIGH_FINDINGS[@]}
Medium Findings: ${#MEDIUM_FINDINGS[@]}
Low Findings: ${#LOW_FINDINGS[@]}
Passed Checks: ${#PASSED_CHECKS[@]}

CRITICAL FINDINGS
=================
EOF

    if [ ${#CRITICAL_FINDINGS[@]} -eq 0 ]; then
        echo "None" >> "$text_report"
    else
        for finding in "${CRITICAL_FINDINGS[@]}"; do
            IFS='|' read -r message recommendation poc <<< "$finding"
            echo "❌ $message" >> "$text_report"
            echo "   Recommendation: $recommendation" >> "$text_report"
            echo "   Proof of Concept: $poc" >> "$text_report"
            echo "" >> "$text_report"
        done
    fi

    cat >> "$text_report" << EOF

HIGH SEVERITY FINDINGS
======================
EOF

    if [ ${#HIGH_FINDINGS[@]} -eq 0 ]; then
        echo "None" >> "$text_report"
    else
        for finding in "${HIGH_FINDINGS[@]}"; do
            IFS='|' read -r message recommendation poc <<< "$finding"
            echo "⚠️ $message" >> "$text_report"
            echo "   Recommendation: $recommendation" >> "$text_report"
            echo "   Proof of Concept: $poc" >> "$text_report"
            echo "" >> "$text_report"
        done
    fi

    cat >> "$text_report" << EOF

MEDIUM SEVERITY FINDINGS
========================
EOF

    if [ ${#MEDIUM_FINDINGS[@]} -eq 0 ]; then
        echo "None" >> "$text_report"
    else
        for finding in "${MEDIUM_FINDINGS[@]}"; do
            IFS='|' read -r message recommendation poc <<< "$finding"
            echo "🔸 $message" >> "$text_report"
            echo "   Recommendation: $recommendation" >> "$text_report"
            echo "   Proof of Concept: $poc" >> "$text_report"
            echo "" >> "$text_report"
        done
    fi

    cat >> "$text_report" << EOF

LOW SEVERITY FINDINGS
=====================
EOF

    if [ ${#LOW_FINDINGS[@]} -eq 0 ]; then
        echo "None" >> "$text_report"
    else
        for finding in "${LOW_FINDINGS[@]}"; do
            IFS='|' read -r message recommendation poc <<< "$finding"
            echo "ℹ️ $message" >> "$text_report"
            echo "   Recommendation: $recommendation" >> "$text_report"
            echo "   Proof of Concept: $poc" >> "$text_report"
            echo "" >> "$text_report"
        done
    fi

    cat >> "$text_report" << EOF

PASSED SECURITY CHECKS
======================
EOF

    if [ ${#PASSED_CHECKS[@]} -eq 0 ]; then
        echo "None" >> "$text_report"
    else
        for finding in "${PASSED_CHECKS[@]}"; do
            echo "✅ $finding" >> "$text_report"
        done
    fi

    cat >> "$text_report" << EOF

TECHNICAL DETAILS
=================
Name Servers:
$(dig NS $DOMAIN +short 2>/dev/null)

IP Addresses:
$(for ns in $(dig NS $DOMAIN +short 2>/dev/null); do 
    ip=$(dig A $ns +short 2>/dev/null | head -1)
    echo "- $ns: $ip"
done)

SPF Record:
$(dig TXT $DOMAIN +short | grep "spf" 2>/dev/null)

DMARC Record:
$(dig TXT _dmarc.$DOMAIN +short 2>/dev/null)

DKIM Records Checked:
$(common_selectors=("default" "dkim" "selector1" "selector2" "google" "mail" "k1" "domainkey")
for selector in "${common_selectors[@]}"; do
    record=$(dig TXT ${selector}._domainkey.$DOMAIN +short 2>/dev/null)
    if [ -n "$record" ] && echo "$record" | grep -q "v=DKIM1"; then
        echo "- $selector: FOUND"
    else
        echo "- $selector: not found"
    fi
done)

ASSESSMENT SCOPE
================
- DNS Infrastructure Security
- Email Authentication (SPF, DKIM, DMARC)
- Network Service Exposure
- SSL/TLS Configuration
- Name Server Distribution
- DNSSEC Validation
- Open Resolver Testing

RECOMMENDATION PRIORITY
=======================
1. Address CRITICAL findings immediately
2. Resolve HIGH severity findings within 1 week
3. Plan MEDIUM severity fixes within 1 month
4. Review LOW severity items as capacity allows

EOF
}

# Main execution
main() {
    # Show configuration
    show_config
    
    log "Starting comprehensive security assessment for: $DOMAIN"
    log "Report directory: $REPORT_DIR"
    
    # Check required tools
    log "Checking required tools..."
    check_command dig
    check_command whois
    check_command nslookup
    check_command curl
    if [ "$NO_NETWORK" = false ]; then
        check_command nc
    fi
    
    # Run assessments based on options
    if [ "$DNS_ONLY" = true ]; then
        log "Running DNS-only assessment..."
        assess_dns_infrastructure
        assess_dns_security
    elif [ "$EMAIL_ONLY" = true ]; then
        log "Running email-only assessment..."
        assess_email_security
    else
        # Full assessment
        log "Running full security assessment..."
        assess_dns_infrastructure
        assess_dns_security
        assess_email_security
        if [ "$NO_NETWORK" = false ]; then
            assess_network_security
        fi
        assess_ssl_tls
    fi
    
    # Generate reports
    if [ "$NO_HTML" = false ]; then
        generate_html_report
    fi
    generate_text_report
    
    # Summary - Always show this, even in quiet mode
    echo ""
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                         DomainShield                           ║"
    echo "║                 DNS & EMAIL SECURITY AUDITOR                   ║"
    echo "║                  Automated Assessment Tool                     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${GREEN}=== ASSESSMENT SUMMARY ===${NC}"
    echo -e "${RED}Critical:${NC} ${#CRITICAL_FINDINGS[@]}"
    echo -e "${YELLOW}High:${NC} ${#HIGH_FINDINGS[@]}"
    echo -e "${BLUE}Medium:${NC} ${#MEDIUM_FINDINGS[@]}"
    echo -e "${CYAN}Low:${NC} ${#LOW_FINDINGS[@]}"
    echo -e "${PURPLE}Passed:${NC} ${#PASSED_CHECKS[@]}"
    echo ""
    
    # Only show these additional messages if not in quiet mode
    if [ "$QUIET" = false ]; then
        success "Assessment completed!"
        log "Reports generated in: $REPORT_DIR"
        if [ "$NO_HTML" = false ]; then
            log "HTML Report: $HTML_REPORT"
        fi
        log "Text Report: $REPORT_DIR/technical_report.txt"
    fi
    
    # Final recommendations - Always show critical warnings
    if [ ${#CRITICAL_FINDINGS[@]} -gt 0 ]; then
        echo -e "${RED}🚨 URGENT: Critical findings require immediate attention!${NC}"
    fi
}

# Run main function
main "$@"
