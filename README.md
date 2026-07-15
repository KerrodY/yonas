# Yonas

Yonas is a Discord-integrated Ruby on Rails application for managing [New World](https://www.newworld.com) game communities. It automates server setup, player build registration, PvP group creation, company applications, influence push tracking, and game update notifications — all through Discord slash commands.

## Tech Stack

| Technology | Purpose |
|---|---|
| Ruby 4.0.5 | Language |
| Rails 8.1 | Web framework |
| SQLite3 | Database |
| [Discordrb](https://github.com/shardlab/discordrb) | Discord bot framework |
| [Nokogiri](https://nokogiri.org/) | Web scraping (server status, news articles) |
| [Rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) | Recurring scheduled tasks |
| Puma | Web server |
| RSpec | Testing |
| Docker | Containerised deployment |

## Project Structure

```
app/
├── commands/        # Discord slash command modules
│   ├── commands.rb        # General & server management commands
│   ├── forms.rb           # Company application commands
│   ├── influence_push.rb  # Influence push tracking commands
│   ├── player_builds.rb   # PvP build registration commands
│   └── pvp_groups.rb      # PvP group creation commands
├── models/          # ActiveRecord models
├── services/        # Bot singleton, server setup, boot logic
│   ├── discord_bot.rb     # Bot singleton with event listeners
│   ├── setup.rb           # Auto-creates roles, channels, reaction roles
│   └── start_bot.rb       # Initialises and authenticates the bot
├── tasks/           # Scheduled background tasks
│   ├── new_world_notifications.rb  # Server status & news monitoring
│   └── player_builds_task.rb       # Non-member build cleanup
config/
├── initializers/
│   └── bot.rb       # Entrypoint — starts tasks and bot on Rails boot
lib/
├── authenticate_user.rb  # Role-based command access control
└── data.rb               # Constants (roles, channels, weapons, etc.)
```

## CI/CD

Pushes to `master` are built and deployed by [Buildkite](https://buildkite.com) via an agent on the Raspberry Pi. The pipeline (`.buildkite/pipeline.yml`) lints and runs specs in Docker, builds the production image, and replaces the running container — health-checked against `/up`. Secrets come from Rails encrypted credentials (`config/credentials/production.yml.enc`), decrypted with the key at `/etc/yonas/master.key` on the Pi.

## Setup

### Requirements

- Ruby 4.0.5
- Bundler
- Docker (optional)

### Installation

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

### Configuration

- Database settings: `config/database.yml`
- Discord bot token and secrets: `config/credentials.yml.enc`

### Running

```sh
rails server
```

On boot, `config/initializers/bot.rb` starts the scheduled tasks and Discord bot automatically (skipped in test environment and Rails console).

### Testing

```sh
bundle exec rspec
```

## Roles & Permissions

Yonas automatically creates and manages Discord roles on each server. These control both Discord server permissions and bot command access.

### Company Roles

Permissions are cumulative — each role inherits all permissions from the roles below it.

| Role | Colour | Discord Permissions | Purpose |
|---|---|---|---|
| **Governor** | 🟣 Purple | Administrator | Full server control |
| **Consul** | 🔴 Red | + priority speaker, kick/ban members, manage channels & roles | Senior leadership |
| **Officer** | 🟠 Orange | + move/mute/deafen members, manage nicknames & messages | Moderation |
| **Member** | 🔵 Blue | + invite, reactions, stream, embeds, attachments, message history | Verified company members |
| **Guest** | ⚪ Grey | Read/send messages, connect, speak, slash commands, threads | New joiners (auto-assigned) |

### Command Access Groups

Bot commands are gated by named access groups defined in `lib/authenticate_user.rb`. If no group is specified, a command defaults to **Member**.

| Access Group | Allowed Roles |
|---|---|
| **Any** | Governor, Consul, Officer, Member, Guest |
| **Guest** | Guest |
| **Member** | Governor, Consul, Officer, Member |
| **Staff** | Governor, Consul, Officer |
| **Admin** | Governor, Consul |
| **Governor** | Governor |

### Weapon Roles

16 weapon roles (e.g. Sword and Shield, Great Axe, Life Staff) are auto-created on the server. When a player registers their PvP build, their old weapon roles are removed and the new ones are assigned automatically. These can be used to mention all players using a specific weapon.

### Crafting Roles

7 crafting trade roles — Weaponsmithing, Armoring, Engineering, Jewelcrafting, Arcana, Cooking, and Furnishing — are created on the server and self-assignable via reaction roles in the `🎲┃roles` channel.

## Bot Commands

### General & Server Management

| Command | Description | Access |
|---|---|---|
| `/help` | List all available Yonas commands | Member |
| `/server_status` | Check a New World server's online status | Member |
| `/scorpio` | Start a Scorpio respawn countdown timer (89 min) | Member |
| `/scorpio_stop` | Cancel the active Scorpio timer | Member |
| `/list_members` | List all users with the Member role | Member |
| `/roll` | Roll a six-sided dice | Member |
| `/subscribe_to_updates` | Subscribe the current channel to news notifications | Staff |
| `/unsubscribe_to_updates` | Unsubscribe the current channel from news notifications | Staff |
| `/cleanse` | Kick all non-owner, non-bot users from the server | Governor |

### Company Applications

| Command | Description | Access |
|---|---|---|
| `/apply` | Open a modal form to apply to join the company | Guest |
| `/review_applications` | Review and approve/reject all pending applications | Staff |

Approved applications automatically assign the Member role, remove the Guest role, and set the user's nickname to their in-game name.

### Player Builds

| Command | Description | Access |
|---|---|---|
| `/register_pvp_build` | Register or update your PvP war build (role, weapons, heartrune, armour) | Any |
| `/delete_pvp_build` | Delete your registered PvP build | Any |
| `/search_pvp_builds` | Search builds by weapon, armour weight, heartrune, or player name | Member |
| `/show_pvp_builds` | Display all registered PvP builds in a formatted table | Member |
| `/unregistered_pvp_builds` | List members who haven't registered a build | Staff |
| `/export_pvp_builds` | Export all builds to a CSV file | Staff |

### Influence Push

| Command | Description | Access |
|---|---|---|
| `/register_influence_push` | Log attendance for all users in your voice channel for a territory | Staff |
| `/influence_push_player_totals` | Show attendance stats and percentages for all players | Staff |

### PvP Groups

| Command | Description | Access |
|---|---|---|
| `/create_pvp_groups` | Auto-create balanced groups from players in your voice channel | Member |

Groups are split by role (Healer, Tank, DPS, Ranged DPS, Mage) to ensure balanced composition.

## Automated Server Setup

When Yonas joins a server (or on bot boot for existing servers), `Setup` runs three steps automatically. Existing roles, channels, and messages are skipped — nothing is duplicated.

### 1. Role Creation

Creates all company roles (Governor → Guest), weapon roles (16 weapons), and crafting roles (7 trades) if they don't already exist on the server.

### 2. Channel Creation

Creates a **YONAS** category with the following channels:

| Channel | Type | Visibility |
|---|---|---|
| `🤖┃general` | Text | Member, Officer, Consul |
| `📢┃announcements` | Text | Read: Member+ · Write: Officer+ |
| `👋┃welcome` | Text | Everyone |
| `🎲┃roles` | Text | Read-only for Member+ |
| `🏅┃admin` | Text | Officer, Consul |
| `📝┃applications` | Text | Officer, Consul |
| `📧┃yonas-feedback` | Text | Member, Officer, Consul |
| `👄┃Join to Create` | Voice | Member, Officer, Consul |

### 3. Reaction Roles

Posts embed messages in the `🎲┃roles` channel with emoji reactions for all weapon types and crafting trades. Users react to self-assign the corresponding role, and react again to remove it.

## Event Listeners

| Event | Behaviour |
|---|---|
| **Server join** | Triggers the full automated setup (roles, channels, reaction roles) |
| **Member join** | Auto-assigns the Guest role and sends a welcome message in `👋┃welcome` prompting the user to `/apply` |
| **Voice state update** | Join to Create — when a user joins `👄┃Join to Create`, a temporary voice channel named after them is created and they are moved into it. The channel is deleted automatically when empty |
| **Feedback message** | Messages sent in `📧┃yonas-feedback` are saved to the database and acknowledged with a random emoji reaction |

## Scheduled Tasks

All tasks are started via `config/initializers/bot.rb` on Rails boot (skipped in test environment and Rails console).

| Task | Interval | Description |
|---|---|---|
| **Server status monitor** | 4 minutes | Scrapes the New World server status page. Notifies `📢┃announcements` when servers go offline or come back online |
| **News scraper** | 1 hour | Scrapes newworld.com/news for new articles. Posts new articles to all channels subscribed via `/subscribe_to_updates` |
| **Build cleanup** | 1 hour | Deletes PvP builds for users who no longer have the Member role on the server |

## Database Models

| Model | Description |
|---|---|
| `PlayerBuild` | PvP build registrations (player, role, weapons, heartrune, armour weight, guest flag) |
| `CompanyApplication` | Company join applications with approve/reject status workflow |
| `InfluencePushRegistration` | Territory influence push attendance records (per player, per territory, per day) |
| `Feedback` | User feedback messages captured from the feedback channel |
| `NewsArticle` | Tracks the last scraped article URL to prevent duplicate notifications |
| `UpdateNotification` | Channels subscribed to receive news article notifications |
| `PvpEvents` | Temporary records used during PvP group creation |

## Future Planned Features

- **War Events Registration & Grouping** — Players will be able to register for war events. Groups will be created for these events, with the option to use predefined groups for organisation.
- **PvP Groups Improvements** — The PvP group creation feature will be enhanced to support specifying the number of players per group, allowing for more flexible team sizes.

## Deployment

- See `Dockerfile` for containerised deployment.
- Standard Rails deployment supported.

## Contributing

Pull requests are welcome. For major changes, open an issue first.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
