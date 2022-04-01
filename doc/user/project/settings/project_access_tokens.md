---
stage: Manage
group: Access
info: "To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments"
type: reference, howto
---

# Project access tokens

NOTE:
Project access tokens are supported for self-managed instances on Free and above. They are also supported on GitLab SaaS Premium and above (excluding [trial licenses](https://about.gitlab.com/free-trial/)). Self-managed Free instances should review their security and compliance policies with regards to [user self-enrollment](../../admin_area/settings/sign_up_restrictions.md#disable-new-sign-ups) and consider [disabling project access tokens](#enable-or-disable-project-access-token-creation) to lower potential abuse.

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/210181) in GitLab 13.0.
> - [Became available on GitLab.com](https://gitlab.com/gitlab-org/gitlab/-/issues/235765) in GitLab 13.5 for paid groups only.
> - [Feature flag removed](https://gitlab.com/gitlab-org/gitlab/-/issues/235765) in GitLab 13.5.

WARNING:
This feature might not be available to you. Check the **version history** note above for details.

Project access tokens are scoped to a project and can be used to authenticate with the
[GitLab API](../../../api/index.md#personalproject-access-tokens). You can also use
project access tokens with Git to authenticate over HTTPS. If you are asked for a
username when authenticating over HTTPS, you can use any non-empty value because only
the token is needed.

Project access tokens expire on the date you define, at midnight UTC.

For examples of how you can use a project access token to authenticate with the API, see the following section from our [API Docs](../../../api/index.md#personalproject-access-tokens).

## Creating a project access token

1. Log in to GitLab.
1. Navigate to the project you would like to create an access token for.
1. In the **Settings** menu choose **Access Tokens**.
1. Choose a name and optional expiry date for the token.
1. Choose a role for the token.
1. Choose the [desired scopes](#limiting-scopes-of-a-project-access-token).
1. Click the **Create project access token** button.
1. Save the project access token somewhere safe. Once you leave or refresh
   the page, you don't have access to it again.

## Project bot users

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/210181) in GitLab 13.0.
> - [Excluded from license seat use](https://gitlab.com/gitlab-org/gitlab/-/issues/223695) in GitLab 13.5.

Project bot users are [GitLab-created service accounts](../../../subscriptions/self_managed/index.md#billable-users) and do not count as licensed seats.

For each project access token created, a bot user is created and added to the project with
the [specified level permissions](../../permissions.md#project-members-permissions).

For the bot:

- The name is set to the name of the token.
- The username is set to `project_{project_id}_bot` for the first access token, such as `project_123_bot`.
- The username is set to `project_{project_id}_bot{bot_count}` for further access tokens, such as `project_123_bot1`.

API calls made with a project access token are associated with the corresponding bot user.

These bot users are included in a project's **Project information > Members** list but cannot be modified. Also, a bot
user cannot be added to any other project.

- The username is set to `project_{project_id}_bot` for the first access token, such as `project_123_bot`.
- The username is set to `project_{project_id}_bot{bot_count}` for further access tokens, such as `project_123_bot1`.

When the project access token is [revoked](#revoking-a-project-access-token) the bot user is deleted
and all records are moved to a system-wide user with the username "Ghost User". For more
information, see [Associated Records](../../profile/account/delete_account.md#associated-records).

## Revoking a project access token

At any time, you can revoke any project access token by clicking the
respective **Revoke** button in **Settings > Access Tokens**.

## Limiting scopes of a project access token

Project access tokens can be created with one or more scopes that allow various
actions that a given token can perform. The available scopes are depicted in
the following table.

| Scope              |  Description |
| ------------------ |  ----------- |
| `api`              | Grants complete read/write access to the scoped project API, including the [Package Registry](../../packages/package_registry/index.md). |
| `read_api`         | Grants read access to the scoped project API, including the [Package Registry](../../packages/package_registry/index.md). |
| `read_registry`    | Allows read-access (pull) to [container registry](../../packages/container_registry/index.md) images if a project is private and authorization is required. |
| `write_registry`   | Allows write-access (push) to [container registry](../../packages/container_registry/index.md). |
| `read_repository`  | Allows read-only access (pull) to the repository. |
| `write_repository` | Allows read-write access (pull, push) to the repository. |

## Enable or disable project access token creation

> [Introduced](https://gitlab.com/gitlab-org/gitlab/-/issues/287707) in GitLab 13.11.

You may enable or disable project access token creation for all projects in a group in **Group > Settings > General > Permissions, LFS, 2FA > Allow project access token creation**.
Even when creation is disabled, you can still use and revoke existing project access tokens.
This setting is available only on top-level groups.

## Group access token workaround **(FREE SELF)**

NOTE:
This section describes a workaround and is subject to change.

Group access tokens let you use a single token to:

- Perform actions at the group level.
- Manage the projects within the group.
- In [GitLab 14.2](https://gitlab.com/gitlab-org/gitlab/-/issues/330718) and later, authenticate
  with Git over HTTPS.

We don't support group access tokens in the GitLab UI, though GitLab self-managed
administrators can create them using the [Rails console](../../../administration/operations/rails_console.md).

<div class="video-fallback">
  For a demo of the group access token workaround, see <a href="https://www.youtube.com/watch?v=W2fg1P1xmU0">Demo: Group Level Access Tokens</a>.
</div>
<figure class="video-container">
  <iframe src="https://www.youtube.com/embed/W2fg1P1xmU0" frameborder="0" allowfullscreen="true"> </iframe>
</figure>

### Create a group access token

To create a group access token, run the following in a Rails console:

```ruby
admin = User.find(1) # group admin
group = Group.find(109) # the group you want to create a token for
bot = Users::CreateService.new(admin, { name: 'group_token', username: "group_#{group.id}_bot", email: "group_#{group.id}_bot@example.com", user_type: :project_bot }).execute # create the group bot user
# for further group access tokens, the username should be group_#{group.id}_bot#{bot_count}, e.g. group_109_bot2, and their email should be group_109_bot2@example.com
bot.confirm # confirm the bot
group.add_user(bot, :maintainer) # add the bot to the group at the desired access level
token = bot.personal_access_tokens.create(scopes:[:api, :write_repository], name: 'group_token') # give it a PAT
gtoken = token.token # get the token value
```

Test if the generated group access token works:

1. Pass the group access token in the `PRIVATE-TOKEN` header to GitLab REST APIs. For example:

   - [Create an epic](../../../api/epics.md#new-epic) on the group.
   - [Create a project pipeline](../../../api/pipelines.md#create-a-new-pipeline)
     in one of the group's projects.
   - [Create an issue](../../../api/issues.md#new-issue) in one of the group's projects.

1. Use the group token to [clone a group's project](../../../gitlab-basics/start-using-git.md#clone-with-https)
   using HTTPS.

### Revoke a group access token

To revoke a group access token, run the following in a Rails console:

```ruby
bot = User.find_by(username: 'group_109_bot') # the owner of the token you want to revoke
token = bot.personal_access_tokens.last # the token you want to revoke
token.revoke!
```
