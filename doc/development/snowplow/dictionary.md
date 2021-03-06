---
stage: Growth
group: Product Intelligence
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

<!---
  This documentation is auto generated by a script.

  Please do not edit this file directly, check generate_event_dictionary task on lib/tasks/gitlab/snowplow.rake.
--->

<!-- vale gitlab.Spelling = NO -->

# Event Dictionary

This file is autogenerated, please do not edit it directly.

To generate these files from the GitLab repository, run:

```shell
bundle exec rake gitlab:snowplow:generate_event_dictionary
```

The Event Dictionary is based on the following event definition YAML files:

- [`config/events`](https://gitlab.com/gitlab-org/gitlab/-/tree/f9a404301ca22d038e7b9a9eb08d9c1bbd6c4d84/config/events)
- [`ee/config/events`](https://gitlab.com/gitlab-org/gitlab/-/tree/f9a404301ca22d038e7b9a9eb08d9c1bbd6c4d84/ee/config/events)

## Event definitions

### `epics promote`

| category | action | label | property | value |
|---|---|---|---|---|
| `epics` | `promote` | `` | `The string "issue_id"` | `ID of the issue` |

Issue promoted to epic

YAML definition: `/ee/config/events/epics_promote.yml`

Owner: `group::product planning`

Tiers: `premium`, `ultimate`
