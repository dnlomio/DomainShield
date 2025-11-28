#!/bin/bash

# DomainShield Requirements Installer
# Author: Debajyoti0-0
# Description: Installs all required tools for DomainShield

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect package manager
detect_package_manager() {
    if command_exists apt; then
        echo "apt"
    elif command_exists yum; then
        echo "yum"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists zypper; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# Function to update package lists (silent)
update_package_lists() {
    local pm="$1"
    print_status "Updating package lists..."
    
    case $pm in
        apt)
            sudo apt update >/dev/null 2>&1
            ;;
        yum)
            sudo yum check-update >/dev/null 2>&1 || true
            ;;
        dnf)
            sudo dnf check-update >/dev/null 2>&1 || true
            ;;
        pacman)
            sudo pacman -Sy >/dev/null 2>&1
            ;;
        zypper)
            sudo zypper refresh >/dev/null 2>&1
            ;;
    esac
}

# Function to install package (silent)
install_package() {
    local pm="$1"
    local package="$2"
    local name="$3"
    
    if command_exists "$package"; then
        print_success "$name is already installed"
        return 0
    fi
    
    print_status "Installing $name..."
    
    case $pm in
        apt)
            sudo apt install -y "$package" >/dev/null 2>&1
            ;;
        yum)
            sudo yum install -y "$package" >/dev/null 2>&1
            ;;
        dnf)
            sudo dnf install -y "$package" >/dev/null 2>&1
            ;;
        pacman)
            sudo pacman -S --noconfirm "$package" >/dev/null 2>&1
            ;;
        zypper)
            sudo zypper install -y "$package" >/dev/null 2>&1
            ;;
    esac
    
    if command_exists "$package"; then
        print_success "$name installed successfully"
        return 0
    else
        print_error "Failed to install $name"
        return 1
    fi
}

# Function to create symlink for global access
create_symlink() {
    local script_path="$1"
    
    if [ ! -f "$script_path" ]; then
        print_error "DomainShield.sh not found at: $script_path"
        return 1
    fi
    
    print_status "Creating global symlink..."
    
    # Remove existing symlink if it exists
    if [ -L "/usr/local/bin/domainshield" ]; then
        sudo rm "/usr/local/bin/domainshield"
    fi
    
    # Create new symlink
    if sudo ln -s "$script_path" "/usr/local/bin/domainshield" 2>/dev/null; then
        sudo chmod +x "/usr/local/bin/domainshield"
        print_success "Symlink created: /usr/local/bin/domainshield"
        return 0
    else
        print_error "Failed to create symlink. You may need to run with sudo."
        return 1
    fi
}

# Function to install specific tools based on package manager
install_tools() {
    local pm="$1"
    
    case $pm in
        apt)
            # Ubuntu/Debian
            install_package "$pm" "dnsutils" "dig/nslookup"
            install_package "$pm" "whois" "whois"
            install_package "$pm" "curl" "curl"
            install_package "$pm" "openssl" "openssl"
            install_package "$pm" "netcat" "netcat"
            ;;
        yum|dnf)
            # CentOS/RHEL/Fedora
            install_package "$pm" "bind-utils" "dig/nslookup"
            install_package "$pm" "whois" "whois"
            install_package "$pm" "curl" "curl"
            install_package "$pm" "openssl" "openssl"
            install_package "$pm" "nc" "netcat"
            ;;
        pacman)
            # Arch Linux
            install_package "$pm" "bind-tools" "dig/nslookup"
            install_package "$pm" "whois" "whois"
            install_package "$pm" "curl" "curl"
            install_package "$pm" "openssl" "openssl"
            install_package "$pm" "netcat" "netcat"
            ;;
        zypper)
            # openSUSE
            install_package "$pm" "bind-utils" "dig/nslookup"
            install_package "$pm" "whois" "whois"
            install_package "$pm" "curl" "curl"
            install_package "$pm" "openssl" "openssl"
            install_package "$pm" "netcat" "netcat"
            ;;
    esac
}

