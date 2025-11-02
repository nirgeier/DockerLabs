#!/bin/bash

# Script to run different Docker Compose examples
# This helps you test each example independently

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker Compose V2 is available
check_docker_compose() {
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose V2 is required but not installed"
        print_info "Please install Docker Compose V2: https://docs.docker.com/compose/install/"
        exit 1
    fi
    print_info "Docker Compose version: $(docker compose version --short)"
}

# Function to validate compose file
validate_compose() {
    local file=$1
    print_info "Validating $file..."
    if docker compose -f "$file" config --quiet; then
        print_info "✓ $file is valid"
        return 0
    else
        print_error "✗ $file has errors"
        return 1
    fi
}

# Function to show merged configuration
show_config() {
    local file=$1
    print_info "Merged configuration for $file:"
    docker compose -f "$file" config
}

# Function to run an example
run_example() {
    local file=$1
    local example_name=$2
    
    print_info "=========================================="
    print_info "Running Example: $example_name"
    print_info "File: $file"
    print_info "=========================================="
    
    # Validate first
    if ! validate_compose "$file"; then
        print_error "Skipping $example_name due to validation errors"
        return 1
    fi
    
    # Start services
    print_info "Starting services..."
    docker compose -f "$file" up -d
    
    # Show status
    print_info "Service status:"
    docker compose -f "$file" ps
    
    # Show logs
    print_info "Recent logs:"
    docker compose -f "$file" logs --tail=20
    
    print_warn "Services are running. Press Enter to stop them, or Ctrl+C to keep them running..."
    read -r
    
    # Stop services
    print_info "Stopping services..."
    docker compose -f "$file" down
    
    print_info "Example completed: $example_name"
    echo ""
}

# Function to cleanup all examples
cleanup_all() {
    print_info "Cleaning up all examples..."
    
    for file in 01-*.yml 02-*.yml 03-*.yml 04-*.yml 05-*.yml; do
        if [ -f "$file" ]; then
            print_info "Stopping $file..."
            docker compose -f "$file" down -v 2>/dev/null || true
        fi
    done
    
    print_info "Cleanup completed"
}

# Function to show menu
show_menu() {
    echo ""
    echo "Docker Compose Fragments Examples"
    echo "=================================="
    echo "1. Basic Fragments (01-basic-fragments.yml)"
    echo "2. Extension Fields (02-extension-fields.yml)"
    echo "3. Merge Multiple Anchors (03-merge-multiple-anchors.yml)"
    echo "4. Include with Fragments (04-with-include.yml)"
    echo "5. Complete Modular Setup (05-modular-complete.yml)"
    echo "=================================="
    echo "v. Validate all examples"
    echo "c. Show merged config for an example"
    echo "x. Cleanup all"
    echo "q. Quit"
    echo ""
}

# Main script
main() {
    check_docker_compose
    
    if [ "$1" = "validate" ]; then
        print_info "Validating all examples..."
        for file in 01-*.yml 02-*.yml 03-*.yml 04-*.yml 05-*.yml; do
            if [ -f "$file" ]; then
                validate_compose "$file"
            fi
        done
        exit 0
    fi
    
    if [ "$1" = "cleanup" ]; then
        cleanup_all
        exit 0
    fi
    
    # Interactive mode
    while true; do
        show_menu
        read -p "Select an option: " choice
        
        case $choice in
            1)
                run_example "01-basic-fragments.yml" "Basic Fragments"
                ;;
            2)
                run_example "02-extension-fields.yml" "Extension Fields"
                ;;
            3)
                run_example "03-merge-multiple-anchors.yml" "Merge Multiple Anchors"
                ;;
            4)
                run_example "04-with-include.yml" "Include with Fragments"
                ;;
            5)
                run_example "05-modular-complete.yml" "Complete Modular Setup"
                ;;
            v|V)
                for file in 01-*.yml 02-*.yml 03-*.yml 04-*.yml 05-*.yml; do
                    if [ -f "$file" ]; then
                        validate_compose "$file"
                    fi
                done
                ;;
            c|C)
                echo "Enter example number (1-5):"
                read -r num
                case $num in
                    1) show_config "01-basic-fragments.yml" ;;
                    2) show_config "02-extension-fields.yml" ;;
                    3) show_config "03-merge-multiple-anchors.yml" ;;
                    4) show_config "04-with-include.yml" ;;
                    5) show_config "05-modular-complete.yml" ;;
                    *) print_error "Invalid example number" ;;
                esac
                ;;
            x|X)
                cleanup_all
                ;;
            q|Q)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option"
                ;;
        esac
    done
}

# Run main function
main "$@"
