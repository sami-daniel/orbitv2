#!/bin/bash

PROJECT_DIR="src/Orbit.Infrastructure"
MIGRATIONS_DIR="Data/Migrations"
SCRIPT_OUTPUT="migration_script.sql"

show_help() {
    echo "Entity Framework Core Migration Helper"
    echo "Usage: $0 <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  add <name>        Create new migration"
    echo "  remove            Remove last pending migration"
    echo "  list              List all migrations"
    echo "  up [migration]    Apply migrations (to latest or specific)"
    echo "  down <migration>  Revert to specific migration"
    echo "  script [from] [to] Generate SQL script"
    echo "  help              Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 add InitialCreate"
    echo "  $0 up"
    echo "  $0 down 20230624120000_InitialCreate"
    echo "  $0 script 20230624120000_InitialCreate 20230625140000_UpdateTables"
}

run_ef() {
    echo "Executing: '$@'"
    DB_CONNECTION="$DB_CONNECTION" dotnet ef "$@" \
        --project "$PROJECT_DIR"
}

add_migration() {
    if [ -z "$1" ]; then
        echo "Error: Migration name required"
        exit 1
    fi
    run_ef migrations add "$1" --output-dir "$MIGRATIONS_DIR"
}

remove_migration() {
    run_ef migrations remove
}

list_migrations() {
    run_ef migrations list
}

update_database() {
    if [ -z "$1" ]; then
        run_ef database update
    else
        run_ef database update "$1"
    fi
}

rollback_migration() {
    if [ -z "$1" ]; then
        echo "Error: Target migration name required for rollback"
        exit 1
    fi

    PREV_MIGRATION=$(list_migrations | grep -B1 "$1" | sort | head -n1)

    if [ -z "$PREV_MIGRATION" ]; then
        echo "Error: No migration found before '$1'"
        exit 1
    fi

    echo "Rolling back to: $PREV_MIGRATION"
    update_database "$PREV_MIGRATION"
}

generate_script() {
    SCRIPT_CMD="migrations script"
    [ -n "$1" ] && SCRIPT_CMD="$SCRIPT_CMD $1"
    [ -n "$2" ] && SCRIPT_CMD="$SCRIPT_CMD $2"

    run_ef $SCRIPT_CMD --output "$SCRIPT_OUTPUT"
    echo "SQL script generated at: $SCRIPT_OUTPUT"
}

main() {
    local command=$1
    shift

    case $command in
        add)
            add_migration "$@"
            ;;
        remove)
            remove_migration
            ;;
        list)
            list_migrations
            ;;
        up)
            update_database "$1"
            ;;
        down)
            rollback_migration "$1"
            ;;
        script)
            generate_script "$1" "$2"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Invalid command: $command"
            show_help
            exit 1
            ;;
    esac
}

if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

main "$@"