# Main installation function
main() {
    clear
    echo -e "${GREEN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                    DomainShield Installer                      ║
║                 DNS & EMAIL SECURITY AUDITOR                   ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo
    
    # Check if user is root or has sudo privileges
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root user"
    elif ! command_exists sudo && ! command_exists su; then
        print_error "This script requires sudo privileges or root access"
        exit 1
    fi
    
    # Detect package manager
    print_status "Detecting package manager..."
    PM=$(detect_package_manager)
    
    if [ "$PM" = "unknown" ]; then
        print_error "Unsupported package manager. Please install tools manually."
        echo "Required tools:"
        echo "  - dig (dnsutils or bind-utils)"
        echo "  - whois"
        echo "  - curl"
        echo "  - openssl"
        echo "  - nc (netcat)"
        exit 1
    fi
    
    print_success "Detected package manager: $PM"
    
    # Update package lists
    update_package_lists "$PM"
    
    # Install tools
    print_status "Installing required tools..."
    install_tools "$PM"
    
    # Verify installations
    print_status "Verifying installations..."
    
    local all_installed=true
    local tools=("dig" "whois" "nslookup" "curl" "openssl" "nc")
    local tool_names=("dig" "whois" "nslookup" "curl" "openssl" "netcat")
    
    for i in "${!tools[@]}"; do
        tool="${tools[$i]}"
        name="${tool_names[$i]}"
        
        if command_exists "$tool"; then
            print_success "$name is installed and accessible"
        else
            print_error "$name is not installed or not in PATH"
            all_installed=false
        fi
    done
    
    # Create symlink for global access
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    SCRIPT_PATH="$SCRIPT_DIR/DomainShield.sh"
    
    if [ "$all_installed" = true ] && [ -f "$SCRIPT_PATH" ]; then
        create_symlink "$SCRIPT_PATH"
        SYMLINK_CREATED=$?
    else
        SYMLINK_CREATED=1
    fi
    
    echo
    if [ "$all_installed" = true ]; then
    	sleep 2;
    	clear
    	echo -e "${GREEN}"
    	cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                    DomainShield Installer                      ║
║                 DNS & EMAIL SECURITY AUDITOR                   ║
╚════════════════════════════════════════════════════════════════╝
EOF
        echo -e "${GREEN}=========================================${NC}"
        echo -e "${GREEN}✅ All requirements installed successfully!${NC}"
        echo -e "${GREEN}=========================================${NC}"
        echo
        
        if [ "$SYMLINK_CREATED" -eq 0 ]; then
            echo "You can now use DomainShield from anywhere:"
            echo "  domainshield example.com"
            echo
            echo "Or using the direct path:"
            echo "  ./DomainShield.sh example.com"
        else
            echo "You can now use DomainShield:"
            echo "  ./DomainShield.sh example.com"
            echo
            echo "To use from anywhere, run:"
            echo "  sudo ln -s \"$SCRIPT_PATH\" /usr/local/bin/domainshield"
        fi
        
        echo
        echo "For more information:"
        echo "  domainshield --help  (or ./DomainShield.sh --help)"
        echo
        echo -e "${GREEN}You can use DomainShield directly in your terminal${NC}"
        echo -e "${GREEN}to perform security assessments on any domain!${NC}"
    else
        echo -e "${YELLOW}=========================================${NC}"
        echo -e "${YELLOW}⚠️  Some tools may need manual installation${NC}"
        echo -e "${YELLOW}=========================================${NC}"
        echo
        echo "Please install missing tools manually and ensure they are in your PATH."
    fi
}

# Help function
show_help() {
    echo "DomainShield Requirements Installer"
    echo ""
    echo "This script installs all required tools for DomainShield:"
    echo "  - dig, nslookup (DNS analysis)"
    echo "  - whois (Domain information)"
    echo "  - curl (Web requests)"
    echo "  - openssl (SSL/TLS checks)"
    echo "  - nc (Network connectivity)"
    echo ""
    echo "Usage: ./install.sh"
    echo ""
    echo "Supported package managers:"
    echo "  - apt (Ubuntu/Debian)"
    echo "  - yum (CentOS/RHEL)"
    echo "  - dnf (Fedora)"
    echo "  - pacman (Arch Linux)"
    echo "  - zypper (openSUSE)"
    echo ""
    echo "The script will automatically detect your system and install the appropriate packages."
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main
        ;;
esac
