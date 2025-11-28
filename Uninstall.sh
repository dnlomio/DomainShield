#!/bin/bash

# DomainShield Uninstaller
# Author: Debajyoti0-0
# Description: Removes DomainShield and optional tools

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

# Function to remove package
remove_package() {
    local pm="$1"
    local package="$2"
    local name="$3"
    
    if ! command_exists "$package" 2>/dev/null; then
        print_status "$name is not installed"
        return 0
    fi
    
    print_status "Removing $name..."
    
    case $pm in
        apt)
            sudo apt remove -y "$package" >/dev/null 2>&1
            ;;
        yum)
            sudo yum remove -y "$package" >/dev/null 2>&1
            ;;
        dnf)
            sudo dnf remove -y "$package" >/dev/null 2>&1
            ;;
        pacman)
            sudo pacman -R --noconfirm "$package" >/dev/null 2>&1
            ;;
        zypper)
            sudo zypper remove -y "$package" >/dev/null 2>&1
            ;;
    esac
    
    if ! command_exists "$package" 2>/dev/null; then
        print_success "$name removed successfully"
        return 0
    else
        print_error "Failed to remove $name"
        return 1
    fi
}

# Function to remove symlink
remove_symlink() {
    print_status "Removing DomainShield symlink..."
    
    if [ -L "/usr/local/bin/domainshield" ]; then
        if sudo rm "/usr/local/bin/domainshield" 2>/dev/null; then
            print_success "Symlink removed: /usr/local/bin/domainshield"
            return 0
        else
            print_error "Failed to remove symlink. You may need to run with sudo."
            return 1
        fi
    else
        print_status "DomainShield symlink not found"
        return 0
    fi
}

# Function to get package names based on package manager
get_package_names() {
    local pm="$1"
    
    case $pm in
        apt)
            echo "dnsutils whois curl openssl netcat"
            ;;
        yum|dnf)
            echo "bind-utils whois curl openssl nc"
            ;;
        pacman)
            echo "bind-tools whois curl openssl netcat"
            ;;
        zypper)
            echo "bind-utils whois curl openssl netcat"
            ;;
    esac
}

# Function to get tool names for display
get_tool_names() {
    echo "dnsutils,whois,curl,openssl,netcat"
}

# Function to check yes/no input
confirm_yes_no() {
    local prompt="$1"
    local default="${2:-no}"
    
    while true; do
        read -p "$prompt [y/N]: " answer
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
        
        case "$answer" in
            y|yes)
                return 0
                ;;
            n|no|"")
                return 1
                ;;
            *)
                echo "Please answer yes (y) or no (n)."
                ;;
        esac
    done
}

# Function to uninstall tools
uninstall_tools() {
    local pm="$1"
    local selection="$2"
    
    case $pm in
        apt)
            case $selection in
                dnsutils) remove_package "$pm" "dnsutils" "dnsutils (dig/nslookup)" ;;
                whois) remove_package "$pm" "whois" "whois" ;;
                curl) remove_package "$pm" "curl" "curl" ;;
                openssl) remove_package "$pm" "openssl" "openssl" ;;
                netcat) remove_package "$pm" "netcat" "netcat" ;;
            esac
            ;;
        yum|dnf)
            case $selection in
                dnsutils) remove_package "$pm" "bind-utils" "bind-utils (dig/nslookup)" ;;
                whois) remove_package "$pm" "whois" "whois" ;;
                curl) remove_package "$pm" "curl" "curl" ;;
                openssl) remove_package "$pm" "openssl" "openssl" ;;
                netcat) remove_package "$pm" "nc" "netcat" ;;
            esac
            ;;
        pacman)
            case $selection in
                dnsutils) remove_package "$pm" "bind-tools" "bind-tools (dig/nslookup)" ;;
                whois) remove_package "$pm" "whois" "whois" ;;
                curl) remove_package "$pm" "curl" "curl" ;;
                openssl) remove_package "$pm" "openssl" "openssl" ;;
                netcat) remove_package "$pm" "netcat" "netcat" ;;
            esac
            ;;
        zypper)
            case $selection in
                dnsutils) remove_package "$pm" "bind-utils" "bind-utils (dig/nslookup)" ;;
                whois) remove_package "$pm" "whois" "whois" ;;
                curl) remove_package "$pm" "curl" "curl" ;;
                openssl) remove_package "$pm" "openssl" "openssl" ;;
                netcat) remove_package "$pm" "netcat" "netcat" ;;
            esac
            ;;
    esac
}

