# Yonas

Yonas is a Discord-integrated Ruby on Rails application for managing New World game communities. It automates various 
tasks, such as player build registrations, PvP group creation, announcement notifications for game events and updates.

## Requirements
- Ruby (see `.ruby-version` or Gemfile for version)
- Rails (see Gemfile for version)
- Bundler
- Docker (optional)

## Setup
1. Install dependencies:
   ```sh
   bundle install
   ```
2. Set up the database:
   ```sh
   rails db:create db:migrate db:seed
   ```
3. (Optional) Start with Docker:
   ```sh
   docker-compose up
   ```

## Configuration
- Edit `config/database.yml` for database settings.
- Credentials are managed in `config/credentials.yml.enc`.

## Running the Application
```sh
rails server
```
Visit [http://localhost:3000](http://localhost:3000).

## Testing
Run the test suite:
```sh
bundle exec rspec
```

## Tasks

Yonas includes the following scheduled tasks:

- **Player Builds Cleanup**: Periodically deletes player builds for users who are no longer members of the Discord server.
- **New World Notifications**: (See `app/tasks/new_world_notifications.rb`) Handles notifications related to New World updates and events.

## Functionality & Bot Commands

Yonas provides a Discord bot with the following commands, grouped by category:

- Commands (General & Server Management)
    - /help
    - /server_online
    - /server_status
    - /subscribe_to_updates
    - /unsubscribe_to_updates
    - /scorpio
    - /scorpio_stop
    - /list_members
    - /roll
- Forms (Company Application)
    - /apply
- InfluencePush (Influence Push Management)
    - /register_influence_push
    - /influence_push_player_totals
- PlayerBuilds (PvP Build Search)
    - /search_pvp_builds
- PvpGroups (PvP Group Creation)
    - /create_pvp_groups

Each command may have specific role requirements (e.g., member, staff, governor, guest).

## Future Planned Features

- **War Events Registration & Grouping**: Players will be able to register for war events. Groups will be created for these events, with the option to use predefined groups for organization.
- **PvP Groups Improvements**: The PvP group creation feature will be enhanced to support specifying the number of players per group, allowing for more flexible team sizes.

## Deployment
- See `Dockerfile` for containerization.
- Standard Rails deployment supported.

## Contributing
Pull requests are welcome. For major changes, open an issue first.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
