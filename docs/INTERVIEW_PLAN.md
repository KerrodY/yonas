# Yonas Presentation

---

## 1. Context & Motivation

- I played a game called New World — an MMO where you join a "company" (guild) of up to 100 players
- Managing a company across Discord is painful — manual role assignments, no way to track who plays what, no attendance records, no structured onboarding
- I built **Yonas** as a solo side project to automate all of that
- It's a **Rails 8 app** that runs a **Discord bot** inside the same process
- Tech stack:
  - **Ruby 4.0.5 / Rails 8** — web framework & ORM
  - **SQLite** — lightweight, single-file database
  - **Discordrb** — Ruby Discord bot library
  - **Nokogiri** — web scraping (server status page, news articles)
  - **Rufus-scheduler** — recurring background tasks
- When you run `rails server`, the bot boots automatically via a Rails initializer (`config/initializers/bot.rb`) — no separate process needed

---

## 2. Architecture Walkthrough

- Open `config/initializers/bot.rb` — this is the entrypoint
  - On Rails boot (skipped in test env and console), it starts:
    1. `NewWorldNotifications` — scheduled scraping tasks
    2. `PlayerBuildsTask` — scheduled cleanup task
    3. `DiscordBot.instance` — the bot itself (Singleton pattern)
- Open `app/services/discord_bot.rb`
  - **Singleton** — only one bot instance across the whole app
  - `COMMANDS` array holds all command modules — easy to add new ones
  - `setup` method: includes all command modules via `bot.include!`, then runs `Setup.new(bot)`, then registers event listeners
  - Modular design — each feature is its own module (`Commands`, `PlayerBuilds`, `InfluencePush`, `Forms`, `PvpGroups`)
- Open `app/services/start_bot.rb`
  - Loads the Discord token from Rails encrypted credentials
  - Creates the bot, runs it in async mode (`run(true)`) so it doesn't block the Rails process

---

## 3. Automated Server Setup

- Open `app/services/setup.rb`
  - Runs on bot boot for every server, AND when the bot joins a new server
  - Three steps, all **idempotent** — checks if things exist before creating, so it never duplicates
- **Step 1: Role creation** (`create_roles`)
  - Creates company hierarchy roles: Governor → Consul → Officer → Member → Guest
  - Creates 16 weapon roles (Great Axe, Life Staff, etc.) and 7 crafting roles
  - Each role has specific Discord permissions
- Open `lib/data.rb` — show the permissions setup
  - Permissions are **cumulative**: `MEMBER = GUEST + MEMBER_PERMISSIONS`, `OFFICER = MEMBER + OFFICER_PERMISSIONS`, etc.
  - This mirrors a real company hierarchy — each rank inherits everything below it
- **Step 2: Channel creation** (`create_server_channels`)
  - Creates a "YONAS" category with 8 channels (general, announcements, welcome, roles, admin, applications, feedback, voice)
  - Each channel has **per-role permission overwrites** defined declaratively in `data.rb`
  - `format_permissions` translates my config hashes into Discordrb API objects — it's a small DSL that keeps the channel definitions clean and readable
- **Step 3: Reaction roles** (`create_react_roles`)
  - Posts embed messages in the roles channel with emoji reactions
  - Users react to self-assign weapon/crafting roles, react again to remove

---

## 4. Company Applications Workflow

- This is a full end-to-end workflow — open `app/commands/forms.rb`
- **Guest runs `/apply`**
  - Opens a Discord modal form (hours played, PvP player?, in-game name, role, extra info)
  - On submit → saved to `CompanyApplication` model in the database
  - Notification posted to the `📝┃applications` channel with the pending count
- **Staff runs `/review_applications`**
  - Loads all pending applications from the database
  - Posts each one as a rich embed with **Approve / Reject buttons**
  - On approve:
    - Assigns the `Member` role, removes the `Guest` role
    - Sets the user's Discord nickname to their in-game name they provided in the form
    - All automatic — no manual work for the staff member
---

## 5. Role-Based Access Control

- Open `lib/authenticate_user.rb` — it's only 22 lines
- `ROLE_GROUPS` hash defines access tiers: `:any`, `:guest`, `:member`, `:staff`, `:admin`, `:governor`
- Single `authorized?` method checks if the user has any role in the required group
- Every command starts with `next unless AuthenticateUser.authorized?(event, :staff)` (or whatever level)
- Clean, simple, consistent — easy to reason about who can do what
- Default is `:member` if no group is specified

---

## 6. Web Scraping & Scheduled Tasks

- Open `app/tasks/new_world_notifications.rb`
- **Server status monitor** (every 4 minutes)
  - Scrapes the New World server status page with Nokogiri
  - Tracks online/offline state with an instance variable (`@server_status_offline`)
  - When servers go offline → notifies all `📢┃announcements` channels
  - When coming back online → **triple-checks** over 3 minutes before announcing (avoids false positives from flaky status page)
- **News scraper** (every hour)
  - Scrapes `newworld.com/news` for article links and titles
  - Compares against the last known article URL stored in `NewsArticle` model
  - Posts new articles to all channels that opted in via `/subscribe_to_updates`
- **Build cleanup** (every hour, in `app/tasks/player_builds_task.rb`)
  - Deletes PvP build records for users who no longer have the Member role
  - Keeps the data clean automatically

---

## 7. Live Demo

- Demo `/register_pvp_build` — register a build with weapons, armour weight, heartrune, role
- Demo `/show_pvp_builds` — displays all builds in a formatted table
- Demo `/search_pvp_builds` — filter by weapon, armour, etc.
- Demo application workflow
- 
---

## 8. What's next?

- Before the EOL announcement I had many plans to expand out the bot's functionality:
  - Add a web dashboard with discord omniauth that can determine permissions from the company discord server
    - staff can plan war/event rosters, manage events, view/input analytics
    - members can view their own stats and company news 
    - feedback provided in the channel can be read and responded to in the dashboard
  - Allow players to register multiple builds for wars and events
  - Finish implementing reaction roles for all weapon types and crafting disciplines
- Since EOL... refactor the bot for the general MMO community — make it more configurable so it can be used by any guild, not just New World companies
  - targeting games like WoW, FFXIV, Chrono Odyssey that have similar guild management needs
  - Open source the code so other developers can contribute and use it for their own communities

---
