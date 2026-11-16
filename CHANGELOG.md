# Changelog

## 1.1.2 (unreleased)

- Verify standalone and Builder integration on disposable test databases,
  including PostgreSQL constraints, optional-source failure handling and privacy.
- Align dummy schema loading with Core migration paths; remove unused dashboard
  scaffolds, Item routes, empty helpers and the obsolete Webpack asset.
- Expand demo coverage with UTC date boundaries and cancelled public events.
- Use the profile/application timezone consistently in FullCalendar, Agenda, forms and panels, without changing stored instants or invitation responses.

- Update compatibility for Lesli 5.1, Ruby 3.3.5, and Rails 8.1.
- Complete the Calendar and agenda Tailwind migration.
- Add standalone tests and Linux lockfile support.
- Adopt the shared LesliActions engine workflow.
