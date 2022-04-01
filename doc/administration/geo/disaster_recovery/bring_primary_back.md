---
stage: Enablement
group: Geo
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
type: howto
---

# Bring a demoted primary node back online **(PREMIUM SELF)**

After a failover, it is possible to fail back to the demoted **primary** node to
restore your original configuration. This process consists of two steps:

1. Making the old **primary** node a **secondary** node.
1. Promoting a **secondary** node to a **primary** node.

WARNING:
If you have any doubts about the consistency of the data on this node, we recommend setting it up from scratch.

## Configure the former **primary** node to be a **secondary** node

Since the former **primary** node will be out of sync with the current **primary** node, the first step is to bring the former **primary** node up to date. Note, deletion of data stored on disk like
repositories and uploads will not be replayed when bringing the former **primary** node back
into sync, which may result in increased disk usage.
Alternatively, you can [set up a new **secondary** GitLab instance](../setup/index.md) to avoid this.

To bring the former **primary** node up to date:

1. SSH into the former **primary** node that has fallen behind.
1. Make sure all the services are up:

   ```shell
   sudo gitlab-ctl start
   ```

   NOTE:
   If you [disabled the **primary** node permanently](index.md#step-2-permanently-disable-the-primary-node),
   you need to undo those steps now. For Debian/Ubuntu you just need to run
   `sudo systemctl enable gitlab-runsvdir`. For CentOS 6, you need to install
   the GitLab instance from scratch and set it up as a **secondary** node by
   following [Setup instructions](../setup/index.md). In this case, you don't need to follow the next step.

   NOTE:
   If you [changed the DNS records](index.md#step-4-optional-updating-the-primary-domain-dns-record)
   for this node during disaster recovery procedure you may need to [block
   all the writes to this node](planned_failover.md#prevent-updates-to-the-primary-node)
   during this procedure.

1. [Set up database replication](../setup/database.md). In this case, the **secondary** node
   refers to the former **primary** node.
   1. If [PgBouncer](../../postgresql/pgbouncer.md) was enabled on the **current secondary** node
      (when it was a primary node) disable it by editing `/etc/gitlab/gitlab.rb`
      and running `sudo gitlab-ctl reconfigure`.
   1. You can then set up database replication on the **secondary** node.

If you have lost your original **primary** node, follow the
[setup instructions](../setup/index.md) to set up a new **secondary** node.

## Promote the **secondary** node to **primary** node

When the initial replication is complete and the **primary** node and **secondary** node are
closely in sync, you can do a [planned failover](planned_failover.md).

## Restore the **secondary** node

If your objective is to have two nodes again, you need to bring your **secondary**
node back online as well by repeating the first step
([configure the former **primary** node to be a **secondary** node](#configure-the-former-primary-node-to-be-a-secondary-node))
for the **secondary** node.