# Function to handle tool uninstallation
handle_tool_uninstallation() {
    local pm="$1"
    
    echo
    if confirm_yes_no "Do you want to uninstall any tools?"; then
        echo
        print_status "Available tools to uninstall:"
        echo -e "${YELLOW}$(get_tool_names)${NC}"
        echo
        echo "You can:"
        echo "  - Type 'all' to uninstall all tools"
        echo "  - Type a specific tool name (e.g., dnsutils)"
        echo "  - Type 'none' to skip tool uninstallation"
        echo
        
        while true; do
            read -p "Enter your choice: " choice
            choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
            
            case "$choice" in
                all)
                    echo
                    print_status "Uninstalling all tools..."
                    echo
                    uninstall_tools "$pm" "dnsutils"
                    uninstall_tools "$pm" "whois"
                    uninstall_tools "$pm" "curl"
                    uninstall_tools "$pm" "openssl"
                    uninstall_tools "$pm" "netcat"
                    break
                    ;;
                dnsutils|whois|curl|openssl|netcat)
                    echo
                    uninstall_tools "$pm" "$choice"
                    break
                    ;;
                none|skip)
                    print_status "Skipping tool uninstallation"
                    break
                    ;;
                "")
                    print_status "No input provided, skipping tool uninstallation"
                    break
                    ;;
                *)
                    print_error "Invalid choice: $choice"
                    echo "Valid choices: all, dnsutils, whois, curl, openssl, netcat, none"
                    echo
                    ;;
            esac
        done
    else
        print_status "Skipping tool uninstallation"
    fi
}

# Main uninstallation function
main() {
    clear
    echo -e "${RED}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                   DomainShield Uninstaller                     ║
║                 DNS & EMAIL SECURITY AUDITOR                   ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo
    
    # Check if user is root or has sudo privileges
    if [ "$EUID" -ne 0 ] && ! command_exists sudo && ! command_exists su; then
        print_error "This script requires sudo privileges or root access"
        exit 1
    fi
    
    # Remove symlink
    remove_symlink
    
    # Detect package manager for tool uninstallation
    PM=$(detect_package_manager)
    
    if [ "$PM" = "unknown" ]; then
        print_warning "Unsupported package manager detected."
        print_status "Skipping tool uninstallation (manual removal required)"
    else
        print_success "Detected package manager: $PM"
        handle_tool_uninstallation "$PM"
    fi
    
    echo
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}✅ Uninstallation completed!${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo
    echo "DomainShield has been uninstalled."
    echo "The script files in the current directory remain intact."
    echo
    echo "To reinstall, run: ./install.sh"
}

# Help function
show_help() {
    echo "DomainShield Uninstaller"
    echo ""
    echo "This script removes DomainShield symlink and optionally uninstalls tools."
    echo ""
    echo "Usage: ./Uninstall.sh"
    echo ""
    echo "The script will:"
    echo "  1. Remove the domainshield symlink from /usr/local/bin/"
    echo "  2. Ask if you want to uninstall any tools"
    echo "  3. Provide options to uninstall specific tools or all tools"
    echo ""
    echo "Available tools to uninstall:"
    echo "  - dnsutils/bind-utils (dig, nslookup)"
    echo "  - whois"
    echo "  - curl"
    echo "  - openssl"
    echo "  - netcat"
    echo ""
    echo "Note: The DomainShield script files will remain in the current directory."
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
